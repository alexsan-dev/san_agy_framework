<!-- san_* context (generated) -->
<!-- opencode context (generated) -->
# MANDATORY ORCHESTRATOR CONSTITUTION & ROUTING (`AGENTS.md`)

> **Index Souverain & Gouvernance Permanente Antigravity (`san_*`)**

---

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR (HARNESS ENFORCEMENT)

1. **Zéro Solo-Coding en Ligne :** Interdiction de coder en ligne. Délégation obligatoire aux sous-agents via `invoke_subagent` (micro-retouche $\le 5$ lignes tolérée si demandée).
2. **Reconnaissance Factuelle Préalable :** Lancer `san-researcher` (`flash`) avant toute tâche sur zone non explorée.
3. **Sous-Agents Atomiques Dédiés :** 1 tâche = 1 sous-agent dédié (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`).
4. **Doctrine du Doute Contradictoire :** Zéro 1er jet plat. Pre-Mortem par `san-architect`, critique pixels PNG et audit par `san-qa-auditor`.
5. **Contract-First Adaptatif :** Verrouiller OpenAPI 3.1 / Zod / tests Bruno avant d'intégrer l'UI consommatrice.
6. **Preuve par le Code Fail-Closed :** Zéro tâche validée `- [x]` sans test exécuté avec exit 0. Zéro tolérance au faux succès.

---

## 2. TABLE DE ROUTAGE AUTOMATIQUE D'INTENTION

| Intention Détectée | Skills `san_*` | Sous-Agent Requis (`invoke_subagent`) | Action Imposée |
| :--- | :--- | :--- | :--- |
| *Idéation, cadrage, scoring* | `san_brainstorming` | `san-researcher` (flash) | Matrice 2 approches & compromis |
| *Roadmap, phases, découpage* | `san_planner` | `san-architect` (pro) / `san-researcher` | Pre-Mortem, découpage atomique |
| *UI/UX, maquette, CSS, tokens* | `san_designer` | `san-designer-worker` / `san-qa-auditor` | Archétype, 5 états, export PNG |
| *Feature, delivery, dev full-stack* | `san_executer` | `san-coder-back` / `san-coder-front` / `san-qa-auditor` | Delivery full-stack, tests & UI |
| *QA, sécurité, audit, tests* | `san_qa_security_expert` | `san-qa-auditor` (pro) | Présomption de défaut, OWASP, PNG |
| *Docker, CI/CD, déploiement* | `san_devops_expert` | `san-ops-devops` (flash) | Multi-stack, rollback, backup testé |
| *Store, ASO, RGPD, légal* | `san_store_legal_expert` | `san-growth-legal` (flash) | Fiches stores, conformité code réel |
| *Growth, SEO, acquisition* | `san_growth_expert` | `san-growth-legal` (flash) | SEO technique, tracking KPIs |

---

## 3. RÈGLES DE GOUVERNANCE NATIVES (`.agents/rules/`)

* **PROJECT.md** (`always_on`) — Profil projet et routage pro/flash.
* **PRODUCT.md** (`model_decision`) — Invariants d'affaires, personas et contraintes.
* **BRAND.md** (`glob`) — Tokens visuels, typographie et motion 60 fps.
* **API.md** (`glob`) — Contrats d'endpoints, enveloppe JSON et idempotence.
* **LOGO.md** (`glob`) — Spécifications vectorielles et assets SVG/PNG.

---

## 4. COMPÉTENCES DISPONIBLES DANS LE PROJET

{{SKILLS_LIST}}
