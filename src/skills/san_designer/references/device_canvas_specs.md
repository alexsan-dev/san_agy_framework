# Spécifications Normatives des 5 Canvas Stores & Devices

Ce document consigne les dimensions géométriques exactes, les safe areas critiques, les ratios d'aspect et les contraintes techniques régissant la production d'écrans dans le framework Antigravity (`san_designer`).

---

## 1. TABLEAU DE SYNTHÈSE DES 5 CANVAS STANDARDS

| Format | Largeur ($W$) | Hauteur ($H$) | Ratio | Safe Areas / Marges d'Exclusion | Usage Principal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Play Store Screenshot** | `1080 px` | `1920 px` | 9:16 | Haut : `120px` (titre) / Bas : `160px` | Fiche Google Play Store pour smartphones. Pas de transparence PNG. |
| **App Store Screenshot** | `1290 px` | `2796 px` | 19.5:9 | Haut : `180px` (Dynamic Island) / Bas : `140px` | Fiche App Store pour iPhone 15/16 Pro Max 6.7". |
| **Desktop Canvas** | `1440 px` | `900 px` | 16:10 | Marges latérales : `80px` / En-tête : `72px` | Web App / Backoffice responsive widescreen standard. |
| **Tablette Canvas** | `820 px` | `1180 px` | 1:1.44 | Marges latérales : `48px` / En-tête : `64px` | iPad Air et tablettes Android en orientation portrait. |
| **Feature Graphic** | `1024 px` | `500 px` | ~2.05:1 | Marge de sécurité périphérique : `60px` | Bannière promotionnelle obligatoire en tête de fiche Google Play. |
| *Prototypage Mobile In-App* | `390 px` | `844 px` | 9:19.5 | Notch/Island : `47px` / Home bar : `34px` | Viewport de référence pour l'ergonomie mobile nominale à une main. |

---

## 2. DÉTAILS D'IMPLÉMENTATION PAR CANVAS

### 1. Google Play Store Screenshot (`1080×1920 px`)
* **Résolution & Format :** PNG 24-bit ou 32-bit sans canal alpha (fond 100% opaque obligatoire sous peine de rejet Google Play Console).
* **Composition Visuelle :**
  - **Tiers supérieur (0 à 450px) :** Titre d'accroche percutant (2 à 4 mots maximum, typographie bold, contraste $> 7:1$).
  - **Tiers médian et inférieur (450 à 1920px) :** Appareil en perspective ou mockup vertical centré présentant l'écran réel de l'application.
* **Tag En-tête Obligatoire :**
  ```html
  <!-- CANVAS_SPEC: width=1080px height=1920px device="Play Store Screenshot" export_scale=1 -->
  ```

### 2. Apple App Store Screenshot (`1290×2796 px`)
* **Résolution & Format :** PNG 24-bit (sRGB ou Display P3), échelle 1x pour 1290x2796 (iPhone 6.7" Super Retina XDR).
* **Spécificités iOS :**
  - Intégration de la Dynamic Island (`top: 180px`, centré).
  - Respect de l'indicateur d'accueil inférieur (`Home Indicator`, `bottom: 140px`).
* **Tag En-tête Obligatoire :**
  ```html
  <!-- CANVAS_SPEC: width=1290px height=2796px device="App Store iPhone 6.7" export_scale=1 -->
  ```

### 3. Google Play Feature Graphic (`1024×500 px`)
* **Règle absolue :** La bannière héroïque apparaît sur Google Play au-dessus des captures.
* **Zone de sécurité (*Safe Zone*) :** Aucun texte, logo ou élément de marque ne doit se trouver à moins de **60px des 4 bords** pour éviter tout rognage lors des adaptations d'affichage du store.
* **Composition :** Visuel émotionnel de marque, promesse de valeur centrale, pas de capture d'écran brute ni de boutons factices « Télécharger ».
* **Tag En-tête Obligatoire :**
  ```html
  <!-- CANVAS_SPEC: width=1024px height=500px device="Play Store Feature Graphic" export_scale=1 -->
  ```

### 4. Desktop Canvas (`1440×900 px`)
* **Résolution :** Format panoramique 16:10 standardisé pour les présentations clients, dashboards et backoffices SaaS.
* **Tag En-tête Obligatoire :**
  ```html
  <!-- CANVAS_SPEC: width=1440px height=900px device="Desktop Widescreen" export_scale=1 -->
  ```

### 5. Tablette Canvas (`820×1180 px`)
* **Résolution :** Simulation iPad Air et tablettes tactiles en point de vente (POS / Caisse).
* **Tag En-tête Obligatoire :**
  ```html
  <!-- CANVAS_SPEC: width=820px height=1180px device="Tablet Portrait" export_scale=1 -->
  ```
