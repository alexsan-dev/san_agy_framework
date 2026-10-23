# MANUEL D'EXPLOITATION & PROCÉDURES DE CRISE (RUNBOOKS)

> **Règle Cardinale de Réversibilité :** Chaque procédure d'incident comporte obligatoirement sa commande immédiate de retour arrière (*Rollback Command*) exécutable en moins de 30 secondes.

---

## FICHE D'INCIDENT #01 : ÉCHEC OU RÉGRESSION LORS DU DÉPLOIEMENT EN PRODUCTION

### Symptôme
Erreurs HTTP 500 consécutives sur les requêtes clients suite à la mise en ligne d'une nouvelle release.

### Procédure de Rollback Immédiat (Délai : < 30 secondes)
Connectez-vous en SSH sur le VPS de production et basculez instantanément le lien symbolique vers la release antérieure :

```bash
# 1. Identifier le dossier de la release précédente
cd /home/alexsan-app/releases && ls -dt */ | head -n 2

# 2. Re-pointer atomiquement le lien symbolique current sur la release précédente
PREV_RELEASE=$(ls -dt /home/alexsan-app/releases/*/ | sed -n '2p' | tr -d '/')
ln -sfn "$PREV_RELEASE" /home/alexsan-app/htdocs/current

# 3. Recharger sans coupure PHP-FPM et vider l'OPcache
sudo systemctl reload php8.2-fpm && sudo systemctl reload nginx

# 4. Redémarrer les workers de queue asynchrones
sudo supervisorctl restart all
```

### Rollback des Migrations de Base de Données (si nécessaire) :
```bash
cd /home/alexsan-app/htdocs/current
php artisan migrate:rollback --step=1 --force
```

---

## FICHE D'INCIDENT #02 : PANNE OU CORRUPTION DE LA BASE DE DONNÉES (RESTORE DRILL)

### Symptôme
Incohérence transactionnelle majeure ou altération accidentelle de tables critiques.

### Procédure de Restauration d'Urgence depuis le Dump Chiffré S3 :
```bash
# 1. Télécharger le dernier dump chiffré depuis S3
aws s3 cp s3://alexsan-backups-vault/db/latest.sql.gpg /tmp/latest.sql.gpg

# 2. Déchiffrement du dump en mémoire temporaire
gpg --decrypt --passphrase-file /etc/backup-secrets/vault.key /tmp/latest.sql.gpg > /tmp/restore_ready.sql

# 3. Activation temporaire de la page de maintenance Nginx
sudo cp /etc/nginx/maintenance.on /etc/nginx/sites-enabled/maintenance.conf
sudo systemctl reload nginx

# 4. Importation sécurisée dans la base de production
mysql --defaults-extra-file=/etc/mysql/backup.cnf alexsan_prod < /tmp/restore_ready.sql

# 5. Destruction immédiate et sécurisée du fichier SQL en clair
shred -u /tmp/restore_ready.sql /tmp/latest.sql.gpg

# 6. Réactivation du trafic applicatif
sudo rm -f /etc/nginx/sites-enabled/maintenance.conf
sudo systemctl reload nginx
```

---

## FICHE D'INCIDENT #03 : EXPIRATION IMPRÉVUE DU CERTIFICAT SSL / TLS

### Symptôme
Avertissement de sécurité navigateur « Connexion non sécurisée » ou `ERR_CERT_DATE_INVALID` pour les utilisateurs finaux.

### Procédure de Renouvellement Forcé :
```bash
# 1. Si hébergé sous CloudPanel :
clp-ssl --renew --domain=alexsan.pro

# 2. Si géré via Certbot autonome :
sudo certbot renew --force-renewal --nginx

# 3. Rechargement du service Web
sudo systemctl reload nginx

# 4. Contrôle immédiat de la validité
echo | openssl s_client -servername alexsan.pro -connect alexsan.pro:443 2>/dev/null | openssl x509 -noout -dates
```

---

## FICHE D'INCIDENT #04 : SATURATION OU SATURATION MÉMOIRE DES WORKERS REDIS

### Symptôme
Les files d'attente ne dépilent plus, saturation mémoire Redis (*OOM: Out of Memory*) ou processus zombies Supervisor.

### Procédure de Résolution :
```bash
# 1. Vérifier la charge et la mémoire consommée par Redis
redis-cli info memory | grep used_memory_human

# 2. Identifier les jobs bloqués ou en échec
php /home/alexsan-app/htdocs/current/artisan queue:failed

# 3. Redémarrer proprement les workers sous Supervisor
sudo supervisorctl restart laravel-worker:*

# 4. En cas de blocage persistant, relancer Redis avec persistance RDB
sudo systemctl restart redis-server
```

---

## FICHE D'INCIDENT #05 : CONGESTION DE LA FILE D'ATTENTE OU REJET MAILCOW

### Symptôme
Les e-mails transactionnels (OTP SMS, confirmations) s'accumulent dans la file Postfix ou sont rejetés avec code 550 par les serveurs distants.

### Procédure de Déblocage :
```bash
# 1. Vérifier le volume de la file d'attente Postfix dans le conteneur Mailcow
docker exec -it $(docker ps -qf name=postfix-mailcow) postqueue -p

# 2. Forcer l'envoi immédiat des messages différés
docker exec -it $(docker ps -qf name=postfix-mailcow) postqueue -f

# 3. Analyser les motifs d'erreur dans les logs Rspamd et Postfix
docker logs --tail 100 $(docker ps -qf name=postfix-mailcow) | grep -E "reject|defer"

# 4. Vérifier la conformité de l'adresse IP sur les listes RBL
bash .agents/skills/san_devops_expert/references/mailcow_and_deliverability.md#rbl-check
```
