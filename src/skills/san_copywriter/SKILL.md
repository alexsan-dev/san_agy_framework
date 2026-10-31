---
name: san_copywriter
description: Déclenché quand l'utilisateur souhaite rédiger des micro-copies UX percutantes, bannir le Lorem Ipsum, concevoir les textes empathiques des 5 états UI ou localiser le vocabulaire transactionnel (FCFA, Mobile Money).
---

# `san_copywriter` — Runbook de Rédaction UX, Micro-Copie & Localisation Réaliste

Protocole de micro-copie et de conception éditoriale pour interfaces Web et Mobiles. Éradique le *Lorem Ipsum*, les abstractions paresseuses (*"John Doe"*, prix factices) et dote les interfaces d'une voix humaine, empathique et culturellement ancrée.

---

## 1. RÈGLES D'OR DE LA PLUME UX v2.0

1. **Le Texte est l'Interface :** Pas de bouche-trou cosmétique. Chaque mot dissipe l'anxiété transactionnelle et catalyse l'action.
2. **Éradication Totale du Lorem Ipsum :** Zéro faux texte, zéro placeholder générique. Données réalistes et prix authentiques dans la devise cible (`2 500 FCFA` avec espace insécable `\u00A0`).
3. **Le Triptyque Cartésien de l'Erreur :** Constat sans blâme + Cause/Réassurance + Action de remédiation immédiate.
4. **Ancrage Culturel et Réalités de Terrain :** Terminologie Mobile Money explicite (MTN MoMo, Airtel Money), repères visuels urbains partagés et assistance WhatsApp.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Audit et Chasse au Faux Texte (`check_lorem.sh`)
- Lancer le linter déterministe pour débusquer tout texte factice ou placeholder paresseux :
  ```bash
  bash .agents/skills/san_copywriter/scripts/check_lorem.sh --dir src/
  ```
- Sanctionner impitoyablement les occurrences de `lorem ipsum`, `dolor sit amet`, `john doe`, `foo bar`, `test test`.

### Étape 2 : Rédaction Complète des 5 États UI
- Pour chaque écran ou composant interactif majeur, appliquer le gabarit [UI_5_STATES_COPY_TEMPLATE.md](templates/UI_5_STATES_COPY_TEMPLATE.md) :
  1. **État Nominal :** Titre contextualisé, données chiffrées concrètes, CTA `[Verbe d'action] + [Bénéfice]`.
  2. **État Vide (*Empty State*) :** Constat doux, promesse de valeur et CTA d'amorçage.
  3. **État Chargement (*Skeleton Copy*) :** Micro-copie d'attente rassurante sans masquer l'état précédent (*Stale-While-Revalidate*).
  4. **État Erreur :** Triptyque bienveillant sans blâmer l'utilisateur, avec bouton de réessai.
  5. **État Hors-Ligne :** Notification de mode hors-ligne, données locales conservées et CTA de reconnexion.

### Étape 3 : Localisation Monétaire & Repères Urbains
- Respecter scrupuleusement les conventions du guide [Lignes Directrices de Localisation](references/local_copy_guidelines.md) :
  - Espaces insécables obligatoires avant et entre les milliers des devises locales (`2 500 FCFA`, `10 000 XAF`).
  - Adresses basées sur des repères visuels partagés (marchés, carrefours, pharmacies).
  - Instructions de confirmation claires pour les flux USSD et STK Push.

### Étape 4 : Calibrage Physique des Textes & Stores (ASO)
- Valider le respect strict des limites de caractères sur les métadonnées de stores :
  ```bash
  node .agents/skills/san_copywriter/scripts/validate_copy_length.mjs docs/STORE_LISTING.md
  ```
- Titre ($\le 30$ car.), sous-titre ($\le 30$ ou $\le 80$ car.), puces bénéfices structurées.

### Étape 5 : Extraction et Dictionnaires i18n
- Structurer les clés de traduction selon [I18N_DICTIONARY_TEMPLATE.json](templates/I18N_DICTIONARY_TEMPLATE.json) dans `locales/fr.json` ou `src/constants/copy.ts`.
- Bannir toute chaîne de caractères en dur non internationalisée dans les composants frontend de [san_ux_ui_expert](../san_ux_ui_expert/SKILL.md).

---

## 3. RESSOURCES DU SKILL

- **Scripts Déterministes :**
  - [scripts/check_lorem.sh](scripts/check_lorem.sh) : Linter récursif anti-faux texte (exit 1 si anomalie).
  - [scripts/validate_copy_length.mjs](scripts/validate_copy_length.mjs) : Contrôle des longueurs de caractères stores et boutons.
- **Modèles et Dictionnaires :**
  - [templates/UI_5_STATES_COPY_TEMPLATE.md](templates/UI_5_STATES_COPY_TEMPLATE.md) : Gabarit des 5 états textuels normatifs.
  - [templates/I18N_DICTIONARY_TEMPLATE.json](templates/I18N_DICTIONARY_TEMPLATE.json) : Squelette de dictionnaire de localisation i18n.
- **Guides de Référence :**
  - [references/local_copy_guidelines.md](references/local_copy_guidelines.md) : Formulations locales, vocabulaire Mobile Money et toponymes.
