# TABLE DE ROUTAGE & CONSTITUTION DUAL-HARNESS (`GEMINI.md`)

> **SAN AI Harness v3.0 (Dual-Harness) :** L'orchestrateur utilise le `/model` choisi par l'utilisateur (`inherit-user-model`), aligne d'abord le cadrage produit/UI (`ask_question` / `question` + captures `export_png.mjs --url`), puis choisit librement entre `Plan → Execute` natif (tâches simples/mono-couche) et délégation parallèle (`swarm` / `san_swarm`).

---

## 1. PRINCIPES DIRECTEURS (LÉGERS & ADAPTATIFS)

1. **Orchestration Dual-Harness Libre & Adaptative :**
   - **Orchestrateur :** Hérite du `/model` utilisateur (`inherit-user-model`). Aucune contrainte mécanique empêchant `Plan → Execute` sur des modifications simples ou mono-couche.
   - **Exécution Parallèle / Multi-Couches (`.agents/models.json`, `san-harness models`) :**
     - **Google Antigravity (`agy`) :** `swarm(action: "add", model: "<agy.executor>", ...)` pour paralléliser les chantiers multi-couches, Duels UI et audits `san-qa-auditor` (`invoke_subagent(Model: "inherit")` évité).
     - **OpenCode V2.3 (`opencode`) :** `san_swarm(action: "dispatch", ...)` (avec vue tableau Swarm Board) ou `subagent({ agent: "san-..." })` utilisant `<opencode.executor>` défini dans `opencode.json`.
2. **Alignement Socratique & Visuel Préalable :** Avant de rédiger/déléguer une roadmap ou une refonte UI, valider les choix structurants avec l'utilisateur (`ask_question` / `question`) et capturer les sites d'inspiration via Playwright (`export_png.mjs --url=<https://...> --viewports=desktop,mobile`).
3. **Doute Contradictoire & Contract-First :** Pre-Mortem (`san-architect`), contrats OpenAPI 3.1 / Zod / TypeBox gelés sur chantiers multi-couches, Studio Duel UI + audit DOM/PNG (`san-qa-auditor`).
4. **Preuve par le Code :** Zéro tâche `- [x]` sans test exécuté (`exit 0`), zéro *testing theater*.
5. **Compaction Automatique 120k :** Aucun fichier map/cache redondant ; compacter la conversation autour de `120 000` tokens (`/compact`).

---

## 2. TABLE DE ROUTAGE D'INTENTION VERS WORKERS & SKILLS

| Intention Détectée | Skills `san_*` | Worker Dual-Harness | Action Clé |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | `ask_question` + matrice 2 approches |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Alignement, Pre-Mortem, Contract-First |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | Capture `--url`, Studio Duel UI, 5 états, PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` / `san-qa-auditor` | Plan→Execute ou `swarm` / `san_swarm`, tests |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | Présomption de défaut, OWASP, Fitness, PNG |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Multi-stack, rollback < 30s, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Fiches stores, conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, tracking KPIs |

---

## 3. RÈGLES DE GOUVERNANCE NATIVES (`.agents/rules/`)

* **`.agents/rules/PROJECT.md`** (`trigger: always_on`) — Constitution technique, `PROJECT_PROFILE` et routage Dual-Harness (`.agents/models.json`).
* **`.agents/rules/PRODUCT.md`** (`trigger: model_decision`) — Cadrage fonctionnel, personas et contraintes terrain.
* **`.agents/rules/BRAND.md`** (`trigger: glob`) — Archétype esthétique, tokens chromatiques, typographie et motion 60 fps.
* **`.agents/rules/API.md`** (`trigger: glob`) — Contrats d'endpoints, enveloppe JSON canonique, idempotence et suite Bruno.
* **`.agents/rules/LOGO.md`** (`trigger: glob`) — Spécifications vectorielles maîtres et matrice d'assets PNG.

---

## 4. SUIVI OPÉRATIONNEL (`roadmaps/`)

* **Roadmap Active en Cours :** `roadmaps/[NOM_ROADMAP_ACTIVE].md`
* **Archives des Roadmaps Achevées (100% cochées) :** `roadmaps/archives/`
* **Idéations & Brainstorming :** `roadmaps/ideas/`
* **Journal de Bord :** `CHANGELOG.md` (Keep a Changelog / SemVer)
