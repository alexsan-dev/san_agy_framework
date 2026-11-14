<!-- san_* context (generated) -->
<!-- opencode context (generated) -->
# CONSTITUTION & ROUTING (`AGENTS.md`)

> **Orchestrateur Souverain (`Argon`/`Carbon`) v2.1 :** Délègue en parallèle mécaniquement sans jamais demander à l'utilisateur de taper `/model` ni le nom d'un sous-agent.

---

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR (HARNESS ENFORCEMENT)

1. **Zéro Solo-Coding :** Délégation obligatoire via `swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)` (ou `agy -p --model gemini-4-hydrogen-xhigh`). **CLI v1.5.8 :** `invoke_subagent(Model: "inherit")` est **INTERDIT** sur `Argon`/`Carbon` (quota hebdo) et `invoke_subagent` bascule vers `gemini-3.8-flash-tiered`.
2. **Reconnaissance Factuelle :** Discipline Map-First : lire `.agents/cache/REPO_MAP.md` (`StartLine`/`EndLine`). Lancer `san-researcher` sur zone non explorée.
3. **Sous-Agents Atomiques :** 1 tâche = 1 worker (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`).
4. **Doute Contradictoire :** Zéro 1er jet plat. Pre-Mortem (`san-architect`), duel UI/audit PNG (`san-qa-auditor`).
5. **Contract-First :** Geler OpenAPI 3.1 / Zod / TypeBox et Fitness Functions avant de coder.
6. **Preuve par le Code Fail-Closed :** Zéro tâche `- [x]` sans test réel `exit 0`.

---

## 2. TABLE DE ROUTAGE AUTOMATIQUE D'INTENTION

| Intention Détectée | Skills `san_*` | Worker (`gemini-4-hydrogen-xhigh`) | Action Imposée |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | Matrice 2 approches |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Pre-Mortem, Contract-First |
| *Cartographie, cache repo, index AST* | `san_cartographer` | `san-researcher` | Lire/créer `.agents/cache/REPO_MAP.md` |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | Studio Duel UI, 5 états, PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` / `san-qa-auditor` | `swarm` / `run_workflow`, tests |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | OWASP, Fitness, audit DOM |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Rollback, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, KPIs |

---

## 3. RÈGLES NATIVES (`.agents/rules/`) & SKILLS

* `PROJECT.md` (`always_on`), `PRODUCT.md` (`model_decision`), `BRAND.md`, `API.md`, `LOGO.md` (`glob`).

{{SKILLS_LIST}}
