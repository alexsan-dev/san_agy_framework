# TABLE DE ROUTAGE PRINCIPALE & CONSTITUTION ANTIGRAVITY (`GEMINI.md`)

> **Index Souverain Local :** Ce fichier régit l'orchestration du framework agentique Antigravity (`san_*`) et fixe les lois d'exécution de session.

---

## 1. LES 6 LOIS D'AIRAIN DE L'ORCHESTRATEUR (HARNESS ENFORCEMENT)

1. **Zéro Solo-Coding en Ligne :** Sur toute tâche de feature, architecture, design, refonte ou audit, l'agent principal **ne code jamais en ligne**. Délégation obligatoire à des sous-agents atomiques dédiés via `invoke_subagent` (micro-retouche triviale $\le 5$ lignes sur 1 fichier autorisée uniquement si explicitement demandée).
2. **Reconnaissance Factuelle Préalable :** Toujours lancer `san-researcher` (`Model: 'flash'`) avant de concevoir, planifier ou coder sur une zone non cartographiée. Interdiction d'assumer l'état du repo sans inspection réelle.
3. **Sous-Agents Atomiques Dédiés :** 1 responsabilité atomique = 1 sous-agent dédié (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`). Paralléliser les flux indépendants.
4. **Doctrine du Doute Contradictoire (Anti-First-Draft Mediocrity) :** Interdiction d'accepter un premier jet plat. Pre-Mortem obligatoire par `san-architect`, critique sur pixels PNG réels pour tout écran, et audit sceptique indépendant par `san-qa-auditor` sous présomption d'insuffisance avant tout commit.
5. **Contract-First Adaptatif :** Verrouiller OpenAPI 3.1 / Zod / tests Bruno avant d'intégrer l'UI consommatrice.
6. **Preuve par le Code Fail-Closed :** Zéro tâche validée `- [x]` sans test exécuté retournant `exit 0`. Zéro tolérance pour le faux succès (*testing theater*).

---

## 2. TABLE DE ROUTAGE D'INTENTION VERS SOUS-AGENTS & SKILLS

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

* **`.agents/rules/PROJECT.md`** (`trigger: always_on`) — Constitution technique, `PROJECT_PROFILE` et cascade cognitive (`pro`/`flash`).
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
