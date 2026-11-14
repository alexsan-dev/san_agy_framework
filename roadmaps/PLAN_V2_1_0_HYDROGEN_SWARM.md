---
id: ROADMAP-SAN_AGY_V2_1_0-14112026
version: "2.1.0"
theme: "Autonomous Orchestrator (Argon) + 100% Gemini 4 Hydrogen XHigh Swarm + Studio UI Engine"
status: "COMPLETED"
created_at: "2026-11-14T06:15:00+01:00"
---

# PLAN D'EXÉCUTION PARALLÈLE (`SWARM`) — `san_agy_framework v2.1.0`

> **Objectif Stratégique :** Faire passer `san_agy_framework` en `v2.1.0` avec une **autonomie mécanique totale de l'Orchestrateur (`Argon` / `Carbon`)**. L'utilisateur exprime son besoin en une phrase sans jamais manipuler `/model` ni dicter quel sous-agent appeler : l'Orchestrateur pilote automatiquement ses workers en parallèle via l'outil natif **`swarm(action: "add", model: "gemini-4-hydrogen-xhigh")`** (zéro `invoke_subagent` qui dégraderait en `gemini-3.8-flash-tiered`, zéro `inherit` qui brûlerait le quota hebdomadaire `Argon`).

---

## Architecture de Déploiement en 5 Chantiers `Swarm` (`model: "gemini-4-hydrogen-xhigh"`)

Chaque worker du `swarm` est épinglé explicitement sur **`model: "gemini-4-hydrogen-xhigh"`** et opère sur un périmètre de fichiers strictement disjoint pour permettre une exécution 100 % parallèle sans conflit d'édition.

| Worker Swarm | Modèle Épinglé | Périmètre de Fichiers Exclusif | Livrables Clés |
| :--- | :--- | :--- | :--- |
| **`worker-constitution`** | `gemini-4-hydrogen-xhigh` | `src/skills/san_init/templates/*`, `src/agents/*.md`, `src/skills/san_subagent_manager/*`, `src/skills/san_planner/*` | Autonomie de l'Orchestrateur (`Argon` $\rightarrow$ `swarm` Hydrogen XHigh), purge de `3.1-pro`/`3.8-flash`, Contract-First & Fitness Functions dans `san-architect.md`. |
| **`worker-hooks`** | `gemini-4-hydrogen-xhigh` | `src/hooks/hooks.json`, `src/hooks/scripts/stop_guard.mjs`, `src/hooks/scripts/pre_invocation.mjs` | Hook `Stop` (`stop_guard.mjs`) avec Circuit Breaker anti-boucle (max 2 essais, exemption docs/greenfield) + migration `pre_invocation.mjs` vers `systemMessage` (Hooks API v2). |
| **`worker-workflows`** | `gemini-4-hydrogen-xhigh` | `src/skills/san_executer/*`, `src/skills/san_qa_security_expert/*` | Scripts Python `run_workflow` + JSON Schema (`autonomous_slice_workflow.py`, `parallel_inquisition_workflow.py`) + protocole `swarm` Hydrogen XHigh. |
| **`worker-studio-ui`** | `gemini-4-hydrogen-xhigh` | `src/skills/san_designer/*`, `src/skills/san_exporter/*` | `export_png.mjs` v2 (Multi-Viewports `mobile,tablet,desktop` sur instance Chromium unique + Linter Géométrique DOM `--audit-dom`) + Mode *Studio Duel UI* (`option-a` vs `option-b`) + Motion System 5 états. |
| **`worker-cli-whatsnew`** | `gemini-4-hydrogen-xhigh` | `package.json`, `src/cli/*`, `src/hooks/scripts/session_start.mjs`, `CHANGELOG.md` | Version `2.1.0`, module **"What's New on san-agy"** (`src/cli/whats_new.js` + terminal output sur `update` + injection unique au 1er `SessionStart` via `.agents/cache/whats_new_pending.json`), Mode Héritage Léger (`--light` / `.agents/skills.json` `"inherits"`). |

---

## Détail des Tâches par Chantier

### Chantier 1 : `worker-constitution` — Orchestrateur Autonome, Doctrine `gemini-4-hydrogen-xhigh` & Contract-First
- [x] **1.1** Mettre à jour `src/skills/san_init/templates/AGENTS_INDEX_TEMPLATE.md`, `GEMINI_INDEX_TEMPLATE.md` et `rules/PROJECT_TEMPLATE.md` :
  - Inscrire la doctrine **Orchestrateur Souverain (`Argon` / `Carbon`)** : délégation automatique sans sollicitation manuelle de l'utilisateur.
  - Documenter la vérité technique CLI v1.5.8 : interdiction de `invoke_subagent(Model: "inherit")` (protection quota Argon) et remplacement des appels `invoke_subagent` par **`swarm(action: "add", model: "gemini-4-hydrogen-xhigh")`** pour garantir l'exécution réelle sur **Gemini 4 Hydrogen (XHigh)** (et éviter le fallback caché sur `gemini-3.8-flash-tiered`).
- [x] **1.2** Mettre à jour les 8 fichiers `src/agents/*.md` (`san-architect`, `san-qa-auditor`, `san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-researcher`, `san-ops-devops`, `san-growth-legal`) et `src/skills/san_subagent_manager/scripts/validate_subagent_spec.sh` :
  - Remplacer toutes les mentions de `gemini-3.1-pro-high` et `gemini-3.8-flash-high` par **`gemini-4-hydrogen-xhigh`** (`model: "pro"` dans le frontmatter legacy pour compatibilité ascendante).
- [x] **1.3** Enrichir `src/agents/san-architect.md`, `src/skills/san_planner/SKILL.md` et `src/skills/san_planner/templates/ROADMAP_TEMPLATE.md` :
  - Imposer l'**Architecture Contract-First** (schémas OpenAPI 3.1 / Zod / TypeBox partagés avant codage) et les **Architectural Fitness Functions** (tests automatisés d'étanchéité inter-modules et de budgets techniques vérifiés au Quality Gate).
- [x] **1.4** Enrichir `src/agents/san-coder-front.md` et `src/agents/san-designer-worker.md` :
  - Intégrer le **Standard UI 5 États non-destructifs** (*Stale-While-Revalidate*) + **Motion System** (`cubic-bezier`, transitions d'entrée, `prefers-reduced-motion`, cibles tactiles $\ge 44\times 44\text{px}$) + protocole **Studio Duel UI** (Variante A vs Variante B).

### Chantier 2 : `worker-hooks` — Hook `Stop` (`stop_guard.mjs`) & Hooks API v2 (`systemMessage`)
- [x] **2.1** Créer `src/hooks/scripts/stop_guard.mjs` (`chmod +x`) :
  - Lire le payload JSON sur `stdin` (`terminationReason`, `continuationActive`, `workspacePaths`).
  - Implémenter le **Circuit Breaker anti-boucle infinie** :
    - Autoriser immédiatement l'arrêt (`{}`) si `continuationActive === true`, si aucun fichier de code applicatif n'est modifié dans `git status --porcelain` (exemption `DOC_ONLY`), ou après 2 relances consécutives enregistrées dans `.agents/cache/stop-guard-state.json`.
    - Si du code applicatif a été modifié sans preuve récente de Quality Gate vert (`.agents/cache/last-gate-status.json`), renvoyer `{"decision": "continue", "reason": "[SAN.AGY STOP GUARD] Code modifié sans Quality Gate validé..."}`.
- [x] **2.2** Mettre à jour `src/hooks/hooks.json` pour enregistrer l'événement `"Stop"` pointant vers `node ./hooks/scripts/stop_guard.mjs` (timeout `5`).
- [x] **2.3** Migrer `src/hooks/scripts/pre_invocation.mjs` de `ephemeralMessage` (déprécié) vers `systemMessage: { systemMessage: reminderText }` (Hooks API v2) en injectant le rappel d'autonomie Map-First (`REPO_MAP.md`) + délégation `swarm` sur `gemini-4-hydrogen-xhigh`.

### Chantier 3 : `worker-workflows` — Workflows Python Déterministes (`run_workflow` + JSON Schema)
- [x] **3.1** Créer `src/skills/san_executer/scripts/autonomous_slice_workflow.py` et mettre à jour `src/skills/san_executer/SKILL.md` (`<= 130` lignes) :
  - Pipeline Python déterministe pour `run_workflow` utilisant `phase()`, `parallel()`, `pipeline()` et validation JSON Schema (`CODE_SLICE_SCHEMA` et `QA_VERDICT_SCHEMA`) avec boucle multi-tours `coder ↔ san-qa-auditor` (max 3 tours) et mise à jour de `.agents/cache/last-gate-status.json`.
- [x] **3.2** Créer `src/skills/san_qa_security_expert/scripts/parallel_inquisition_workflow.py` et mettre à jour `src/skills/san_qa_security_expert/SKILL.md` (`<= 130` lignes) :
  - Fan-out parallèle sur les vecteurs OWASP, Substance des Tests (anti-Mock Theater) et Performance/UI, avec sortie JSON Schema agrégée.

### Chantier 4 : `worker-studio-ui` — `export_png.mjs` v2 (Multi-Viewports + Linter Géométrique DOM) & Studio Duel UI
- [x] **4.1** Mettre à niveau `src/skills/san_designer/scripts/export_png.mjs` (et synchroniser `src/skills/san_exporter/scripts/export_png.mjs`) :
  - Ajouter l'option `--viewports=mobile,tablet,desktop` (redimensionnement séquentiel d'une instance Chromium unique : Mobile `390×844`, Tablette `820×1180`, Desktop `1440×900`).
  - Ajouter le **Linter Géométrique DOM (`--audit-dom` / activé par défaut avec rapport JSON optionnel `--report`)** via `page.evaluate()` : détection mathématique des débordements horizontaux (`scrollWidth > clientWidth`), collisions de boîtes, cibles interactives `< 44×44px`, et chiffres sans `tabular-nums`.
  - Conserver 100 % de compatibilité ascendante avec les arguments existants (`--input`, `--output`, `--target`, `--width`, `--height`).
- [x] **4.2** Mettre à jour `src/skills/san_designer/SKILL.md` (`<= 130` lignes) :
  - Intégrer le **Mode Studio Duel UI** (génération parallèle de 2 directions artistiques `option-a` vs `option-b` via `swarm` sur `gemini-4-hydrogen-xhigh`, export multi-viewports + audit géométrique DOM, arbitrage visuel par `san-qa-auditor`).

### Chantier 5 : `worker-cli-whatsnew` — CLI `v2.1.0`, « What's New on san-agy », Mode `--light` & Validation Tests
- [x] **5.1** Passer `package.json` en `"version": "2.1.0"` et documenter la release dans `CHANGELOG.md`.
- [x] **5.2** Créer `src/cli/whats_new.js` et l'intégrer dans `src/cli/index.js`, `src/cli/installer.js` et `src/hooks/scripts/session_start.mjs` :
  - Afficher l'encart **"What's New on san-agy v2.1.0"** dans le terminal lors d'un `npx san-agy update` (et via la sous-commande `npx san-agy whats-new`).
  - Écrire `.agents/cache/whats_new_pending.json` (`{ "version": "2.1.0", "seen": false, ... }`) lors de `updateFramework()`.
  - Dans `src/hooks/scripts/session_start.mjs`, si `.agents/cache/whats_new_pending.json` a `seen: false`, injecter le bloc `[WHAT'S NEW ON SAN.AGY v2.1.0]` dans le `systemMessage` au 1er démarrage d'`agy`, puis marquer `seen: true`.
- [x] **5.3** Ajouter le **Mode Héritage Léger (`--light`)** dans `src/cli/index.js` et `src/cli/installer.js` :
  - Générer `.agents/skills.json` avec `"inherits"` tout en maintenant `.agents/rules/`, `.agents/hooks/` et `.agents/cache/` 100 % locaux au projet, et adapter `runDoctor()` pour valider `stop_guard.mjs` ainsi que le mode `--light`.
- [x] **5.4** Mettre à jour les suites de tests (`tests/v2/test_phase1_rules.sh`, `tests/v2/test_phase2_agents.sh`, `tests/v2/test_phase3_hooks.sh`, `tests/v2/test_phase5_skills.sh`, `tests/v2/test_phase6_cli.sh`, `tests/v2/test_e2e_v2_harness.sh`, `tests/phase7/test_cli.sh`, `tests/phase8/test_e2e_full.sh`) et valider `npm test` à 100 % (`exit 0`).
