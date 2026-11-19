# CHANGELOG — `san_ai_harness`

> **Langue :** Français | [English version](CHANGELOG.en.md)

Toutes les modifications notables apportées à ce projet sont consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [Unreleased]

### Planned
- Publication officielle sur le registre npm (`npm publish --access public`).
- Déploiements étendus sur les dépôts de production.

---

## [3.0.0] - 2026-11-19

### Added
- **Identité `san_ai_harness` (`@alexsan/san-ai-harness`) & Binaire `san-harness` :**
  - Renommage du package npm, du dépôt GitHub (`alexsan-dev/san_ai_harness`) et de l'identité visuelle, avec ajout du binaire principal `san-harness` (conservant les alias `san-framework` et `agy-framework`).
  - Nouveaux logos vectoriels adaptatifs pour thèmes GitHub Sombre et Clair (`logos/san_harness_logo_dark.svg`, `logos/san_harness_logo_light.svg`, `logos/san_harness_icon.svg`) intégrés via `<picture>` dans les READMEs.
- **Plugin Natif OpenCode v2.3.0 (`src/opencode/san-harness-plugin.mjs`) & Swarm Board :**
  - Plugin ESM pur Node (zéro dépendance Bun) déployé automatiquement dans `.agents/opencode/` lors de `init --opencode` / `update --opencode`.
  - Enregistre l'outil **`san_swarm`** (`dispatch`, `board`, `status`), le panneau Markdown **Swarm Board** + Workflow Summary, et la commande `/san-board` dans `opencode.json`.
  - Gère l'orchestrateur principal **`san-orchestrator`** sans champ `model` codé en dur (hérite du `/model` utilisateur actif).
- **Compaction Automatique 120k Tokens (`--compaction=<tokens>`) :**
  - Ajout de `compaction: { targetTokens: 120000, auto: true }` dans `.agents/models.json` et de l'option `san-harness models --compaction=<tokens>`.
  - Réécriture de `src/hooks/scripts/pre_invocation.mjs` en garde de compaction automatique `120 000` tokens (silencieux sous le seuil) et configuration native `compaction` (`auto: true`, `background: true`, `keep.tokens: 12000`, `buffer: 20000`) dans `opencode.json` + hooks plugin.

### Changed
- **Découplage Complet des Modèles & Doctrine Adaptative (`inherit-user-model`) :**
  - Suppression de tous les noms de modèles orchestrateurs codés en dur (`Argon`, `Carbon`, `hy4`, `gemini-4-argon-high`, `gemini-4-hydrogen-xhigh`) dans les 8 agents, 17 skills, 17 wrappers et templates (`AGENTS_INDEX_TEMPLATE.md`, `GEMINI_INDEX_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `ROADMAP_TEMPLATE.md`).
  - L'orchestrateur hérite librement du `/model` choisi par l'utilisateur ; seul l'exécuteur worker reste configuré dans `.agents/models.json` (`san-harness models`).
  - Allègement de la doctrine d'exécution : autorisation explicite du cycle natif **`Plan → Execute`** pour les tâches simples/mono-couche, réservant `swarm` (Antigravity) et `san_swarm` / `subagent` (OpenCode) au parallélisme multi-couches, aux Duels UI et à l'inquisition QA (`san-qa-auditor`).
  - Migration automatique des mentions legacy v2.x dans `.agents/rules/*.md` lors de `san-harness update` tout en préservant le contenu métier utilisateur et les références cryptographiques légitimes (`Argon2id`).

### Removed
- **Suppression Complète de `.agents/cache/`, de la Cartographie AST & des Transcripts :**
  - Éradication des modules consommateurs de tokens : `src/skills/san_cartographer/`, `src/skills/san_transcriber/`, `src/hooks/scripts/post_tool_indexer.mjs`, `src/hooks/scripts/stop_guard.mjs`, `REPO_MAP.md`, `.agents/cache/` et `roadmaps/transcripts/` (catalogue passé de 19 à **17 skills** et de 5 à **3 hooks sobres**).
  - Purge active et automatique lors de `san-harness init` / `san-harness update` (`purgeObsoleteArtifacts()` supprimant `.agents/cache/`, anciens hooks, anciens skills et `.agents/AGENTS.md`) avec contrôle de santé intégré dans `san-harness doctor`.

---

## [2.2.1] - 2026-11-18

### Fixed
- Correction de `ReferenceError: resolveProjectRoot is not defined` dans `san-framework update` (`src/cli/installer.js`).
- Reconnaissance native des installations existantes (`.agents/` ou `.agents/skills.json`) et résolution ascendante en contexte monorepo sans réinstallation parasite.
- Durcissement anti-OOM de l'ancien indexeur en mode *Git-First* (`git ls-files`) sur les dépôts volumineux (module ensuite remplacé par la compaction 120k en v3.0.0).

---

## [2.2.0] - 2026-11-14

### Added
- **1. Architecture Dual-Harness (`Antigravity` + `OpenCode V2`) & Commande `san-framework models` :**
  - Support natif d'**OpenCode V2 (`v2.2.7+` / `2.3.0`)** dans `mergeOpencodeConfig()` (`src/cli/installer.js`) avec génération et fusion automatiques de la clé `"agents"` dans `opencode.json` pour les 8 sous-agents `san-*` (`mode: "subagent"`, `description`, `model`, `system`, et `permissions` en refus d'édition sur les agents en lecture seule `san-researcher`, `san-architect` et `san-qa-auditor`), invocables via l'outil `subagent` en parallèle du moteur `swarm` d'Antigravity.
  - Gestionnaire de profil modèle **`.agents/models.json`** (`DEFAULT_MODELS_CONFIG`, `profile: "unified-executor"`) et nouvelle commande CLI **`san-framework models`** (`--opencode=<model>`, `--agy=<model>`, `--orchestrator=<model>`, `--set=<model>`, `--dir=<chemin>`) pilotant le **Profil Exécuteur Unifié** : ex. `opencode-go/deepseek-v4-pro` ou `opencode-go/qwen3.8-flash` (orchestrateur `opencode-go/hy4`) sous OpenCode V2, et `gemini-4-hydrogen-xhigh` (orchestrateur `gemini-4-argon-high`) sous Google Antigravity, avec resynchronisation immédiate de `opencode.json`.
  - Resynchronisation automatique d'`opencode.json` lors de `san-framework update` lorsque `opencode.json` est déjà présent ou avec `--opencode`.
- **2. Nouveau 19e Skill : `san_transcriber` (`src/skills/san_transcriber/`, `roadmaps/transcripts/`) :**
  - Module de relais de fin de quota invoqué via `/san_transcriber` (`SKILL.md <= 130` lignes, `scripts/transcript_helper.mjs`, `templates/TRANSCRIPT_TEMPLATE.md`).
  - Génère des transcripts déterministes dans `roadmaps/transcripts/TRANSCRIPT_<ROADMAP>_<DATE>.md` liés aux roadmaps actives (`roadmaps/*.md`), collectant l'état Git et l'avancement des tâches (`- [x]` / `- [ ]`).
  - Intègre le **Protocole de Relais Sceptique (*Doubt & Verify*)** poussant l'agent entrant à auditer, vérifier par les faits et challenger le travail du premier agent.
  - Détection automatique du transcript le plus récent dans `roadmaps/transcripts/*.md` au démarrage de session par `src/hooks/scripts/session_start.mjs` (bannière `[SAN.AGY CONSTITUTION v2.2]`).
- **3. Capture Web Live (`export_png.mjs --url`) & Résolution Playwright Universelle :**
  - Ajout des options `--url=<https://...>` (URL unique ou liste CSV) et `--full-page` dans `export_png.mjs` (`san_designer` et `san_exporter`) pour capturer les vrais pixels de sites web d'inspiration via Playwright (viewports par défaut `desktop` `1440×900` + `mobile` `390×844` dans `design/references/<hostname>-<pathname>-<viewport>.png`, avec support `--audit-dom`).
  - Extension de `loadPlaywright()` pour résoudre Playwright dans le projet local (`cwd`), `NODE_PATH`, la hiérarchie du script (`import.meta.url` / `realpathSync`), le plugin global (`~/.gemini/antigravity-cli/plugins/san-framework/node_modules`) et le cache `~/.npm/_npx`.

### Changed
- **Dé-Lobotomisation Cognitive & Alignement Socratique (`AGENTS_INDEX_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `san_planner`, `san_brainstorming`, `san_designer`) :**
  - Remplacement de l'injonction aveugle de délégation immédiate par la **Règle d'Alignement Socratique & Visuel** (Étape 0) : obligation pour l'Orchestrateur (`Argon 4` / `hy4`) d'aligner les choix structurants avec l'utilisateur via `ask_question` / `question` et d'inspecter les captures réelles (`export_png.mjs --url`) avant toute délégation de rédaction de roadmap ou de maquette aux sous-agents.
- **Unification Dual-Harness & Déduplication Stricte à l'Octet Près (Audit HY4) :**
  - Passage du catalogue de **18 à 19 skills** (`package.json`, `src/plugin/plugin.json`, `src/cli/whats_new.js`, `src/cli/index.js`, `src/cli/installer.js`) et suppression du couplage mono-vendor au profit du **Profil Exécuteur Unifié** (`Antigravity` `swarm` | `OpenCode V2` `subagent`) dans les 8 sous-agents et 19 skills.
  - Unification stricte à l'octet près (`cmp -s` = 0) des 3 paires de scripts partagés : `export_png.mjs` (`san_designer` $\leftrightarrow$ `san_exporter`), `archive_roadmap.sh` (`san_planner` $\leftrightarrow$ `san_doc_keeper`, préservant `roadmaps/archives/<BASENAME>` et l'en-tête SHA-256) et `svg_to_png.mjs` (`san_init` $\leftrightarrow$ `san_exporter`, incluant l'aplatissement Apple `ITMS-90717`).
  - Synchronisation des 19 wrappers `skills/*.md` et `sub-skills/*.md` en `version: "2.2.0"` (incluant `san_transcriber.md`).

### Fixed
- **Élimination des faux positifs dans `stop_guard.mjs` (`src/hooks/scripts/stop_guard.mjs`) :**
  - Filtrage par horodatage `mtimeMs` ignorant les fichiers modifiés préexistants (antérieurs à 10 minutes ou au dernier `last-gate-status.json`) afin d'éviter les blocages intempestifs lors de sessions de cadrage ou de planification sur dépôts déjà sales.
  - Extension des exemptions aux fichiers et répertoires non applicatifs : `design/**`, `logos/**`, `.opencode/**`, `opencode.json`, `opencode.jsonc`, `.gitignore`, `*.md`, `*.mdx`, `*.txt`, `roadmaps/**`, `docs/**`, `.agents/**`.
- **Hygiène Python `.gitignore` (Audit HY4) :**
  - Ajout de `__pycache__/`, `*.py[cod]` et `*$py.class` dans `.gitignore` à la racine du dépôt ainsi que dans le bloc d'isolation généré par `src/skills/san_init/scripts/git_ai_hygiene.sh`.

---

## [2.1.0] - 2026-11-14

### Added
- **1. What's New on san-agy (`src/cli/whats_new.js`, `san-framework whats-new`) :**
  - Encart de release notes structuré affiché dans le terminal lors d'un `san-framework update` et consultable à tout moment via `npx @alexsan/agy-framework whats-new`.
  - Notification automatique en **injection unique** au premier `SessionStart` post-mise à jour via `.agents/cache/whats_new_pending.json` (`seen: false` $\rightarrow$ `seen: true`) dans `session_start.mjs`.
- **2. Doctrine Orchestrateur Autonome (`Argon` / `Carbon`) $\rightarrow$ Swarm `gemini-4-hydrogen-xhigh` :**
  - L'Orchestrateur délègue automatiquement les tâches en parallèle via l'outil natif `swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)` (ou `agy -p --model gemini-4-hydrogen-xhigh`) sans jamais solliciter manuellement l'utilisateur sur `/model` ni le nom d'un sous-agent.
  - Interdiction stricte de `invoke_subagent(Model: "inherit")` sur `Argon`/`Carbon` (sanctuarisation du quota hebdomadaire) et éradication du fallback silencieux sur `gemini-3.8-flash-tiered`.
  - Basculement intégral des 8 sous-agents natifs et des matrices de routage vers **`gemini-4-hydrogen-xhigh`** (tout en conservant `model: "pro"` dans le frontmatter YAML pour compatibilité CLI).
- **3. Hook `Stop` (`stop_guard.mjs`) + Hooks API v2 (`systemMessage`) :**
  - Nouveau script `src/hooks/scripts/stop_guard.mjs` (`chmod +x`) enregistré sur l'événement `"Stop"` de `src/hooks/hooks.json` (timeout `5s`).
  - **Circuit Breaker anti-boucle infinie** : autorise immédiatement l'arrêt (`{}`) si `continuationActive === true`, sur interruption non-nominale, en session purement documentaire/config (`DOC_ONLY` : `*.md`, `roadmaps/*`, `docs/*`, `.agents/*`), sur repo propre/non-git, ou après 2 relances consécutives tracées dans `.agents/cache/stop-guard-state.json` ; bloque (`decision: "continue"`) si du code applicatif a été modifié sans preuve récente (< 30 min) de Quality Gate vert dans `.agents/cache/last-gate-status.json`.
  - Migration de `src/hooks/scripts/pre_invocation.mjs` de la clé dépréciée `ephemeralMessage` vers le format officiel Hooks API v2 `{ systemMessage: { systemMessage: ... } }`.
- **4. Mode Héritage Léger (`--light` / `.agents/skills.json`) :**
  - Support du drapeau `--light` sur `init` et `update` générant `.agents/skills.json` (`{ "version": 1, "inherits": [".../src/skills"] }`) sans dupliquer les 18 répertoires de skills, tout en conservant `.agents/rules/`, `.agents/agents/`, `.agents/hooks/` et `.agents/cache/` 100 % locaux au projet.
  - Adaptation de `san-framework doctor` pour valider les skills via le chemin `"inherits"` de `.agents/skills.json` ainsi que la présence et l'exécutabilité de `stop_guard.mjs`.
- **5. Workflows Python Déterministes (`run_workflow` + JSON Schema) :**
  - Création de `src/skills/san_executer/scripts/autonomous_slice_workflow.py` (`CODE_SLICE_SCHEMA`, `QA_VERDICT_SCHEMA`, boucle multi-tours `coder ↔ san-qa-auditor`, mise à jour de `.agents/cache/last-gate-status.json`).
  - Création de `src/skills/san_qa_security_expert/scripts/parallel_inquisition_workflow.py` (fan-out parallèle OWASP, substance des tests anti-Mock Theater, performance/UI et `INQUISITION_REPORT_SCHEMA`).
- **6. Architecture Contract-First & Architectural Fitness Functions :**
  - Renforcement de `san-architect.md`, `san_planner/SKILL.md` et `ROADMAP_TEMPLATE.md` imposant le gel des contrats partagés (OpenAPI 3.1 / Zod / TypeBox) avant tout codage parallèle Front/Back et la vérification de fonctions de fitness architecturales au Quality Gate.
- **7. `export_png.mjs` v2 (Multi-Viewports + Linter Géométrique DOM) :**
  - Capture séquentielle multi-viewports (`--viewports=mobile,tablet,desktop` : `390×844`, `820×1180`, `1440×900`) sur une **instance Chromium unique** dans `san_designer` et `san_exporter` tout en conservant 100 % de compatibilité ascendante.
  - Linter géométrique DOM Playwright (`--audit-dom`, `--report=<path.json>`, `--strict-dom`) détectant les débordements horizontaux (`scrollWidth > clientWidth`), collisions de boîtes, cibles tactiles `< 44×44px` et métriques sans `tabular-nums`.
- **8. Mode Studio Duel UI :**
  - Génération parallèle de 2 directions artistiques distinctes (`option-a` vs `option-b`) via `swarm` (`gemini-4-hydrogen-xhigh`) dans `san_designer`, capture multi-viewports + audit DOM et arbitrage visuel par `san-qa-auditor`.
- **9. Standard UI 5 États, Motion System & Continuité Map-First (`san_cartographer` / `REPO_MAP.md`) :**
  - Formalisation des 5 états non-destructifs (`Empty`, `Skeleton Cold-Start`, `Populated`, `Stale-While-Revalidate`, `Error`) et du Motion System (`cubic-bezier`, `@media (prefers-reduced-motion: reduce)`, cibles $\ge 44\times 44\text{px}$, `font-variant-numeric: tabular-nums`) dans `san-coder-front.md` et `san-designer-worker.md`, en synergie continue avec l'indexation Map-First `san_cartographer` & `.agents/cache/REPO_MAP.md`.

### Changed
- Remplacement de toutes les références à `gemini-3.1-pro-high` et `gemini-3.8-flash-high` par `gemini-4-hydrogen-xhigh` dans les gabarits de constitution, sous-agents et validateurs.
- Mise à jour des suites de tests (`tests/v2/*`, `tests/phase7/*`, `tests/phase8/*`) pour valider le CLI `v2.1.0`, `whats-new`, `--light`, `stop_guard.mjs`, `systemMessage` et la doctrine `gemini-4-hydrogen-xhigh`.

---

## [2.0.0] - 2026-10-31

### Added
- **Architecture v2.0 à 4 Couches :**
  - **Couche 1 (Gouvernance Souveraine) :** Déploiement de `<root>/AGENTS.md` (sans frontmatter YAML, < 4096 octets, compatible `always_on` Antigravity & opencode) et des 5 règles normatives `.agents/rules/*.md` dotées des frontmatters YAML officiels (`PROJECT.md`, `PRODUCT.md`, `BRAND.md`, `API.md`, `LOGO.md`).
  - **Couche 2 (8 Sous-Agents Natifs et Spécialisés) :** Création des définitions d'agents `.agents/agents/*.md` :
    - `san-researcher` (`model: "flash"`, lecture seule, exploration et cartographie factuelle) ;
    - `san-architect` (`model: "pro"`, Pre-Mortem à 6 mois, arbitrage 2-approches sans épouvantail, modèles de domaine) ;
    - `san-designer-worker` (`model: "flash"`, maquettes HTML/Tailwind, archétypes visuels, rythme Gestalt, rendu headless PNG) ;
    - `san-coder-back` (`model: "flash"`, dialectique avant frappe, transactions atomiques, vrais tests de domaine) ;
    - `san-coder-front` (`model: "flash"`, modules < 220 lignes, 5 états Stale-While-Revalidate non destructifs, A11y clavier stricte) ;
    - `san-qa-auditor` (`model: "pro"`, inquisiteur sceptique en lecture seule, audit de substance des tests, critique visuelle multimodale sur pixels réels PNG via `read_file`, verdict binaire `LIVRABLE | RETOUR_ATELIER`) ;
    - `san-ops-devops` (`model: "flash"`, CI/CD, conteneurs, Nginx, diagnostics d'infrastructure Fail-Closed) ;
    - `san-growth-legal` (`model: "flash"`, RGPD, conformité des stores, SEO/ASO, boucles d'acquisition).
  - **Couche 3 (Garde-fous Mécaniques du Cycle de Vie) :** Orchestration via `.agents/hooks.json` et 3 scripts de hooks déterministes :
    - `SessionStart` (`session_start.mjs`) : Détection automatique de la roadmap active et du `PROJECT_PROFILE`, injection du prompt système d'orchestration.
    - `PreInvocation` (`pre_invocation.mjs`) : Rappel éphémère (< 110 tokens) interdisant le solo-coding et imposant le doute contradictoire avant toute frappe.
    - `PreToolUse` (`pre_tool_guard.mjs`) : Interception de `write_file`/`edit_file`, blocage de l'archivage de roadmaps incomplètes (`- [ ]`), blocage du *Lorem Ipsum*, et respect des permissions utilisateur.
  - **Couche 4 (17 Runbooks Impératifs de Compétences) :** Refonte intégrale des `SKILL.md` en runbooks directifs condensés ($\le 130$ lignes chacun) avec tables de routage, triggers d'intention et références spécialisées déportées.
- **Ingénierie du Doute Contradictoire (*Doubt Engineering*) :**
  - *Pre-Mortem Systémique* : Simulation des 3 causes majeures d'échec à 6 mois avant tout engagement architectural.
  - *Dialectique Avant Frappe* : Formulation et comparaison obligatoire de 2 approches viables avant tout commit d'implémentation.
  - *Visual Vision Loop* : Pipeline de capture headless Playwright (`export_png.mjs` avec micro-serveur HTTP éphémère Node sur `127.0.0.1:0`), inspection multimodale des pixels PNG via `read_file` par `san-qa-auditor`, et 1 passe de raffinement obligatoire avant livraison.
  - *Inquisition QA & Présomption de Défaut* : Éradication de la complaisance du premier jet (*first-draft sycophancy*), traque du *Testing Theater*, et verdict binaire sans compromis.
- **Profils Contextuels de Projet (`PROJECT_PROFILE`) :**
  - Prise en charge modulaire de 5 profils dans les règles et scripts : `emerging_market` (résilience 3G, Mobile Money, Outbox offline), `global_saas`, `mobile_consumer`, `cli_devtools`, et `api_platform`.
- **Packaging Plugin Officiel Antigravity (`src/plugin/plugin.json`) :**
  - Manifeste v2.0.0 complet avec logo vectoriel, métadonnées, et compatibilité certifiée `agy plugin validate --strict`.
- **Nouvelle Commande CLI `doctor` :**
  - Diagnostic déterministe des 6 piliers de santé (Gouvernance, Règles normatives, Sous-agents natifs, Hooks de cycle de vie, Catalogue des 17 skills $\le 130$ lignes, Étanchéité Git) avec code retour `0` ou `1`.
- **Sauvegarde Réversible (`.agents/backups/`) :**
  - Remplacement de la suppression destructrice des anciennes configurations IA concurrentes par un déplacement horodaté dans `.agents/backups/legacy-ai-configs/<timestamp>/`.

### Changed
- **Refonte des 17 `SKILL.md` en Runbooks Impératifs ($\le 130$ lignes) :**
  - Réduction drastique des pavés verbeux (de 300-600 lignes à $\le 130$ lignes directes) orientés passage à l'action immédiat et délégation aux sous-agents.
- **Constitution Racine `AGENTS.md` Souveraine :**
  - Déploiement par défaut à la racine du projet d'un `AGENTS.md` sans frontmatter YAML (< 4096 octets), assurant un chargement `always_on` automatique par le moteur Antigravity et `opencode`.
- **Basculement Universel en Mode Fail-Closed :**
  - Tous les Quality Gates (`qa_security_gate.sh`, `backend_quality_gate.sh`, `front_quality_gate.sh`, `e2e_verification_gate.sh`) exigent désormais des vérifications réelles et échouent (`exit 1`) si aucun test n'a tourné ou si un outil est manquant.
- **Support Multi-Stack Élargi :**
  - `backend_quality_gate.sh` prend en charge nativement Node/TypeScript (NestJS, Express, Fastify), Python (`ruff`, `mypy`, `pytest`), Go (`go vet`, `go test`), en plus de PHP / Laravel / AdonisJS.
- **Moteur CLI (`src/cli/`) :**
  - `san-framework init --local` déploie les 4 couches complètes avec Smart Merge sans écraser les règles personnalisées.
  - `san-framework init --global` assemble le Plugin officiel Antigravity complet.
  - `san-framework update` permet une migration instantanée v1.0 $\rightarrow$ v2.0 sans écraser les personnalisations du développeur.

### Removed
- **Suppression Formelle de `rules.json` :** Fichier obsolète et non reconnu par le moteur Antigravity définitivement supprimé.
- **Éradication de `--passWithNoTests` :** Interdiction des faux succès sans tests dans `qa_security_gate.sh`.
- **Suppression des `rm -rf` Destructeurs :** Élimination des suppressions irrémédiables dans `git_ai_hygiene.sh`.
- **Suppression des Domaines Propriétaires en Dur :** Retrait de toute référence codée en dur à `alexsan.pro` dans les scripts d'infrastructure (`infra_health_check.sh`, `verify_tracking_and_seo.sh`) et de la référence `.agents/` en CI (`DEPLOYMENT_WORKFLOW.yml`).

### Fixed
- **Correction de 12 Vulnérabilités Logiques et Techniques :**
  1. Fuites d'effets de bord `useEffect` sans fonction de nettoyage détectées dans `front_quality_gate.sh`.
  2. Élimination du bypass d'audit de sécurité des dépendances (`|| true`) dans `front_quality_gate.sh`.
  3. Faux succès `[0/4 checks] -> exit 0` éliminé dans `backend_quality_gate.sh`.
  4. Faux succès statique Bruno dans `e2e_verification_gate.sh` requérant désormais l'exécution réelle d'une suite de tests API.
  5. Détection des composants monolithiques (> 300 lignes) et des `<div onClick>` inaccessibles.
  6. Détection et blocage des chaînes de connexion BDD avec identifiants en clair (`postgresql://`, `mysql://`, `mongodb://`, `redis://`).
  7. Parsing réel des sections spacing, radii et typography de `BRAND.md` dans `build_tokens.mjs`, avec `process.exit(1)` en cas d'échec de contraste WCAG.
  8. Unification du parser `CANVAS_SPEC` et basculement de `file://` vers un serveur HTTP éphémère local Node dans `export_png.mjs` pour éliminer les blocages CORS.
  9. Duplication de 4 arguments Node corrigée dans `doc_scraper.sh` et remplacement du blocage rigide par un avertissement tracé.
  10. Retrait des faux positifs en langue française (`tata`, `toto`, `titi`, attribut `placeholder`) dans `check_lorem.sh`.
  11. Adaptation du score d'idées `score_idea.py` selon le `PROJECT_PROFILE` pour ne plus disqualifier arbitrairement les outils SaaS et CLI.
  12. Préservation de `AGENTS.md` racine lors des purges d'hygiène Git.

### Security
- **Détection Étendue des Secrets :** Regex renforcée couvrant les URLs de bases de données avec mots de passe, les signatures webhooks (`whsec_`), les clés API tierces et les tokens sensibles codés en dur.
- **Isolation Hermétique Git :** Verrouillage automatique bidirectionnel `.gitignore` et `.git/info/exclude` garantissant zéro fuite d'artefacts internes.

---

## [1.1.0] - 2026-10-29

### Added
- **Compatibilité opencode (contexte & mise à jour) :**
  - **Commande `update` :** Resynchronise les compétences et génère/rafraîchit la couche de contexte opencode (`AGENTS.md` + `opencode.json`) sur toute codebase déjà déployée, la rendant immédiatement compréhensible par opencode.
  - **Drapeau `--opencode` (pour `init`) :** Génère en plus le contexte opencode lors d'une installation locale : `AGENTS.md` (instructions auto-chargées) et `opencode.json` (`skills.paths: [".agents/skills"]` + `instructions: [".agents/GEMINI.md"]`).
  - **Smart Merge du contexte opencode :** Un `AGENTS.md` personnalisé (sans marqueur) n'est jamais écrasé ; `opencode.json` est fusionné sans toucher aux champs utilisateur.
  - **Hygiène Git opencode-aware :** En mode opencode, `AGENTS.md` reste committable et `.opencode/`/`AGENTS.md` ne sont plus purgés.
  - **Gabarit `AGENTS_INDEX_TEMPLATE.md` :** Modèle de contexte opencode avec table de routage des 17 compétences.
- **Suite de tests Phase 9 (`tests/phase9/test_opencode.sh`) :** 9 vérifications automatisées (génération du contexte, commande `update`, Smart Merge, dry-run) validées à 100 %.

---

## [1.0.0] - 2026-10-23

### Added
- **Phase 8 Validée — Validation Globale & Tests d'Intégration End-to-End (E2E) :**
  - **Suite de tests E2E exhaustive (`tests/phase8/test_e2e_full.sh`) :** 24 vérifications d'intégration automatisées validées à 100 % au vert.
  - **Simulation de projet client réaliste :** Validation du déploiement sur une application Next.js / TypeScript avec Git, vérification des 17 modules dans `.agents/skills/`, des 5 règles normatives et de l'exécutabilité des 22 scripts.
  - **Exécution réelle en environnement client :** Validation in-situ de `build_tokens.mjs` (compilation CSS / contraste WCAG AAA), `check_lorem.sh` (détection stricte du faux-texte), `archive_roadmap.sh` (blocage sur roadmap incomplète et succès sur 100 %).
  - **Déploiement global (`--global`) :** Validation de l'installation des 17 modules dans l'espace utilisateur Antigravity (`~/.gemini/antigravity-cli/skills/`).
  - **Étanchéité Git absolue :** Vérification de l'absence totale de fuite dans `git status --porcelain`, purge physique et désindexation Git des résidus concurrents (`CLAUDE.md`, `.cursorrules`).
  - **Smart Merge & Non-Régression :** Préservation garantie des règles personnalisées (`PRODUCT.md`) et des compétences tierces custom (`my_custom_skill`).
  - **Audit de conformité des 17 modules :** Validation du frontmatter YAML des 17 `SKILL.md` et éradication de toute mention privée résiduelle pour une universalité totale.
  - **Unification des tests (`package.json`) :** Ajout de `test:phase8` et du script unifié `npm test` orchestrant l'ensemble des suites de tests de la Phase 3 à la Phase 8.
- **Clôture et Archivage Formel de la Roadmap MVP :**
  - Validation physique à 100 % de toutes les tâches des Phases 1 à 8.
  - Archivage déterministe via `archive_roadmap.sh` dans `roadmaps/archives/MVP_BUILD_FRAMEWORK_23102026.md`.

---

## [0.6.0] - 2026-10-23

### Added
- **Phase 7 Validée — Moteur d'Installation Universel CLI (`npx @alexsan/agy-framework init`) :**
  - **`package.json` racine :** Configuration officielle pour distribution npm/npx avec déclaration des binaires `agy-framework` et `san-framework`, suite de tests `test:phase3` à `test:phase7`, zéro dépendance externe pour résilience et rapidité maximale.
  - **`src/cli/index.js` :** Point d'entrée exécutable autonome (`chmod +x`), affichage de la bannière ASCII officielle (`logos/LOGO_ASCII.txt`), parsing CLI natif (`node:util` `parseArgs`), menu interactif TTY (`node:readline/promises`), gestion des drapeaux (`--local`, `--global`, `--all`, `--skills=...`, `--dry-run`, `--force`).
  - **`src/cli/installer.js` :** Moteur de déploiement déterministe assurant la copie des 17 modules natifs depuis `src/skills/` vers `.agents/skills/` ou `~/.gemini/antigravity-cli/skills/`.
  - **Smart Merge :** Préservation scrupuleuse des règles personnalisées de l'utilisateur (`BRAND.md`, `PRODUCT.md`, `PROJECT.md`, `API.md`) et instanciation uniquement des règles manquantes, de l'index maître `GEMINI.md` et de `rules.json`.
  - **Hygiène Git Automatique :** Purge physique des anciens résidus d'agents (`CLAUDE.md`, `.cursorrules`, etc.), désindexation du cache Git (`git rm --cached`) et verrouillage hermétique (`.gitignore` et `.git/info/exclude`).
- **Suite de Tests Automatisés Phase 7 (`tests/phase7/test_cli.sh`) :**
  - Validation des commandes de base (`--help`, `--version`, `list` avec les 17 modules).
  - Validation du déploiement `--local --all` avec Smart Merge, purge Git et isolation.
  - Validation de la sélection granulaire (`--skills=san_init,san_planner`).
  - Validation du mode simulation (`--dry-run`).

---

## [0.5.0] - 2026-10-23

### Added
- **Phase 6 Validée — Packaging du Pôle Qualité, DevOps, Légal & Croissance dans `src/skills/` :**
  - **`src/skills/san_qa_security_expert/` :**
    - `SKILL.md` : Responsable unique QA/Sécurité/Perf, stricte indépendance (zéro correctif codé par l'auditeur), verdict binaire déterministe (`LIVRABLE`/`NON LIVRABLE`), helper Playwright CDP de simulation réseau 3G/EDGE dégradé (750 kbps down / 250 kbps up / 150ms RTT).
    - `references/owasp_unified_checklist.md` : OWASP Web, API 2023 et Mobile 2024 Top 10 consolidés.
    - `references/perf_benchmarks.md` : Seuils stricts Core Web Vitals, latences API p95 < 200ms, taille APK < 25 Mo, RAM < 150 Mo, 60 fps.
    - `references/testing_protocols.md` : Protocoles E2E déterministes Playwright.
    - `scripts/qa_security_gate.sh` : Script Bash déterministe avec scan CVEs, `tsc --noEmit`, détection de fuites de secrets/clés privées et tests unitaires/E2E.
    - `templates/QA_REPORT_TEMPLATE.md`, `templates/SECURITY_REPORT_TEMPLATE.md` (scoré sur 100), `templates/PERF_REPORT_TEMPLATE.md`.
  - **`src/skills/san_devops_expert/` :**
    - `SKILL.md` : Lead DevOps, administration VPS Ubuntu LTS, CloudPanel, Nginx HTTP/2 TLS 1.3, pools PHP-FPM, PM2, Supervisor, Redis, bases SQL, réversibilité absolue (< 30s) et principe de la sauvegarde testée.
    - `references/cloudpanel_and_vps.md` & `references/mailcow_and_deliverability.md` (score 10/10 Mail-Tester, SPF -all, DKIM 2048b, DMARC p=reject, rDNS PTR).
    - `references/backup_and_restore_protocols.md` : Sauvegarde 3-2-1, dumps chiffrés AES-256 GPG et banc de test de restauration déterministe sur conteneur Docker éphémère.
    - `scripts/infra_health_check.sh` : Script Bash autonome de contrôle SSL openssl, DNS dig, ports ss, espace disque/inodes df, et sonde HTTP 200 `/api/health`.
    - `templates/INFRA_TEMPLATE.md`, `templates/RUNBOOK_TEMPLATE.md`, `templates/DEPLOYMENT_WORKFLOW.yml`.
  - **`src/skills/san_store_legal_expert/` :**
    - `SKILL.md` : Conformité Play Store & App Store, ingénierie anti-rejet, compte test reviewer déterministe (`reviewer@alexsan.pro` / OTP fixe `123456` / 25 000 FCFA virtuels), respect de la directive Apple 5.1.1 (suppression in-app en ≤ 3 taps + purge sous 30j) et chartes légales basées sur la vérité du code.
    - `references/store_rejection_patterns.md` : Motifs de rejet Google/Apple et remédiations directes.
    - `scripts/scan_app_permissions.sh` : Script Bash analysant `AndroidManifest.xml`, `Info.plist`, `app.json` et `package.json` pour extraire permissions et SDKs tiers collecteurs.
    - `templates/STORE_CHECKLIST_TEMPLATE.md`, `templates/PRIVACY_POLICY_TEMPLATE.md`, `templates/TERMS_TEMPLATE.md`, `templates/DATA_MAP_TEMPLATE.md`.
  - **`src/skills/san_growth_expert/` :**
    - `SKILL.md` : Lead Growth, éthique 100% White-Hat (zéro faux avis), SEO local Afrique/Congo (Brazzaville, Pointe-Noire, Kinshasa, repères urbains, devises XAF/FCFA/USD, MoMo/Airtel), stratégie ASO stores (30/80 car., 4 volets, storyboard en 5 scènes), et plan de tracking unifié `snake_case`.
    - `references/local_seo_congo.md`, `references/aso_playbook.md`, `references/tracking_taxonomy.md`.
    - `scripts/verify_tracking_and_seo.sh` : Script Bash validant `robots.txt`, accessibilité `sitemap.xml`, balises `<meta>` et syntaxe JSON des blocs Schema.org JSON-LD.
    - `templates/TRACKING_PLAN_TEMPLATE.md`, `templates/STORE_LISTING_TEMPLATE.md`.
- **Suite de Tests Automatisés Phase 6 (`tests/phase6/test_phase6.sh`) :**
  - Validation de `scan_app_permissions.sh` sur manifestes Android et Expo.
  - Validation de `infra_health_check.sh` en mode local.
  - Validation de `verify_tracking_and_seo.sh` sur mock sitemap, robots et Schema.org.

---

## [0.4.0] - 2026-10-23

### Added
- **Phase 5 Validée — Packaging du Pôle Conception Visuelle & Full-Stack dans `src/skills/` :**
  - **`src/skills/san_designer/` :**
    - `SKILL.md` : Design visuel haute fidélité 100% code (HTML/Tailwind), zéro CDN externe, 5 canvas normés (Play Store 1080x1920, App Store 1290x2796, Desktop 1440x900, Tablette 820x1180, Feature Graphic 1024x500), workflow `/ux-scan` à 2 étages et formules mathématiques du contraste (> 7:1 plein soleil).
    - `references/audit_criteria.md` : Grille d'évaluation des 3 auditeurs (Psychologie cognitive, Contexte local Afrique/3G, Design System tokens).
    - `references/contrast_mathematics.md` & `references/device_canvas_specs.md`.
    - `templates/device_frames.html` : Composants purs HTML/CSS reproduisant iPhone (Dynamic Island) et Android (poinçon) sans CDN.
    - `templates/mockup_standalone.html` & `scripts/export_png.mjs`.
  - **`src/skills/san_ux_ui_expert/` :**
    - `SKILL.md` : Lead Frontend & Mobile, React.js / React Native / Expo Router / Tailwind strict, gestion obligatoire des 5 états UI sur CHAQUE vue, résilience 3G et sécurité zéro-fuite (Keychain / Keystore).
    - `references/anti_ai_taste_rules.md` : Matrice négative proscrivant les tics visuels IA (dégradés néon, cartes 3 colonnes grises uniformes, spinners aveugles).
    - `references/client_resilience_domains.md` : Cache SQLite/MMKV, Optimistic UI, file d'attente Outbox, compression d'images < 300 Ko et haptiques Expo.
    - `scripts/front_quality_gate.sh` : Script Bash déterministe avec détection de gestionnaire de paquets, `tsc --noEmit`, linters, tests Jest/Vitest et scan de fuites mémoire.
    - `templates/FIVE_STATES_COMPONENT.tsx`, `templates/USE_OFFLINE_MUTATION.ts`, `templates/FRONT_SECURITY_PERF_REPORT.md`.
  - **`src/skills/san_backend_expert/` :**
    - `SKILL.md` : Lead Backend & Systèmes Distribués, PHP 8.2+ Laravel / AdonisJS v6 strict, dogme de l'idempotence absolue (`Idempotency-Key` UUIDv4 avec verrou atomique Redis 24h), sécurité financière Mobile Money de fer (triple verrou, webhooks HMAC-SHA256 en temps constant avec `hash_equals()`, cron de réconciliation 5 min).
    - `references/backend_stack_alexsan.md` & `references/resilience_and_domains.md` (exponential backoff avec full jitter anti-thundering herd).
    - `scripts/backend_quality_gate.sh` : Script Bash autonome exécutant PHPStan max / `tsc`, Pest / PHPUnit / Japa, scan statique anti-N+1 (`preventLazyLoading`) et audit de sécurité Composer/NPM.
    - `templates/SECURITY_REPORT_TEMPLATE.md` (audit pentest OWASP API Security Top 10), `ENDPOINT_RULE_TEMPLATE.md`, `BRUNO_REQUEST_TEMPLATE.bru`, `SERVICE_ACTION_TEMPLATE.php`, `MOMO_WEBHOOK_CONTROLLER.php`.
  - **`src/skills/san_executer/` :**
    - `SKILL.md` : Chef d'orchestre Full-Stack, moteur de triage architectural en 3 profils (`BACK_ONLY`, `FRONT_ONLY`, `FULL_STACK`), pipeline de delivery en 6 étapes et disjoncteur anti-boucle.
    - `references/orchestration_matrix.md` : Arbre de décision Mermaid et allocation des sous-agents au moindre privilège.
    - `references/contract_first_protocol.md` : Synchronisation intangible des spécifications d'endpoints, interfaces TypeScript et requêtes Bruno.
    - `scripts/e2e_verification_gate.sh` : Script de coordination globale exécutant les gates front + back et assertions de contrats Bruno.
    - `templates/ENDPOINT_CONTRACT_TEMPLATE.md`, `templates/BRUNO_REQUEST_TEMPLATE.bru`, `templates/EXECUTION_REPORT_TEMPLATE.md`.
- **Suite de Tests Automatisés Phase 5 (`tests/phase5/test_phase5.sh`) :**
  - Validation du rejet strict (`exit 1`) en cas d'erreurs simulées sur le frontend et le backend.
  - Validation du succès (`exit 0`) sur environnements conformes et coordination E2E globale.

---

## [0.3.0] - 2026-10-23

### Added
- **Phase 4 Validée — Packaging des Sous-Skills Transversaux d'Exécution dans `src/skills/` :**
  - **`src/skills/san_subagent_manager/` :**
    - `SKILL.md` : Guide opérationnel complet pour l'allocation chirurgicale de sous-agents, principe de moindre privilège, sélection `Model: 'flash'` vs `Model: 'inherit'`, et protocole de reddition hermétique par `send_message`.
    - Templates de prompts fermés : `SUBAGENT_PROMPT_TEMPLATE.md`, `ATOMIC_CODER_PROMPT.md` et `AUDITOR_PROMPT.md`.
    - `scripts/validate_subagent_spec.sh` : Script Bash validant la conformité des 6 sections requises dans les prompts.
    - Références : `least_privilege_matrix.md`, `subagent_archetypes.md`, `prompt_engineering_standards.md`.
  - **`src/skills/san_searcher/` :**
    - `SKILL.md` : Protocole de *Context Shielding* préservant le contexte de l'orchestrateur, règle stricte de pinning des versions via manifestes locaux.
    - `scripts/detect_stack_versions.sh` : Détection automatique des versions pour Node/React/Expo, PHP/Laravel, Go et Docker.
    - `scripts/doc_scraper.sh` : Sas de décontamination et conversion HTML vers Markdown pur épuré des balises parasites.
    - `templates/RESEARCH_NOTE_TEMPLATE.md` : Gabarit canonique pour `docs/research/TECH_INVESTIGATION_*.md`.
    - Références : `official_authorities.md` et `version_matrix_guidelines.md`.
  - **`src/skills/san_doc_keeper/` :**
    - `SKILL.md` : Gouvernance SemVer 2.0.0, 7 catégories Keep a Changelog et Fast-Track d'hygiène immédiat sans gaspillage de tokens.
    - `scripts/changelog_helper.sh` : Insertion automatisée déterministe d'entrées sous `[Unreleased]`.
    - `scripts/archive_roadmap.sh` : Contrôle déterministe d'exhaustivité 100% (`- [x]`) et archivage avec empreinte SHA-256.
    - Gabarits : `CHANGELOG_TEMPLATE.md` et `README_TEMPLATE.md`.
  - **`src/skills/san_copywriter/` :**
    - `SKILL.md` : Plume UX vivante, bannissement du *Lorem Ipsum*, règles de devises avec espace insécable (`2 500 FCFA`), toponymie par repères urbains sans cadastre, et réflexes Mobile Money.
    - `references/local_copy_guidelines.md` : Répertoire d'exemples réels pour les 5 états UI (Nominal, Vide, Skeleton, Erreur en triptyque, Hors-ligne).
    - `scripts/check_lorem.sh` : Linter bash récursif traquant impitoyablement le faux texte (exit 1 si détecté).
    - `scripts/validate_copy_length.mjs` : Contrôle déterministe des plafonds de caractères stores et boutons.
    - Gabarits : `I18N_DICTIONARY_TEMPLATE.json` et `UI_5_STATES_COPY_TEMPLATE.md`.
  - **`src/skills/san_design_tokens/` :**
    - `SKILL.md` : Invariance des tokens de marque, accessibilité WCAG AAA plein soleil (> 7:1) et signature cinétique 60 fps.
    - `scripts/build_tokens.mjs` : Compilateur autonome Markdown vers variables CSS (`:root`), Tailwind (`@theme` v4 et config extend v3) et TypeScript (`tokens.ts`).
    - `scripts/audit_magic_values.sh` : Scanner statique traquant les couleurs arbitraires en dur et espacements magiques.
    - `templates/BRAND_TOKENS_TEMPLATE.md` et références cinétiques / contrastes.
  - **`src/skills/san_exporter/` :**
    - `SKILL.md` : Pipeline de capture déterministe headless Playwright, synchronisation `networkidle` + `document.fonts.ready` + pause stabilisatrice.
    - Formats normés : Play Store (1080x1920, 1024x500), App Store (1290x2796), et Print A4 300 DPI (2480x3508).
    - `scripts/export_png.mjs` : Moteur de capture Playwright avec registre d'intégrité SHA-256.
    - `scripts/svg_to_png.mjs` : Déclinaison vectorielle sans canal alpha (élimination du rejet Apple ITMS-90717).
- **Suite de Tests Automatisés Phase 4 (`tests/phase4/test_phase4.sh`) :**
  - Validation de `check_lorem.sh` sur code pollué (exit 1) et code propre (exit 0).
  - Validation de `build_tokens.mjs` avec compilation CSS et TypeScript.
  - Validation de `audit_magic_values.sh` (détection des couleurs et styles magiques).
  - Validation de `changelog_helper.sh` (insertion correcte sous Keep a Changelog).

---

## [0.2.0] - 2026-10-23

### Added
- **Phase 3 Validée — Packaging du Socle d'Onboarding & Cadrage dans `src/skills/` :**
  - **`src/skills/san_init/` :**
    - `SKILL.md` : Guide opérationnel complet avec frontmatter YAML conforme Antigravity, protocole d'initialisation en 7 phases, détection déterministe de 10 stacks logicielles.
    - `scripts/git_ai_hygiene.sh` : Script Bash autonome (`chmod +x`), purge des anciens agents (`CLAUDE.md`, `.cursorrules`, etc.), désindexation cache Git (`git rm --cached`) et verrouillage hermétique (`.gitignore` et `.git/info/exclude`).
    - `scripts/svg_to_png.mjs` : Déclinaison vectorielle multi-résolution avec moteur Sharp et gestion des fallbacks système.
    - Gabarits de règles : `BRAND_TEMPLATE.md`, `PRODUCT_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `API_TEMPLATE.md`, `LOGO_TEMPLATE.md`, `rules_json_template.json` et index maître `GEMINI_INDEX_TEMPLATE.md`.
  - **`src/skills/san_brainstorming/` :**
    - `SKILL.md` : Processus socratique d'investigation en 5 questions fermées, seuils d'arbitrage et protocoles de déclenchement.
    - `references/ideation_scoring_matrix.md` : Grille d'évaluation quantifiée sur 40 points (Impact, Faisabilité, Réalité Terrain Afrique, Risques) avec clauses éliminatoires.
    - `references/congo_market_signals.md` : Intelligence terrain sur la connectivité 3G, Mobile Money (Airtel/MTN MoMo), usages WhatsApp et parcs terminaux Android low-end.
    - `scripts/score_idea.py` : Moteur de calcul déterministe CLI et export JSON.
    - `templates/IDEA_TEMPLATE.md` : Squelette normalisé pour `/roadmaps/ideas/*.md` avec payload de transition vers `san_planner`.
  - **`src/skills/san_planner/` :**
    - `SKILL.md` : Découpage cartésien en 6 phases séquentielles étanches (CPM), règle stricte de Preuve par le Code, matrice des tests obligatoires par stack et Fast-Track orchestrateur.
    - `templates/ROADMAP_TEMPLATE.md` : Squelette normé de feuille de route avec tests obligatoires.
    - `templates/CHANGELOG_TEMPLATE.md` : Gabarit conforme à Keep a Changelog.
    - `scripts/archive_roadmap.sh` : Script Bash autonome vérifiant que 100 % des cases sont cochées (`- [x]`) avant archivage vers `/roadmaps/archives/`.
- **Suite de Tests Automatisés Phase 3 (`tests/phase3/`) :**
  - `test_git_ai_hygiene.sh` : Test d'intégration complet sur dépôt Git temporaire pollué (100 % passants).
  - `test_archive_roadmap.sh` : Tests unitaires de rejet des roadmaps incomplètes/vides et validation d'archivage déterministe (100 % passants).
- **Élévation Complète des Spécifications (`skills/` et `sub-skills/`) :**
  - Refonte intégrale des 11 skills principaux et 6 sous-skills avec code de production, schémas TypeScript, formules mathématiques et zéro placeholder.

---

## [0.1.0] - 2026-10-23

### Added
- **Architecture Modulaire Cartésienne :** Structuration complète du framework en rôles maîtres (`/skills/`) et outillage transversal (`/sub-skills/`).
- **11 Spécifications de Skills Principaux :**
  - [`san_init`](skills/san_init.md) : Initialisation, isolation Git et rétro-ingénierie de codebase.
  - [`san_brainstorming`](skills/san_brainstorming.md) : Cadrage amont, triage multicritères et maturation d'idées.
  - [`san_planner`](skills/san_planner.md) : Planification de roadmaps, phasage et auto-nettoyage.
  - [`san_designer`](skills/san_designer.md) : Conception visuelle 100 % code, HTML/Tailwind, `/ux-scan` et screenshots stores.
  - [`san_ux_ui_expert`](skills/san_ux_ui_expert.md) : Lead Frontend & Mobile, anti-IA taste, 5 états obligatoires et résilience 3G.
  - [`san_backend_expert`](skills/san_backend_expert.md) : Lead Backend, APIs SOLID, idempotence Redis, Bruno et Mobile Money.
  - [`san_executer`](skills/san_executer.md) : Chef d'orchestre Full-Stack, protocole *Contract-First* et delivery E2E.
  - [`san_qa_security_expert`](skills/san_qa_security_expert.md) : Juge de paix unique QA E2E, sécurité OWASP, performance et verdict binaire (`LIVRABLE`).
  - [`san_devops_expert`](skills/san_devops_expert.md) : Infrastructure, CloudPanel, Mailcow, VPS, CI/CD, réversibilité et runbooks.
  - [`san_store_legal_expert`](skills/san_store_legal_expert.md) : Conformité stores Google/Apple, anti-rejet et chartes légales basées sur le code.
  - [`san_growth_expert`](skills/san_growth_expert.md) : SEO local (Afrique/Congo), ASO fiches stores et plan de tracking Firebase/Meta/Google.
- **6 Spécifications de Sous-Skills Transversaux :**
  - [`san_subagent_manager`](sub-skills/san_subagent_manager.md) : Calibrage chirurgical des sous-agents et routage `flash`/`inherit`.
  - [`san_searcher`](sub-skills/san_searcher.md) : Documentaliste, scraping officiel et veille technique sans pollution de contexte.
  - [`san_doc_keeper`](sub-skills/san_doc_keeper.md) : Tenue de `CHANGELOG.md`, `README.md` et Fast-Track d'archivage.
  - [`san_copywriter`](sub-skills/san_copywriter.md) : Micro-copies UX, localisation terrain et bannissement du *Lorem Ipsum*.
  - [`san_design_tokens`](sub-skills/san_design_tokens.md) : Gardien de `BRAND.md`, tokens statiques et signature cinétique.
  - [`san_exporter`](sub-skills/san_exporter.md) : Pipeline de capture headless Playwright et déclinaison vectorielle SVG $\rightarrow$ PNG.
- **Protocoles d'Ingénierie Clés :**
  - Entonnoir d'audit en 2 étages (Étage 1 scripté sans token LLM $\rightarrow$ Étage 2 audits cognitifs spécialisés).
  - Fast-Track d'hygiène immédiat de l'orchestrateur (cochage après preuve, archivage, changelog).
  - Isolation Git absolue (`.agents/` ignoré dans `.gitignore` et `.git/info/exclude`).
- **Identité Visuelle & Logos :**
  - Charte graphique [`logos/LOGO.md`](logos/LOGO.md).
  - Assets vectoriels [`logos/san_framework_logo.svg`](logos/san_framework_logo.svg), [`logos/san_framework_icon.svg`](logos/san_framework_icon.svg) et [`logos/san_framework_dark.svg`](logos/san_framework_dark.svg).
- **Périmètre Distribuable :**
  - Création de [`src/`](src/README.md) matérialisant la frontière entre notre codebase source et l'output injecté sur les projets clients.
