---
trigger: glob
globs: "*.tsx, *.jsx, *.vue, *.svelte, *.html, *.css, *.scss, *tailwind*"
description: "UI design tokens, artistic direction archetype, typography tension, non-destructive 5 UI states, A11y, and 60fps motion."
---
# CHARTE DE MARQUE, DIRECTION ARTISTIQUE & MOTION (`BRAND.md`)

> **Règle absolue :** Zéro composant générique « AI template ». L'interface doit posséder une âme, une tension graphique assumée, une lisibilité irréprochable et un système cinétique maîtrisé à 60 fps.

---

## 1. ARCHÉTYPE ESTHÉTIQUE & MANIFESTE SENSORIEL

Pour briser la monotonie du cliché universel « Dark Slate-900 + Ambre », chaque projet sélectionne formellement son **Archétype Esthétique Maître** :

* **ARCHÉTYPE ACTIF :** `[Minimalist Swiss | Neo-Brutalist | Editorial Warm | Cyber Linear | High-Density Enterprise | Craft Custom]`

### Répertoire des Archétypes Esthétiques :
1. **Minimalist Swiss :** Grille rigoureuse, palette monochrome pure (noir/blanc/gris neutre) relevée d'un accent franc (bleu outremer ou rouge signalétique), typographie néo-grotesque à fort contraste d'échelle, zéro ornement superflu.
2. **Neo-Brutalist :** Bordures noires franches (`border-2 border-black`), ombres portées nettes et décalées sans flou (`shadow-[4px_4px_0px_0px_#000]`), aplats chromatiques vifs, typographie condensée percutante, boutons tactiles affirmés.
3. **Editorial Warm :** Surfaces crème et papier chaud (`#FDFBF7`, `#1A1816`), typographie avec empattements (Serif de prestige) pour les titrages et Sans-Serif humaniste pour le corps, teintes terreuses, olive ou bordeaux, respiration spatiale généreuse.
4. **Cyber Linear :** Fond sombre technique (`#0A0D14`), micro-surfaces aux contours subtils (1px semi-transparent), accents ciblés haute intensité (cyan, vert électrique), typographie monospace pour les métriques, esprit tableau de bord d'ingénierie.
5. **High-Density Enterprise :** Composants ultra-compacts, disposition pensée pour la densité d'information, contrastes de données optimaux, micro-étiquettes en majuscules discrètes, teintes grises feutrées, navigation rapide au clavier.
6. **Craft Custom :** Identité sur mesure documentée dans la palette ci-dessous.

### Directives Strictes Anti-AI Taste (Tolérance Zéro)
1. **INTERDICTION des dégradés violets / indigo génériques :** Proscription formelle des cartes néon violet stéréotypées.
2. **INTERDICTION des bordures luminescentes « glow » gratuites :** Pas d'effets cybernétiques sans état fonctionnel actif.
3. **INTERDICTION des illustrations 3D molles :** Bannir les visuels 3D en pâte à modeler et illustrations génériques.
4. **INTERDICTION du faux texte « Lorem Ipsum » :** Données, noms et chiffres réalistes obligatoires.
5. **INTERDICTION de `select-none` global sur `<body>` :** Le texte doit rester sélectionnable par l'utilisateur.
6. **INTERDICTION de la surcharge d'élévation :** Privilégier les contrastes de surfaces et la typographie aux ombres floues superposées.

---

## 2. DESIGN TOKENS CHROMATIQUES

| Jeton (Token) | Mode Sombre (Dark) | Mode Clair (Light) | Rôle & Usage Sémantique |
| :--- | :--- | :--- | :--- |
| `color-primary` | `#[HEX_PRIMAIRE_DARK]` | `#[HEX_PRIMAIRE_LIGHT]` | Identité maîtresse, boutons d'action clés (CTA). |
| `color-primary-hover` | `#[HEX_PRIMAIRE_HOVER_DARK]` | `#[HEX_PRIMAIRE_HOVER_LIGHT]` | État survol / pression sur action principale. |
| `color-surface` | `#0B0F19` | `#FFFFFF` | Cartes, modales, panneaux et conteneurs. |
| `color-surface-subtle` | `#111827` | `#F8FAFC` | Fonds alternés, tables, champs inactifs. |
| `color-background` | `#030712` | `#F1F5F9` | Toile de fond globale de l'application. |
| `color-on-surface` | `#F9FAFB` | `#0F172A` | Texte principal, titres (contraste > 7:1). |
| `color-on-surface-muted`| `#9CA3AF` | `#64748B` | Légendes, labels secondaires, métadonnées. |
| `color-border` | `#1F2937` | `#E2E8F0` | Délimitation subtile des composants. |
| `color-border-focus` | `#[HEX_ACCENT]` | `#[HEX_ACCENT]` | Anneau d'accessibilité (`focus-visible:ring-2`). |
| `color-accent` | `#[HEX_ACCENT]` | `#[HEX_ACCENT]` | Badges spéciaux, sélections actives. |
| `color-success` | `#10B981` | `#059669` | Succès, opérations validées, statuts actifs. |
| `color-warning` | `#F59E0B` | `#D97706` | Alertes préventives, attentes réseau. |
| `color-error` | `#EF4444` | `#DC2626` | Échecs critiques, rejet, erreurs de saisie. |
| `color-info` | `#3B82F6` | `#2563EB` | Informations système, statuts neutres. |

---

## 3. TYPOGRAPHIE & TENSION VISUELLE

### Familles Typographiques Normalisées
* **Titrages & Accroches (Display) :** `[Police_Display]`, `Inter`, `-apple-system`, `sans-serif`
* **Texte Courant & Interface (Body / UI) :** `Inter`, `-apple-system`, `BlinkMacSystemFont`, `sans-serif`
* **Chiffres, Code & Données (Mono / Numeric) :** `JetBrains Mono`, `ui-monospace`, `SFMono-Regular`, `monospace`

### Règle d'Or des Données Tabulaires
> Tout montant financier, compteur numérique, chronomètre ou solde **DOIT APPLIQUER OBLIGATOIREMENT** :
> ```css
> font-variant-numeric: tabular-nums;
> ```
> Ceci prévient le tremblement horizontal lors des mises à jour incrémentales.

---

## 4. CHORÉGRAPHIE NON-DESTRUCTIVE DES 5 ÉTATS UI (*STALE-WHILE-REVALIDATE*)

Pour offrir une expérience fluide sans saccade visuelle :

1. **État Idéal :** Disposition stable avec hiérarchie claire en 3 plans (Héro, Données, Silencieux).
2. **État Vide :** Message empathique orienté action avec bouton d'amorce immédiat.
3. **État de Chargement Non-Destructif :**
   - Interdiction formelle du `if (loading) return <Skeleton/>` destructeur lors d'un refetch ou changement de filtre.
   - Les données précédentes restent visibles avec un indicateur discret de chargement (*Stale-While-Revalidate*).
   - Les squelettes initiaux respectent rigoureusement les dimensions finales du contenu.
4. **État d'Erreur Actionnable :** Bannière ou toast explicite avec action « Réessayer », sans masquer les données déjà présentes en mémoire.
5. **État Hors-Ligne :** Badge visuel rassurant indiquant la date de dernière synchronisation.

---

## 5. ACCESSIBILITÉ (A11Y) & INTERACTIONS CLAVIER

* **Focus Clavier Obligatoire :** Tous les éléments interactifs disposent d'un anneau visible `focus-visible:ring-2 focus-visible:ring-offset-2`.
* **Sémantique Native :** Interdiction des `<div onClick="...">` sans `role="button"` ni `tabIndex={0}`. Privilégier les éléments `<button>` natifs.
* **Cibles Tactiles Mobiles :** Dimensions minimales de `44 x 44 px` pour tout bouton interactif.

---

## 6. SYSTÈME CINÉTIQUE & MOTION 60 FPS

* **Propriétés Animables Autorisées :** Strictement restreintes à `transform` et `opacity`.
* **Propriétés Proscrites en Animation :** Interdiction d'animer `width`, `height`, `margin`, `padding`, `top`, `left` (causes majeures de saccades et layout thrashing).
* **Durées Standards :** Micro-interactions $100\text{ms} - 150\text{ms}$ ; transitions modales/volets $200\text{ms} - 260\text{ms}$.
