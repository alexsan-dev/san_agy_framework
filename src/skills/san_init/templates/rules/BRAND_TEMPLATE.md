# CHARTE DE MARQUE, DIRECTION ARTISTIQUE & MOTION (`BRAND.md`)

> **Règle absolue :** Zéro composant générique « AI template ». L'interface doit posséder une âme, une tension graphique assumée, une lisibilité irréprochable et un système cinétique maîtrisé à 60 fps.

---

## 1. MANIFESTE SENSORIEL & ÂME DE MARQUE

* **Nom de Marque / Projet :** `[NOM_PROJET]`
* **Émotion Brute Voulue :** `[Ex: Confiance bancaire inébranlable, précision chirurgicale d'ingénierie, sobriété statutaire]`
* **Archétype Visuel :** `[Ex: Néo-brutalisme fonctionnel / Minimalisme High-Tech / FinTech feutrée]`
* **Ambiance Lumineuse par Défaut :** `[Dark Mode Natif / Light Mode Neutre / Hybride selon préférence système]`

### Directives Strictes Anti-AI Taste (Tolérance Zéro)
Toute contribution graphique ou composant UI enfreignant ces règles sera immédiatement rejeté :
1. **INTERDICTION des dégradés violets / indigo / magenta génériques :** Proscription formelle des fonds de cartes « néon violet » stéréotypés des générateurs d'interfaces IA.
2. **INTERDICTION des bordures luminescentes « glow » gratuites :** Pas de pseudo-effets cybernétiques sans état fonctionnel explicite (focus, alerte active).
3. **INTERDICTION des illustrations 3D molles :** Bannir les visuels 3D en pâte à modeler, les mascottes amorphes et les illustrations génériques de banques d'images.
4. **INTERDICTION du faux texte « Lorem Ipsum » :** Tous les mockups, prototypes et tests doivent utiliser des données réelles, des noms réalistes, des numéros de téléphone et des montants monétaires contextualisés.
5. **INTERDICTION de la surcharge d'élévation :** Pas de couches infinies d'ombres floues. Les hiérarchies visuelles se construisent en priorité par les contrastes de surfaces et la typographie.

---

## 2. DESIGN TOKENS CHROMATIQUES

### Palette Chromatique Maîtresse (Sémantique & Hexadécimale)

| Jeton (Token) | Mode Sombre (Dark) | Mode Clair (Light) | Rôle & Usage Sémantique |
| :--- | :--- | :--- | :--- |
| `color-primary` | `#[HEX_PRIMAIRE_DARK]` | `#[HEX_PRIMAIRE_LIGHT]` | Identité forte de la marque, boutons d'action clés (CTA). |
| `color-primary-hover` | `#[HEX_PRIMAIRE_HOVER_DARK]` | `#[HEX_PRIMAIRE_HOVER_LIGHT]` | État survol / pression sur action principale. |
| `color-surface` | `#0B0F19` | `#FFFFFF` | Surface des cartes, modales, panneaux et conteneurs. |
| `color-surface-subtle` | `#111827` | `#F8FAFC` | Fonds alternés, tables, champs de formulaire inactifs. |
| `color-background` | `#030712` | `#F1F5F9` | Toile de fond globale de l'application. |
| `color-on-surface` | `#F9FAFB` | `#0F172A` | Texte principal, titres, icônes dominantes (contraste > 7:1). |
| `color-on-surface-muted`| `#9CA3AF` | `#64748B` | Légendes, labels secondaires, métadonnées horodatées. |
| `color-border` | `#1F2937` | `#E2E8F0` | Délimitation subtile des composants et diviseurs de listes. |
| `color-border-focus` | `#[HEX_ACCENT]` | `#[HEX_ACCENT]` | Anneau d'accessibilité et focus clavier (outline 2px). |
| `color-accent` | `#[HEX_ACCENT]` | `#[HEX_ACCENT]` | Éléments d'accroche, badges spéciaux, sélections actives. |
| `color-success` | `#10B981` | `#059669` | Validation, transferts réussis, statut en ligne, soldes positifs. |
| `color-warning` | `#F59E0B` | `#D97706` | Alertes préventives, solde faible, délai d'attente réseau. |
| `color-error` | `#EF4444` | `#DC2626` | Échecs critiques, rejet de transaction, erreurs de saisie. |
| `color-info` | `#3B82F6` | `#2563EB` | Informations système, statuts neutres en transit. |

---

## 3. TYPOGRAPHIE & RYTHME VISUEL

### Familles Typographiques Normalisées
* **Titrages & Accroches (Display / Heading) :** `[Nom_Police_Display]`, `Inter`, `-apple-system`, `sans-serif`
* **Texte Courant & Interface (Body / UI) :** `Inter`, `-apple-system`, `BlinkMacSystemFont`, `sans-serif`
* **Chiffres, Code & Données Tabulaires (Mono / Numeric) :** `JetBrains Mono`, `ui-monospace`, `SFMono-Regular`, `monospace`

### Échelle Typographique Déterministe

| Nom du Token | Taille (rem / px) | Hauteur de Ligne (Leading) | Graisse (Weight) | Usage Recommandé |
| :--- | :--- | :--- | :--- | :--- |
| `text-xs` | `0.75rem` (12px) | `1.00rem` (16px) | `400` / `500` | Badges, micro-horodatages, mentions légales |
| `text-sm` | `0.875rem` (14px) | `1.25rem` (20px) | `400` / `500` | Labels de formulaires, textes secondaires, infobulles |
| `text-base` | `1.00rem` (16px) | `1.50rem` (24px) | `400` / `500` | Corps de texte standard, saisies utilisateur |
| `text-lg` | `1.125rem` (18px) | `1.75rem` (28px) | `500` / `600` | Sous-titres de cartes, boutons d'action majeurs |
| `text-xl` | `1.25rem` (20px) | `1.75rem` (28px) | `600` / `700` | Titres de sections, totaux de paniers / soldes |
| `text-2xl` | `1.50rem` (24px) | `2.00rem` (32px) | `600` / `700` | Titres de modales, headers d'écrans mobiles |
| `text-3xl` | `1.875rem` (30px) | `2.25rem` (36px) | `700` | En-têtes de tableaux de bord, soldes géants |
| `text-4xl` | `2.25rem` (36px) | `2.50rem` (40px) | `800` | Chiffres d'impact, landing hero display |

### Règle Impérative des Données Tabulaires
> Tout montant financier (FCFA, XAF, EUR, USD), compteur numérique, chronomètre ou ligne de solde **DOIT OBLIGATOIREMENT** appliquer la propriété :
> ```css
> font-variant-numeric: tabular-nums;
> ```
> Ceci empêche le sautillement horizontal lors des mises à jour incrémentales de valeurs.

---

## 4. GRILLE D'ESPACEMENT & GÉOMÉTRIE (GRID 4PX / 8PX)

L'ensemble des marges (`margin`), espacements internes (`padding`) et gouttières (`gap`) dérive d'une base absolue de **4px** :

* `space-1` : `4px` (`0.25rem`) — Micro-espacement icône/texte
* `space-2` : `8px` (`0.50rem`) — Espacement interne compact (pills, badges)
* `space-3` : `12px` (`0.75rem`) — Gouttière interne d'input ou bouton compact
* `space-4` : `16px` (`1.00rem`) — Padding par défaut des conteneurs, inputs et cartes mobiles
* `space-5` : `20px` (`1.25rem`) — Séparation intermédiaire entre sous-blocs
* `space-6` : `24px` (`1.50rem`) — Padding standard de carte desktop ou modale
* `space-8` : `32px` (`2.00rem`) — Espacement entre sections majeures
* `space-10` : `40px` (`2.50rem`) — Marge de respiration desktop
* `space-12` : `48px` (`3.00rem`) — En-têtes de pages
* `space-16` : `64px` (`4.00rem`) — Ruptures thématiques fortes

### Rayons de Courbure (Border Radius)
* `radius-none` : `0px` — Éléments bruts, dividers
* `radius-sm` : `4px` — Badges, micro-étiquettes, infobulles
* `radius-md` : `8px` — Champs de saisie (inputs), boutons secondaires
* `radius-lg` : `12px` — Boutons primaires, cartes moyennes
* `radius-xl` : `16px` — Grandes cartes, modales, bottom sheets mobiles
* `radius-full` : `9999px` — Boutons ronds, avatars circulaires, capsules de statut

### Système d'Ombres & Élévation (Elevation Hierarchy)
* **Élévation 0 (À plat) :** `none` (Fonds de page, cartes en ligne)
* **Élévation 1 (Cartes au repos) :**
  - Sombre : `0 1px 3px 0 rgba(0, 0, 0, 0.4), 0 1px 2px -1px rgba(0, 0, 0, 0.4)`
  - Clair : `0 1px 3px 0 rgba(0, 0, 0, 0.08), 0 1px 2px -1px rgba(0, 0, 0, 0.04)`
* **Élévation 2 (Menus déroulants / Popovers / Cartes actives) :**
  - Sombre : `0 4px 6px -1px rgba(0, 0, 0, 0.5), 0 2px 4px -2px rgba(0, 0, 0, 0.5)`
  - Clair : `0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.06)`
* **Élévation 3 (Modales / Dialogues / Drawers) :**
  - Sombre : `0 20px 25px -5px rgba(0, 0, 0, 0.6), 0 8px 10px -6px rgba(0, 0, 0, 0.6)`
  - Clair : `0 20px 25px -5px rgba(0, 0, 0, 0.15), 0 8px 10px -6px rgba(0, 0, 0, 0.1)`

---

## 5. SYSTÈME CINÉTIQUE, RETOUR HAPTIQUE & MOTION 60 FPS

Le mouvement n'est pas un ornement cosmétique : il communique la physique du système et oriente le regard utilisateur.

### Courbes de Bézier Standardisées
* **Accélération Entrante (Ease-In) :** `cubic-bezier(0.4, 0.0, 1.0, 1.0)` — Sortie d'éléments
* **Décélération Douce (Ease-Out) :** `cubic-bezier(0.0, 0.0, 0.2, 1.0)` — Arrivée d'éléments
* **Mouvement Maître Fluide (Ease-In-Out) :** `cubic-bezier(0.16, 1.0, 0.3, 1.0)` — Déplacements et ouvertures
* **Ressort Amorti (Spring Micro-Physics) :** `cubic-bezier(0.34, 1.56, 0.64, 1.0)` — Toggles, succès, rebonds d'actions

### Échelle des Durées (Timing Scale)
* **Micro-interactions (Hover, Active, Switch) :** `100ms - 150ms`
* **Transitions Locales (Accordéon, Tooltip, Dropdown) :** `180ms - 220ms`
* **Conteneurs Majeurs (Modale, Bottom Sheet, Toast) :** `220ms - 260ms`
* **Changements d'Écran / Navigation de Vue :** `280ms - 300ms max`

### Contrat Strict de Performance 60 FPS
* **Propriétés Animables Autorisées :** Strictement restreintes à `transform` et `opacity`.
* **Propriétés Interdites en Animation :** Interdiction absolue d'animer `width`, `height`, `margin`, `padding`, `top`, `left`, `bottom`, `right`. Ces attributs déclenchent des recalculs de géométrie (reflow / layout thrashing) et détruisent la fluidité sur smartphones modestes.
* **Propriété `will-change` :** À utiliser avec parcimonie sur les éléments en cours de translation pour forcer la promotion sur le GPU compositeur.

### Retours Haptiques Mobiles (Vibration API / Native Haptics)
Pour les applications mobiles (React Native, Expo, PWA) :
* **Tap Standard (Bouton, Tab) :** `HapticFeedback.lightImpact()` (ou vibration 10ms)
* **Action Réversible (Toggle, Checkbox) :** `HapticFeedback.selection()`
* **Validation Critique (Paiement confirmé, Succès) :** `HapticFeedback.notificationAsync('success')`
* **Rejet / Erreur de saisie :** `HapticFeedback.notificationAsync('error')` (triple pulsation 30ms/50ms/30ms)
