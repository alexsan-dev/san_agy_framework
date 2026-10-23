# SECTION DESIGN TOKENS CANONIQUE POUR BRAND.md

Insérez ou mettez à jour cette section dans votre fichier `.agents/rules/BRAND.md`.

---

## DESIGN TOKENS CHROMATIQUES

### Palette Maîtresse (Sémantique & Hexadécimale)

| Jeton (Token) | Mode Sombre (Dark) | Mode Clair (Light) | Rôle & Usage Sémantique |
| :--- | :--- | :--- | :--- |
| `color-primary` | `#2563EB` | `#1D4ED8` | Action principale, identité dominante (CTA). |
| `color-primary-hover` | `#1D4ED8` | `#1E40AF` | État survol et pression sur bouton d'action. |
| `color-surface` | `#0B0F19` | `#FFFFFF` | Fond des cartes, modales, panneaux et conteneurs. |
| `color-surface-subtle` | `#111827` | `#F8FAFC` | Fonds alternés, tables, champs inactifs. |
| `color-background` | `#030712` | `#F1F5F9` | Toile de fond globale de l'application. |
| `color-on-surface` | `#F9FAFB` | `#0F172A` | Texte principal, titres, icônes dominantes (> 7:1). |
| `color-on-surface-muted`| `#9CA3AF` | `#64748B` | Légendes, horodatages, textes secondaires. |
| `color-border` | `#1F2937` | `#E2E8F0` | Délimitation subtile des composants et listes. |
| `color-border-focus` | `#3B82F6` | `#2563EB` | Anneau d'accessibilité et focus clavier (outline 2px). |
| `color-accent` | `#3B82F6` | `#2563EB` | Badges, sélections actives, accents visuels. |
| `color-success` | `#10B981` | `#059669` | Validation, transferts réussis, soldes positifs. |
| `color-warning` | `#F59E0B` | `#D97706` | Alertes préventives, délai réseau. |
| `color-error` | `#EF4444` | `#DC2626` | Rejets, échecs critiques, champs invalides. |
| `color-info` | `#3B82F6` | `#2563EB` | Statuts informatifs neutres. |

---

## ESPACEMENT, RAYONS & ÉLÉVATIONS (BASE 4PX)

* **Espacements :** `space-1` (4px), `space-2` (8px), `space-3` (12px), `space-4` (16px), `space-5` (20px), `space-6` (24px), `space-8` (32px), `space-10` (40px), `space-12` (48px), `space-16` (64px).
* **Rayons :** `radius-none` (0px), `radius-sm` (4px), `radius-md` (8px), `radius-lg` (12px), `radius-xl` (16px), `radius-full` (9999px).
* **Ombres :** `shadow-none`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`.

---

## SIGNATURE CINÉTIQUE & MOTION 60 FPS

* **Durées :** `duration-fast` (150ms), `duration-normal` (250ms), `duration-slow` (400ms).
* **Courbes Bézier :**
  - Standard : `cubic-bezier(0.2, 0.0, 0.0, 1.0)`
  - Spring (ressort) : `cubic-bezier(0.175, 0.885, 0.32, 1.275)`
  - Décroissance : `cubic-bezier(0.0, 0.0, 0.2, 1.0)`
  - Transition : `cubic-bezier(0.16, 1.0, 0.3, 1.0)`
