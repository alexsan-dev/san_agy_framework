# NOMENCLATURE UNIFIÉE DES DESIGN TOKENS (san_*)

Pour éliminer l'ambiguïté entre designers, développeurs web et ingénieurs mobiles, `san_design_tokens` applique une taxonomie stricte à trois niveaux.

---

## 1. NIVEAUX D'ABSTRACTION

1. **Tokens Primitifs (Valeurs brutes) :**
   Exemples : `blue-600: #2563EB`, `gray-900: #0B0F19`, `scale-4: 16px`.
   *Rôle :* Réserve de valeurs universelles (interdites d'usage direct dans les composants applicatifs).

2. **Tokens Sémantiques (Intentions fonctionnelles) :**
   Exemples : `color-primary`, `color-surface`, `color-on-surface`, `space-4`.
   *Rôle :* Consommés par les interfaces pour garantir la compatibilité multi-thèmes et la clarté d'intention.

3. **Tokens de Composants (Spécifiques) :**
   Exemples : `button-primary-bg: var(--color-primary)`.
   *Rôle :* Encapsulation locale si une complexité visuelle l'exige.

---

## 2. RÈGLES DE NOMMAGE PAR DOMAINE

### A. Couleurs
- Préfixe : `color-*`
- Surfaces : `color-surface`, `color-surface-subtle`, `color-background`
- Contenu sur surface : `color-on-surface`, `color-on-surface-muted`
- Actions : `color-primary`, `color-primary-hover`, `color-accent`
- États : `color-success`, `color-warning`, `color-error`, `color-info`
- Délimitations : `color-border`, `color-border-focus`

### B. Espacements (Échelle base 4px)
- `space-1` = 4px
- `space-2` = 8px
- `space-3` = 12px
- `space-4` = 16px
- `space-5` = 20px
- `space-6` = 24px
- `space-8` = 32px
- `space-10` = 40px
- `space-12` = 48px
- `space-16` = 64px

### C. Rayons de Courbure
- `radius-none` = 0px
- `radius-sm` = 4px
- `radius-md` = 8px
- `radius-lg` = 12px
- `radius-xl` = 16px
- `radius-full` = 9999px

### D. Mouvement
- Durées : `duration-fast` (150ms), `duration-normal` (250ms), `duration-slow` (400ms)
- Courbes : `ease-standard`, `ease-spring`, `ease-decelerate`, `ease-in-out`
