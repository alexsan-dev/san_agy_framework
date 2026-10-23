# Guide Pratique de Micro-Copie Locale, Rédaction UX & 5 États UI

Ce guide constitue le répertoire de référence officiel du skill `san_copywriter`. Il offre un catalogue prêt à l'emploi de formulations réelles, éprouvées sur le terrain, bannissant le faux texte et les abstractions occidentales inadaptées aux contextes émergents et africains.

---

## 1. Principes Fondamentaux de Voix UX (*Tone of Voice*)

1. **Clarté & Concision :** Des phrases courtes en syntaxe directe (Sujet + Verbe + Complément). Chaque mot doit mériter sa place sur un écran de 360px de large.
2. **Empathie Active :** L'utilisateur n'est jamais coupable d'un échec. Les explications sont bienveillantes, dénuées de blâme et pédagogiques.
3. **Zéro Jargon Technique :** Jamais de *"Error 500"*, *"NullPointerException"*, *"Failed to fetch"*, *"Socket timeout"* ou *"Erreur interne du serveur"*.
4. **Réassurance Transactionnelle :** Expliciter toujours le statut de l'argent et des données : *"Votre compte n'a pas été débité"*, *"Vos données saisies sont conservées"*.
5. **Incitation Naturelle :** Des libellés de boutons orientés bénéfice direct : `[Verbe d'action] + [Bénéfice]` plutôt qu'un vague `"OK"` ou `"Soumettre"`.

---

## 2. Règles Strictes de Localisation et Formatage

### 1. Devises et Espaces Insécables
- En zone CEMAC (FCFA / XAF) et UEMOA (FCFA / XOF), écrire impérativement avec un espace insécable entre les milliers et avant le symbole :
  - ✅ **Correct :** `2 500 FCFA` ou `15 000 XAF`
  - ❌ **Interdit :** `2500FCFA`, `2500 FCFA` (espace sécable risquant un saut de ligne orphelin), `$ 2500`, `2500$`
- En code HTML : `2&nbsp;500&nbsp;FCFA`
- En JavaScript / TypeScript : `amount.toLocaleString('fr-FR') + '\u00A0FCFA'`

### 2. Repères Urbains sans Cadastre Postal
Les adresses postales de type européen (*"12 rue des Fleurs"*) sont inopérantes dans la majorité des villes africaines. La géolocalisation se décrit par carrefours, arrêts de bus, marchés et édifices de notoriété publique :
- **Brazzaville :**
  - *"Bacongo, Arrêt Marché Total, à côté de la pharmacie de l'Union"*
  - *"Moungali, Rond-point des Trois Martyrs, face à la boulangerie"*
  - *"Poto-Poto, Rue Mbaka, croisement Avenue de la Paix"*
  - *"Ouenzé, Marché 10 Francs, 2ème ruelle après l'école"*
- **Pointe-Noire :**
  - *"Grand Marché, face Pharmacie de la Paix"*
  - *"Tié-Tié, Arrêt Fond Tié-Tié, près du transformateur E2C"*
  - *"Lumumba, Avenue Denis Sassou Nguesso, Immeuble Mayombe"*
- **Abidjan :**
  - *"Yopougon, Carrefour Siporex, non loin du maquis"*
  - *"Cocody Angré, 8ème Tranche, Terminus 81/82"*
- **Dakar :**
  - *"Médina, Rue 6 angle Blaise Diagne"*
  - *"Grand Yoff, près du terrain de football"*
- **Kinshasa :**
  - *"Bandalungwa, Bloc Bisengo, Arrêt Adoula"*
  - *"Gombe, Boulevard du 30 Juin, en face de la BCDC"*

### 3. Numéros de Téléphone Réels
Utiliser les préfixes officiels des opérateurs locaux avec espacement lisible :
- **Congo-Brazzaville :**
  - MTN Congo : `+242 06 654 32 10`
  - Airtel Congo : `+242 05 512 34 56`
- **Côte d'Ivoire :** `+225 07 08 09 10 11` (Orange), `+225 05 ...` (MTN), `+225 01 ...` (Moov)
- **Sénégal :** `+221 77 123 45 67` (Orange), `+221 76 ...` (Free), `+221 70 ...` (Expresso)
- **RDC :** `+243 81 234 56 78` (Vodacom), `+243 99 ...` (Airtel), `+243 89 ...` (Orange)

---

## 3. Anatomie Chirurgicale des 5 États UI

Pour chaque écran, composant ou fonctionnalité, rédiger rigoureusement les 5 états suivants :

### État 1 : NOMINAL (Interface Active avec Données)
- **Titre d'écran :** Contextualisé et clair (*"Mes livraisons en cours"*, *"Solde disponible"*).
- **Données réelles :** Noms d'utilisateurs authentiques (*"Mabiala Christian"*, *"Awa Traoré"*), montants précis (*"14 500 FCFA"*).
- **CTA Principal :** `[Verbe d'action] + [Bénéfice]` :
  - *"Commander mon repas"* (au lieu de *"Valider"*)
  - *"Recharger mon compte MoMo"* (au lieu de *"Payer"*)
  - *"Confirmer l'adresse de livraison"* (au lieu de *"OK"*)

### État 2 : VIDE (Empty State Incitatif)
Un écran vide ne doit jamais être un cul-de-sac triste : il doit éveiller la curiosité et amorcer l'action.
- **Illustration sémantique :** Métaphore chaleureuse (panier en attente, carnet de notes ouvert).
- **Constat simple :** *"Votre panier est vide pour l'instant"* ou *"Aucune commande récente"*.
- **Promesse de valeur :** *"Découvrez les restaurants partenaires de votre quartier livrés en moins de 30 minutes."*
- **CTA d'amorçage :** *"Explorer le menu du jour"* ou *"Parcourir les produits"*.

### État 3 : CHARGEMENT (Skeleton Copy Rassurante)
Sur les réseaux instables (3G/EDGE), le chargement peut durer plusieurs secondes. Le texte doit rassurer sur la progression active :
- **Micro-copie primaire :** *"Connexion sécurisée avec votre opérateur..."*
- **Réassurance d'action :** *"Nous préparons votre récapitulatif. Cela ne prend que quelques secondes."*
- **Patience mobile :** *"Ne fermez pas l'application pendant la vérification du paiement."*

### État 4 : ERREUR (Le Triptyque Cartésien Inviolable)
Chaque message d'erreur d'interface doit obligatoirement respecter l'anatomie en 3 parties :
1. **Le Constat (Sans blâme) :** Que s'est-il passé de façon factuelle ?
   - *"La connexion avec le service Mobile Money a été interrompue."*
2. **La Cause & Réassurance :** Pourquoi mes données ou mon argent sont saufs ?
   - *"Votre compte bancaire ou MoMo n'a pas été débité. Vos articles restent réservés dans votre panier."*
3. **L'Action de Remédiation :** Quel bouton cliquer maintenant ?
   - Bouton principal : *"Réessayer le paiement"*
   - Lien secondaire : *"Payer en espèces à la livraison"* ou *"Assistance WhatsApp au +242 06 000 00 00"*

### État 5 : HORS-LIGNE (Réseau Dégradé 3G/EDGE/Coupure)
- **Bannière d'alerte :** *"Mode hors-ligne actif (réseau indisponible)"*
- **Explication transparente :** *"Vous consultez vos données déjà enregistrées sur votre appareil. Vos nouvelles actions seront synchronisées automatiquement dès le retour de la connexion."*
- **CTA persistant :** *"Vérifier la connexion"* ou *"Actualiser"*

---

## 4. Répertoire de Formulations Mobile Money

### 1. MTN Mobile Money (MoMo)
- **Initialisation :**
  - Titre : *"Paiement par MTN MoMo"*
  - Sous-titre : *"Numéro de téléphone : +242 06 123 45 67"*
  - Montant : *"Total à payer : 7 500 FCFA (frais opérateur inclus)"*
- **Instruction d'attente Push USSD :**
  - Titre : *"Validez la demande sur votre téléphone"*
  - Corps : *"Un message vient d'apparaître sur votre écran. Entrez votre code secret MTN MoMo pour approuver le paiement de 7 500 FCFA. Aucun frais supplémentaire n'est appliqué."*
  - Si le prompt USSD ne s'affiche pas : *"Vous n'avez pas reçu le message ? Tapez *126# ou *133# sur votre clavier d'appel."*
- **Confirmation de succès :**
  - Titre : *"Paiement MTN MoMo validé !"*
  - Corps : *"Votre transaction n° 492834 a été confirmée. Le livreur prépare votre commande."*
  - Bouton : *"Suivre mon colis en temps réel"*

### 2. Airtel Money
- **Initialisation :**
  - Titre : *"Paiement par Airtel Money"*
  - Instruction : *"Veuillez vérifier votre solde Airtel Money avant de poursuivre. Montant exact débité : 4 200 FCFA."*
- **Instruction d'attente Push STK :**
  - Titre : *"Approbation requise sur votre mobile"*
  - Corps : *"Une notification Airtel Money est envoyée sur le +242 05 987 65 43. Confirmez avec votre code PIN personnel."*
- **Notification SMS :**
  - *"Vous recevrez un SMS de confirmation de transaction officiel d'Airtel Money dans un instant."*

### 3. Orange Money
- **Attente validation :**
  - Titre : *"Validation Orange Money"*
  - Corps : *"Composez le #144# ou autorisez la demande reçue sur votre application Orange Money pour finaliser votre commande de 12 000 FCFA."*

### 4. Wave (Sénégal / Côte d'Ivoire)
- **Validation instantanée :**
  - Titre : *"Paiement Wave sans frais"*
  - Corps : *"Scannez le QR Code ou ouvrez votre application Wave pour valider le débit immédiat de 5 000 FCFA sans frais cachés."*

---

## 5. Bannières et Modales d'Erreur Réelles en Triptyque

### Exemple 1 : Échec Transaction Mobile Money
```markdown
[Icone Alerte Ambrée]
Titre : Échec de la demande de paiement
Constat : Votre opérateur n'a pas pu valider le débit à temps.
Réassurance : Aucun montant n'a été retiré de votre compte Mobile Money. Vos articles restent bien au chaud dans votre panier.
Action :
  [Bouton Plein] : Réessayer avec un autre numéro
  [Bouton Bordure] : Choisir le paiement en espèces à la livraison
```

### Exemple 2 : Perte Totale de Signal Réseau
```markdown
[Icone Nuage Déconnecté]
Titre : Connexion Internet perdue
Constat : Impossible de contacter nos serveurs pour le moment.
Réassurance : Ne vous inquiétez pas, votre brouillon de commande est sauvegardé dans votre téléphone.
Action :
  [Bouton Plein] : Réessayer la synchronisation
  [Lien Texte] : Écrire au support sur WhatsApp (+242 06 123 45 67)
```

### Exemple 3 : Stock Épuisé à la Validation
```markdown
[Icone Boîte Vide]
Titre : Un article vient d'être réservé
Constat : Le dernier 'Saka-Saka au poisson fumé' a été commandé par un autre client il y a quelques secondes.
Réassurance : Le reste de votre commande est prêt et votre paiement n'a pas été débité.
Action :
  [Bouton Plein] : Choisir un autre plat d'accompagnement
  [Lien Texte] : Modifier mon panier
```

---

## 6. Micro-Copies de Boutons d'Action (CTAs Haute Conversion)

| Contexte | ❌ Mauvais libellé (Froid / Jargon) | ✅ Bon libellé (san_copywriter) |
| :--- | :--- | :--- |
| **Ajout au panier** | `Ajouter` / `Submit` | `Ajouter à ma commande (2 500 FCFA)` |
| **Checkout** | `Payer` / `Procéder` | `Valider et payer par MoMo` |
| **Création de compte** | `S'inscrire` / `Envoyer` | `Créer mon compte en 1 minute` |
| **Support client** | `Contact` / `Formulaire` | `Discuter avec un conseiller sur WhatsApp` |
| **Reprise d'erreur** | `Erreur` / `Fermer` | `Réessayer la vérification` |
| **Géolocalisation** | `Partager GPS` | `Utiliser ma position actuelle` |
| **Repère manuel** | `Adresse ligne 2` | `Indiquer un point de repère (marché, pharmacie)` |
