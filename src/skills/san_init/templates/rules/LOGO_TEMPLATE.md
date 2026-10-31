---
trigger: glob
globs: "*logo*, *icon*, *favicon*, *manifest*, *.svg"
description: "Master vector logo rules and multi-resolution icon asset guidelines."
---
# GUIDE D'UTILISATION DU LOGO & ASSETS DE MARQUE (`LOGO.md`)

> **Source de vérité visuelle :** Ce document consigne l'emplacement, les règles de construction géométrique, les zones d'exclusion et l'inventaire des déclinaisons du logo officiel du projet.

---

## 1. LOGOS MAÎTRES VECTORIELS (SOURCES OFFICIELLES)

Les fichiers sources vectoriels (SVG) maîtres sont stockés dans le répertoire `logos/` (ou `assets/branding/`) :
* **Icône Maîtresse (Symbol Mark) :** `logos/logo_icon.svg`
* **Logo Complet Horizontal (Logotype + Symbole) :** `logos/logo_horizontal.svg`
* **Variante Monochrome Sombre (Dark Canvas) :** `logos/logo_dark.svg`
* **Variante Monochrome Claire (Light Canvas) :** `logos/logo_light.svg`

---

## 2. RÈGLES DE COMPOSITION & ZONES DE DÉGAGEMENT

* **Zone de Protection Minimale (Clear Space) :**
  - Une marge de sécurité minimale équivalente à $0.25 \times \text{hauteur totale}$ doit séparer le logo de tout texte ou élément d'interface contigu.
* **Taille Minimale d'Affichage :**
  - Numérique Web : `24px` de hauteur minimale pour l'icône seule, `32px` pour le logotype complet.
  - Impression physique : `10mm` de hauteur minimale.
* **Usages Proscrits :**
  - Ne jamais déformer l'échelle des axes X et Y (respecter le ratio d'aspect initial).
  - Ne jamais appliquer d'ombrage flou (« drop shadow ») ou de contour néon sur le tracé vectoriel.
  - Ne jamais placer le logo sur un fond manquant de contraste (contraste minimal requis : 4.5:1).

---

## 3. INVENTAIRE DES ASSETS MATRICIELS PNG GÉNÉRÉS

Générés via le pipeline `node scripts/svg_to_png.mjs` dans le dossier cible (par défaut `public/assets/branding/` ou `public/icons/`) :

| Fichier PNG | Résolution (px) | Destination & Usage |
| :--- | :--- | :--- |
| `favicon-16x16.png` | `16 x 16` | Onglet de navigateur desktop (haute densité d'onglets) |
| `favicon-32x32.png` | `32 x 32` | Favicon standard pour navigateurs modernes |
| `favicon-48x48.png` | `48 x 48` | Affichage dans les raccourcis de bureau |
| `favicon-64x64.png` | `64 x 64` | Marque-pages haute résolution |
| `apple-touch-icon.png` | `180 x 180` | Écran d'accueil iOS (iPhone & iPad Safari) |
| `pwa-192x192.png` | `192 x 192` | Écran de démarrage PWA et tiroir d'applications Android |
| `pwa-512x512.png` | `512 x 512` | Manifeste PWA & fiches de stores d'applications |
| `maskable-icon-512x512.png` | `512 x 512` | Icône adaptative Android avec marge de sécurité circulaire |
| `logo-brand-512x128.png` | `512 x 128` | En-têtes d'e-mails transactionnels & headers de documentation |
| `logo-brand-1024x256.png` | `1024 x 256` | Bannières haute fidélité pour réseaux sociaux et stores |
| `splash-mobile-portrait-1242x2688.png` | `1242 x 2688` | Écran de démarrage vertical mobile (Splash Screen natif) |
| `splash-square-2048x2048.png` | `2048 x 2048` | Splash screen universel centré pour tablettes et moniteurs |
