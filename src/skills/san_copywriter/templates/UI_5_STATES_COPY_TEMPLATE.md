# Gabarit des 5 États UI pour Composant / Écran

Utilisez ce modèle pour formaliser la micro-copie de tout écran ou composant avant son implémentation dans le code frontend ou mobile.

---

## Composant / Écran : `[Nom de l'écran, ex: CheckoutMobileMoney]`

### 1. ÉTAT NOMINAL (Interface Active avec Données)
- **Titre principal :** `[Ex: Récapitulatif de votre commande]`
- **Sous-titre / Contextualisation :** `[Ex: Livraison express à Bacongo, Marché Total]`
- **Format monétaire :** `[Ex: 14 500 FCFA]` *(Toujours avec espace insécable)*
- **Identité usager :** `[Ex: Mabiala Christian, +242 06 123 45 67]`
- **Bouton d'action principal (CTA) :** `[Verbe d'action] + [Bénéfice], ex: Valider et payer par MoMo`
- **Action secondaire :** `[Ex: Modifier les articles]`

### 2. ÉTAT VIDE (Empty State Incitatif)
- **Illustration sémantique :** `[Ex: Panier détendu / Sac ouvert]`
- **Constat immédiat :** `[Ex: Votre panier est encore vide]`
- **Promesse de valeur :** `[Ex: Retrouvez les plats de vos restaurants préférés livrés chez vous en moins de 30 minutes.]`
- **CTA d'amorçage :** `[Ex: Découvrir les spécialités du jour]`

### 3. ÉTAT CHARGEMENT (Skeleton & Micro-copie Rassurante)
- **Titre d'attente :** `[Ex: Connexion sécurisée avec MTN MoMo...]`
- **Sous-titre réassurance :** `[Ex: Nous préparons l'envoi de la demande sur votre mobile. Cela ne prend que quelques secondes.]`
- **Consigne de patience :** `[Ex: Veuillez ne pas quitter l'écran]`

### 4. ÉTAT ERREUR (Le Triptyque Cartésien Inviolable)
- **1. Constat (Sans blâme) :** `[Ex: Le paiement Mobile Money n'a pas pu être validé.]`
- **2. Réassurance & Données sauves :** `[Ex: Votre compte MoMo n'a pas été débité et votre sélection d'articles reste intacte.]`
- **3. Action de remédiation :**
  - **CTA Principal :** `[Ex: Réessayer la transaction]`
  - **Lien / Option alternative :** `[Ex: Choisir le paiement en espèces à la livraison]`
  - **Issue d'urgence :** `[Ex: Assistance WhatsApp : +242 06 000 00 00]`

### 5. ÉTAT HORS-LIGNE (Réseau Dégradé 3G/EDGE)
- **Bannière d'état :** `[Ex: Connexion Internet instable]`
- **Message explicatif :** `[Ex: Vous consultez les données sauvegardées sur votre téléphone. Vos actions seront envoyées dès le retour du réseau.]`
- **CTA persistant :** `[Ex: Réessayer la connexion]`
