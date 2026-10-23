# `/src/` — OUTPUT DESTINÉ À LA MACHINE DU CLIENT

> **Périmètre :** Ce répertoire contient exclusivement le code, les modules et les assets distribuables qui sont injectés sur la machine et la codebase du client lors de l'exécution de `npx @alexsan/agy-framework init`.

---

## Structure de Distribution

```txt
src/
├── cli/                                # Script d'installation et de setup (Node.js / Bash)
│   ├── index.js                        # Point d'entrée du CLI npx
│   └── installer.js                    # Copie, purge et configuration Git locale
│
├── skills/                             # Les vrais skills Antigravity exécutables
│   └── san_{nom}/
│       ├── SKILL.md                    # Instructions maîtresses exécutables
│       ├── templates/                  # Gabarits réels injectables
│       ├── references/                 # Grilles d'évaluation et matrices
│       └── scripts/                    # Scripts exécutables (bash, node)
│
├── sub-skills/                         # Les vrais sub-skills Antigravity exécutables
│   └── san_{nom}/
│       ├── SKILL.md                    # Instructions d'exécution
│       └── scripts/                    # Scripts réutilisables (export, lint, search)
│
└── templates/                          # Modèles initiaux pour le projet client
    └── rules/
        ├── BRAND_TEMPLATE.md           # Gabarit BRAND.md initial
        ├── PRODUCT_TEMPLATE.md         # Gabarit PRODUCT.md initial
        ├── PROJECT_TEMPLATE.md         # Gabarit PROJECT.md initial
        └── API_TEMPLATE.md             # Gabarit API.md initial
```
