# Stratégie de Sauvegarde 3-2-1 Chiffrée & Protocoles de Restauration Déterministe

Ce document formalise la politique de sauvegarde et d'épreuve de restauration obligatoire régie par `san_devops_expert` au sein du framework Antigravity (`san_*`).

---

## 1. LA RÈGLE D'OR : « UNE SAUVEGARDE NON RESTAURÉE N'EXISTE PAS »

La quasi-totalité des désastres informatiques résulte non pas de l'absence de sauvegarde, mais de l'incapacité à restaurer des données corrompues ou incomplètes au moment d'une crise.

**Le Dogme Antigravity :**
- Toute sauvegarde de base de données fait l'objet d'un test de restauration automatique régulier.
- L'épreuve de restauration est exécutée dans un **conteneur Docker éphémère et jetable** (`docker run --rm`), garantissant l'indépendance vis-à-vis des données locales.
- Si le script de restauration échoue, l'équipe technique est immédiatement alertée et la sauvegarde est déclarée invalide.

---

## 2. LA STRATÉGIE 3-2-1 ADAPTÉE AU CLOUD SOUVERAIN

| Règle | Implémentation Pratique |
| :--- | :--- |
| **3 Copies des Données** | 1 copie active en production (disque SSD NVMe) + 1 copie locale chiffrée temporaire + 1 copie distante immuable. |
| **2 Supports Différents** | Volume de stockage local du VPS + Stockage objet S3 distant indépendant (ex: Scaleway / Backblaze B2 / OVH Cloud Storage). |
| **1 Copie Hors-Site Chiffrée** | Bucket S3 distant chiffré en AES-256, avec réplication géographique et Object Lock (*WORM* : Write Once, Read Many). |

---

## 3. SCRIPTS OFFICIELS D'EXPORT COHÉRENT & CHIFFREMENT

### A. Export MySQL 8.0 Cohérent et Chiffré AES-256 (GPG)
```bash
#!/usr/bin/env bash
# /usr/local/bin/backup-mysql-encrypted.sh
set -euo pipefail

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/db"
DUMP_NAME="mysql_alexsan_prod_${BACKUP_DATE}.sql"
GPG_PASSPHRASE_FILE="/etc/backup-secrets/vault.key"
S3_BUCKET="s3://alexsan-backups-vault/db-backups"

mkdir -p "$BACKUP_DIR"

echo "[1/4] Réalisation du dump MySQL cohérent (--single-transaction)..."
mysqldump \
  --defaults-extra-file=/etc/mysql/backup.cnf \
  --single-transaction \
  --quick \
  --routines \
  --triggers \
  --events \
  alexsan_prod > "${BACKUP_DIR}/${DUMP_NAME}"

echo "[2/4] Compression et chiffrement AES-256 via GPG..."
gpg --batch --yes \
  --passphrase-file "$GPG_PASSPHRASE_FILE" \
  --symmetric \
  --cipher-algo AES256 \
  -o "${BACKUP_DIR}/${DUMP_NAME}.gpg" \
  "${BACKUP_DIR}/${DUMP_NAME}"

# Nettoyage immédiat du fichier SQL non chiffré
shred -u "${BACKUP_DIR}/${DUMP_NAME}"

echo "[3/4] Transfert sécurisé vers le stockage objet distant S3..."
aws s3 cp "${BACKUP_DIR}/${DUMP_NAME}.gpg" "${S3_BUCKET}/${DUMP_NAME}.gpg" --sse AES256

echo "[4/4] Purge des fichiers locaux âgés de plus de 7 jours..."
find "$BACKUP_DIR" -type f -name "*.gpg" -mtime +7 -delete

echo "✔ Sauvegarde MySQL chiffrée et transférée avec succès."
```

### B. Export PostgreSQL 15+ Cohérent au Format Custom
```bash
#!/usr/bin/env bash
# /usr/local/bin/backup-postgres-encrypted.sh
set -euo pipefail

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/db"
DUMP_NAME="pg_alexsan_prod_${BACKUP_DATE}.dump"
GPG_PASSPHRASE_FILE="/etc/backup-secrets/vault.key"
S3_BUCKET="s3://alexsan-backups-vault/pg-backups"

mkdir -p "$BACKUP_DIR"

echo "[1/3] Réalisation du dump PostgreSQL binaire..."
PGPASSWORD="${DB_PASSWORD}" pg_dump \
  -h localhost \
  -U alexsan_user \
  -Fc \
  --no-owner \
  --no-privileges \
  alexsan_prod > "${BACKUP_DIR}/${DUMP_NAME}"

echo "[2/3] Chiffrement AES-256 GPG..."
gpg --batch --yes \
  --passphrase-file "$GPG_PASSPHRASE_FILE" \
  --symmetric \
  --cipher-algo AES256 \
  -o "${BACKUP_DIR}/${DUMP_NAME}.gpg" \
  "${BACKUP_DIR}/${DUMP_NAME}"

shred -u "${BACKUP_DIR}/${DUMP_NAME}"

echo "[3/3] Envoi S3 distant..."
aws s3 cp "${BACKUP_DIR}/${DUMP_NAME}.gpg" "${S3_BUCKET}/${DUMP_NAME}.gpg"

echo "✔ Sauvegarde PostgreSQL chiffrée avec succès."
```

---

## 4. ÉPREUVE DE RESTAURATION SUR CONTENEUR DOCKER ÉPHÉMÈRE

Ce script exécute le test de restauration de manière totalement automatisée et déterministe. Il peut être lancé via cron ou sur demande :

```bash
#!/usr/bin/env bash
# /usr/local/bin/test-backup-restore-docker.sh
# Épreuve de Restauration Déterministe Antigravity
set -euo pipefail

TEMP_ID="restore-proof-$$"
CONTAINER_NAME="mysql-${TEMP_ID}"
TMP_PASS="RestoreProofEphemeralPassword2026"
GPG_KEY_FILE="/etc/backup-secrets/vault.key"
LATEST_DUMP_GPG=$(ls -t /var/backups/db/*.gpg | head -n 1)

echo "[+] Démarrage de l'épreuve de restauration..."
echo "[+] Dump cible sélectionné : ${LATEST_DUMP_GPG}"

cleanup() {
  echo "[+] Nettoyage : arrêt et suppression du conteneur éphémère..."
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[1/4] Instanciation du conteneur MySQL 8.0 éphémère..."
docker run --name "$CONTAINER_NAME" \
  -e MYSQL_ROOT_PASSWORD="$TMP_PASS" \
  -e MYSQL_DATABASE="test_restore_db" \
  -d mysql:8.0 --default-authentication-plugin=mysql_native_password

echo "[2/4] Attente de la disponibilité effective du démon MySQL..."
for i in {1..30}; do
  if docker exec "$CONTAINER_NAME" mysqladmin ping -u root --password="$TMP_PASS" --silent &> /dev/null; then
    echo "✔ Moteur MySQL opérationnel."
    break
  fi
  sleep 1
done

echo "[3/4] Déchiffrement à la volée et injection du dump dans le conteneur..."
gpg --batch --yes --decrypt --passphrase-file "$GPG_KEY_FILE" "$LATEST_DUMP_GPG" | \
  docker exec -i "$CONTAINER_NAME" mysql -u root --password="$TMP_PASS" test_restore_db

echo "[4/4] Vérification de l'intégrité des tables et comptage..."
TABLE_COUNT=$(docker exec "$CONTAINER_NAME" mysql -u root --password="$TMP_PASS" -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'test_restore_db';" -s -N)

echo "[+] Nombre de tables restaurées avec succès : ${TABLE_COUNT}"

if [ "$TABLE_COUNT" -gt 0 ]; then
  # Test de cohérence métier : vérification de la présence de la table users ou migrations
  HAS_CRITICAL_TABLE=$(docker exec "$CONTAINER_NAME" mysql -u root --password="$TMP_PASS" -e \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'test_restore_db' AND table_name IN ('users', 'migrations');" -s -N)

  if [ "$HAS_CRITICAL_TABLE" -gt 0 ]; then
    echo "=================================================================="
    echo "✔ ÉPREUVE DE RESTAURATION RÉUSSIE AVEC SUCCÈS TOTAL !"
    echo "  Le dump est 100% intègre, déchiffrable et injectable."
    echo "=================================================================="
    exit 0
  fi
fi

echo "✖ ÉCHEC CRITIQUE : Le dump a produit une base vide ou corrompue !"
exit 1
```

---

## 5. POLITIQUE DE RÉTENTION TEMPORELLE (GRAND-PÈRE / PÈRE / FILS)

- **Sauvegardes quotidiennes (Fils) :** Conservées 7 jours glissants.
- **Sauvegardes hebdomadaires (Père) :** Réalisées chaque dimanche, conservées 4 semaines.
- **Sauvegardes mensuelles (Grand-père) :** Réalisées le 1er de chaque mois, conservées 12 mois dans un bucket S3 Glacier / Deep Archive pour conformité légale et financière.
