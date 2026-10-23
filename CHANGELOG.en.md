# CHANGELOG — `san_agy_framework`

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Language:** [Version française](CHANGELOG.md)

---

## [Unreleased]

### Planned
- Official publication on the public npm registry (`npm publish --access public`).
- Pilot deployments on production codebases.

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
