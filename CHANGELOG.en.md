# CHANGELOG — `san_agy_framework`

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Language:** [Version française](CHANGELOG.md)

---

## [Unreleased]

### Planned
- Universal CLI installer implementation (`npx @alexsan/agy-framework init`).
- Packaging Phase 4 (Transversal execution sub-skills into `src/skills/`).
- Packaging Phase 5 (Visual design & Full-Stack core into `src/skills/`).
- Packaging Phase 6 (Quality, DevOps, legal & growth into `src/skills/`).

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
