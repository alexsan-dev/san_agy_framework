# CHECKLIST DE CONFORMITÉ DISTRIBUTION STORES (APPLE & GOOGLE)

> **Application :** [Nom de l'Application Mobile]  
> **Identifiant Bundle / Package :** `pro.alexsan.[app_name]`  
> **Plateformes Cibles :** Apple App Store (iOS) & Google Play Store (Android)  
> **Auditeur Technique :** `san_store_legal_expert`  
> **Dernier Audit :** YYYY-MM-DD  
> **Statut Global :** [0 BLOQUANT | PRÊT POUR SOUMISSION]  

---

## 1. COMPTE DE TEST DÉDIÉ POUR LES EXAMINATEURS (*REVIEWERS*)

L'équipe d'examen Apple et Google doit pouvoir tester l'intégralité du parcours utilisateur sans blocage par SMS payant, géolocalisation ou saisie de carte bancaire réelle.

| Paramètre de Connexion | Valeur Conforme Validée |
| :--- | :--- |
| **Identifiant / E-mail de Test** | `reviewer@alexsan.pro` |
| **Numéro de Téléphone Test** | `+242000000000` |
| **Code OTP Déterministe (Bypass SMS)** | `123456` (actif sur environnement de review & production) |
| **Mot de passe** | `StoreReviewerPass2026!` |
| **Solde Virtuel Portefeuille (Mocké)** | `25 000 FCFA` (permet de simuler 2 commandes sans paiement réel) |
| **Historique & Données Pré-chargées** | Profil complet, 3 commandes antérieures, 1 adresse à Brazzaville |
| **Texte exact pour notes de soumission** | *"Use credentials reviewer@alexsan.pro / password StoreReviewerPass2026!. For OTP verification step, enter deterministic code 123456 (bypasses SMS gateway). A virtual balance of 25,000 XAF is preloaded to test complete checkout flows."* |

---

## 2. AUDIT DE CONFORMITÉ DIRECTIVE APPLE 5.1.1 (SUPPRESSION DE COMPTE)

- [x] **Présence du bouton in-app :** Accessible en moins de 3 taps depuis l'écran principal (*Accueil > Profil > Sécurité & Compte > Supprimer mon compte*).
- [x] **Avertissement & Confirmation explicite :** Fenêtre modale avec texte clair sur les conséquences irréversibles et demande de confirmation (saisie du mot de passe ou validation OTP).
- [x] **Endpoint Backend Dédié :** Appel HTTP `DELETE /api/v1/account/me` avec code retour HTTP 200 OK.
- [x] **Révocation immédiate des accès :** Déconnexion forcée, révocation immédiate du token JWT de session et du token FCM de notifications.
- [x] **Purge et Anonymisation sous 30 jours :** Effacement irréversible des identifiants directs (nom, email, numéro de téléphone, avatar). Seules les traces comptables légalement requises sont conservées sous forme anonymisée.
- [x] **URL publique de suppression externe (Exigence Google Play 2024 & Apple Web) :** Page web publique accessible sans l'application : `https://alexsan.pro/account/delete-request`.

---

## 3. MATRICE DES JUSTIFICATIONS DE PERMISSIONS SENSIBLES

Toutes les permissions déclarées dans `AndroidManifest.xml` et `Info.plist` disposent d'un argumentaire clair et centré sur le bénéfice utilisateur :

| Permission Système | Plateforme | Justification Conforme Saisie dans la Console Store |
| :--- | :--- | :--- |
| `CAMERA`<br>`NSCameraUsageDescription` | iOS & Android | « Permet de scanner le QR code d'un commerçant partenaire pour valider un paiement en magasin ou de photographier un justificatif d'identité pour la vérification de compte. » |
| `ACCESS_FINE_LOCATION`<br>`NSLocationWhenInUseUsageDescription` | iOS & Android | « Permet de localiser sur la carte interactive les points de retrait, agences et commerçants Mobile Money partenaires les plus proches de votre position. » |
| `READ_MEDIA_IMAGES`<br>`NSPhotoLibraryUsageDescription` | iOS & Android | « Permet de sélectionner une photo depuis votre galerie pour personnaliser votre avatar de profil ou pour joindre un reçu de paiement au support client. » |
| `POST_NOTIFICATIONS` | Android 13+ | « Permet de recevoir en temps réel les notifications d'état de vos commandes et les alertes de sécurité sur votre compte. » |

---

## 4. VALIDATION DES LIENS PUBLICS OBLIGATOIRES (CODE HTTP 200 OK)

- [x] **Politique de Confidentialité :** `https://alexsan.pro/privacy` (Accessible publiquement, sans mot de passe ni captcha, HTTP 200 vérifié).
- [x] **Conditions Générales d'Utilisation :** `https://alexsan.pro/terms` (HTTP 200 vérifié).
- [x] **Page de Demande de Suppression de Compte :** `https://alexsan.pro/account/delete-request` (HTTP 200 vérifié).
- [x] **Support Client & Contact :** `https://alexsan.pro/support` (Adresse email support `support@alexsan.pro` et lien direct WhatsApp réactif).

---

## 5. DÉCLARATIONS CONSOLES DE SÉCURITÉ DES DONNÉES (DATA SAFETY & NUTRITION LABELS)

- [x] **Chiffrement en Transit :** Certifié actif pour 100% des flux réseaux (`TLS 1.3 / HTTPS`).
- [x] **Données Personnelles Collectées :** Correspondance exacte avec `docs/DATA_MAP.md` (Nom, Téléphone, Email déclarés).
- [x] **Données Financières :** Déclarées au titre de l'exécution du contrat d'achat (Historique de transaction, Référence MoMo).
- [x] **SDKs Tiers & Traceurs :** Alignement strict entre le scan statique `scan_app_permissions.sh` et les déclarations consoles (Firebase Crashlytics déclaré pour le diagnostic technique).
- [x] **Partage avec des Tiers :** Aucun partage à des fins publicitaires ou de revente de données sans consentement.

---

## 6. VALIDATION FINALE AVANT SOUMISSION

- **Anomalies Bloquantes :** 0
- **Avertissements Mineurs :** 0
- **Approbation Technique :** `san_store_legal_expert` (Validé)
- **Signature Release :** `alexsan.pro Engineering Team`
