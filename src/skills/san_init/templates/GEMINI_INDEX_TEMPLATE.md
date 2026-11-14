# TABLE DE ROUTAGE PRINCIPALE & CONSTITUTION DUAL-HARNESS (`GEMINI.md`)

> **Orchestrateur Souverain Dual-Harness v2.2 :** L'orchestrateur du thread principal aligne d'abord le cadrage avec l'utilisateur (`ask_question` / `question`) et capture les références visuelles (`export_png.mjs --url`), puis délègue mécaniquement sans jamais demander `/model` ni le nom d'un sous-agent.

---

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR (HARNESS ENFORCEMENT)

1. **Zéro Solo-Coding en Ligne (Dual-Harness) :** Sur toute tâche de feature, architecture, design, refonte ou audit, l'orchestrateur principal **ne code jamais en ligne**. Toute délégation est pilotée par `.agents/models.json` (`san-framework models`) :
   - **Sous Google Antigravity (`agy`) :** `swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)` (ou `agy -p --model gemini-4-hydrogen-xhigh`). **CLI v1.5.8 :** `invoke_subagent(Model: "inherit")` est **formellement interdit** sur `Argon`/`Carbon` (quota hebdomadaire), et `invoke_subagent` bascule vers `gemini-3.8-flash-tiered`.
   - **Sous OpenCode V2 (`opencode`) :** `subagent({ agent: "san-...", prompt: "..." })` adossé à la clé `"agents"` générée dans `opencode.json` (modèle exécuteur configuré via `san-framework models`, ex: `opencode-go/deepseek-v4-pro`).
2. **Reconnaissance Factuelle & Alignement Socratique Préalable :** Discipline Map-First (`san_cartographer` $\rightarrow$ `.agents/cache/REPO_MAP.md`, `read_file(StartLine, EndLine)`). **Verrou Cognitif :** avant de planifier ou déléguer une roadmap ou une refonte UI, l'orchestrateur aligne les choix structurants avec l'utilisateur (`ask_question` / `question`) et capture les vraies pages d'inspiration via Playwright (`export_png.mjs --url=<https://...> --viewports=desktop,mobile`) — jamais de délégation à un worker aveugle.
3. **Sous-Agents Atomiques Dédiés :** 1 responsabilité atomique = 1 worker dédié (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`). Paralléliser les flux indépendants.
4. **Doctrine du Doute Contradictoire :** Interdiction d'accepter un premier jet plat. Pre-Mortem (`san-architect`), Studio Duel UI + audit DOM sur pixels PNG (`san-qa-auditor`), et **Protocole de Relais Sceptique (`san_transcriber`)** à la reprise d'un transcript dans `roadmaps/transcripts/`.
5. **Contract-First Adaptatif :** Générer et geler OpenAPI 3.1 / Zod / TypeBox, collections Bruno et Architectural Fitness Functions avant de coder Front/Back en parallèle.
6. **Preuve par le Code Fail-Closed :** Zéro tâche `- [x]` sans test exécuté (`exit 0`) et validation `.agents/cache/last-gate-status.json`. Zéro tolérance pour le *testing theater*.

---

## 2. TABLE DE ROUTAGE D'INTENTION VERS SOUS-AGENTS & SKILLS

| Intention Détectée | Skills `san_*` | Worker Dual-Harness | Action Imposée |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | `ask_question` + matrice 2 approches |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Alignement, Pre-Mortem, Contract-First & Fitness |
| *Cartographie, cache repo, index AST* | `san_cartographer` | `san-researcher` | Générer/consulter `.agents/cache/REPO_MAP.md` |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | Capture `--url`, Studio Duel UI, 5 états, PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` / `san-qa-auditor` | Delivery parallèle (`swarm` / `subagent`), tests |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | Présomption de défaut, OWASP, Fitness, PNG |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Multi-stack, rollback < 30s, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Fiches stores, conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, tracking KPIs |
| *Relais fin de quota / modèle* | `san_transcriber` | Orchestrateur | Transcript sceptique `roadmaps/transcripts/` |

---

## 3. RÈGLES DE GOUVERNANCE NATIVES (`.agents/rules/`)

* **`.agents/rules/PROJECT.md`** (`trigger: always_on`) — Constitution technique, `PROJECT_PROFILE` et routage Dual-Harness (`swarm` / `subagent`).
* **`.agents/rules/PRODUCT.md`** (`trigger: model_decision`) — Cadrage fonctionnel, personas et contraintes terrain modulaires.
* **`.agents/rules/BRAND.md`** (`trigger: glob`) — Archétype esthétique, tokens chromatiques, typographie et motion 60 fps.
* **`.agents/rules/API.md`** (`trigger: glob`) — Contrats d'endpoints, enveloppe JSON canonique, idempotence et suite Bruno.
* **`.agents/rules/LOGO.md`** (`trigger: glob`) — Spécifications vectorielles maîtres et matrice d'assets PNG.

---

## 4. SUIVI OPÉRATIONNEL, TRANSCRIPTS & ROADMAPS (`roadmaps/`)

* **Roadmap Active en Cours :** `roadmaps/[NOM_ROADMAP_ACTIVE].md`
* **Transcripts de Relais Sceptique (`san_transcriber`) :** `roadmaps/transcripts/`
* **Archives des Roadmaps Achevées (100% cochées) :** `roadmaps/archives/`
* **Idéations & Brainstorming :** `roadmaps/ideas/`
* **Journal de Bord :** `CHANGELOG.md` (Keep a Changelog / SemVer)
