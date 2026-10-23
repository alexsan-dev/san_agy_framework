# Grilles d'Évaluation & Critères d'Audit `/ux-scan`

Ce document constitue la référence méthodologique absolue pour l'exécution du workflow d'audit **`/ux-scan`** (Étage 2) opéré par les 3 auditeurs cognitifs parallèles (`Model: 'inherit'`) :
1. `ux_psychology_auditor` (Psychologie Cognitive & Lois Ergonomiques)
2. `ux_context_auditor` (Réalité Terrain & Ancrage Local)
3. `ui_design_system_auditor` (Design System, Fidélité BRAND.md & Anti-AI Taste)

---

## 1. FORMULE D'ÉVALUATION ET CONDITIONS D'APPROBATION

Chaque auditeur évalue le mockup sur **10 critères unitaires notés de 0.0 à 10.0**, dégage une **Note Globale /10**, et qualifie chaque défaut selon trois niveaux de sévérité :

* **`BLOQUANT` :** Défaut inacceptable violant l'accessibilité fondamentale, la sécurité ou l'ergonomie critique. **Rejet automatique de la maquette** (`STATUT: REJETÉ`).
* **`MAJEUR` :** Incohérence fonctionnelle ou visuelle importante dégradant significativement l'expérience utilisateur. Doit faire l'objet d'une correction avant transmission à [`san_ux_ui_expert`](../../san_ux_ui_expert/SKILL.md).
* **`MINEUR` :** Ajustement cosmétique ou micro-détail esthétique sans impact critique sur le parcours utilisateur.

### Règle Mathématique de Validation Officielle :
$$\text{Écran Validé (/ux-scan)} \iff \begin{cases} \text{Note}(\texttt{ux\_psychology}) \ge 8.5 / 10 \\ \text{Note}(\texttt{ux\_context}) \ge 8.5 / 10 \\ \text{Note}(\texttt{ui\_design\_system}) \ge 8.5 / 10 \\ \sum \texttt{BLOQUANT} = 0 \end{cases}$$

---

## 2. AUDITEUR 1 : `ux_psychology_auditor`

Cet auditeur analyse la charge cognitive, les lois biomécaniques et les heuristiques psychologiques régissant l'attention et la prise de décision.

### Grille d'Évaluation (10 Critères / 10 Points)

| N° | Critère Ergonomique | Fondement Théorique | Spécifications Requises & Seuils | Statut si Non-Respect |
| :--- | :--- | :--- | :--- | :--- |
| **P1** | **Loi de Hick** (Minimisation du choix) | $T = b \cdot \log_2(n + 1)$ | Nombre d'actions concurrentes principales limité à 1 (ou max 2 avec hiérarchie visuelle marquée). Pas de surcharge d'options au même niveau. | `BLOQUANT` si > 3 CTA concurrents sans hiérarchie. |
| **P2** | **Loi de Fitts** (Cible tactile minimale) | $T = a + b \log_2(1 + \frac{D}{W})$ | Surface cliquable/tactile minimale absolue $\ge 44 \times 44\text{px}$ (`min-h-[44px] min-w-[44px]`). Gutters inter-cibles $\ge 8\text{px}$. | `BLOQUANT` si cible $< 40\text{px}$ ou chevauchement tactile. |
| **P3** | **Zone du Pouce** (Biomécanique) | *Thumb Zone Map* | Actions majeures (soumission, validation, sélection MoMo) situées dans les 40% inférieurs de l'écran. 0 action critique dans les 30% supérieurs. | `BLOQUANT` si CTA principal dans le tiers supérieur. |
| **P4** | **Loi de Miller** (Découpage de l'information) | Empan mnésique $7 \pm 2$ | Regroupement des flux longs (formulaires, listes) en blocs logiques (*chunking*) de 3 à 5 éléments distincts. | `MAJEUR` si liste dense $> 8$ items sans séparation visuelle. |
| **P5** | **Effet de Von Restorff** (Isolation du CTA) | Saillance visuelle | Le bouton d'engagement primaire doit dominer visuellement l'ensemble de la vue par sa couleur, son élévation et sa graisse. | `BLOQUANT` si le CTA est indiscernable des actions secondaires. |
| **P6** | **Loi de Jakob** (Conventions familières) | Modèles mentaux | Utilisation de patterns standards : croix de fermeture en haut à droite, flèche retour en haut à gauche, panier en haut à droite, navigation basse. | `MAJEUR` si inversion contre-intuitive des conventions d'OS. |
| **P7** | **Loi de Proximité** (Gestalt) | Perception groupée | Les libellés d'entrées, aides contextuelles et messages d'erreur sont visuellement plus proches de leur champ associé que de l'élément suivant. | `MINEUR` ou `MAJEUR` si ambiguïté d'association. |
| **P8** | **Clarté du Statut Système** (Nielsen #1) | Rétroaction immédiate | Indicateur clair de l'état en cours (badge de sécurité, barre de progression, étape 2 sur 3, statut de connexion). | `MAJEUR` si l'utilisateur ne sait pas où il se trouve. |
| **P9** | **Prévention des Erreurs Involontaires** | Double validation | Présence d'un récapitulatif clair avant toute opération monétaire irréversible. Boutons destructeurs visuellement différenciés. | `BLOQUANT` si débit financier direct sans écran de confirmation. |
| **P10**| **Hiérarchie Typographique & Scannabilité** | F-Shaped reading | Distinction immédiate H1 > H2 > Corps > Légende. Lecture en diagonale efficace en moins de 3 secondes. | `MAJEUR` si 3 tailles de police différentes partagent la même graisse. |

---

## 3. AUDITEUR 2 : `ux_context_auditor`

Cet auditeur passe l'interface au crible des conditions d'usage réelles : forte luminosité solaire, dégradation réseau, équipements d'entrée/milieu de gamme et ancrage socio-économique en Afrique subsaharienne.

### Grille d'Évaluation (10 Critères / 10 Points)

| N° | Critère de Contexte | Réalité Physique & Terrain | Spécifications Requises & Seuils | Statut si Non-Respect |
| :--- | :--- | :--- | :--- | :--- |
| **C1** | **Contraste Plein Soleil** (WCAG AAA) | Éclairage ambiant $> 10\,000\text{ lux}$ | Ratio de contraste $CR \ge 7.0:1$ sur tous les textes critiques, montants et boutons. Bannissement des gris clairs (`#9ca3af`, `#d1d5db`). | `BLOQUANT` si $CR < 7:1$ sur textes critiques ou CTA. |
| **C2** | **Lisibilité Reflets Écran** | Écrans LCD / Dalles brillantes | Fonds suffisamment sombres ou très contrastés pour neutraliser les reflets parasites en extérieur. Pas de pastel sur fond blanc pur. | `MAJEUR` si contraste général faible face aux reflets. |
| **C3** | **Montants Monétaires en FCFA Réels** | Clarté financière | Montants obligatoirement libellés avec espace insécable et unité explicite (ex: `25 000 FCFA` ou `1 500 XAF`). Zéro symbole `$`, `€` ou chiffres fantaisistes. | `BLOQUANT` si devise étrangère ou format non africain. |
| **C4** | **Flux Mobile Money Natif** | MTN MoMo / Airtel Money / Orange | Interface intégrant directement les logos, couleurs et flux opérateurs familiers (jaune MoMo, rouge Airtel, orange). Formulaire numéro adapté (+242, +237, +225). | `BLOQUANT` si carte bancaire imposée seule sans Mobile Money. |
| **C5** | **Repères Urbains Authentiques** | Adressage local informel | Données d'exemple basées sur des repères réels (*« Face Station Total Mikalou, Brazzaville »*, *« Carrefour Kébi, Pointe-Noire »*) et non des adresses de type *« 123 Rue de Paris »*. | `MAJEUR` si utilisation de fausses adresses occidentales. |
| **C6** | **Noms et Identités Réalistes** | Ancrage culturel | Patronymes et prénoms locaux authentiques (*« Alain Ngoma »*, *« Grâce Moukoko »*), zéro stéréotype et zéro *John Doe*. | `MAJEUR` si texte générique anglophone ou fictif. |
| **C7** | **Sobriété DOM & Poids Réseau 3G** | Bande passante limitée / EDGE | Structure HTML/Tailwind légère, aucune image décorative lourde non optimisée. Icônes en SVG inline ultra-compacts. | `MAJEUR` si image bitmap $> 100\text{ Ko}$ pour du simple décor. |
| **C8** | **Densité d'Écran sur Écrans Étroits** | Tailles d'écran 360px - 390px | Mise en page fluide sans débordement horizontal (`overflow-x-hidden`), textes qui ne tronquent pas les montants clés. | `BLOQUANT` si scroll horizontal indésirable. |
| **C9** | **Indication de Connectivité & Mode Hors-ligne** | Réseau intermittent | Présence visible d'un indicateur de statut réseau ou d'un bandeau d'avertissement de travail hors-ligne. | `MAJEUR` si aucune gestion visible de la perte de réseau. |
| **C10**| **Micro-Copies Françaises & Locales Précises** | Clarté linguistique | Français simple, chaleureux, direct, sans jargon technique incompréhensible ni tournures alambiquées. | `MAJEUR` si messages système bruts en anglais (*Failed to fetch*). |

---

## 4. AUDITEUR 3 : `ui_design_system_auditor`

Cet auditeur audite la pureté stylistique, le respect absolu de `.agents/rules/BRAND.md`, la vivacité de la signature cinétique et la destruction systématique des tics visuels « générés par IA ».

### Grille d'Évaluation (10 Critères / 10 Points)

| N° | Critère de Craft Visuel | Norme de Référence | Spécifications Requises & Seuils | Statut si Non-Respect |
| :--- | :--- | :--- | :--- | :--- |
| **D1** | **Conformité Stricte aux Tokens BRAND.md** | `.agents/rules/BRAND.md` | Toutes les couleurs, typographies, élévations et rayons proviennent de la palette officielle. Zéro code hexadécimal arbitraire inventé. | `BLOQUANT` si utilisation de couleurs hors palette. |
| **D2** | **Autonomie Totale Zéro CDN** | Sécurité & Déterminisme | Zéro balise `<link>` ou `<script>` pointant vers un CDN tiers (`cdn.tailwindcss.com`, `googleapis.com`, `cdnjs`). Styles locaux ou compilés. | `BLOQUANT` si présence d'un CDN externe. |
| **D3** | **Polices Locales Embarquées** | Rendu déterministe | `@font-face` pointant vers des fichiers locaux (`.woff2`) ou fontes système universelles (`system-ui`, `-apple-system`). | `BLOQUANT` si appel à Google Fonts distant. |
| **D4** | **Traque Anti-AI Taste : Grilles 3 Cartes** | Singularité artistique | Interdiction des 3 cartes identiques monochromes avec icône pastel centrée. Organisation asymétrique, hiérarchique et vivante. | `MAJEUR` si présence d'un cliché de layout IA. |
| **D5** | **Traque Anti-AI Taste : Dégradés Néon** | Cohérence esthétique | Interdiction formelle des dégradés violets/bleus saturés plaqués sans justification sur fond noir absolu. | `BLOQUANT` si dégradé IA stéréotypé non prévu par BRAND.md. |
| **D6** | **Signature Cinétique & Micro-Interactions** | Dynamique physique | Présence systématique des classes d'état interactives : `:hover`, `:active`, `active:scale-[0.98]`, transitions douces $\le 250\text{ms}$. | `MAJEUR` si boutons totalement statiques et inertes. |
| **D7** | **Cohérence des Rayons de Courbure (Radii)** | Harmonie spatiale | Utilisation consistante de l'échelle des rayons (ex: conteneurs `rounded-2xl`, boutons `rounded-xl`, badges `rounded-full`). | `MINEUR` si mélange désordonné de rayons. |
| **D8** | **Élévations & Ombres Portées** | Profondeur contrôlée | Ombres douces teintées de la couleur de fond ou de marque (`shadow-lg shadow-amber-500/20`), jamais d'ombres noires opaques sales (`rgba(0,0,0,0.8)`). | `MAJEUR` si ombres agressives ou déconnectées du fond. |
| **D9** | **Qualité & Précision des Tracés SVG** | Nettoyage vectoriel | Icônes SVG avec `stroke-width` uniforme, `fill="none"` ou `currentColor`, `viewBox="0 0 24 24"`, parfaitement alignées sur la grille 24px. | `MINEUR` si tracé déformé ou non responsive. |
| **D10**| **Conformité aux Métadonnées CANVAS_SPEC** | Pipeline d'export | Présence exacte en en-tête du tag `<!-- CANVAS_SPEC: width=... height=... device="..." export_scale=... -->`. | `BLOQUANT` si tag absent ou résolutions fantaisistes. |

---

## 5. MODÈLE TYPE DE RAPPORT D'AUDIT `/ux-scan`

Ce rapport est automatiquement émis par l'orchestrateur `/ux-scan` à l'issue de l'analyse :

```markdown
# Rapport d'Audit Consolidé `/ux-scan` : [Nom du Fichier]
Date : 2026-10-23 | Canvas : 390×844 (Mobile) | Itération : 1/5

## Synthèse des Scores
* **Psychologie Cognitive (ux_psychology_auditor) :** 9.2 / 10 ✅
* **Contexte & Réalité Terrain (ux_context_auditor) :** 8.8 / 10 ✅
* **Design System & Craft UI (ui_design_system_auditor) :** 9.0 / 10 ✅
* **Nombre d'anomalies BLOQUANTES :** 0
* **Nombre d'anomalies MAJEURES :** 1
* **Nombre d'anomalies MINEURES :** 2

## Verdict Global : [APPROUVÉ POUR INTÉGRATION | REJETÉ POUR CORRECTION]

### Détail des Constats
1. **[MAJEUR] ux_context_auditor (C1) :** Le libellé secondaire « Frais d'opérateur inclus » a un contraste de 4.8:1, insuffisant pour le plein soleil (> 7:1 requis). Remplacer `text-slate-400` par `text-slate-200`.
2. **[MINEUR] ui_design_system_auditor (D7) :** Le badge MoMo utilise `rounded-lg` alors que la spécification BRAND.md préconise `rounded-xl`.
```
