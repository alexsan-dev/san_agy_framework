# FORMATS D'IMPRESSION HAUTE FIDÉLITÉ (300 DPI)

Pour les livrables d'impression physique (factures, certificats, bannières d'exposition, dossiers d'onboarding partenaires), la résolution doit être calculée à 300 points par pouce (DPI / PPI).

---

## 1. FORMULE DE CONVERSION MILLIMÈTRES $\rightarrow$ PIXELS À 300 DPI

$$
\text{Pixels} = \frac{\text{Millimètres} \times 300}{25.4}
$$

---

## 2. MATRICE DES FORMATS PAPIER ET IMPRESSION

| Format | Dimensions Physiques (mm) | Résolution (px à 300 DPI) | Usage dans `san_*` |
| :--- | :--- | :--- | :--- |
| **A4 Portrait** | $210 \times 297\text{ mm}$ | **`2480 × 3508 px`** | Factures légales, bilans récapitulatifs, fiches d'onboarding |
| **A4 Paysage** | $297 \times 210\text{ mm}$ | **`3508 × 2480 px`** | Diplômes d'honneur, tableaux de bord analytiques, rapports trimestriels |
| **A3 Portrait** | $297 \times 420\text{ mm}$ | **`3508 × 4960 px`** | Affiches d'atelier, organigrammes d'ingénierie |
| **A5 Portrait** | $148 \times 210\text{ mm}$ | **`1748 × 2480 px`** | Flyers de promotion, livrets d'accueil |
| **Carte de Visite** | $85 \times 55\text{ mm}$ | **`1004 × 650 px`** | Badges d'accès, cartes professionnelles |

---

## 3. CONFIGURATION DANS LES MOCKUPS HTML

Pour capturer un document d'impression A4 en fidélité absolue :

```html
<!-- CANVAS_SPEC: target=print width=2480px height=3508px export_scale=1 -->
```
