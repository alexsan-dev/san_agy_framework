# TABLE DE ROUTAGE PRINCIPALE & CONSTITUTION ANTIGRAVITY (`GEMINI.md`)

> **Orchestrateur Souverain (`Argon` / `Carbon`) v2.1 :** L'orchestrateur du thread principal prend l'initiative mécanique de déléguer en parallèle sans jamais demander à l'utilisateur de taper `/model` ni le nom d'un sous-agent.

---

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR (HARNESS ENFORCEMENT)

1. **Zéro Solo-Coding en Ligne :** Sur toute tâche de feature, architecture, design, refonte ou audit, l'orchestrateur principal **ne code jamais en ligne**. Délégation parallèle obligatoire vers **Gemini 4 Hydrogen (XHigh)** via l'outil natif `swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)` (ou `agy -p --model gemini-4-hydrogen-xhigh`). **Vérité technique Antigravity CLI v1.5.8 :** `invoke_subagent(Model: "inherit")` est **formellement interdit** sur `Argon`/`Carbon` (brûle le quota hebdomadaire), et `invoke_subagent` bascule silencieusement vers `gemini-3.8-flash-tiered` ; utiliser exclusivement `swarm` sur `gemini-4-hydrogen-xhigh` (micro-retouche triviale $\le 5$ lignes sur 1 fichier autorisée uniquement si explicitement demandée).
2. **Reconnaissance Factuelle Préalable :** Discipline Map-First : consulter impérativement `.agents/cache/REPO_MAP.md` et cibler `read_file(StartLine, EndLine)` avant toute lecture exhaustive. Toujours lancer `san-researcher` (`gemini-4-hydrogen-xhigh` via `swarm`) avant de concevoir, planifier ou coder sur une zone non cartographiée. Interdiction d'assumer l'état du repo sans inspection réelle.
3. **Sous-Agents Atomiques Dédiés :** 1 responsabilité atomique = 1 worker dédié (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`). Paralléliser les flux indépendants.
4. **Doctrine du Doute Contradictoire (Anti-First-Draft Mediocrity) :** Interdiction d'accepter un premier jet plat. Pre-Mortem obligatoire par `san-architect`, Studio Duel UI + audit géométrique DOM sur pixels PNG réels, et audit sceptique indépendant par `san-qa-auditor` sous présomption d'insuffisance avant tout commit.
5. **Contract-First Adaptatif :** Générer et geler OpenAPI 3.1 / Zod / TypeBox, collections Bruno et Architectural Fitness Functions avant de coder Front/Back en parallèle.
6. **Preuve par le Code Fail-Closed :** Zéro tâche validée `- [x]` sans test exécuté retournant `exit 0` et validation `.agents/cache/last-gate-status.json`. Zéro tolérance pour le faux succès (*testing theater*).

---

## 2. TABLE DE ROUTAGE D'INTENTION VERS SOUS-AGENTS & SKILLS

| Intention Détectée | Skills `san_*` | Worker Swarm (`gemini-4-hydrogen-xhigh`) | Action Imposée |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | Matrice 2 approches & compromis |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Pre-Mortem, Contract-First & Fitness |
| *Cartographie, cache repo, index AST* | `san_cartographer` | `san-researcher` | Générer/consulter .agents/cache/REPO_MAP.md |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | Studio Duel UI, 5 états, export PNG + DOM |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` / `san-qa-auditor` | Delivery parallèle (`run_workflow`), tests & UI |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | Présomption de défaut, OWASP, Fitness, PNG |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Multi-stack, rollback, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Fiches stores, conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, tracking KPIs |

---

## 3. RÈGLES DE GOUVERNANCE NATIVES (`.agents/rules/`)

* **`.agents/rules/PROJECT.md`** (`trigger: always_on`) — Constitution technique, `PROJECT_PROFILE` et doctrine `swarm` (`gemini-4-hydrogen-xhigh`).
* **`.agents/rules/PRODUCT.md`** (`trigger: model_decision`) — Cadrage fonctionnel, personas et contraintes terrain modulaires.
* **`.agents/rules/BRAND.md`** (`trigger: glob`) — Archétype esthétique, tokens chromatiques, typographie et motion 60 fps.
* **`.agents/rules/API.md`** (`trigger: glob`) — Contrats d'endpoints, enveloppe JSON canonique, idempotence et suite Bruno.
* **`.agents/rules/LOGO.md`** (`trigger: glob`) — Spécifications vectorielles maîtres et matrice d'assets PNG.

---

## 4. SUIVI OPÉRATIONNEL & ROADMAPS (`roadmaps/`)

* **Roadmap Active en Cours :** `roadmaps/[NOM_ROADMAP_ACTIVE].md`
* **Archives des Roadmaps Achevées (100% cochées) :** `roadmaps/archives/`
* **Idéations & Brainstorming :** `roadmaps/ideas/`
* **Journal de Bord :** `CHANGELOG.md` (Keep a Changelog / SemVer)
