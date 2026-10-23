# CARTOGRAPHIE TECHNIQUE DES DONNÉES PERSONNELLES (*DATA MAP*)

> **Application / Service :** [Nom du Produit Mobile & Web]  
> **Source de Vérité :** Analyse statique du code source (`scripts/scan_app_permissions.sh`) et migrations de BDD  
> **Auditeur Responsable :** `san_store_legal_expert`  
> **Dernière Synchronisation :** YYYY-MM-DD  

---

## 1. MATRICE D'INVENTAIRE DES DONNÉES PERSONNELLES

Toutes les données ci-dessous proviennent de l'inventaire physique des tables de base de données, des appels d'APIs et des SDKs intégrés au binaire client.

| Attribut / Champ | Table BDD / Source | Typologie Donnée | Finalité Métier / Technique | Base Légale | Rétention Maximale | Destinataire Tiers | Sécurité & Chiffrement |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `phone_number` | `users.phone` | Sensible (Identifiant) | Authentification par OTP, contact support | Exécution contrat | Durée du compte actif | Passerelle SMS (MTN/Airtel) | Chiffré au repos (AES-256) |
| `password_hash` | `users.password` | Critique | Contrôle d'accès et authentification | Exécution contrat | Durée du compte actif | Aucun (Strictement interne) | Hachage `Argon2id` / `Bcrypt` |
| `email` | `users.email` | Contact | Envoi des reçus d'achat et alertes compte | Exécution contrat | Durée du compte actif | Serveur Mailcow autohébergé | TLS 1.3 en transit |
| `full_name` | `users.name` | Identité | Personnalisation du profil et livraisons | Exécution contrat | Durée du compte actif | Chauffeur-livreur (partiel) | TLS 1.3 |
| `momo_ref` | `orders.momo_ref` | Financière | Suivi transactionnel et réconciliation | Obligation légale | 10 ans (obligation fiscale) | MTN MoMo / Airtel Money | Verrou pessimiste SQL |
| `amount_xaf` | `orders.total_xaf` | Financière | Calcul des montants et facturation | Obligation légale | 10 ans (obligation fiscale) | Comptabilité interne | Contrôle de type entier strict |
| `latitude`, `longitude` | Requête GPS mobile | Géolocalisation | Calcul de proximité des agences et livreurs | Consentement | Volatile (non persisté si non requis) | Aucun | Précision limitée, TLS 1.3 |
| `fcm_token` | `devices.fcm_token` | Technique | Acheminement des notifications push | Intérêt légitime | Jusqu'à déconnexion du device | Firebase Cloud Messaging | HTTPS / TLS 1.3 |
| `jwt_token` | `SecureStore (Mobile)` | Critique | Maintien de session authentifiée | Exécution contrat | 15 minutes (rotation continue) | Aucun (Stockage local appareil) | Hardware Keystore / Keychain |
| `crash_log` | Crashlytics / Sentry | Technique | Diagnostic des pannes et erreurs d'exécution | Intérêt légitime | 90 jours glissants | Google LLC / Sentry Inc. | Anonymisé, zéro PII |

---

## 2. SYNCHRONISATION AVEC LES DÉCLARATIONS DES CONSOLES STORES

### A. Déclaration Google Play Data Safety
* **Données de localisation :** Collectées au premier plan avec consentement explicite $\rightarrow$ Déclaré : *Localisation approximative et précise*.
* **Données personnelles :** Nom, adresse e-mail, numéro de téléphone $\rightarrow$ Déclaré : *Gestion du compte utilisateur*.
* **Données financières :** Historique des achats, informations de paiement $\rightarrow$ Déclaré : *Opérations financières & prévention des fraudes*.
* **Données de diagnostic :** Journaux de plantage $\rightarrow$ Déclaré : *Analyse et stabilité applicative*.
* **Mesures de protection :** Chiffrement des données en transit coché à *Oui*.
* **Suppression des données :** URL externe publique déclarée : `https://alexsan.pro/account/delete-request`.

### B. Déclaration Apple App Privacy (Nutrition Labels)
* **Data Used to Track You :** Aucune donnée n'est liée à un identifiant publicitaire sans accord préalable via App Tracking Transparency.
* **Data Linked to You :**
  - Contact Info (Phone, Name, Email) $\rightarrow$ Fonctionnalité de l'application.
  - Financial Info (Payment Info, Purchase History) $\rightarrow$ Traitement des commandes.
  - User Content (Photos sélectionnées pour l'avatar ou le support).
* **Data Not Linked to You :**
  - Diagnostics (Crash Data, Performance Data) $\rightarrow$ Amélioration de l'application.

---

## 3. PROTOCOLE DE MISE À JOUR DE LA DATA MAP

Chaque développeur ou sous-agent ajoutant un nouveau champ dans les migrations SQL ou intégrant une nouvelle dépendance npm/composer doit :
1. Ré-exécuter `scripts/scan_app_permissions.sh`.
2. Compléter la table ci-dessus avec la finalité et la base légale.
3. Vérifier que la politique de confidentialité (`docs/PRIVACY_POLICY.md`) cite expressément la nouvelle donnée.
4. Mettre à jour les formulaires de conformité sur Google Play Console et App Store Connect avant de soumettre une nouvelle release.
