# Matrice d'Audit Consolidée OWASP : Web Top 10, API Security 2023 & Mobile 2024

Ce document constitue la référence méthodologique officielle de `san_qa_security_expert` pour mener les audits de sécurité applicative, pentests d'APIs et contrôles de conformité mobile au sein du framework Antigravity (`san_*`).

---

## 1. OWASP API SECURITY TOP 10 (ÉDITION 2023)

Les interfaces de programmation d'application constituent la première surface d'attaque moderne. Chaque endpoint documenté ou découvert doit faire l'objet des vérifications suivantes :

### API1:2023 — Broken Object Level Authorization (BOLA / IDOR)
* **Description :** L'API expose des identifiants d'objets (`/api/v1/orders/{id}`, `/wallets/{uuid}`) sans valider que l'utilisateur authentifié possède les droits d'accès à l'objet ciblé.
* **Vecteur d'attaque :** Substitution de l'identifiant par celui d'un autre utilisateur avec un token légitime.
* **Contrôle d'audit :**
  - Tenter d'accéder à la ressource avec un jeton appartenant à un autre tenant ou compte utilisateur.
  - Tenter d'accéder sans jeton d'authentification.
* **Remédiation attendue :** Utilisation systématique de Policies (`$this->authorize('view', $model)` sous Laravel, ou vérification du `tenant_id` / `user_id` dans la clause `WHERE` sous AdonisJS/PostgreSQL).

### API2:2023 — Broken Authentication
* **Description :** Vulnérabilités dans les mécanismes d'authentification (jetons JWT faibles, absence de révocation, brute-force sur OTP SMS, secrets partagés).
* **Vecteur d'attaque :** Émission de jetons non signés (`"alg": "none"`), réutilisation de refresh tokens expirés, tentative de saturation d'OTP par force brute.
* **Contrôle d'audit :**
  - Tester l'endpoint OTP (`POST /api/v1/auth/otp/verify`) avec plus de 5 tentatives erronées consécutives.
  - Vérifier la présence d'une signature cryptographique asymétrique (RS256) ou HMAC-SHA256 robuste sur les tokens JWT.
* **Remédiation attendue :** Rate limiting strict (max 5 tentatives par tranche de 10 min par numéro), jetons d'accès éphémères (15 min max) et rotation systématique des Refresh Tokens stockés sous forme de hash en base.

### API3:2023 — Broken Object Property Level Authorization (Mass Assignment & Excessive Data Exposure)
* **Description :** Exposition de propriétés sensibles dans les réponses JSON (`password_hash`, `momo_pin`, `is_admin`) ou acceptation de modifications illégitimes de champs (`is_verified`, `balance`, `role`).
* **Vecteur d'attaque :** Injection de `{"is_admin": true}` ou `{"balance": 100000}` dans le corps d'une requête `PATCH /api/v1/profile`.
* **Contrôle d'audit :**
  - Tenter d'injecter des propriétés système non exposées dans l'interface cliente.
  - Examiner la charge utile de réponse (`GET`) pour détecter les fuites de métadonnées d'administration.
* **Remédiation attendue :** Utilisation stricte de DTOs ou `$request->validated()` sous Laravel / VineJS sous AdonisJS avec interdiction formelle de `$request->all()`.

### API4:2023 — Unrestricted Resource Consumption
* **Description :** Absence de quotas de requêtes (*Rate Limiting*), de pagination obligatoire ou de limitation de taille de requêtes.
* **Vecteur d'attaque :** Envoi d'une requête `GET /api/v1/catalog?limit=1000000` provoquant un déni de service par épuisement de la mémoire serveur (OOM).
* **Contrôle d'audit :**
  - Tester l'absence de paramètre de pagination ou une valeur de `limit` aberrante.
  - Émettre des rafales de requêtes avec `autocannon` ou `ab` pour éprouver le middleware de throttle.
* **Remédiation attendue :** Forçage d'une limite maximale de pagination (ex: 50 items max), rate limiting par IP et par token (`throttle:60,1`).

### API5:2023 — Broken Function Level Authorization (BFLA)
* **Description :** L'utilisateur d'un groupe ordinaire peut accéder à des fonctions d'administration en devinant simplement les endpoints (`/api/v1/admin/users/delete`).
* **Vecteur d'attaque :** Requête vers un endpoint administratif avec un token d'utilisateur standard.
* **Contrôle d'audit :**
  - Cartographier les routes sous préfixe `/admin` et vérifier l'interception systématique par un middleware de contrôle de rôle (RBAC).
* **Remédiation attendue :** Middleware de rôle dédié (`role:admin`) et vérification explicite des capacités (*Gates/Abilities*).

### API6:2023 — Unrestricted Access to Sensitive Business Flows
* **Description :** Exploitation automatisée de processus métier critiques (achat d'articles en promotion, envoi de SMS OTP, tirage au sort).
* **Vecteur d'attaque :** Script d'achat automatisé épuisant les stocks ou les quotas de SMS de la passerelle télécom.
* **Contrôle d'audit :**
  - Automatiser la soumission rapide du formulaire d'achat ou de demande d'OTP.
* **Remédiation attendue :** Verrouillage anti-rejeu, clé d'idempotence (`Idempotency-Key`), CAPTCHA invisible (Cloudflare Turnstile) sur les flux sensibles.

### API7:2023 — Server-Side Request Forgery (SSRF)
* **Description :** L'API télécharge une ressource externe à partir d'une URL fournie par l'utilisateur sans validation d'IP.
* **Vecteur d'attaque :** Fournir l'URL `http://169.254.169.254/latest/meta-data/` ou `http://localhost:6379` dans un champ de webhook ou d'importation d'avatar.
* **Contrôle d'audit :**
  - Injecter des adresses de loopback (`127.0.0.1`, `[::1]`) et de métadonnées cloud dans les champs d'URLs distantes.
* **Remédiation attendue :** Whitelist stricte de domaines autorisés, interdiction des plages IP privées (RFC 1918) et résolution DNS préalable avec blocage d'adresses internes.

### API8:2023 — Security Misconfiguration
* **Description :** Messages d'erreurs détaillés affichant la stack trace, headers de sécurité manquants, méthodes HTTP superflues (`TRACE`, `DEBUG`).
* **Vecteur d'attaque :** Envoi d'un payload malformé pour forcer une erreur SQL et lire la structure de la base dans la réponse.
* **Contrôle d'audit :**
  - Provoquer des erreurs 500 et s'assurer qu'aucun détail interne (`file`, `line`, `trace`) n'est retourné en production.
  - Vérifier les en-têtes HTTP de sécurité (`Content-Security-Policy`, `X-Content-Type-Options: nosniff`).
* **Remédiation attendue :** Mode production strict (`APP_DEBUG=false`), format d'erreur JSON générique `{"message": "Erreur interne"}`.

### API9:2023 — Improper Inventory Management
* **Description :** Versions d'APIs obsolètes maintenues en ligne (`/api/v0/`, staging exposé publiquement), contournant les correctifs de sécurité récents.
* **Vecteur d'attaque :** Recherche de routes oubliées ou de mocks non désactivés lors du passage en production.
* **Contrôle d'audit :**
  - Scan de routes d'anciens endpoints ou de documentation Swagger/OpenAPI exposée sans authentification.
* **Remédiation attendue :** Désactivation formelle des anciennes versions d'endpoints et restriction de l'accès aux interfaces de documentation technique.

### API10:2023 — Unsafe Consumption of APIs
* **Description :** Confiance aveugle accordée aux APIs tierces (MTN MoMo, Airtel Money, passerelles SMS, webhooks entrants).
* **Vecteur d'attaque :** Falsification d'une réponse de webhook partenaire confirmant un faux paiement.
* **Contrôle d'audit :**
  - Vérifier la validation cryptographique des signatures de webhooks (HMAC-SHA256 avec comparaison en temps constant).
* **Remédiation attendue :** Vérification systématique de l'en-tête de signature avec `hash_equals()`, réconciliation directe avec l'API du partenaire en cas de doute.

---

## 2. OWASP MOBILE TOP 10 (ÉDITION 2024)

Les applications hybrides (React Native / Expo) requièrent des contrôles stricts sur le stockage local et les communications.

### M1: Improper Credential Usage
* **Contrôle :** Interdiction absolue de stocker des mots de passe, tokens d'accès ou clés secrètes dans `AsyncStorage` ou `localStorage` en clair.
* **Validation :** Utilisation obligatoire de `expo-secure-store` s'appuyant sur le **Keychain iOS** et **Android Keystore** avec chiffrement AES-256-GCM hardware.

### M2: Inadequate Supply Chain Security
* **Contrôle :** Audit des packages npm et des bibliothèques natives Android/iOS intégrées.
* **Validation :** Exécution de `npm audit --audit-level=high` avec zéro vulnérabilité tolérée. Vérification de la réputation et de la maintenance des dépendances tierces.

### M3: Insecure Authentication / Authorization
* **Contrôle :** Persistance de session locale sécurisée et ré-authentification biométrique pour les actions financières sensibles.
* **Validation :** Vérification de l'invalidation de la session mobile lors de la déconnexion ou de la modification de mot de passe côté serveur.

### M4: Insufficient Input / Output Validation
* **Contrôle :** Assainissement des données affichées dans les WebViews et validation stricte des deep links (`scheme://path`).
* **Validation :** Aucun deep link ne doit pouvoir déclencher une action sensible (mutation de compte, virement) sans confirmation explicite et authentifiée de l'utilisateur.

### M5: Insecure Communication
* **Contrôle :** Chiffrement systématique des flux réseaux en transit.
* **Validation :** Forçage strict de HTTPS (TLS 1.3), interdiction formelle du trafic HTTP en clair (`cleartextTrafficPermitted="false"` dans `AndroidManifest.xml`).

### M6: Inadequate Privacy Controls
* **Contrôle :** Collecte minimale de données conformément aux déclarations de conformité des stores (Google Play & App Store).
* **Validation :** Aucune transmission de données sensibles (géolocalisation précise, contacts) sans consentement préalable et explicite de l'utilisateur.

### M7: Insufficient Binary Protections
* **Contrôle :** Obfuscation et minification du bundle JavaScript et du binaire natif.
* **Validation :** Activation du moteur Hermes avec bytecode précompilé (`enableHermes: true`) et règles ProGuard / R8 actives sur la compilation release Android.

### M8: Security Misconfiguration
* **Contrôle :** Désactivation des flags de débogage dans les builds de production.
* **Validation :** Vérifier que `android:debuggable="false"` dans le manifeste de release et qu'aucun serveur de débogage Metro n'est joignable.

### M9: Insecure Data Storage
* **Contrôle :** Vérification du cache applicatif, des logs système (`console.log`) et des captures d'écran lors de la mise en tâche de fond.
* **Validation :** Neutralisation des logs sensibles contenant des numéros de téléphone ou des données bancaires dans les builds de release.

### M10: Insufficient Cryptography
* **Contrôle :** Interdiction des algorithmes cryptographiques obsolètes (MD5, SHA-1, DES).
* **Validation :** Emploi exclusif d'algorithmes modernes (AES-256, SHA-256, Ed25519) fournis par la plateforme native.

---

## 3. OWASP WEB TOP 10 (RÉFÉRENCE UNIFIÉE)

### A01: Broken Access Control
* Contrôle systématique des sessions et droits d'administration sur les pages et routes Web.
* Interdiction de l'accès aux interfaces d'administration via la manipulation d'URL.

### A02: Cryptographic Failures
* Forçage strict du protocole TLS 1.3 avec redirection 301 immédiate depuis le port 80 (HTTP).
* Configuration du flag `Strict-Transport-Security` (HSTS) avec une durée minimale de 1 an (`max-age=31536000; includeSubDomains`).

### A03: Injection (SQL, NoSQL, OS Command)
* Bannissement absolu de la concaténation brute de paramètres utilisateur dans les requêtes SQL.
* Utilisation exclusive de requêtes préparées via l'ORM (Eloquent / Lucid) ou PDO avec bind parameters.

### A04: Insecure Design
* Implémentation du principe de moindre privilège et de la défense en profondeur.
* Limitation mathématique des flux transactionnels pour prévenir les doubles dépenses.

### A05: Security Misconfiguration
* En-têtes HTTP de sécurité obligatoires sur tous les vhosts Nginx :
  ```nginx
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
  ```

### A06: Vulnerable and Outdated Components
* Surveillance automatisée des vulnérabilités via `npm audit` et `composer audit` dans le pipeline de CI/CD et le Quality Gate local.

### A07: Identification and Authentication Failures
* Protection contre les attaques par force brute via rate limiting adaptatif.
* Expiration et régénération des identifiants de session lors des connexions/déconnexions.

### A08: Software and Data Integrity Failures
* Validation cryptographique des webhooks externes et signatures des packages.

### A09: Security Logging and Monitoring Failures
* Traçabilité des événements critiques de sécurité (échecs répétés d'authentification, modifications de droits, rejets de transactions) sans journalisation de données sensibles (mots de passe, tokens).

### A10: Server-Side Request Forgery (SSRF)
* Filtrage strict des flux réseau sortants initiés par le serveur Web.
