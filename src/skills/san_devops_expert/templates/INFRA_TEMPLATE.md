# CARTOGRAPHIE DE L'INFRASTRUCTURE DE PRODUCTION

> **Dernière mise à jour :** AAAA-MM-JJ  
> **Responsable d'Exploitation :** `san_devops_expert`  
> **Politique de Confidentialité :** Zéro secret, aucun mot de passe ni clé privée dans ce document.

---

## 1. TOPOLOGIE DES SERVEURS & LOGICIELS

| Rôle | Fournisseur / Localisation | OS | Logiciels & Runtimes | Adressage Public / FQDN |
| :--- | :--- | :--- | :--- | :--- |
| **Serveur Web & API Principal** | VPS Cloud / Francfort | Ubuntu 22.04 LTS | CloudPanel, Nginx 1.24, PHP 8.2-FPM, Node 20 LTS, Redis 7.0 | `vps-prod.alexsan.pro` (`198.51.100.10`) |
| **Serveur Messagerie Mailcow** | VPS Cloud / Gravelines | Ubuntu 22.04 LTS | Docker 25, Mailcow:dockerized, Postfix, Dovecot, Rspamd | `mail.alexsan.pro` (`198.51.100.25`) |
| **Serveur Base de Données** | Instance Dédiée / Privée | Ubuntu 22.04 LTS | MySQL 8.0 / PostgreSQL 15, Buffer Pool 4 Go | Réseau Privé VPC (`10.0.0.5`) |

---

## 2. CONFIGURATION DES REVERSE PROXIES & PORTS

### Nginx (Front Web SPA & API REST)
- **Ports en écoute :**
  - `80/tcp` : Redirection permanente `301` immédiate vers `https://$host$request_uri`.
  - `443/tcp` : TLS 1.3 forcé, HTTP/2 actif.
- **Fichier de Vhost :** `/etc/nginx/sites-available/api.alexsan.pro.conf` $\rightarrow$ FastCGI vers `unix:/run/php/php8.2-fpm-alexsan-app.sock`.
- **En-têtes de Sécurité Injectés :**
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
  - `X-Frame-Options: SAMEORIGIN`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy: geolocation=(), microphone=(), camera=()`

### Gestionnaire de Tâches Asynchrones (Supervisor)
- **Service système :** `supervisor`
- **Fichier de configuration :** `/etc/supervisor/conf.d/laravel-worker.conf`
- **Processus supervisés :** 4 workers écoutant les files Redis (`default`, `emails`, `payments`).
- **Commande exécutée :** `php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600`

---

## 3. DÉLIVRABILITÉ E-MAIL TRANSACTIONNELLE (MAILCOW)

- **Reverse DNS (PTR) :** `198.51.100.25` résout strictement en `mail.alexsan.pro.`.
- **SPF (Racine `@`) :** `v=spf1 mx ip4:198.51.100.25 -all` (interdiction du SoftFail `~all`).
- **DKIM (Sous-domaine `mail._domainkey`) :** Clé RSA 2048 bits validée par Rspamd.
- **DMARC (Sous-domaine `_dmarc`) :** `v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; rua=mailto:dmarc@alexsan.pro; pct=100`.
- **Score Mail-Tester :** **10 / 10** validé lors du dernier audit de délivrabilité.

---

## 4. POLITIQUE DE SAUVEGARDE & RÉTENTION (STRATÉGIE 3-2-1)

- **Format des Dumps :** Dumps cohérents (`mysqldump --single-transaction` ou `pg_dump -Fc`), compressés et chiffrés en **AES-256 via GPG**.
- **Destination Distante :** Stockage objet distant S3 (`s3://alexsan-backups-vault/db/`) avec chiffrement côté serveur SSE-AES256.
- **Politique de Rétention :**
  - 7 sauvegardes quotidiennes glissantes.
  - 4 sauvegardes hebdomadaires (dimanche).
  - 12 sauvegardes mensuelles archivées dans S3 Glacier.
- **Épreuve de Restauration Déterministe :** Exécutée mensuellement via le script `test-backup-restore-docker.sh` sur conteneur Docker éphémère (`docker run --rm`).
