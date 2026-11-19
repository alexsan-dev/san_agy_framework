<!-- san_* context (generated) -->
<!-- opencode context (generated) -->
# CONSTITUTION & ROUTING (`AGENTS.md`)

> **SAN AI Harness v3.0 (Dual-Harness) :** Orchestration libre via `/model` (`inherit-user-model`). Cycle natif `Plan → Execute` autorisé pour les tâches simples/mono-couche ; workers configurés dans `.agents/models.json` (`san-harness models`).

## 1. PRINCIPES DIRECTEURS (LÉGERS & ADAPTATIFS)

1. **Orchestration Adaptative (Dual-Harness) :** Pas de modèle imposé à l'orchestrateur. Tâches simples/mono-couche $\rightarrow$ `Plan → Execute` natif autorisé ; features multi-couches, Studio Duel UI ou audit `san-qa-auditor` $\rightarrow$ **AGY** `swarm(action: "add", model: "<agy.executor>")` ou **OpenCode V2.3** `san_swarm(action: "dispatch")` (ou `subagent` via `.agents/models.json`). `invoke_subagent(Model: "inherit")` évité sous AGY.
2. **Respect des Règles & Alignement :** Honorer `.agents/rules/*.md`. Cadrer les choix structurants (`ask_question`/`question`) et capturer les URLs UI (`export_png.mjs --url`) avant toute roadmap ou refonte UI.
3. **Doute Contradictoire & Contract-First :** Pre-Mortem (`san-architect`), contrats OpenAPI/Zod gelés sur chantiers multi-couches, duel UI + audit DOM/PNG (`san-qa-auditor`).
4. **Preuve par le Code :** Zéro `- [x]` sans test réel exécuté (`exit 0`), zéro *testing theater*.
5. **Compaction 120k (Zéro Cache) :** Contexte allégé avec compaction automatique à 120k tokens (`/compact`).

## 2. TABLE DE ROUTAGE D'INTENTION

| Intention Détectée | Skill `san_*` | Worker Dual-Harness | Action Clé |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` | `ask_question` + 2 approches |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` / `san-researcher` | Alignement, Pre-Mortem, Contract-First |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | `--url`, Studio Duel, 5 états, PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` | Plan→Execute ou `swarm`/`san_swarm`, tests |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` | OWASP, Fitness, audit DOM |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` | Rollback < 30s, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` | Conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` | SEO technique, KPIs |

## 3. RÈGLES NATIVES (`.agents/rules/`) & SKILLS
`PROJECT.md` (`always_on`), `PRODUCT.md` (`model_decision`), `BRAND.md`, `API.md`, `LOGO.md` (`glob`).

{{SKILLS_LIST}}
