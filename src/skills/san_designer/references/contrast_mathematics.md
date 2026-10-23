# Mathématiques du Contraste & Seuils Plein Soleil

Ce document formalise les calculs photométriques et les algorithmes déterministes utilisés par `san_designer` et `/ux-scan` pour certifier l'accessibilité universelle et la lisibilité en extérieur.

---

## 1. FORMULE UNIVERSELLE WCAG 2.1 (LUMINANCE RELATIVE)

La luminance relative $L$ représente la luminosité perçue d'un point dans l'espace colorimétrique sRGB, normalisée de 0 (noir absolu) à 1 (blanc pur).

### Étape 1 : Linéarisation des composantes sRGB
Pour chaque canal $C \in \{R, G, B\}$, la valeur entière $[0, 255]$ est d'abord convertie en fraction $[0.0, 1.0]$ :
$$C_{\text{srgb}} = \frac{C_{255}}{255}$$

On applique ensuite la courbe gamma inverse standard sRGB :
$$C_{\text{linear}} = \begin{cases} \dfrac{C_{\text{srgb}}}{12.92} & \text{si } C_{\text{srgb}} \le 0.04045 \\ \left(\dfrac{C_{\text{srgb}} + 0.055}{1.055}\right)^{2.4} & \text{si } C_{\text{srgb}} > 0.04045 \end{cases}$$

### Étape 2 : Calcul de la Luminance Relative $L$
Les coefficients photométriques de la CIE (Commission Internationale de l'Éclairage) pondèrent la sensibilité spectrale de l'œil humain :
$$L = 0.2126 \cdot R_{\text{linear}} + 0.7152 \cdot G_{\text{linear}} + 0.0722 \cdot B_{\text{linear}}$$

### Étape 3 : Calcul du Ratio de Contraste $CR$
Soient $L_1$ la luminance de la couleur la plus claire et $L_2$ la luminance de la plus sombre ($L_1 \ge L_2$) :
$$CR = \frac{L_1 + 0.05}{L_2 + 0.05}$$
Le ratio $CR$ est compris dans l'intervalle $[1.0, 21.0]$.

---

## 2. MATRICE DES SEUILS D'ACCEPTATION

| Scénario d'Usage | Condition Luminosité | Seuil Minimal Obligatoire | Norme | Statut /ux-scan si Défaut |
| :--- | :--- | :--- | :--- | :--- |
| **Texte Normal Corps** | Intérieur / Standard ($< 2\,000\text{ lux}$) | $CR \ge 4.5:1$ | WCAG AA | `BLOQUANT` |
| **Texte Large ($\ge 18\text{pt}$ ou $\ge 14\text{pt}$ bold)** | Intérieur / Standard | $CR \ge 3.0:1$ | WCAG AA | `BLOQUANT` |
| **Composants d'Interface & Icônes** | Intérieur / Standard | $CR \ge 3.0:1$ | WCAG AA | `MAJEUR` |
| **RÈGLE PLEIN SOLEIL (Extérieur)** | Fort ensoleillement ($> 10\,000\text{ lux}$) | $CR_{\text{soleil}} \ge 7.0:1$ | WCAG AAA | `BLOQUANT` |
| **Montants Monétaires & CTA** | Tout environnement extérieur | $CR \ge 7.0:1$ | Renforcé | `BLOQUANT` |

---

## 3. IMPLÉMENTATION ALGORITHMIQUE JAVASCRIPT

```javascript
/**
 * Calcule le ratio de contraste exact entre deux couleurs hexadécimales.
 * @param {string} hex1 - Ex: '#ffffff'
 * @param {string} hex2 - Ex: '#0f172a'
 * @returns {number} Ratio de contraste (ex: 15.42)
 */
export function getContrastRatio(hex1, hex2) {
  const getLuminance = (hex) => {
    const cleanHex = hex.replace('#', '');
    const r = parseInt(cleanHex.substring(0, 2), 16) / 255;
    const g = parseInt(cleanHex.substring(2, 4), 16) / 255;
    const b = parseInt(cleanHex.substring(4, 6), 16) / 255;

    const toLinear = (c) => (c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
    return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);
  };

  const l1 = getLuminance(hex1);
  const l2 = getLuminance(hex2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);

  return parseFloat(((lighter + 0.05) / (darker + 0.05)).toFixed(2));
}
```
