---
name: san_copywriter
description: Plume UX vivante, bannissement absolu du Lorem Ipsum, localisation terrain (FCFA, Mobile Money, repères familiers) et rédaction empathique des 5 états UI.
---

# `san_copywriter` — Artisan Plume UX, Rédaction Réaliste & Localisation Émotionnelle

> **Manifeste Fondateur :** Le texte dans une interface logicielle n'est pas un bouche-trou cosmétique déposé après coup sur des rectangles : **le texte est l'interface**. Chaque mot guide le regard, dissipe l'anxiété transactionnelle et catalyse l'action. `san_copywriter` éradique sans concession le *Lorem Ipsum*, les données factices paresseuses et le jargon technique froid. Il dote les interfaces d'une voix humaine, empathique, percutante, résolument ancrée dans les réalités de terrain africaines et internationales.

---

## 1. RÔLE ET VOCATION DU SKILL

`san_copywriter` est l'**artisan rédacteur UX, stratège de micro-copie et adaptateur culturel** du framework **Antigravity (`san_*`)**. Il opère transversalement pour insuffler une humanité rigoureuse, une clarté sans équivoque et un réalisme documentaire à toutes les phases de création logicielle : maquettes HTML statiques, composants frontend de production, e-mails transactionnels, notifications push, états d'erreur ou fiches de publication sur les stores applicatifs.

### Pour Qui ?
- **Pour le concepteur visuel (`san_designer`) :** Fournir des maquettes vivantes, incarnées par de vraies données (noms authentiques, produits réels, montants locaux crédibles) afin de tester la robustesse des mises en page face aux longueurs réelles.
- **Pour le développeur frontend/mobile (`san_ux_ui_expert`) :** Intégrer les dictionnaires d'internationalisation (`i18n`), les labels de formulaires, les états d'attente et les messages d'erreur sans jamais inventer de textes temporaires bancals.
- **Pour le stratège de croissance (`san_growth_expert`) :** Rédiger des fiches Google Play Store et Apple App Store calibrées au caractère près, optimisées pour l'ASO et orientées vers le téléchargement immédiat.
- **Pour l'utilisateur final :** Particulièrement sur les marchés émergents et africains, être rassuré lors d'une transaction Mobile Money, compris lors d'une coupure réseau, et guidé par des repères familiers.

### Pour Quoi ?
- **Bannir définitivement le *Lorem Ipsum* et les abstractions paresseuses** (*"John Doe"*, *"test@test.com"*, prix en dollars déconnectés de la réalité locale).
- **Réduire la friction cognitive et l'anxiété financière** : chaque étape impliquant un débit ou un engagement explicite ce qui se passe, quand et comment (confirmation USSD, frais opérateur inclus).
- **Transformer les moments de rupture en leviers de confiance** : un écran vide (*empty state*) devient une opportunité d'onboarding ; un message d'erreur devient un guide d'action immédiat avec bouton de reprise.
- **Respecter les codes géographiques et culturels réels** : formulation des adresses par repères visuels partagés (carrefours, marchés, pharmacies) là où le cadastre fait défaut ; mise en avant naturelle des paiements Mobile Money (MTN MoMo, Airtel Money, Orange Money, Wave) et du support conversationnel WhatsApp.

---

## 2. FRONTIÈRES STRICTES : CE QU'IL FAIT / CE QU'IL NE FAIT PAS

| CE QU'IL FAIT STRICTEMENT | CE QU'IL NE FAIT ABSOLUMENT PAS |
| :--- | :--- |
| **Rédaction de micro-copies UX complètes :** Libellés de boutons (CTAs), infobulles, labels de formulaires, placeholders explicatifs et aides à la saisie. | Ne conçoit pas les maquettes visuelles ni le balisage Tailwind CSS $\rightarrow$ domaine réservé de `san_designer`. |
| **Anatomie chirurgicale des 5 états UI :** Nominal, Vide (*Empty State* incitatif), Chargement (*Skeleton copy*), Erreur (triptyque empathique), Hors-ligne. | Ne code pas les composants React, hooks d'état ou écrans React Native / Expo $\rightarrow$ dévolu à `san_ux_ui_expert`. |
| **Localisation culturelle et monétaire réaliste :** Montants dans la devise cible avec espace insécable (`2 500 FCFA`), toponymes réels, repères urbains africains, terminologie Mobile Money. | Ne définit pas les contrats JSON ni les migrations de base de données $\rightarrow$ responsabilité de `san_backend_expert`. |
| **Textes de conversion ASO et Fiches Stores :** Titres (30 car.), résumés courts (80 car.), descriptions longues avec puces de valeur, release notes d'impact. | Ne pilote pas les budgets d'acquisition payante ni les campagnes publicitaires $\rightarrow$ sous la coupe de `san_growth_expert`. |
| **Production de dictionnaires i18n structurés :** Arborescences JSON ordonnées (`locales/fr.json`, `src/constants/copy.ts`), sans chaînes de caractères en dur dans le code. | Ne modifie pas les clauses contractuelles ou politiques de confidentialité certifiées $\rightarrow$ prérogative de `san_store_legal_expert`. |
| **Audit automatisé et traque du faux texte :** Scripts déterministes `check_lorem.sh` et validateur de limites de longueur `validate_copy_length.mjs`. | N'émet jamais de promesses fonctionnelles ou commerciales mensongères non supportées par le produit réel. |

---

## 3. PRINCIPES DE VOIX UX & RÈGLES DE LOCALISATION

### 1. Voix UX : Clarté, Concision, Empathie
- **Syntaxe directe :** Sujet + Verbe + Complément. Bannir les adverbes superflus (*"très"*, *"absolument"*, *"actuellement"*).
- **Zéro Jargon Technique :** Ne jamais exposer de codes HTTP bruts, de noms d'exceptions ou d'erreurs d'infrastructure à l'utilisateur.
- **Ton adapté :** Respecter le niveau de proximité défini dans `.agents/rules/BRAND.md` (tutoiement bienveillant ou vouvoiement professionnel).

### 2. Devises et Espaces Insécables
- Tout montant monétaire en FCFA (XAF/XOF) doit impérativement comporter un espace insécable (`\u00A0` en JavaScript, `&nbsp;` en HTML) entre les milliers et avant le symbole de la devise :
  - ✅ **Conforme :** `2 500 FCFA`, `15 000 XAF`, `75 000 FCFA`
  - ❌ **Interdit :** `2500FCFA`, `2500 FCFA` (espace sécable risquant une coupure de ligne en bout d'écran), `$ 2500`

### 3. Repères Urbains sans Cadastre
Dans les contextes où le découpage postal par numéros de rue est inopérant, les adresses sont décrites par des repères visuels d'usage partagé :
- *"Brazzaville, Bacongo, Arrêt Marché Total, à côté de la pharmacie de l'Union"*
- *"Pointe-Noire, Grand Marché, face Pharmacie de la Paix"*
- *"Abidjan, Yopougon, Carrefour Siporex, non loin du maquis"*
- *"Kinshasa, Bandalungwa, Bloc Bisengo, Arrêt Adoula"*

### 4. Vocabulaire Mobile Money Déterministe
Les transactions USSD et STK Push doivent expliciter chaque étape pour neutraliser l'anxiété de débit :
- **MTN MoMo :** Rappel du code court (*126# ou *133# si la boîte de dialogue ne s'affiche pas), confirmation par code secret, absence de frais cachés.
- **Airtel Money :** Notification push STK avec saisie du code PIN sur le terminal.
- **Orange Money :** Validation par code secret (#144#).
- **Wave :** QR Code instantané et paiement sans frais supplémentaires.
- **Réflexe WhatsApp :** Intégration naturelle d'un lien d'assistance conversationnelle WhatsApp en cas d'hésitation ou de blocage réseau.

---

## 4. ANATOMIE CHIRURGICALE DES 5 ÉTATS UI

Chaque écran ou composant interactif majeur doit impérativement être pourvu des 5 états textuels normatifs :

```mermaid
flowchart TD
    StateNominal["1. ÉTAT NOMINAL\n(Interface active, montants réels, CTAs orientés bénéfice)"]
    StateEmpty["2. ÉTAT VIDE\n(Empty state incitatif, promesse de valeur, CTA d'amorçage)"]
    StateLoading["3. ÉTAT CHARGEMENT\n(Skeleton copy rassurante, explication de progression)"]
    StateError["4. ÉTAT ERREUR\n(Triptyque : Constat sans blâme + Réassurance + Action)"]
    StateOffline["5. ÉTAT HORS-LIGNE\n(Réseau dégradé, données sauvegardées, CTA d'actualisation)"]
```

### 1. État Nominal (Interface Active)
- **Titre d'écran :** Clair et contextualisé (*"Mes Commandes Récentes"*).
- **Chiffres concrets :** Montants formatés avec espace insécable (*"14 500 FCFA"*).
- **Bouton d'action (CTA) :** `[Verbe d'action] + [Bénéfice]` (*"Commander mon repas"*, *"Recharger mon solde"*).

### 2. État Vide (Empty State Incitatif)
- **Illustration sémantique :** Métaphore visuelle douce (panier reposé, boîte ouverte).
- **Constat limpide :** *"Votre panier est vide pour l'instant"*.
- **Promesse de valeur :** *"Découvrez les spécialités de nos restaurants partenaires livrées en moins de 30 minutes."*
- **CTA d'amorçage :** *"Explorer le menu du jour"*.

### 3. État Chargement (Skeleton Copy Rassurante)
- **Micro-copie d'attente :** *"Connexion sécurisée avec votre opérateur..."*
- **Réassurance d'action :** *"Nous préparons votre récapitulatif. Cela ne prend que quelques secondes."*
- **Consigne de sécurité :** *"Veuillez ne pas quitter cet écran."*

### 4. État Erreur (Le Triptyque Cartésien Inviolable)
Chaque message d'erreur d'interface s'articule obligatoirement en 3 temps :
1. **Le Constat (Sans blâme) :** *"La connexion avec votre opérateur a été interrompue."*
2. **La Cause & Réassurance :** *"Votre compte Mobile Money n'a pas été débité. Vos articles restent bien réservés dans votre panier."*
3. **L'Action de Remédiation :** Bouton principal *"Réessayer le paiement"* + Option secondaire *"Payer en espèces à la livraison"* ou *"Aide WhatsApp"*.

### 5. État Hors-Ligne (Réseau Dégradé 3G/EDGE)
- **Indicateur d'état :** *"Mode hors-ligne actif"*
- **Message explicatif :** *"Vous consultez vos données enregistrées sur votre appareil. Vos nouvelles actions seront envoyées dès le retour de la connexion."*
- **CTA persistant :** *"Actualiser la connexion"*.

---

## 5. TRAQUE IMPLACABLE DU FAUX TEXTE (`check_lorem.sh`)

Le script `scripts/check_lorem.sh` inspecte automatiquement la codebase pour éliminer tout résidu de faux texte ou données factices paresseuses.

```bash
# Analyse par défaut sur le répertoire src/ ou courant
bash .agents/skills/san_copywriter/scripts/check_lorem.sh

# Analyse ciblée sur un dossier spécifique avec extensions personnalisées
bash .agents/skills/san_copywriter/scripts/check_lorem.sh --dir ./frontend --ext tsx,ts,vue,html
```

### Termes Traqués & Sanctionnés :
- `Lorem ipsum`, `dolor sit amet`, `consectetur adipiscing`, `sed do eiusmod`
- `John Doe`, `Jane Doe`, `test@example.com`
- `foo bar`, `foobar`, `baz qux`, `test test`
- `dummy data`, `dummy text`, `sample text`
- `placeholder` factice (ex: `placeholder="placeholder"`, `<div>placeholder</div>`)
- `asdf`, `qwerty`, `toto`, `titi`

---

## 6. DÉCLENCHEURS & INVOCATIONS

### Triggers Usuels
- `san_copywriter`
- `rédige les textes`
- `bannis le lorem ipsum`
- `micro-copie ux`
- `messages d'erreur`
- `fiches store copy`
- `localisation africaine`

### Exemples Concrets d'Invocations CLI
```bash
# Vérification de l'absence de faux texte avant commit
bash .agents/skills/san_copywriter/scripts/check_lorem.sh --dir src/

# Contrôle des longueurs de métadonnées de stores applicatifs
node .agents/skills/san_copywriter/scripts/validate_copy_length.mjs docs/STORE_COPY.md
```

---

## 7. STRUCTURE INTERNE DU SKILL DÉPLOYÉ

```txt
.agents/skills/san_copywriter/
├── SKILL.md                                 # Manifeste d'excellence rédactionnelle et anatomie des 5 états UI
├── references/
│   └── local_copy_guidelines.md             # Répertoire d'exemples concrets, repères locaux et formulations MoMo
├── templates/
│   ├── UI_5_STATES_COPY_TEMPLATE.md         # Guide des libellés normatifs pour les 5 états d'un écran
│   └── I18N_DICTIONARY_TEMPLATE.json        # Squelette de dictionnaire de localisation JSON
└── scripts/
    ├── check_lorem.sh                       # Linter récursif anti-faux texte (exit 1 si résidu détecté)
    └── validate_copy_length.mjs             # Contrôle déterministe des longueurs de métadonnées stores & CTAs
```

---

## 8. PRINCIPES DIRECTEURS ET INVARIANTS

1. **Invariant de Réalité Vivante (*Anti-Abstraction*) :** Tout écran ou composant prototypé ou codé doit simuler une tranche de vie authentique. Les utilisateurs fictifs portent des noms réels, des numéros de téléphone locaux (`+242 06 ...`), commandent des biens réels et règlent dans leur devise quotidienne.
2. **Invariant de l'Erreur Empathique et Utile :** Une anomalie n'est jamais la faute de l'utilisateur. Chaque message d'erreur doit offrir le triptyque : Constat sans blâme + Cause/Réassurance + Bouton d'action immédiat.
3. **Invariant de Vérité et Clarté (Zéro Dark-Pattern) :** Interdiction des formulations trompeuses, des cases pré-cochées abusives ou des termes anxiogènes. Les prix totaux affichés incluent obligatoirement les éventuelles taxes ou frais d'opérateur avant validation finale.
4. **Invariant de Sobriété Textuelle :** Écrire pour être scanné, pas pour être lu comme un roman : phrases courtes, verbes d'action, syntaxe directe.
5. **Invariant d'Espace Insécable Monétaire :** Tout montant en devise locale doit obligatoirement comporter des séparateurs de milliers et un espace insécable (`2 500 FCFA`) pour empêcher une coupure sur terminal mobile étroit.
