# Guide d'Ingénierie VPS Ubuntu, CloudPanel, Nginx, PHP-FPM & Supervisor

Ce document détaille les architectures de référence, configurations et bonnes pratiques pour l'exploitation des serveurs de production sous **CloudPanel** et **Ubuntu LTS (22.04 / 24.04)** au sein de la stack souveraine **alexsan.pro**.

---

## 1. TOPOLOGIE CLOUDPANEL & STRUCTURE DES RÉPERTOIRES

CloudPanel isole chaque site dans son propre utilisateur système sous `/home/<site-user>/` :

```txt
/home/alexsan-app/
├── htdocs/
│   └── current -> /home/alexsan-app/releases/20261023_120000/public
├── releases/
│   ├── 20261023_110000/
│   └── 20261023_120000/
└── shared/
    ├── .env
    └── storage/
```

### Avantages de l'Architecture par Symlinks :
- **Atomicité :** La bascule d'une release à l'autre se fait via un appel système `ln -sfn`, sans aucun état intermédiaire ou fichier partiel.
- **Rollback instantané :** En cas d'anomalie critique, il suffit de repointer le lien symbolique sur le dossier de la release antérieure en moins de 5 secondes.

---

## 2. CONFIGURATION DE PRODUCTION NGINX (REVERSE PROXY & FASTCGI)

Configuration de référence d'un virtual host haute performance pour API Laravel / SPA moderne :

```nginx
# /etc/nginx/sites-available/api.alexsan.pro.conf

# 1. Limitation de débit (Rate Limiting anti-bruteforce et anti-DDoS)
limit_req_zone $binary_remote_addr zone=api_throttle:10m rate=60r/m;
limit_req_zone $binary_remote_addr zone=auth_throttle:10m rate=10r/m;

# 2. Redirection HTTP vers HTTPS (Port 80 -> 443)
server {
    listen 80;
    listen [::]:80;
    server_name api.alexsan.pro;
    return 301 https://$host$request_uri;
}

# 3. Serveur Principal HTTPS (TLS 1.3 / HTTP/2)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.alexsan.pro;

    root /home/alexsan-app/htdocs/current/public;
    index index.php index.html;

    # Certificats SSL / Let's Encrypt gérés par CloudPanel
    ssl_certificate /etc/letsencrypt/live/api.alexsan.pro/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.alexsan.pro/privkey.pem;

    # Protocoles cryptographiques modernes et stricts
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # Headers de Sécurité Obligatoires
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

    # Optimisation de la compression (Gzip)
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;

    # Cache agressif pour les assets statiques immuables
    location ~* \.(ico|css|js|gif|jpeg|jpg|png|woff|woff2|ttf|svg|eot|webp|avif)$ {
        expires 1y;
        add_header Cache-Control "public, max-age=31536000, immutable";
        access_log off;
    }

    # Protection des routes sensibles par Rate Limiting
    location /api/v1/auth/ {
        limit_req zone=auth_throttle burst=5 nodelay;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Routage général des APIs
    location / {
        limit_req zone=api_throttle burst=20 nodelay;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Traitement FastCGI PHP 8.2-FPM
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_read_timeout 60s;
        internal;
    }

    # Interdiction d'accès aux fichiers cachés (.git, .env)
    location ~ /\.(?!well-known).* {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

---

## 3. OPTIMISATION DU POOL PHP-FPM & OPCACHE

Fichier de pool de production pour utilisateur applicatif :

```ini
; /etc/php/8.2/fpm/pool.d/alexsan-app.conf
[alexsan-app]
user = alexsan-app
group = alexsan-app
listen = /run/php/php8.2-fpm-alexsan-app.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Gestion dynamique des processus selon mémoire disponible (ex: VPS 4 Go RAM)
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.max_requests = 1000

; Sécurité et limites d'exécution
request_terminate_timeout = 60s
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 60
php_admin_value[upload_max_filesize] = 20M
php_admin_value[post_max_size] = 25M
php_admin_flag[display_errors] = off
```

### Configuration Haute Performance OPcache :
```ini
; /etc/php/8.2/fpm/conf.d/10-opcache.ini
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.validate_timestamps=0 ; Désactive le contrôle disque en prod pour max perf
opcache.save_comments=1
opcache.fast_shutdown=1
opcache.jit=tracing
opcache.jit_buffer_size=64M
```

---

## 4. GESTION DES TÂCHES ASYNCHRONES AVEC SUPERVISOR

Supervisor pilote la persistance des processus de files d'attente (Laravel Queues sous Redis) :

```ini
; /etc/supervisor/conf.d/laravel-worker.conf
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/alexsan-app/htdocs/current/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600 --timeout=90
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=alexsan-app
numprocs=4
redirect_stderr=true
stdout_logfile=/home/alexsan-app/shared/storage/logs/supervisor-worker.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stopwaitsecs=3600
```

### Commandes Usuelles Supervisor :
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status
sudo supervisorctl restart all
```

---

## 5. DÉPLOIEMENT NODE.JS AVEC PM2 EN MODE CLUSTER

Pour les APIs ou microservices sous Node.js / AdonisJS v6 :

```javascript
// ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'alexsan-api-node',
      script: './build/server.js',
      instances: 'max', // 1 processus par cœur processeur
      exec_mode: 'cluster',
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOST: '127.0.0.1',
      },
    },
  ],
};
```

### Rechargement Zéro-Downtime sous PM2 :
```bash
pm2 reload ecosystem.config.js --env production
```
