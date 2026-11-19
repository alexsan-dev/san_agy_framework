# CHANGELOG — `san_ai_harness`

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Language:** [Version française](CHANGELOG.md)

---

## [Unreleased]

### Planned
- Official publication on the public npm registry (`npm publish --access public`).
- Extended production deployments.

---

## [3.0.0] - 2026-11-19

### Added
- **`san_ai_harness` Identity (`@alexsan/san-ai-harness`) & `san-harness` Binary:**
  - Rebranded package, GitHub repository (`alexsan-dev/san_ai_harness`), and visual identity with primary CLI `san-harness` (retaining `san-framework` and `agy-framework` backward-compatible aliases).
  - Theme-adaptive GitHub SVG logos (`logos/san_harness_logo_dark.svg`, `logos/san_harness_logo_light.svg`, `logos/san_harness_icon.svg`) wired via `<picture>` in both READMEs.
- **Native OpenCode v2.3.0 Plugin (`src/opencode/san-harness-plugin.mjs`) & Swarm Board:**
  - Pure-Node ESM plugin (zero Bun dependency) deployed automatically to `.agents/opencode/` on `init --opencode` / `update --opencode`.
  - Registers the **`san_swarm`** tool (`dispatch`, `board`, `status`), live Markdown **Swarm Board** + Workflow Summary rendering, and `/san-board` command inside `opencode.json`.
  - Declares primary agent **`san-orchestrator`** without a hardcoded `model` field so it freely inherits the user's selected `/model`.
- **120k-Token Auto-Compaction (`--compaction=<tokens>`):**
  - Added `compaction: { targetTokens: 120000, auto: true }` to `.agents/models.json` and `san-harness models --compaction=<tokens>` flag.
  - Rewrote `src/hooks/scripts/pre_invocation.mjs` as a `120 000`-token auto-compaction guard (silent `{ injectSteps: [] }` below threshold) alongside native OpenCode `compaction` (`auto: true`, `background: true`, `keep.tokens: 12000`, `buffer: 20000`) settings and plugin hooks.

### Changed
- **Complete Model Decoupling & Adaptive Orchestration Doctrine (`inherit-user-model`):**
  - Removed all hardcoded orchestrator model identifiers (`Argon`, `Carbon`, `hy4`, `gemini-4-argon-high`, `gemini-4-hydrogen-xhigh`) across all 8 agents, 17 skills, 17 root wrappers, and templates (`AGENTS_INDEX_TEMPLATE.md`, `GEMINI_INDEX_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `ROADMAP_TEMPLATE.md`).
  - Orchestrators inherit the user's `/model`; only worker executors are configured via `.agents/models.json` (`san-harness models`).
  - Relaxed mechanical delegation locks: simple/single-layer tasks may use native **`Plan → Execute`** directly, reserving `swarm` (Antigravity) and `san_swarm` / `subagent` (OpenCode) for multi-layer work, Studio Duel UI, and adversarial `san-qa-auditor` QA.
  - Added surgical v2.x migration for `.agents/rules/*.md` during `san-harness update` while preserving custom project rules and legitimate `Argon2id` crypto references.

### Removed
- **Full Purge of `.agents/cache/`, AST Map & Transcripts Modules:**
  - Removed token-bloating modules: `src/skills/san_cartographer/`, `src/skills/san_transcriber/`, `src/hooks/scripts/post_tool_indexer.mjs`, `src/hooks/scripts/stop_guard.mjs`, `REPO_MAP.md`, `.agents/cache/`, and `roadmaps/transcripts/` (streamlining the catalog from 19 to **17 skills** and from 5 to **3 lean hooks**).
  - Active cleanup via `purgeObsoleteArtifacts()` during `san-harness init` / `san-harness update` (removing legacy `.agents/cache/`, obsolete hooks/skills, and duplicate `.agents/AGENTS.md`), verified by `san-harness doctor`.

---

## [2.2.1] - 2026-11-18

### Fixed
- Fixed `ReferenceError: resolveProjectRoot is not defined` in `san-framework update` (`src/cli/installer.js`).
- Added native recognition of existing installations (`.agents/` or `.agents/skills.json`) with monorepo upward root resolution to stop spurious re-install prompts.
- Hardened the legacy repository scanner with a Git-First (`git ls-files`) anti-OOM strategy on large repositories (subsequently superseded by 120k auto-compaction in v3.0.0).

---

## [2.2.0] - 2026-11-14

### Added
- **1. Dual-Harness Architecture (`Antigravity` + `OpenCode V2`) & `san-framework models` Command:**
  - Native **OpenCode V2 (`v2.2.7+` / `2.3.0`)** support in `mergeOpencodeConfig()` (`src/cli/installer.js`) automatically generating and merging the `"agents"` key inside `opencode.json` for all 8 `san-*` subagents (`mode: "subagent"`, `description`, `model`, `system`, and read-only edit-deny `permissions` for `san-researcher`, `san-architect`, and `san-qa-auditor`), invoked via the `subagent` tool alongside Antigravity's `swarm` engine.
  - New model profile manager **`.agents/models.json`** (`DEFAULT_MODELS_CONFIG`, `profile: "unified-executor"`) and CLI command **`san-framework models`** (`--opencode=<model>`, `--agy=<model>`, `--orchestrator=<model>`, `--set=<model>`, `--dir=<path>`) managing the **Unified Executor Profile**: e.g., `opencode-go/deepseek-v4-pro` or `opencode-go/qwen3.8-flash` (orchestrator `opencode-go/hy4`) on OpenCode V2, and `gemini-4-hydrogen-xhigh` (orchestrator `gemini-4-argon-high`) on Google Antigravity, with instant resynchronization of `opencode.json`.
  - Automatic resynchronization of `opencode.json` during `san-framework update` when `opencode.json` already exists or when `--opencode` is passed.
- **2. New 19th Skill: `san_transcriber` (`src/skills/san_transcriber/`, `roadmaps/transcripts/`):**
  - Quota-exhaustion handoff skill invoked via `/san_transcriber` (`SKILL.md <= 130` lines, `scripts/transcript_helper.mjs`, `templates/TRANSCRIPT_TEMPLATE.md`).
  - Generates deterministic transcripts in `roadmaps/transcripts/TRANSCRIPT_<ROADMAP>_<DATE>.md` linked to active roadmaps (`roadmaps/*.md`), capturing Git state and `- [x]` / `- [ ]` task progress.
  - Enforces the **Skeptical Handoff Protocol (*Doubt & Verify*)**, prompting the incoming agent to audit, verify from source/tests, and challenge the outgoing agent's work.
  - Automatic startup detection of the latest transcript in `roadmaps/transcripts/*.md` by `src/hooks/scripts/session_start.mjs` (`[SAN.AGY CONSTITUTION v2.2]` banner).
- **3. Live Web Capture (`export_png.mjs --url`) & Universal Playwright Resolution:**
  - Added `--url=<https://...>` (single URL or comma-separated list) and `--full-page` flags to `export_png.mjs` (`san_designer` and `san_exporter`) to capture real rendered pixels from inspiration websites via Playwright (defaulting to `desktop` `1440×900` + `mobile` `390×844` into `design/references/<hostname>-<pathname>-<viewport>.png`, with `--audit-dom` support).
  - Extended `loadPlaywright()` resolution across local project `cwd`, `NODE_PATH`, script ancestry (`import.meta.url` / `realpathSync`), global plugin (`~/.gemini/antigravity-cli/plugins/san-framework/node_modules`), and `~/.npm/_npx` cache.

### Changed
- **Cognitive De-Lobotomization & Socratic Alignment (`AGENTS_INDEX_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `san_planner`, `san_brainstorming`, `san_designer`):**
  - Replaced blind immediate-delegation directives with the **Socratic & Visual Alignment Rule** (Stage 0): the Orchestrator (`Argon 4` / `hy4`) must align key design/product decisions directly with the user via `ask_question` / `question` and inspect real visual captures (`export_png.mjs --url`) before delegating roadmap authoring or mockup implementation to subagents.
- **Dual-Harness Unification & Byte-Identical Script Deduplication (HY4 Audit):**
  - Expanded catalog from **18 to 19 skills** (`package.json`, `src/plugin/plugin.json`, `src/cli/whats_new.js`, `src/cli/index.js`, `src/cli/installer.js`) and replaced mono-vendor coupling with the **Unified Executor Profile** (`Antigravity` `swarm` | `OpenCode V2` `subagent`) across all 8 subagents and 19 skills.
  - Byte-identical unification (`cmp -s` = 0) of the 3 shared script pairs: `export_png.mjs` (`san_designer` $\leftrightarrow$ `san_exporter`), `archive_roadmap.sh` (`san_planner` $\leftrightarrow$ `san_doc_keeper`, preserving `roadmaps/archives/<BASENAME>` and SHA-256 certification header), and `svg_to_png.mjs` (`san_init` $\leftrightarrow$ `san_exporter`, including Apple `ITMS-90717` alpha-channel flattening).
  - Synchronized all 19 `skills/*.md` and `sub-skills/*.md` wrappers to `version: "2.2.0"` (including `san_transcriber.md`).

### Fixed
- **Eliminated false positives in `stop_guard.mjs` (`src/hooks/scripts/stop_guard.mjs`):**
  - Added `mtimeMs` timestamp filtering to ignore pre-existing dirty files (older than 10 minutes or predating `last-gate-status.json`), preventing spurious blocks during scoping and planning sessions on repos with uncommitted pre-existing changes.
  - Expanded exemptions to non-application paths and docs: `design/**`, `logos/**`, `.opencode/**`, `opencode.json`, `opencode.jsonc`, `.gitignore`, `*.md`, `*.mdx`, `*.txt`, `roadmaps/**`, `docs/**`, `.agents/**`.
- **Python `.gitignore` Hygiene (HY4 Audit):**
  - Added `__pycache__/`, `*.py[cod]`, and `*$py.class` to the root `.gitignore` and to the isolation block injected by `src/skills/san_init/scripts/git_ai_hygiene.sh`.

---

## [2.1.0] - 2026-11-14

### Added
- **1. What's New on san-agy (`src/cli/whats_new.js`, `san-framework whats-new`):**
  - Structured release notes banner displayed in the terminal during `san-framework update` and available anytime via `npx @alexsan/agy-framework whats-new`.
  - Automatic **one-shot notification** injected at the first `SessionStart` after an update via `.agents/cache/whats_new_pending.json` (`seen: false` $\rightarrow$ `seen: true`) in `session_start.mjs`.
- **2. Autonomous Orchestrator (`Argon` / `Carbon`) $\rightarrow$ `gemini-4-hydrogen-xhigh` Swarm Doctrine:**
  - The main-thread Orchestrator automatically delegates tasks in parallel via the native `swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)` tool (or `agy -p --model gemini-4-hydrogen-xhigh`) without ever asking the user to manually switch `/model` or type subagent names.
  - Strict prohibition of `invoke_subagent(Model: "inherit")` on `Argon`/`Carbon` (protecting weekly orchestrator quota) and elimination of silent fallback to `gemini-3.8-flash-tiered`.
  - Full migration of all 8 native subagents and routing matrices to **`gemini-4-hydrogen-xhigh`** (while keeping `model: "pro"` in YAML frontmatter for CLI parser compatibility).
- **3. `Stop` Hook (`stop_guard.mjs`) + Hooks API v2 (`systemMessage`):**
  - New `src/hooks/scripts/stop_guard.mjs` (`chmod +x`) registered on the `"Stop"` event in `src/hooks/hooks.json` (`timeout: 5`).
  - **Anti-Loop Circuit Breaker**: immediately allows stopping (`{}`) if `continuationActive === true`, on user/error interruption, in documentation/config-only sessions (`DOC_ONLY`: `*.md`, `roadmaps/*`, `docs/*`, `.agents/*`), on clean/non-git repos, or after 2 consecutive retries tracked in `.agents/cache/stop-guard-state.json`; blocks (`decision: "continue"`) when application code was modified without a recent (< 30 min) green Quality Gate proof in `.agents/cache/last-gate-status.json`.
  - Migrated `src/hooks/scripts/pre_invocation.mjs` from deprecated `ephemeralMessage` to the official Hooks API v2 `{ systemMessage: { systemMessage: ... } }`.
- **4. Lightweight Inheritance Mode (`--light` / `.agents/skills.json`):**
  - Added `--light` flag on `init` and `update` generating `.agents/skills.json` (`{ "version": 1, "inherits": [".../src/skills"] }`) without duplicating the 18 skill directories, while keeping `.agents/rules/`, `.agents/agents/`, `.agents/hooks/`, and `.agents/cache/` 100% local to the project.
  - Updated `san-framework doctor` to validate skills via `.agents/skills.json` `"inherits"` as well as `stop_guard.mjs` presence and permissions.
- **5. Deterministic Python Workflows (`run_workflow` + JSON Schema):**
  - Created `src/skills/san_executer/scripts/autonomous_slice_workflow.py` (`CODE_SLICE_SCHEMA`, `QA_VERDICT_SCHEMA`, multi-turn `coder ↔ san-qa-auditor` loop, and `.agents/cache/last-gate-status.json` update).
  - Created `src/skills/san_qa_security_expert/scripts/parallel_inquisition_workflow.py` (parallel fan-out across OWASP security, anti-Mock Theater test substance & Architectural Fitness Functions, and DOM geometry/UI states with `INQUISITION_REPORT_SCHEMA`).
- **6. Contract-First Architecture & Architectural Fitness Functions:**
  - Enhanced `san-architect.md`, `san_planner/SKILL.md`, and `ROADMAP_TEMPLATE.md` enforcing shared contract freeze (OpenAPI 3.1 / Zod / TypeBox) prior to parallel Front/Back coding and automated architectural boundary tests at the Quality Gate.
- **7. `export_png.mjs` v2 (Multi-Viewports + Playwright DOM Geometry Linter):**
  - Sequential multi-viewport capture (`--viewports=mobile,tablet,desktop`: `390×844`, `820×1180`, `1440×900`) on a **single Chromium instance** in `san_designer` and `san_exporter` with 100% backward compatibility.
  - Playwright DOM Geometry Linter (`--audit-dom`, `--report=<path.json>`, `--strict-dom`) mathematically detecting horizontal overflows (`scrollWidth > clientWidth`), sibling box collisions, interactive touch targets `< 44×44px`, and numeric metrics missing `tabular-nums`.
- **8. Studio Duel UI Mode:**
  - Parallel generation of 2 distinct artistic directions (`option-a` vs `option-b`) via `swarm` (`gemini-4-hydrogen-xhigh`) in `san_designer`, multi-viewport + DOM geometry capture, and visual arbitration by `san-qa-auditor`.
- **9. 5-State Non-Destructive UI Standard, Motion System & Map-First (`san_cartographer` / `REPO_MAP.md`):**
  - Enforced the 5 non-destructive UI states (`Empty`, `Skeleton Cold-Start`, `Populated`, `Stale-While-Revalidate`, `Error`) and Motion System (`cubic-bezier`, `@media (prefers-reduced-motion: reduce)`, touch targets $\ge 44\times 44\text{px}$, `font-variant-numeric: tabular-nums`) in `san-coder-front.md` and `san-designer-worker.md`, alongside the 18th skill `san_cartographer` (`repo_mapper.mjs`, `post_tool_indexer.mjs`, `.agents/cache/REPO_MAP.md`).

### Changed
- Replaced all references to `gemini-3.1-pro-high` and `gemini-3.8-flash-high` with `gemini-4-hydrogen-xhigh` across constitution templates, subagents, and validators.
- Updated test suites (`tests/v2/*`, `tests/phase7/*`, `tests/phase8/*`) to validate CLI `v2.1.0`, `whats-new`, `--light`, `stop_guard.mjs`, `systemMessage`, and `gemini-4-hydrogen-xhigh`.

---

## [2.0.0] - 2026-10-31

### Added
- **4-Layer v2.0 Architecture:**
  - **Layer 1 (Sovereign Governance):** Deployment of `<root>/AGENTS.md` (no YAML frontmatter, < 4096 bytes, native `always_on` for Antigravity & opencode) and 5 normative rules `.agents/rules/*.md` equipped with official YAML frontmatters (`PROJECT.md`, `PRODUCT.md`, `BRAND.md`, `API.md`, `LOGO.md`).
  - **Layer 2 (8 Native Specialized Sub-agents):** Creation of agent definitions `.agents/agents/*.md`:
    - `san-researcher` (`model: "flash"`, read-only exploration and factual mapping);
    - `san-architect` (`model: "pro"`, 6-month pre-mortem, 2-approach tradeoff without strawmen, domain models);
    - `san-designer-worker` (`model: "flash"`, HTML/Tailwind mockups, visual archetypes, Gestalt rhythm, headless PNG rendering);
    - `san-coder-back` (`model: "flash"`, dialectic before commit, atomic transactions, real domain tests);
    - `san-coder-front` (`model: "flash"`, modules < 220 lines, non-destructive 5-state Stale-While-Revalidate, strict keyboard A11y);
    - `san-qa-auditor` (`model: "pro"`, read-only skeptical inquisitor, test substance audit, multimodal visual critique on real PNG pixels via `read_file`, binary verdict `LIVRABLE | RETOUR_ATELIER`);
    - `san-ops-devops` (`model: "flash"`, CI/CD, containers, Nginx, Fail-Closed infrastructure health diagnostics);
    - `san-growth-legal` (`model: "flash"`, GDPR, app store compliance, SEO/ASO, acquisition loops).
  - **Layer 3 (Mechanical Lifecycle Guardrails):** Orchestration via `.agents/hooks.json` and 3 deterministic hook scripts:
    - `SessionStart` (`session_start.mjs`): Automatic detection of active roadmap and `PROJECT_PROFILE`, injecting the orchestration system prompt.
    - `PreInvocation` (`pre_invocation.mjs`): Ephemeral prompt (< 110 tokens) preventing inline solo-coding and enforcing contradictory doubt before any action.
    - `PreToolUse` (`pre_tool_guard.mjs`): Interception of `write_file`/`edit_file`, blocking roadmaps archiving with unchecked boxes (`- [ ]`), blocking *Lorem Ipsum*, and respecting user permissions.
  - **Layer 4 (17 Imperative Skill Runbooks):** Complete overhaul of `SKILL.md` files into condensed directive runbooks ($\le 130$ lines each) with routing tables, intent triggers, and outsourced specialized references.
- **Doubt Engineering (*Contradictory Reasoning Engine*):**
  - *Systemic Pre-Mortem*: Simulation of the 3 major causes of failure at 6 months prior to any architectural commitment.
  - *Dialectic Before Commit*: Mandatory formulation and comparison of 2 viable approaches before committing any implementation.
  - *Visual Vision Loop*: Playwright headless capture pipeline (`export_png.mjs` with Node ephemeral HTTP server on `127.0.0.1:0`), multimodal inspection of PNG pixels via `read_file` by `san-qa-auditor`, and 1 mandatory refinement pass before delivery.
  - *QA Inquisition & Presumption of Flaws*: Elimination of first-draft sycophancy, hunting down *Testing Theater*, and uncompromising binary verdicts.
- **Contextual Project Profiles (`PROJECT_PROFILE`):**
  - Modular support for 5 profiles in rules and scripts: `emerging_market` (3G resilience, Mobile Money, offline Outbox), `global_saas`, `mobile_consumer`, `cli_devtools`, and `api_platform`.
- **Official Antigravity Plugin Packaging (`src/plugin/plugin.json`):**
  - Complete v2.0.0 manifest with vector logo, metadata, and certified compatibility with `agy plugin validate --strict`.
- **New `doctor` CLI Command:**
  - Deterministic diagnostic of the 6 health pillars (Governance, Normative rules, Native sub-agents, Lifecycle hooks, 17-skill catalog $\le 130$ lines, Git isolation) with return code `0` or `1`.
- **Reversible Backups (`.agents/backups/`):**
  - Replaced destructive deletion of legacy AI configurations with timestamped safe moves to `.agents/backups/legacy-ai-configs/<timestamp>/`.

### Changed
- **Overhaul of 17 `SKILL.md` into Imperative Runbooks ($\le 130$ lines):**
  - Drastic reduction of verbose texts (from 300-600 lines down to $\le 130$ direct lines) focused on immediate action and sub-agent delegation.
- **Root Sovereign Constitution `AGENTS.md`:**
  - Default deployment at project root of an `AGENTS.md` without YAML frontmatter (< 4096 bytes), ensuring automatic `always_on` loading by Antigravity and `opencode`.
- **Universal Fail-Closed Mode Across Quality Gates:**
  - All Quality Gates (`qa_security_gate.sh`, `backend_quality_gate.sh`, `front_quality_gate.sh`, `e2e_verification_gate.sh`) now require real checks and fail (`exit 1`) if no tests ran or if tools are missing.
- **Expanded Multi-Stack Support:**
  - `backend_quality_gate.sh` natively supports Node/TypeScript (NestJS, Express, Fastify), Python (`ruff`, `mypy`, `pytest`), Go (`go vet`, `go test`), alongside PHP / Laravel / AdonisJS.
- **CLI Installer Engine (`src/cli/`):**
  - `san-framework init --local` deploys all 4 layers with Smart Merge without overwriting customized rules.
  - `san-framework init --global` bundles the complete official Antigravity Plugin.
  - `san-framework update` enables seamless instant v1.0 $\rightarrow$ v2.0 migration without touching developer customizations.

### Removed
- **Formal Removal of `rules.json`:** Obsolete file unrecognized by Antigravity engine permanently deleted.
- **Eradication of `--passWithNoTests`:** Prohibited empty-pass fake test results in `qa_security_gate.sh`.
- **Removal of Destructive `rm -rf`:** Elimination of unrecoverable file deletions in `git_ai_hygiene.sh`.
- **Elimination of Hardcoded Proprietary Domains:** Removed hardcoded `alexsan.pro` references in infrastructure scripts (`infra_health_check.sh`, `verify_tracking_and_seo.sh`) and `.agents/` reference in CI (`DEPLOYMENT_WORKFLOW.yml`).

### Fixed
- **Resolution of 12 Logical and Technical Vulnerabilities:**
  1. `useEffect` side-effect memory leaks without cleanup functions detected in `front_quality_gate.sh`.
  2. Bypassed dependency audit (`|| true`) eliminated in `front_quality_gate.sh`.
  3. False success `[0/4 checks] -> exit 0` eliminated in `backend_quality_gate.sh`.
  4. False Bruno static pass in `e2e_verification_gate.sh` requiring actual API test suite execution.
  5. Detection of monolithic components (> 300 lines) and inaccessible `<div onClick>` elements.
  6. Detection and blocking of plain-text database credentials in URLs (`postgresql://`, `mysql://`, `mongodb://`, `redis://`).
  7. Real parsing of spacing, radii, and typography sections in `BRAND.md` within `build_tokens.mjs`, exiting `1` on WCAG contrast failure.
  8. Unified `CANVAS_SPEC` parser and migration from `file://` to local Node ephemeral HTTP server in `export_png.mjs` resolving CORS font/CSS blocking.
  9. Fixed duplicated 4 Node arguments in `doc_scraper.sh` and replaced rigid blocking with traced warnings.
  10. Removed French false positives (`tata`, `toto`, `titi`, `placeholder` attribute) in `check_lorem.sh`.
  11. Adapted idea scoring `score_idea.py` according to `PROJECT_PROFILE` to prevent wrongful SaaS/CLI disqualification.
  12. Preserved root `AGENTS.md` during Git hygiene purge operations.

### Security
- **Extended Secrets Detection:** Hardened regex covering database URLs with passwords, webhook signatures (`whsec_`), third-party API keys, and plain-text sensitive tokens.
- **Hermetic Git Isolation:** Dual automatic lock `.gitignore` and `.git/info/exclude` ensuring zero internal artifact leaks.

---

## [1.1.0] - 2026-10-29

### Added
- **opencode compatibility (context & update):**
  - **`update` command:** Re-synchronizes skills and generates/refreshes the opencode context layer (`AGENTS.md` + `opencode.json`) on any already-deployed codebase, making it immediately understandable by opencode.
  - **`--opencode` flag (for `init`):** Additionally generates the opencode context during a local install: `AGENTS.md` (auto-loaded instructions) and `opencode.json` (`skills.paths: [".agents/skills"]` + `instructions: [".agents/GEMINI.md"]`).
  - **opencode Smart Merge:** A customized `AGENTS.md` (without the marker) is never overwritten; `opencode.json` is merged without altering user fields.
  - **opencode-aware Git hygiene:** In opencode mode, `AGENTS.md` stays committable and `.opencode/`/`AGENTS.md` are no longer purged.
  - **`AGENTS_INDEX_TEMPLATE.md` template:** opencode context model with a routing table of the 17 skills.
- **Phase 9 test suite (`tests/phase9/test_opencode.sh`):** 9 automated checks (context generation, `update` command, Smart Merge, dry-run) validated at 100%.

---

## [1.0.0] - 2026-10-23

### Added
- **Phase 8 Validated — Global End-to-End (E2E) Integration & Validation:**
  - **Exhaustive E2E Test Suite (`tests/phase8/test_e2e_full.sh`):** 24 automated integration verifications passing 100% green.
  - **Realistic Client Simulation:** Validated deployment onto a realistic Next.js / TypeScript codebase with Git, verifying all 17 modules in `.agents/skills/`, 5 normative rule files, and executable bits on 22 scripts.
  - **In-Situ Script Execution in Client Context:** Real execution of `build_tokens.mjs` (CSS compilation / WCAG AAA contrast audit), `check_lorem.sh` (zero false positives, strict rejection of placeholder text), `archive_roadmap.sh` (blocking incomplete roadmaps and successfully archiving 100% completed roadmaps).
  - **Global Deployment (`--global`):** Validated installation of 17 modules into Antigravity CLI user directory (`~/.gemini/antigravity-cli/skills/`).
  - **Absolute Git Isolation:** Verified zero leaks in `git status --porcelain`, automatic physical purge and Git cache un-tracking of competitor agent artifacts (`CLAUDE.md`, `.cursorrules`).
  - **Smart Merge & Non-Regression:** Guaranteed preservation of customized user rules (`PRODUCT.md`) and third-party custom skills (`my_custom_skill`).
  - **Cartesian Compliance Audit of 17 Modules:** Validated YAML frontmatter across all 17 `SKILL.md` files and purged all residual private mentions for complete universality.
  - **Unified npm Test Tooling (`package.json`):** Added `test:phase8` and master `npm test` script chaining test suites from Phase 3 through Phase 8.
- **Formal MVP Roadmap Completion & Archiving:**
  - 100% physical completion of all tasks across Phases 1 through 8.
  - Deterministic archiving via `archive_roadmap.sh` to `roadmaps/archives/MVP_BUILD_FRAMEWORK_23102026.md`.

---

## [0.6.0] - 2026-10-23

### Added
- **Phase 7 Validated — Universal CLI Installer Engine (`npx @alexsan/agy-framework init`):**
  - **Root `package.json`:** Official distribution config for npm/npx with binary declaration (`agy-framework` and `san-framework`), test scripts `test:phase3` through `test:phase7`, zero external dependencies for maximum resilience and blazingly fast execution.
  - **`src/cli/index.js`:** Autonomous executable CLI entry point (`chmod +x`), official ASCII banner display (`logos/LOGO_ASCII.txt`), native CLI parser (`node:util` `parseArgs`), interactive TTY wizard (`node:readline/promises`), flag handling (`--local`, `--global`, `--all`, `--skills=...`, `--dry-run`, `--force`).
  - **`src/cli/installer.js`:** Deterministic deployment engine copying the 17 native skill modules from `src/skills/` to target `.agents/skills/` or `~/.gemini/antigravity-cli/skills/`.
  - **Smart Merge:** Scrupulous preservation of user's customized rules (`BRAND.md`, `PRODUCT.md`, `PROJECT.md`, `API.md`) and only instantiating missing rules, master index `GEMINI.md`, and `rules.json`.
  - **Automated Git Hygiene:** Physical removal of legacy agent residues (`CLAUDE.md`, `.cursorrules`, etc.), Git index un-tracking (`git rm --cached`), and airtight dual locking (`.gitignore` & `.git/info/exclude`).
- **Phase 7 Automated Test Suite (`tests/phase7/test_cli.sh`):**
  - Validation of base commands (`--help`, `--version`, `list` with all 17 modules).
  - Validation of `--local --all` deployment with Smart Merge, legacy purge, and Git isolation.
  - Validation of granular selection (`--skills=san_init,san_planner`).
  - Validation of simulation mode (`--dry-run`).

---

## [0.5.0] - 2026-10-23

### Added
- **Phase 6 Validated — Packaging of Quality, DevOps, Legal & Growth into `src/skills/`:**
  - **`src/skills/san_qa_security_expert/`:**
    - `SKILL.md`: Unified QA/Security/Perf gatekeeper, strict independence (auditors write zero code patches), deterministic binary verdict (`DELIVERABLE`/`NOT DELIVERABLE`), Playwright CDP helper simulating degraded 3G/EDGE network (750 kbps down / 250 kbps up / 150ms RTT).
    - `references/owasp_unified_checklist.md`: Consolidated OWASP Web, API 2023, and Mobile 2024 Top 10.
    - `references/perf_benchmarks.md`: Strict Core Web Vitals thresholds, p95 API latencies < 200ms, APK size < 25 MB, idle RAM < 150 MB, 60 fps.
    - `references/testing_protocols.md`: Deterministic Playwright E2E testing protocols.
    - `scripts/qa_security_gate.sh`: Deterministic bash script with CVE scanning, `tsc --noEmit`, secrets/private keys leak detection, and test execution.
    - `templates/QA_REPORT_TEMPLATE.md`, `templates/SECURITY_REPORT_TEMPLATE.md` (scored on 100 pts), `templates/PERF_REPORT_TEMPLATE.md`.
  - **`src/skills/san_devops_expert/`:**
    - `SKILL.md`: Lead DevOps, VPS Ubuntu LTS administration, CloudPanel, Nginx HTTP/2 TLS 1.3, PHP-FPM pools, PM2, Supervisor, Redis, SQL databases, absolute reversibility (< 30s) and tested backup principle.
    - `references/cloudpanel_and_vps.md` & `references/mailcow_and_deliverability.md` (10/10 Mail-Tester score, SPF -all, DKIM 2048b, DMARC p=reject, strict rDNS PTR).
    - `references/backup_and_restore_protocols.md`: 3-2-1 backup strategy, AES-256 GPG encrypted dumps, and deterministic container restoration tests.
    - `scripts/infra_health_check.sh`: Autonomous bash health check for openssl SSL, dig DNS, ss ports, df disk/inodes, and HTTP 200 probe.
    - `templates/INFRA_TEMPLATE.md`, `templates/RUNBOOK_TEMPLATE.md`, `templates/DEPLOYMENT_WORKFLOW.yml`.
  - **`src/skills/san_store_legal_expert/`:**
    - `SKILL.md`: Play Store & App Store compliance, anti-rejection engineering, deterministic reviewer demo account (`reviewer@alexsan.pro` / OTP `123456` / 25 000 FCFA), Apple Directive 5.1.1 (in-app deletion in <= 3 taps + 30-day purge), and code-backed legal drafts.
    - `references/store_rejection_patterns.md`: Google/Apple rejection reasons and actionable remediations.
    - `scripts/scan_app_permissions.sh`: Bash script scanning `AndroidManifest.xml`, `Info.plist`, `app.json`, and `package.json` to detect permissions and tracker SDKs.
    - `templates/STORE_CHECKLIST_TEMPLATE.md`, `templates/PRIVACY_POLICY_TEMPLATE.md`, `templates/TERMS_TEMPLATE.md`, `templates/DATA_MAP_TEMPLATE.md`.
  - **`src/skills/san_growth_expert/`:**
    - `SKILL.md`: Lead Growth, 100% White-Hat ethics (zero fake reviews), local Africa/Congo SEO (Brazzaville, Pointe-Noire, Kinshasa, landmarks, XAF/FCFA/USD, MoMo/Airtel), store ASO strategy (30/80 char, 4 sections, 5-scene storyboard), and unified `snake_case` tracking taxonomy.
    - `references/local_seo_congo.md`, `references/aso_playbook.md`, `references/tracking_taxonomy.md`.
    - `scripts/verify_tracking_and_seo.sh`: Bash script validating `robots.txt`, `sitemap.xml` accessibility, `<meta>` tags, and Schema.org JSON-LD syntax.
    - `templates/TRACKING_PLAN_TEMPLATE.md`, `templates/STORE_LISTING_TEMPLATE.md`.
- **Phase 6 Automated Test Suite (`tests/phase6/test_phase6.sh`):**
  - Validation of `scan_app_permissions.sh` on Android and Expo manifests.
  - Validation of `infra_health_check.sh` in local mode.
  - Validation of `verify_tracking_and_seo.sh` on mock sitemap, robots, and Schema.org.

---

## [0.4.0] - 2026-10-23

### Added
- **Phase 5 Validated — Packaging of Visual Design & Full-Stack Core into `src/skills/`:**
  - **`src/skills/san_designer/`:**
    - `SKILL.md`: High-fidelity 100% code visual design (HTML/Tailwind), zero external CDN, 5 standard canvas specifications (Play Store 1080x1920, App Store 1290x2796, Desktop 1440x900, Tablet 820x1180, Feature Graphic 1024x500), two-tier `/ux-scan` workflow, and mathematical contrast models (> 7:1 daylight AAA).
    - `references/audit_criteria.md`: 10-pt evaluation grid across 3 auditor profiles (Cognitive Psychology, Emerging Markets/3G Reality, Design System tokens).
    - `references/contrast_mathematics.md` & `references/device_canvas_specs.md`.
    - `templates/device_frames.html`: Pure HTML/CSS device frames simulating iPhone (Dynamic Island) and Android (punch-hole) with zero CDN dependencies.
    - `templates/mockup_standalone.html` & `scripts/export_png.mjs`.
  - **`src/skills/san_ux_ui_expert/`:**
    - `SKILL.md`: Lead Frontend & Mobile Engineer, React.js / React Native / Expo Router / Tailwind strict, mandatory implementation of the 5 UI states across EVERY view, 3G resilience, and zero-leak client security (Keychain/Keystore).
    - `references/anti_ai_taste_rules.md`: Negative matrix prohibiting AI visual clichés (neon gradients, uniform 3-column grey cards, blind full-screen spinners).
    - `references/client_resilience_domains.md`: SQLite/MMKV caching, Optimistic UI, Outbox queue pattern, image pre-compression < 300 KB, and Expo haptics.
    - `scripts/front_quality_gate.sh`: Deterministic bash script with package manager detection, `tsc --noEmit`, linters, Jest/Vitest tests, and memory leak scanning.
    - `templates/FIVE_STATES_COMPONENT.tsx`, `templates/USE_OFFLINE_MUTATION.ts`, `templates/FRONT_SECURITY_PERF_REPORT.md`.
  - **`src/skills/san_backend_expert/`:**
    - `SKILL.md`: Lead Backend & Distributed Systems, PHP 8.2+ Laravel / AdonisJS v6 strict, absolute idempotency dogma (`Idempotency-Key` UUIDv4 with 24h atomic Redis lock), ironclad Mobile Money financial security (triple locking, constant-time HMAC-SHA256 webhooks via `hash_equals()`, 5-min reconciliation cron).
    - `references/backend_stack_alexsan.md` & `references/resilience_and_domains.md` (exponential backoff with full jitter anti-thundering herd).
    - `scripts/backend_quality_gate.sh`: Autonomous bash script executing PHPStan max / `tsc`, Pest / PHPUnit / Japa, static N+1 query prevention (`preventLazyLoading`), and Composer/NPM security audits.
    - `templates/SECURITY_REPORT_TEMPLATE.md` (OWASP API Security Top 10 pentest report), `ENDPOINT_RULE_TEMPLATE.md`, `BRUNO_REQUEST_TEMPLATE.bru`, `SERVICE_ACTION_TEMPLATE.php`, `MOMO_WEBHOOK_CONTROLLER.php`.
  - **`src/skills/san_executer/`:**
    - `SKILL.md`: Full-Stack Orchestrator, 3-profile architectural triage engine (`BACK_ONLY`, `FRONT_ONLY`, `FULL_STACK`), 6-step delivery pipeline, and circuit-breaker.
    - `references/orchestration_matrix.md`: Mermaid decision tree and least-privilege subagent assignment matrix.
    - `references/contract_first_protocol.md`: Inviolable synchronization of endpoint specifications, TypeScript interfaces, and Bruno requests.
    - `scripts/e2e_verification_gate.sh`: Unified coordinator script executing front + back quality gates and Bruno contract assertions.
    - `templates/ENDPOINT_CONTRACT_TEMPLATE.md`, `templates/BRUNO_REQUEST_TEMPLATE.bru`, `templates/EXECUTION_REPORT_TEMPLATE.md`.
- **Phase 5 Automated Test Suite (`tests/phase5/test_phase5.sh`):**
  - Validation of strict rejection (`exit 1`) upon simulated frontend and backend errors.
  - Validation of success (`exit 0`) on compliant environments and global E2E orchestration.

---

## [0.3.0] - 2026-10-23

### Added
- **Phase 4 Validated — Packaging of Transversal Execution Sub-Skills into `src/skills/`:**
  - **`src/skills/san_subagent_manager/`:**
    - `SKILL.md`: Comprehensive operational manual for surgical subagent allocation, principle of least privilege, strict model selection (`Model: 'flash'` vs `Model: 'inherit'`), and sealed handover protocol via `send_message`.
    - Closed prompt templates: `SUBAGENT_PROMPT_TEMPLATE.md`, `ATOMIC_CODER_PROMPT.md`, and `AUDITOR_PROMPT.md`.
    - `scripts/validate_subagent_spec.sh`: Bash script validating compliance of the 6 mandatory prompt sections.
    - References: `least_privilege_matrix.md`, `subagent_archetypes.md`, `prompt_engineering_standards.md`.
  - **`src/skills/san_searcher/`:**
    - `SKILL.md`: *Context Shielding* protocol protecting orchestrator context, strict dependency pinning via local project manifests.
    - `scripts/detect_stack_versions.sh`: Automated version detection for Node/React/Expo, PHP/Laravel, Go, and Docker.
    - `scripts/doc_scraper.sh`: Decontamination airlock converting fetched HTML into clean Markdown without extraneous DOM tags.
    - `templates/RESEARCH_NOTE_TEMPLATE.md`: Canonical investigation note template for `docs/research/TECH_INVESTIGATION_*.md`.
    - References: `official_authorities.md` and `version_matrix_guidelines.md`.
  - **`src/skills/san_doc_keeper/`:**
    - `SKILL.md`: SemVer 2.0.0 governance, 7 Keep a Changelog categories, and zero-token immediate hygiene Fast-Track.
    - `scripts/changelog_helper.sh`: Deterministic automated changelog insertion under `[Unreleased]`.
    - `scripts/archive_roadmap.sh`: Deterministic 100% completion check (`- [x]`) and archiving with SHA-256 fingerprinting.
    - Templates: `CHANGELOG_TEMPLATE.md` and `README_TEMPLATE.md`.
  - **`src/skills/san_copywriter/`:**
    - `SKILL.md`: Empathetic UX voice, strict prohibition of *Lorem Ipsum*, non-breaking space currency formatting (`2 500 FCFA`), landmark-based addresses, and Mobile Money instincts.
    - `references/local_copy_guidelines.md`: Production-ready copy library for the 5 UI states (Nominal, Empty, Skeleton, 3-part Error, Offline).
    - `scripts/check_lorem.sh`: Recursive bash linter tracking dummy text residues (exit code 1 on detection).
    - `scripts/validate_copy_length.mjs`: Character limit validator for app store metadata and CTAs.
    - Templates: `I18N_DICTIONARY_TEMPLATE.json` and `UI_5_STATES_COPY_TEMPLATE.md`.
  - **`src/skills/san_design_tokens/`:**
    - `SKILL.md`: Design token invariance, WCAG AAA daylight accessibility (> 7:1), and 60 fps kinetic motion invariants.
    - `scripts/build_tokens.mjs`: Standalone Markdown parser compiling tokens to CSS variables (`:root`), Tailwind (`@theme` v4 and v3 extend), and TypeScript (`tokens.ts`).
    - `scripts/audit_magic_values.sh`: Static scanner tracking hardcoded hex colors and arbitrary pixel spacings.
    - `templates/BRAND_TOKENS_TEMPLATE.md` and kinetic/contrast references.
  - **`src/skills/san_exporter/`:**
    - `SKILL.md`: Headless Playwright capture pipeline, `networkidle` + `document.fonts.ready` synchronization.
    - Target formats: Google Play (1080x1920, 1024x500), Apple App Store (1290x2796), and Print A4 300 DPI (2480x3508).
    - `scripts/export_png.mjs`: Headless Playwright capture engine with SHA-256 manifest logging.
    - `scripts/svg_to_png.mjs`: Vector-to-raster compiler with mandatory alpha channel removal (eliminates Apple ITMS-90717 rejection).
- **Phase 4 Automated Test Suite (`tests/phase4/test_phase4.sh`):**
  - Verification of `check_lorem.sh` on dirty code (exit 1) and clean code (exit 0).
  - Verification of `build_tokens.mjs` with full CSS and TypeScript compilation.
  - Verification of `audit_magic_values.sh` (hardcoded magic color/value detection).
  - Verification of `changelog_helper.sh` (proper Keep a Changelog entry insertion).

---

## [0.2.0] - 2026-10-23

### Added
- **Phase 3 Validated — Packaging of Onboarding & Scoping Core into `src/skills/`:**
  - **`src/skills/san_init/`:**
    - `SKILL.md`: Comprehensive operational manual with official Antigravity YAML frontmatter, 7-phase init protocol, and deterministic detection across 10 software stacks.
    - `scripts/git_ai_hygiene.sh`: Standalone bash script (`chmod +x`), legacy agent config purge (`CLAUDE.md`, `.cursorrules`, etc.), Git index un-tracking (`git rm --cached`), and airtight dual locking (`.gitignore` & `.git/info/exclude`).
    - `scripts/svg_to_png.mjs`: Multi-resolution vector asset processing with Sharp engine and graceful fallback.
    - Rules templates: `BRAND_TEMPLATE.md`, `PRODUCT_TEMPLATE.md`, `PROJECT_TEMPLATE.md`, `API_TEMPLATE.md`, `LOGO_TEMPLATE.md`, `rules_json_template.json`, and master index `GEMINI_INDEX_TEMPLATE.md`.
  - **`src/skills/san_brainstorming/`:**
    - `SKILL.md`: Socratic 5-question investigation process, arbitration thresholds, and activation protocols.
    - `references/ideation_scoring_matrix.md`: Quantitative 40-pt scoring grid (Business Impact, Technical Feasibility, Africa Field Reality, Risk Management) with knockout criteria.
    - `references/congo_market_signals.md`: Emerging market field intelligence (3G data costs, Mobile Money webhooks, WhatsApp OS, low-end Android hardware constraints).
    - `scripts/score_idea.py`: Deterministic scoring CLI engine and JSON exporter.
    - `templates/IDEA_TEMPLATE.md`: Normalized template for `/roadmaps/ideas/*.md` with direct handoff payload to `san_planner`.
  - **`src/skills/san_planner/`:**
    - `SKILL.md`: 6 sequential impermeable engineering phases (CPM), Proof-by-Code rule, mandatory testing matrix per stack, and orchestrator Fast-Track.
    - `templates/ROADMAP_TEMPLATE.md`: Canonical roadmap skeleton with mandatory automated test gates.
    - `templates/CHANGELOG_TEMPLATE.md`: Keep a Changelog compliant template.
    - `scripts/archive_roadmap.sh`: Standalone bash script verifying 100% checked items (`- [x]`) before moving to `/roadmaps/archives/`.
- **Phase 3 Automated Test Suite (`tests/phase3/`):**
  - `test_git_ai_hygiene.sh`: Full integration test on isolated dirty Git repository (100% passing).
  - `test_archive_roadmap.sh`: Unit tests validating rejection of incomplete/empty roadmaps and successful deterministic archiving (100% passing).
- **Comprehensive Elevation of All Specifications (`skills/` & `sub-skills/`):**
  - Full rewrite of all 11 primary skills and 6 sub-skills with production code, TypeScript schemas, mathematical formulas, and zero placeholders.

---

## [0.1.0] - 2026-10-23

### Added
- **Cartesian Modular Architecture:** Complete framework design separated into workshop roles (`/skills/`) and transversal utilities (`/sub-skills/`).
- **11 Master Primary Skill Specifications:**
  - [`san_init`](skills/san_init.md): Initialization, Git isolation, and codebase reverse-engineering.
  - [`san_brainstorming`](skills/san_brainstorming.md): Upstream scoping, 40-pt multi-criteria idea scoring.
  - [`san_planner`](skills/san_planner.md): Project roadmap planning, phase scheduling, and auto-cleaning.
  - [`san_designer`](skills/san_designer.md): 100% code visual design, HTML/Tailwind, `/ux-scan`, store screenshots.
  - [`san_ux_ui_expert`](skills/san_ux_ui_expert.md): Lead Frontend & Mobile, anti-AI taste, 5 mandatory UI states, 3G resilience.
  - [`san_backend_expert`](skills/san_backend_expert.md): Lead Backend, SOLID APIs, Redis idempotency, Bruno, Mobile Money.
  - [`san_executer`](skills/san_executer.md): Full-Stack Orchestrator, *Contract-First* protocol, and End-to-End delivery.
  - [`san_qa_security_expert`](skills/san_qa_security_expert.md): Unified Gatekeeper: E2E QA, OWASP security, performance, binary verdict (`DELIVERABLE`).
  - [`san_devops_expert`](skills/san_devops_expert.md): Infrastructure, CloudPanel, Mailcow, VPS, CI/CD, reversibility, and runbooks.
  - [`san_store_legal_expert`](skills/san_store_legal_expert.md): Store compliance (Google Play/Apple), anti-rejection, code-backed legal drafts.
  - [`san_growth_expert`](skills/san_growth_expert.md): Local SEO (Africa/Congo), store ASO, and unified tracking plan (Firebase/Meta/Google).
- **6 Transversal Sub-Skill Specifications:**
  - [`san_subagent_manager`](sub-skills/san_subagent_manager.md): Surgical subagent calibration, prompt sealing, and `flash`/`inherit` routing.
  - [`san_searcher`](sub-skills/san_searcher.md): High-precision researcher, official docs scraping, noise-free context isolation.
  - [`san_doc_keeper`](sub-skills/san_doc_keeper.md): Keeping `CHANGELOG.md`, `README.md`, and Fast-Track roadmap archiving.
  - [`san_copywriter`](sub-skills/san_copywriter.md): UX writer, empathetic micro-copy, localization, zero *Lorem Ipsum*.
  - [`san_design_tokens`](sub-skills/san_design_tokens.md): Guardian of `BRAND.md`, static and kinetic motion invariants.
  - [`san_exporter`](sub-skills/san_exporter.md): Headless Playwright capture and SVG $\rightarrow$ PNG vector icon processing.
- **Key Engineering Protocols:**
  - Two-tier audit gate (Tier 1 deterministic script with 0 LLM tokens $\rightarrow$ Tier 2 specialized cognitive audits).
  - Orchestrator immediate hygiene Fast-Track (checking boxes after proof, archiving, changelog).
  - Absolute Git isolation (`.agents/` strictly ignored in `.gitignore` and `.git/info/exclude`).
- **Brand Identity & Vector Logos:**
  - Brand visual guidelines in [`logos/LOGO.md`](logos/LOGO.md).
  - Vector SVG assets: [`logos/san_framework_logo.svg`](logos/san_framework_logo.svg), [`logos/san_framework_icon.svg`](logos/san_framework_icon.svg), and [`logos/san_framework_dark.svg`](logos/san_framework_dark.svg).
- **Client Product Scope:**
  - Defined [`src/`](src/) representing the exact product boundary destined for client machine `.agents/`.
