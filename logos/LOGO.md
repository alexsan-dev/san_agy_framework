# CHARTE VISUELLE DU LOGO — `san_ai_harness`

> **Identité :** Harnais d'orchestration Dual-Engine (**Google Antigravity** + **OpenCode v2.3**) par Alexsan.pro.
> **Source de vérité :** Répertoire `/logos/` à la racine de la codebase.

---

## 1. CONCEPT & SYMBOLE « S-H » HARNESS

Fini l'ancien prisme hexagonal Antigravity : **`san_ai_harness`** adopte une signature géométrique **Swiss Precision** :

1. **Monogramme « S-H » à Rails Parallèles :** Deux rails verticaux formant un **H** (Dual-Harness : Antigravity + OpenCode) traversés par une épine dorsale **S** imbriquée (`SAN`).
2. **Verrou Mécanique Signal Orange :** Barre centrale géométrique avec pion de verrouillage carré centré (`8×8`), symbolisant la discipline d'orchestration sans lourdeur.
3. **Zéro dégradé AI générique :** Palette brute sans violet ni indigo néon.

---

## 2. PALETTE ADAPTATIVE SOMBRE / CLAIR (GITHUB THEME)

| Rôle Graphique | Mode Sombre (`_dark.svg`) | Mode Clair (`_light.svg`) |
| :--- | :--- | :--- |
| **Épine S & Wordmark** | `#FAFAFA` *(Pure Snow)* | `#09090B` *(Carbon Black)* |
| **Rails Secondaires H** | `#52525B` *(Zinc Steel)* | `#A1A1AA` *(Brushed Aluminium)* |
| **Verrou Central & Underscores `_`** | `#F97316` *(Signal Orange)* | `#EA580C` *(Signal Burnt)* |
| **Pion de Verrouillage** | `#0D1117` *(GitHub Dark)* | `#FFFFFF` *(Pure White)* |
| **Filet Technique & Sous-titre** | `#27272A` / `#A1A1AA` | `#E4E4E7` / `#52525B` |

Usage adaptatif natif GitHub (`README.md` & `README.en.md`) :

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="logos/san_harness_logo_dark.svg"/>
  <source media="(prefers-color-scheme: light)" srcset="logos/san_harness_logo_light.svg"/>
  <img src="logos/san_harness_logo_dark.svg" alt="SAN AI Harness Logo" width="580"/>
</picture>
```

---

## 3. ARBORESCENCE DES ASSETS

```txt
logos/
├── LOGO.md                       # Charte visuelle Swiss Monochrome + Signal Orange
├── LOGO_ASCII.txt                # Bannière CLI avec monogramme S-H
├── san_harness_icon.svg          # Icône carrée 512×512 (miroir src/plugin/assets/logo.svg)
├── san_harness_logo_light.svg    # Logo horizontal adaptatif — Thème Clair GitHub
└── san_harness_logo_dark.svg     # Logo horizontal adaptatif — Thème Sombre GitHub
```
