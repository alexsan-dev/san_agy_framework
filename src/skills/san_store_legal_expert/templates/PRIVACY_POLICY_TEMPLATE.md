# POLITIQUE DE CONFIDENTIALITÉ

> **Dernière mise à jour :** [Date du Jour : YYYY-MM-DD]  
> **Application / Service :** [Nom du Produit / Service alexsan.pro]  
> **Avertissement de Transparence Légale :**  
> *Le présent document est une synthèse technique certifiée issue de l'analyse statique du code source, des modèles de données et des flux d'intégration de l'application. Il ne se substitue pas à une consultation juridique personnalisée et doit être soumis à la validation d'un avocat ou conseiller juridique habilité.*

---

## 1. IDENTITÉ DU RESPONSABLE DE TRAITEMENT

Le responsable du traitement des données personnelles collectées via l'application mobile et les services associés est :
* **Dénomination Sociale :** [Nom de l'Entreprise Éditeur / alexsan.pro]
* **Adresse du Siège :** [Adresse physique, Brazzaville / Pointe-Noire, République du Congo]
* **Contact Délégué à la Protection des Données (DPO) :** `privacy@alexsan.pro`
* **Contact Support & Réclamations :** `support@alexsan.pro`
* **Infrastructure d'Hébergement :** Serveurs VPS souverains sécurisés localisés dans des datacenters certifiés ISO 27001 (Union Européenne / France & Allemagne).

---

## 2. DONNÉES PERSONNELLES COLLECTÉES & BASES LÉGALES

Conformément au principe strict de **minimisation des données**, nous ne collectons que les informations techniquement indispensables au fonctionnement du service et à la sécurité des transactions :

| Catégorie de Données | Données Spécifiques Collectées | Finalité Technique & Métier | Base Légale du Traitement |
| :--- | :--- | :--- | :--- |
| **Identité & Compte** | Nom, prénom, numéro de téléphone, adresse e-mail | Création du compte utilisateur, authentification par code OTP, sécurisation de la session | Exécution des Conditions Générales d'Utilisation (Contrat) |
| **Transactions Financières** | Numéro de transaction, référence Mobile Money (MTN MoMo, Airtel Money), montant en FCFA/XAF, date et heure | Traitement des paiements, réconciliation comptable, prévention de la fraude | Exécution du contrat & Obligations légales comptables |
| **Données de Géolocalisation** | Coordonnées GPS (latitude/longitude) précises au premier plan | Localisation des points de retrait Mobile Money et boutiques partenaires à proximité | Consentement explicite de l'utilisateur (révocable) |
| **Données Techniques & Appareil** | Modèle de smartphone, version de l'OS, identifiant d'installation unique, logs de crash | Diagnostic des erreurs logicielles, maintien de la stabilité de l'application | Intérêt légitime de sécurité et maintenance |

---

## 3. SOUS-TRAITANTS TECHNIQUES & DESTINATAIRES TIERS

Vos données personnelles ne sont **jamais vendues, louées ou cédées** à des courtiers de données (*data brokers*). Elles sont transmises exclusivement aux sous-traitants techniques strictement requis pour l'exécution du service :

1. **Opérateurs Télécoms & Passerelles Mobile Money :**
   * *Entités :* MTN Congo, Airtel Congo.
   * *Données partagées :* Numéro de téléphone MSISDN, montant de la transaction en FCFA, référence de commande.
   * *Finalité :* Émission des requêtes USSD push pour validation du prélèvement sur votre portefeuille mobile.
2. **Infrastructure de Messagerie & Notifications :**
   * *Entités :* Serveur de messagerie transactionnelle Mailcow autohébergé souverain, Firebase Cloud Messaging (Google LLC).
   * *Données partagées :* Adresse e-mail, jeton de notification d'appareil (*push token*).
   * *Finalité :* Acheminement des reçus de commande et alertes de statut de compte.
3. **Télémétrie & Stabilité Applicative :**
   * *Entités :* Firebase Crashlytics / Sentry.
   * *Données partagées :* Traces de pile d'erreur (*stack traces*), version système, sans aucune donnée bancaire ni mot de passe.
   * *Finalité :* Résolution rapide des dysfonctionnements techniques et des pannes.

---

## 4. DURÉE DE CONSERVATION & ARCHIVAGE

* **Données de profil utilisateur :** Conservées pendant toute la durée d'activité du compte utilisateur.
* **Historiques de transactions financières :** Conservés sous forme d'archives sécurisées pendant la durée légale obligatoire de 10 ans conformément aux règles de tenue de comptabilité commerciale.
* **Journaux techniques (Logs) :** Purge automatique des journaux d'accès réseau après une période glissante de 90 jours.

---

## 5. SUPPRESSION DE COMPTE & PURGE DES DONNÉES (DIRECTIVE APPLE 5.1.1)

Tout utilisateur bénéficie du droit inconditionnel de demander la suppression complète et définitive de son compte :

1. **Suppression In-App Directe :**
   * Rendez-vous dans : *Paramètres du Profil > Sécurité & Compte > Supprimer mon compte*.
   * Confirmez votre demande via la saisie de votre mot de passe ou code de vérification.
   * L'application déclenche immédiatement la révocation de vos sessions actives (`DELETE /api/v1/account/me`).
2. **Suppression via Portail Web Externe :**
   * Si vous n'avez plus accès à votre smartphone ou avez désinstallé l'application, vous pouvez soumettre une demande formelle via notre page dédiée : **`https://alexsan.pro/account/delete-request`**.
3. **Effets de la suppression :**
   * Effacement immédiat de vos identifiants nominatifs (nom, téléphone, adresse email, photo).
   * Purge irréversible de vos paniers, préférences et historiques de navigation sous 30 jours calendaires.
   * Les données comptables résiduelles sont rendues anonymes et dissociées de toute identité humaine.

---

## 6. SÉCURITÉ DE VOS DONNÉES PERSONNELLES

Le framework applique les standards industriels de sécurité les plus rigoureux :
* **Chiffrement en Transit :** Toutes les communications réseau utilisent exclusivement le protocole `TLS 1.3 / HTTPS` avec suites cryptographiques renforcées.
* **Chiffrement des Mots de Passe :** Hachage robuste irréversible via les algorithmes `Argon2id` ou `Bcrypt` avec salage individuel.
* **Stockage Local Sécurisé :** Les jetons de session sur smartphone sont consignés dans le trousseau matériel sécurisé (`iOS Keychain` et `Android KeyStore` via `expo-secure-store`).

---

## 7. VOS DROITS & CONTACT

Conformément à la réglementation sur la protection des données personnelles, vous disposez des droits suivants :
* Droit d'accès et d'obtention d'une copie de vos données personnelles.
* Droit de rectification des informations inexactes ou obsolètes.
* Droit d'opposition et de limitation des traitements.
* Droit à l'effacement de vos données (*droit à l'oubli*).

Pour exercer l'un de ces droits, contactez notre équipe à : **`privacy@alexsan.pro`**. Nous nous engageons à traiter toute demande dans un délai maximal de 30 jours ouvrés.
