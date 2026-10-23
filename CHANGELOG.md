# CHANGELOG — `san_agy_framework`

> **Langue :** Français | [English version](CHANGELOG.en.md)

Toutes les modifications notables apportées à ce projet sont consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

---

## [Unreleased]

### Planned
- Implémentation du CLI d'installation (`npx @alexsan/agy-framework init`).
- Validation globale & Tests d'intégration End-to-End (Phase 8).

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
