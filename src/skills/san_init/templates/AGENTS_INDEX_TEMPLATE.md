<!-- san_* context (generated) -->
<!-- opencode context (generated) -->
# CONSTITUTION & ROUTING (`AGENTS.md`)

> **Orchestrateur Dual-Harness v2.2 :** Aligner cadrage (`ask_question`/`question`) & captures UI (`export_png.mjs --url`), puis déléguer sans demander `/model` ni nom d'agent.

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR

1. **Zéro Solo-Coding Dual-Harness :** Déléguer via **AGY** `swarm(action:"add", model:"gemini-4-hydrogen-xhigh")` ou **OpenCode V2** `subagent({agent:"san-..."})` (`.agents/models.json`, `san-framework models`). `invoke_subagent(Model:"inherit")` **INTERDIT** (`Argon`/`Carbon` + fallback `3.8-flash`).
2. **Reconnaissance Factuelle :** Map-First (`.agents/cache/REPO_MAP.md`). Cadrer avec l'utilisateur et capturer les URLs UI avant de déléguer roadmap/maquette.
3. **Sous-Agents Atomiques :** 1 tâche = 1 worker (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`).
4. **Doute Contradictoire :** Pre-Mortem (`san-architect`), duel UI/PNG (`san-qa-auditor`), relais sceptique (`san_transcriber` $\rightarrow$ `roadmaps/transcripts/`).
5. **Contract-First :** Geler OpenAPI 3.1 / Zod / TypeBox et Fitness Functions avant codage.
6. **Preuve par le Code Fail-Closed :** Zéro `- [x]` sans test réel `exit 0`.

## 2. TABLE DE ROUTAGE AUTOMATIQUE D'INTENTION

| Intention Détectée | Skill `san_*` | Worker Dual-Harness | Action Imposée |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | `ask_question` + 2 approches |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Alignement, Pre-Mortem, Contract-First |
| *Cartographie, cache repo* | `san_cartographer` | `san-researcher` | `.agents/cache/REPO_MAP.md` |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | `--url`, Studio Duel, 5 états, PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` | `swarm`/`subagent`, `run_workflow`, tests |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | OWASP, Fitness, audit DOM |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Rollback < 30s, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, KPIs |
| *Relais fin de quota* | `san_transcriber` | Orchestrateur | `roadmaps/transcripts/` |

## 3. RÈGLES NATIVES (`.agents/rules/`) & SKILLS
`PROJECT.md` (`always_on`), `PRODUCT.md` (`model_decision`), `BRAND.md`, `API.md`, `LOGO.md` (`glob`).

{{SKILLS_LIST}}
