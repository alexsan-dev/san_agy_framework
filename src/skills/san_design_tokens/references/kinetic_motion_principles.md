# PRINCIPES CINÉTIQUES ET SIGNATURE DE MOUVEMENT 60 FPS

Le mouvement dans le framework Antigravity (`san_*`) n'est jamais purement cosmétique : il traduit la réalité physique des flux d'information et respecte la physiologie cognitive humaine.

---

## 1. LES 3 DURÉES NORMALISÉES

Aucune durée arbitraire (`0.33s`, `175ms`) n'est tolérée dans la codebase. Tout mouvement s'aligne sur :

| Jeton (Token) | Durée (ms) | Usage UX / Dynamique Perceptive |
| :--- | :--- | :--- |
| `--duration-fast` | **`150ms`** | Micro-interactions tactiles : survol de bouton, changement de statut switch/toggle, focus clavier, pulsations d'icônes. |
| `--duration-normal`| **`250ms`** | Composants locaux : expansion d'accordéons, apparition de menus popovers, onglets, notifications toasters. |
| `--duration-slow`  | **`400ms`** | Macro-transitions : transition de page entière, modale plein écran, glissement de tiroirs latéraux (*drawers*), skeletons. |

---

## 2. COURBES D'ACCÉLÉRATION BÉZIER NOMMÉES

Le système proscrit l'utilisation du mot-clé vague `ease`. Les fonctions de transfert s'appuient sur des courbes cubiques calibrées :

* **`--ease-standard` (`cubic-bezier(0.2, 0.0, 0.0, 1.0)`) :**
  Mouvement fluide universel de décélération naturelle. L'objet part vite et se stabilise avec douceur dans son état final.
* **`--ease-spring` (`cubic-bezier(0.175, 0.885, 0.32, 1.275)`) :**
  Micro-physique à ressort amorti avec rebond léger ($< 5\%$). Idéal pour les validations de panier, transferts réussis ou bascule de favoris.
* **`--ease-decelerate` (`cubic-bezier(0.0, 0.0, 0.2, 1.0)`) :**
  Entrée rapide d'éléments surgissant depuis l'extérieur du viewport.
* **`--ease-in-out` (`cubic-bezier(0.16, 1.0, 0.3, 1.0)`) :**
  Navigation bilatérale et repositionnement d'éléments persistants à l'écran.

---

## 3. GARANTIE ABSOLUE DU 60 FPS (BUDGET DE RENDU 16.6ms)

### Propriétés Animables Autorisées (GPU-Only)
Seules deux propriétés CSS peuvent être manipulées au cours d'une transition continue :
1. `transform` (`translate3d`, `scale`, `rotate`)
2. `opacity`

### Propriétés Formellement Interdites en Animation
L'animation des attributs suivants entraîne un recalcul complet de la géométrie (*layout reflow*) et est bannie :
- `width`, `height`, `min-width`, `max-height`
- `margin`, `padding`
- `top`, `bottom`, `left`, `right`
- `border-width`
