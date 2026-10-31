---
name: san_devops_expert
description: Déclenché quand l'utilisateur souhaite configurer ou déployer l'infrastructure VPS (CloudPanel, Nginx, Mailcow), auditer la réversibilité (< 30s), sécuriser la production ou éprouver la restauration d'une sauvegarde.
---

# `san_devops_expert` — Runbook DevOps, Infrastructure VPS & Fiabilité Production

Protocole d'exploitation et de déploiement pour serveurs Linux (Ubuntu, CloudPanel, Nginx, PHP-FPM, Node/PM2, Docker, Mailcow). Fondé sur deux lois d'airain : la **réversibilité absolue (< 30s)** et le **principe de la sauvegarde testée**.

---

## 1. LES DEUX INVARIANTS INVIOLABLES DE PRODUCTION

1. **La Réversibilité Absolue (Rollback < 30s) :**
   - Tout déploiement s'effectue via bascule de lien symbolique atomique (`/releases/YYYYMMDD_HHMMSS` $\rightarrow$ `/current`).
   - Aucune modification de code ou de schéma BDD n'est appliquée sans procédure inverse documentée dans `docs/RUNBOOKS.md`.
2. **Le Principe de la Sauvegarde Testée :**
   - Une sauvegarde non restaurée avec succès dans un environnement vierge n'a aucune valeur juridique ni technique.
   - Tout dump chiffré (AES-256 GPG) doit subir une épreuve de restauration sur conteneur Docker éphémère (`docker run --rm`).

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Diagnostic Préalable Read-Only (Non-Intrusif)
- Avant toute intervention, exécuter le diagnostic de santé sans modifier le serveur :
  ```bash
  bash .agents/skills/san_devops_expert/scripts/infra_health_check.sh --local
  ```
- Inspecter l'espace disque (`df -h`, seuil < 85%), les inodes (`df -i`), la mémoire libre (`free -m`) et la validité SSL (> 15 jours).
- Consulter le guide d'administration [CloudPanel & VPS](references/cloudpanel_and_vps.md).

### Étape 2 : Conditionnement & Feu Vert QA
- Vérifier impérativement le statut officiel émis par [san_qa_security_expert](../san_qa_security_expert/SKILL.md) : **`VERDICT: LIVRABLE`** obligatoire avant toute mise en production.

### Étape 3 : Déploiement Atomique Zéro-Downtime
1. Sauvegarde préventive de la configuration modifiée (`.bak.$(date +%F_%H%M%S)`).
2. Déploiement dans le répertoire de release horodaté (`/home/app/releases/<timestamp>`).
3. Installation des dépendances sans packages dev et exécution des migrations réversibles.
4. Bascule atomique du symlink :
   ```bash
   ln -sfn /home/app/releases/<timestamp> /home/app/current
   ```
5. Rechargement gracieux des services :
   ```bash
   sudo systemctl reload php8.2-fpm && sudo systemctl reload nginx
   ```
6. En cas d'incident, basculer immédiatement sur la release précédente en moins de 30 secondes.

### Étape 4 : Épreuve de Restauration de Sauvegarde (Conteneur Éphémère)
- Exécuter la procédure de vérification selon les [Protocoles de Sauvegarde et Restauration](references/backup_and_restore_protocols.md) :
  - Déchiffrement du dump en mémoire.
  - Démarrage d'un conteneur MySQL/PostgreSQL jetable (`docker run --rm`).
  - Validation de la cohérence relationnelle et du nombre d'enregistrements clés.

### Étape 5 : Alignement Délivrabilité Mailcow (10/10)
- Configurer les enregistrements DNS selon le protocole [Mailcow & Délivrabilité](references/mailcow_and_deliverability.md) :
  - Reverse DNS (PTR) pointant vers le FQDN de l'instance.
  - SPF strict (`-all`), DKIM 2048 bits et DMARC `p=reject; sp=reject; adkim=s; aspf=s`.

### Étape 6 : Clôture Documentaire
- Mettre à jour `docs/INFRA.md` (via [INFRA_TEMPLATE.md](templates/INFRA_TEMPLATE.md)) et `docs/RUNBOOKS.md` (via [RUNBOOK_TEMPLATE.md](templates/RUNBOOK_TEMPLATE.md)).
- Ne consigner **aucun secret** dans les dépôts Git.

---

## 3. RESSOURCES DU SKILL

- **Scripts d'Inspection :**
  - [scripts/infra_health_check.sh](scripts/infra_health_check.sh) : Sonde SSL, DNS, ports et métriques système.
- **Guides de Référence :**
  - [references/cloudpanel_and_vps.md](references/cloudpanel_and_vps.md) : Optimisation Nginx, PHP-FPM, PM2 et Supervisor.
  - [references/backup_and_restore_protocols.md](references/backup_and_restore_protocols.md) : Stratégie 3-2-1, chiffrement AES-256 et conteneur Docker de test.
  - [references/mailcow_and_deliverability.md](references/mailcow_and_deliverability.md) : Alchimie SPF -all, DKIM 2048b, DMARC reject et rDNS.
- **Templates de Déploiement :**
  - [templates/INFRA_TEMPLATE.md](templates/INFRA_TEMPLATE.md) : Modèle de cartographie de topologie (`docs/INFRA.md`).
  - [templates/RUNBOOK_TEMPLATE.md](templates/RUNBOOK_TEMPLATE.md) : Fiches d'incidents et commandes de rollback (`docs/RUNBOOKS.md`).
  - [templates/DEPLOYMENT_WORKFLOW.yml](templates/DEPLOYMENT_WORKFLOW.yml) : Pipeline CI/CD GitHub Actions zéro-downtime.
