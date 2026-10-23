# CHANGELOG — `san_agy_framework`

Toutes les modifications notables apportées à ce projet sont consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [Unreleased]

### Planned
- Implémentation du CLI d'installation (`npx @alexsan/agy-framework init`).
- Packaging des vrais modules exécutables dans `/src/skills/` et `/src/sub-skills/`.
- Tests d'intégration et scénarios de validation sur codebases clientes test.

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
