# Catalogue Exhaustif des Motifs de Rejet Apple & Google et Remédiations Techniques

> **Framework :** Google Antigravity (`san_*`) — Conçu pour l'ingénierie mobile de distribution souveraine (`alexsan.pro`).  
> **Auditeur de référence :** `san_store_legal_expert`  
> **Objectif :** Élimination catégorique des motifs de rejet évitables lors des soumissions sur l'Apple App Store et le Google Play Store.

---

## 1. CARTOGRAPHIE DES REJETS APPLE APP STORE (APP STORE REVIEW GUIDELINES)

### Motif 1 : Guideline 2.1 — App Completeness & Reviewer Login Failure (Priorité Critique)
* **Description du rejet :** L'équipe de validation Apple (*App Review*) ne parvient pas à se connecter à l'application. Écrans bloqués, OTP non reçu par SMS, obligation d'entrer un numéro de téléphone africain inopérant aux USA, ou application affichant un écran de chargement infini.
* **Conséquence :** Rejet immédiat avec message générique : *"We were unable to sign in to your app to review its content and features."*
* **Remédiation Technique Antigravity :**
  1. **Compte Reviewer Déterministe :** Configurer sur le backend un utilisateur dédié `reviewer@alexsan.pro` ou numéro magique `+242000000000`.
  2. **Bypass OTP Fixe :** Implémenter dans l'authentification un code OTP magique `123456` actif exclusivement pour ce compte reviewer (sans dépendance aux passerelles SMS MTN/Airtel).
  3. **Données Mockées Pré-remplies :** Injecter un jeu de données réaliste : profil complété, solde virtuel de 25 000 FCFA, historique de commandes factices, adresses à Brazzaville/Pointe-Noire pré-enregistrées.
  4. **Instructions de Review Explicites :** Saisir dans la section *Notes de version / App Review Information* d'App Store Connect :
     > *"Identifiants de test : reviewer@alexsan.pro (ou téléphone : +242000000000). Code OTP fixe : 123456. Mot de passe : StoreReviewerPass2026!. Le compte dispose d'un portefeuille pré-approvisionné de 25 000 FCFA pour tester l'intégralité du tunnel d'achat sans paiement réel."*

---

### Motif 2 : Guideline 5.1.1 — Data Collection and Storage : Account Deletion (Priorité Bloquante)
* **Description du rejet :** L'application permet la création de compte, mais n'offre aucun moyen in-app simple pour supprimer son compte, ou renvoie vers un simple formulaire de contact, une adresse email ou un lien externe sans action directe.
* **Règle Apple stricte :** *"If your app supports account creation, you must also offer account deletion within the app. It should be easy to find, typically in the account settings."*
* **Remédiation Technique Antigravity :**
  1. **Parcours In-App en $\le 3$ Taps :** Bouton accessible depuis : `Accueil > Menu Profil > Sécurité & Compte > Supprimer mon compte`.
  2. **Modal de Confirmation & Double Facteur :** Dialogue modal expliquant clairement les conséquences de la suppression, avec saisie du mot de passe utilisateur ou re-confirmation par OTP pour prévenir les clics accidentels.
  3. **Endpoint Backend Dédié :** Appel HTTP `DELETE /api/v1/account/me` avec code HTTP 200.
  4. **Purge Réversible / Irréversible :** Révocation immédiate des tokens JWT/FCM, anonymisation des données personnelles sous 30 jours, conservation stricte des seules traces comptables fiscales imposées par la loi.
  5. **URL Web Externe de Secours :** Mise à disposition d'un formulaire web public d'assistance à la suppression : `https://alexsan.pro/account/delete-request`.

---

### Motif 3 : Guideline 5.1.2 — Data Use and Sharing & Usage Descriptions (Info.plist)
* **Description du rejet :** Présence de descriptions vagues ou génériques pour les permissions demandées dans `Info.plist`, ou absence de déclaration de tracking alors qu'un SDK publicitaire ou d'attribution est intégré.
* **Exemples rejetés par Apple :**
  - `NSCameraUsageDescription` : *"L'application a besoin d'accéder à la caméra."* $\rightarrow$ **REJETÉ.**
  - `NSLocationWhenInUseUsageDescription` : *"Pour une meilleure expérience utilisateur."* $\rightarrow$ **REJETÉ.**
* **Remédiation Technique Antigravity :**
  1. Rédiger une explication contextualisée et bénéfique pour l'utilisateur :
     - `NSCameraUsageDescription` : *"Permet de photographier votre pièce d'identité pour vérifier votre compte et de scanner les QR codes marchands pour régler vos achats."*
     - `NSLocationWhenInUseUsageDescription` : *"Permet de localiser les points de vente et kiosques Mobile Money les plus proches de vous sur la carte."*
     - `NSPhotoLibraryUsageDescription` : *"Permet de sélectionner une photo depuis votre galerie pour votre profil ou de transmettre une preuve de paiement au support."*
  2. Si `react-native-fbsdk-next` ou `react-native-adjust` est utilisé, intégrer obligatoirement le framework `AppTrackingTransparency` (`requestTrackingPermissionsAsync()`) avant toute collecte d'IDFA.

---

### Motif 4 : Guideline 4.0 / 4.2 — Design & Minimum Functionality (Anti-WebView Wrapper)
* **Description du rejet :** L'application n'est qu'un simple conteneur web encapsulant un site responsive dans une WebView sans fonctionnalités natives réelles ni valeur ajoutée.
* **Remédiation Technique Antigravity :**
  1. Développer l'interface en composants React Native natifs (`View`, `Text`, `FlatList`, animations `react-native-reanimated`).
  2. Intégrer des fonctionnalités matérielles natives : notifications push Firebase, retour haptique, accès caméra/galerie, stockage sécurisé hors-ligne (`expo-secure-store`).
  3. Fournir une gestion soignée du mode hors-ligne avec écran de repli ergonomique (*Offline Fallback Screen*).

---

### Motif 5 : Guideline 3.1.1 — In-App Purchases (IAP) vs Paiements Externes (Mobile Money)
* **Description du rejet :** Proposition de paiement Mobile Money ou carte bancaire pour des biens purement numériques (abonnements premium, monnaies virtuelles de jeux, fonctionnalités logicielles débloquées).
* **Règle Apple :** Tout bien ou service numérique consommé à l'intérieur de l'application doit obligatoirement passer par les achats intégrés Apple (StoreKit - commission 15% à 30%).
* **Remédiation Technique Antigravity :**
  - **Biens physiques et services tangibles du monde réel :** Les paiements par Mobile Money (MTN MoMo, Airtel Money) ou Cash à la livraison sont **autorisés et conformes** (commandes e-commerce, livraison de repas, transport, services à domicile, recharges télécoms).
  - **Biens numériques :** Si l'application vend du contenu numérique, intégrer StoreKit pour iOS ou réserver l'achat de ces abonnements au portail web sans lien direct de contournement dans l'application mobile.

---

## 2. CARTOGRAPHIE DES REJETS GOOGLE PLAY STORE (DEVELOPER PROGRAM POLICIES)

### Motif 1 : Google Play Data Safety Mismatch (Déclaration de Sécurité des Données)
* **Description du rejet :** Discordance flagrante entre les déclarations effectuées dans le formulaire *Sécurité des données (Data Safety)* de la Google Play Console et les SDKs présents dans le binaire `.aab`.
* **Exemple fréquent :** Le développeur coche *"Aucune donnée n'est collectée"*, mais l'APK intègre `@react-native-firebase/analytics` ou `@sentry/react-native`.
* **Remédiation Technique Antigravity :**
  1. Exécuter `scripts/scan_app_permissions.sh` pour dresser l'inventaire certifié des SDKs tiers.
  2. Renseigner exhaustivement dans la console Google Play :
     - Données de localisation : si `expo-location` est présent $\rightarrow$ déclarer *Localisation approximative/précise*.
     - Identifiants personnels : si authentification $\rightarrow$ déclarer *Nom, Email, Téléphone*.
     - Données financières : si e-commerce $\rightarrow$ déclarer *Historique des transactions d'achat*.
     - Diagnostic : si Crashlytics/Sentry $\rightarrow$ déclarer *Journaux de plantage et diagnostics de performance*.
  3. Cocher systématiquement : *"Toutes les données sont chiffrées en transit via le protocole HTTPS/TLS."*

---

### Motif 2 : Permissions Dangereuses Injustifiées (SMS, CALL_LOG, QUERY_ALL_PACKAGES)
* **Description du rejet :** Présence dans `AndroidManifest.xml` de permissions hautement restreintes sans que l'application ne soit l'application par défaut de téléphonie ou SMS.
* **Exemple classique :** Utilisation de `android.permission.RECEIVE_SMS` ou `READ_SMS` pour lire automatiquement le code OTP de validation.
* **Remédiation Technique Antigravity :**
  1. Bannir formellement `RECEIVE_SMS` et `READ_SMS`.
  2. Remplacer par l'API moderne Google Play Services : **SMS Retriever API** ou **SMS User Consent API** qui ne requièrent **aucune permission Android déclarée dans le Manifest**.
  3. Supprimer toute déclaration de `QUERY_ALL_PACKAGES` sauf si l'application est un lanceur d'applications ou un antivirus certifié.

---

### Motif 3 : Localisation en Arrière-Plan (`ACCESS_BACKGROUND_LOCATION`)
* **Description du rejet :** Demande de la permission de géolocalisation continue en arrière-plan sans justification essentielle pour la mission principale de l'application, et sans vidéo de démonstration fournie aux examinateurs.
* **Remédiation Technique Antigravity :**
  1. Restreindre l'accès à la localisation au premier plan : `ACCESS_FINE_LOCATION` et `ACCESS_COARSE_LOCATION` uniquement lors de l'utilisation de l'écran de carte.
  2. Supprimer totalement `ACCESS_BACKGROUND_LOCATION` de la configuration Expo et du Manifest sauf si le produit est une application de chauffeur de taxi en course active.

---

### Motif 4 : Exigence Google Play 2024 de Suppression de Compte et URL Publique
* **Description du rejet :** Absence de lien web public accessible sans installer l'application pour solliciter la suppression de compte.
* **Remédiation Technique Antigravity :**
  1. Renseigner dans la console Google Play (section Contenu de l'application > Suppression de compte) l'URL exacte : `https://alexsan.pro/account/delete-request`.
  2. S'assurer que cette page web est publique, indexable, en HTTP 200, et détaille les étapes et délais de suppression (purge sous 30 jours).

---

### Motif 5 : Politiques de Confidentialité Inaccessibles ou Liens Morts (HTTP 404)
* **Description du rejet :** L'URL de la politique de confidentialité configurée sur la fiche Play Store renvoie une erreur HTTP 404, 502, ou est bloquée par un écran de connexion.
* **Remédiation Technique Antigravity :**
  1. Héberger la politique générée (`docs/PRIVACY_POLICY.md`) sur une route statique accessible publiquement : `https://alexsan.pro/privacy`.
  2. Monitorer la disponibilité HTTP 200 de cette URL avant toute publication.

---

## 3. TABLEAU SYNTHÉTIQUE DE CONTRÔLE PRÉ-SOUMISSION

| Risque Détecté | Impact Store | Outil Antigravity Associé | Remédiation Définitive |
| :--- | :--- | :--- | :--- |
| OTP SMS non reçu par le reviewer | Rejet Apple 2.1 & Google Login | `docs/STORE_CHECKLIST.md` | Compte test `reviewer@alexsan.pro` + OTP magique `123456` |
| Pas de bouton in-app de suppression | Rejet Apple 5.1.1 Bloquant | `docs/STORE_CHECKLIST.md` | Écran Profil $\le 3$ taps + endpoint `DELETE /api/v1/account/me` |
| Absence d'URL publique de purge | Rejet Google Play Policy | `docs/PRIVACY_POLICY.md` | Page web publique `https://alexsan.pro/account/delete-request` |
| SDKs non déclarés dans la Privacy Policy | Rejet Apple 5.1.2 & Play Data Safety | `scripts/scan_app_permissions.sh` | Déclaration exhaustive dans `docs/DATA_MAP.md` |
| Permissions SMS intrusives | Rejet Google Play Critique | `scripts/scan_app_permissions.sh` | Remplacement par SMS Retriever API |
| Lien de politique brisé (404) | Rejet Immédiat 2 Stores | `docs/STORE_CHECKLIST.md` | Vérification HTTP 200 sur `https://alexsan.pro/privacy` |
