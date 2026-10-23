# NORMES D'ACCESSIBILITÉ WCAG 2.1 ET CONTRASTES EN PLEIN SOLEIL

Dans l'écosystème Antigravity (`san_*`), l'accessibilité visuelle n'est pas un compromis négociable : elle est mathématiquement modélisée et certifiée lors de la compilation des tokens.

---

## 1. FORMULATION MATHÉMATIQUE (sRGB)

### A. Linéarisation des Composantes RGB
Pour chaque composante $C \in \{R, G, B\}$ normalisée entre $0$ et $1$ ($C = \frac{C_{\text{8bit}}}{255}$) :

$$
C_{\text{linear}} =
\begin{cases}
\frac{C}{12.92} & \text{si } C \le 0.03928 \\
\left(\frac{C + 0.055}{1.055}\right)^{2.4} & \text{si } C > 0.03928
\end{cases}
$$

### B. Luminance Relative ($L$)
La luminance relative selon la recommandation ITU-R BT.709 s'exprime par :

$$
L = 0.2126 \times R_{\text{linear}} + 0.7152 \times G_{\text{linear}} + 0.0722 \times B_{\text{linear}}
$$

### C. Ratio de Contraste ($CR$)
Entre deux couleurs de luminances $L_1$ et $L_2$ avec $L_1 \ge L_2$ :

$$
CR = \frac{L_1 + 0.05}{L_2 + 0.05}
$$

Le ratio varie strictement de $1:1$ (aucun contraste) à $21:1$ (noir pur sur blanc pur).

---

## 2. SEUILS D'EXIGENCE ANTIGRAVITY

| Niveau de Conformité | Ratio Minimal | Cas d'Usage Recommandé | Conditions Environnementales |
| :--- | :--- | :--- | :--- |
| **WCAG AAA (Plein Soleil)** | **$\ge 7.0:1$** | Texte courant, données financières tabulaires, icônes critiques | Consultation extérieure sous ensoleillement direct (> 50 000 lux) |
| **WCAG AA (Standard UI)** | **$\ge 4.5:1$** | Textes secondaires, labels de formulaires, paragraphes d'aide | Éclairage ambiant intérieur et bureau |
| **WCAG AA Large** | **$\ge 3.0:1$** | Grands titres ($\ge 24\text{px}$ ou $\ge 18.5\text{px}$ gras), bordures d'inputs, focus rings | Composants d'interface interactifs |
| **Échec Inacceptable** | **$< 3.0:1$** | **INTERDIT** dans toute application `san_*` | Risque majeur d'invisibilité cognitive |

---

## 3. PAIRES DE TOKENS CANONIQUES À AUDITER

Lors de toute mise à jour de `.agents/rules/BRAND.md`, le script `build_tokens.mjs` valide prioritairement :
1. `color-on-surface` sur `color-surface` (Visibilité du corps de texte dans les conteneurs).
2. `color-on-surface` sur `color-background` (Visibilité globale de l'interface).
3. `color-on-surface-muted` sur `color-surface` (Lisibilité minimale des légendes et horodatages).
4. `color-primary` sur `color-surface` (Perception sans équivoque des boutons d'action).
5. `color-error` et `color-success` sur `color-surface` (Clarté absolue des rétroactions opérationnelles).
