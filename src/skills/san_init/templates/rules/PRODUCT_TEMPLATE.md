# CADRAGE PRODUIT, STRATÉGIE & MARCHÉ (`PRODUCT.md`)

> **Source de vérité produit :** Ce document régit la vision d'affaires, les personas cibles, les métriques de succès et les contraintes opérationnelles indispensables à la prise de décision fonctionnelle.

---

## 1. VISION PRODUIT & PROPOSITION DE VALEUR UNIQUE (UVP)

* **Nom Officiel du Produit :** `[NOM_PRODUIT]`
* **Le Problème Douloureux :** `[Description concise du problème critique et de la friction quotidienne subie par les utilisateurs cibles]`
* **La Solution Déterminante :** `[Comment notre produit pulvérise cette friction en un minimum d'interactions claires]`
* **Proposition de Valeur Unique (UVP) :** `"[Phrase d'impact mémorable en 12 mots maximum résumant l'avantage exclusif]"`
* **Modèle Économique (Business Model) :** `[Commission à la transaction / Abonnement mensuel / Modèle Freemium / Facturation à l'usage]`

---

## 2. PERSONAS CIBLES & ENVIRONNEMENT D'USAGE

### Persona Primaire (Utilisateur Cœur de Cible)
* **Profil Type :** `[Ex: Commerçant de quartier, gestionnaire de flotte, jeune professionnel urbain]`
* **Tranche d'Âge & Alphabétisation Numérique :** `[Ex: 22 - 45 ans, maîtrise des interfaces usuelles (WhatsApp, Facebook, Mobile Money)]`
* **Appareils Principaux :** Smartphones Android d'entrée et milieu de gamme (2 Go à 4 Go de mémoire RAM, processeurs à 4/8 cœurs économiques).
* **Définition d'Écran de Référence :** Résolutions effectives de `360x640` à `393x852` px. Densité d'affichage variable (`dpi 1.5` à `3.0`).
* **Objectif Principal dans l'App :** `[Ex: Effectuer un transfert sécurisé, consulter un stock en temps réel, émettre une facture client]`

### Persona Secondaire (Opérateur / Administrateur)
* **Profil :** `[Ex: Gestionnaire back-office, superviseur financier, agent de support client]`
* **Environnement de Travail :** Poste de bureau / Web desktop moderne (`1280x720` à `1920x1080`), navigateurs Chrome / Firefox / Safari récents.
* **Besoin Clé :** Vision synthétique, exports rapides, traçabilité des opérations et filtres multicritères performants.

---

## 3. RÉALITÉS TERRAIN SPÉCIFIQUES & MARCHÉS ÉMERGENTS

Toute décision ergonomique ou technique doit intégrer sans compromis les réalités d'infrastructure suivantes :

### A. Connectivité Dégradée (3G, EDGE, Coupures Réseau & Hors-Ligne)
* **Démarrage Instantané (Offline-First) :** L'application doit s'ouvrir en moins de 1.5 seconde sans écran blanc, en présentant les données les plus récentes issues du cache local (SQLite, IndexedDB, WatermelonDB ou AsyncStorage).
* **Mises à Jour Optimistes (Optimistic UI) :** Toute action utilisateur (ajout, modification de statut, création d'élément) doit être reflétée instantanément sur l'interface avec un indicateur discret de synchronisation en cours.
* **File d'Attente Locale Sortante (Outbox Pattern) :** Les requêtes émises hors-ligne sont empilées dans une file locale persistante et rejouées séquentiellement dès le rétablissement de la connectivité réseau.
* **Sobriété de Consommation de Données :** La bande passante est coûteuse pour l'utilisateur. Poids total d'une session classique strictement inférieur à `1.5 Mo`. Compression systématique des payloads JSON et des images envoyées.

### B. Transactions Financières & Mobile Money
* **Paiements Locaux Incontournables :** Intégration prioritaire des passerelles Mobile Money (Airtel Money, MTN Mobile Money, Orange Money, Wave, M-Pesa).
* **Gestion Asynchrone des Flux USSD / Push STK :**
  - Ne jamais bloquer l'interface pendant l'attente du code PIN de l'opérateur par l'utilisateur.
  - Affichage d'un panneau d'attente non bloquant invitant l'utilisateur à valider le prompt USSD sur son terminal.
  - Mécanisme de réconciliation par polling intelligent à intervalle progressif (3s, 5s, 10s) couplé à la réception du webhook serveur.
* **Verrou d'Idempotence Transactionnelle :** Génération systématique d'un jeton `Idempotency-Key` (UUIDv4) pour prévenir les doubles débits en cas d'instabilité réseau.

### C. Repérage Géographique & Localisation
* **Proscription des Formulaires Postaux Occidentaux :** Ne jamais exiger de « code postal », « numéro de rue » ou « boîte postale ».
* **Repères Urbains & Familiers :** La localisation physique repose sur le quartier, le carrefour connu, un édifice public ou un repère visuel populaire.
* **Partage Géographique Direct :** Prise en charge native du partage de coordonnées GPS et intégration facilitée des liens de position WhatsApp.

### D. Canaux de Communication & Habitudes d'Interaction
* **Primauté de WhatsApp :** Partage natif des reçus de transaction, devis, factures et rapports sous format PDF ou texte structuré via l'API `whatsapp://send`.
* **Authentification Allégée :** Privilégier la connexion par numéro de téléphone avec vérification OTP par SMS ou WhatsApp plutôt que des combinaisons e-mail/mot de passe complexe sujet à l'abandon.

---

## 4. INDICATEURS CLÉS DE PERFORMANCE (KPIS) & OBJECTIFS D'AFFAIRES

| Indicateur (KPI) | Cible Minimale Exigée | Méthode de Mesure / Outil |
| :--- | :--- | :--- |
| **Taux de complétion de l'onboarding** | $> 85\%$ | Funnel analytique de la première ouverture à l'écran d'accueil |
| **Délai d'exécution de l'action clé** | $< 30\text{ secondes}$ | Chronométrage de la séquence nominale (Time to Value) |
| **Taux d'échec de paiement réconcilié** | $< 2\%$ | Ratio des abandons de transaction sur le total initié |
| **Taux de rétention J+1 (Day 1)** | $> 40\%$ | Utilisateurs réouvrant l'application le lendemain |
| **Taux de rétention J+7 (Day 7)** | $> 25\%$ | Utilisateurs actifs après une semaine |
| **Poids total initial du bundle client** | $< 15\text{ Mo}$ | Taille de l'APK / Bundle web gzippé au téléchargement |
| **Consommation de données par session** | $< 1.5\text{ Mo}$ | Mesure réseau moyenne sur parcours standard de 5 minutes |
