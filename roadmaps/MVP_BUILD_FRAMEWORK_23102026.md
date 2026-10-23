# ROADMAP EXHAUSTIVE — CONSTRUCTION DU FRAMEWORK « GOOGLE ANTIGRAVITY » (`san_*`)

> **Fichier :** `/roadmaps/MVP_BUILD_FRAMEWORK_23102026.md`  
> **Statut :** EN COURS (PHASES 1, 2, 3, 4 & 5 VALIDÉES — PASSAGE EN PHASE 6)  
> **Responsables :** `san_executer` & `san_planner`  
> **Objectif :** Disposer d'un framework 100 % opérationnel, packagé dans `src/` et installable en une commande CLI sur n'importe quel projet client.  
> **Convention de nommage :** `[PHASE]_[PROBLEMATIQUE]_[DATE].md` (format JJMMAAAA)

---

## CONSIGNES D'AUTO-NETTOYAGE & D'HYGIÈNE STRICTE

- [ ] **Vérification avant cochage :** Ne cocher une tâche `- [x]` QUE si le code, le script, le template ou le test correspondant existe physiquement et a été formellement validé.
- [ ] **Fast-Track Orchestrateur :** L'orchestrateur coche lui-même les tâches vérifiées, met à jour `CHANGELOG.md` et déplace la roadmap vers `/roadmaps/archives/` une fois validée à 100 %.
- [ ] **Délégation d'implémentation :** L'écriture des scripts et modules exécutables dans `src/` est déléguée à des sous-agents atomiques propulsés par **`Model: 'flash'`**.
- [ ] **Condition d'archivage :** Seule une roadmap dont 100 % des cases sont cochées et testées peut être archivée dans `/roadmaps/archives/`.

---

## PHASE 1 : SPÉCIFICATIONS, CARTOGRAPHIE & ARCHITECTURE GLOBALE

- [x] Rédiger les 11 spécifications cartésiennes de skills principaux dans `/skills/` :
  - [x] [`skills/san_init.md`](../skills/san_init.md)
  - [x] [`skills/san_brainstorming.md`](../skills/san_brainstorming.md)
  - [x] [`skills/san_planner.md`](../skills/san_planner.md)
  - [x] [`skills/san_designer.md`](../skills/san_designer.md)
  - [x] [`skills/san_ux_ui_expert.md`](../skills/san_ux_ui_expert.md)
  - [x] [`skills/san_backend_expert.md`](../skills/san_backend_expert.md)
  - [x] [`skills/san_executer.md`](../skills/san_executer.md)
  - [x] [`skills/san_qa_security_expert.md`](../skills/san_qa_security_expert.md)
  - [x] [`skills/san_devops_expert.md`](../skills/san_devops_expert.md)
  - [x] [`skills/san_store_legal_expert.md`](../skills/san_store_legal_expert.md)
  - [x] [`skills/san_growth_expert.md`](../skills/san_growth_expert.md)
- [x] Rédiger les 6 spécifications de sous-skills transversaux dans `/sub-skills/` :
  - [x] [`sub-skills/san_subagent_manager.md`](../sub-skills/san_subagent_manager.md)
  - [x] [`sub-skills/san_searcher.md`](../sub-skills/san_searcher.md)
  - [x] [`sub-skills/san_doc_keeper.md`](../sub-skills/san_doc_keeper.md)
  - [x] [`sub-skills/san_copywriter.md`](../sub-skills/san_copywriter.md)
  - [x] [`sub-skills/san_design_tokens.md`](../sub-skills/san_design_tokens.md)
  - [x] [`sub-skills/san_exporter.md`](../sub-skills/san_exporter.md)
- [x] Structurer [`README.md`](../README.md) et [`README.en.md`](../README.en.md) en index maîtres cartographiques avec diagrammes Mermaid.
- [x] Purger toute référence à des projets privés (`koteka`, `vunette`) pour garantir une stricte universalité.

---

## PHASE 2 : IDENTITÉ VISUELLE, LICENCE, GIT & OUTILLAGE DE L'ATELIER

- [x] Initialiser Git sur la branche `main` et verrouiller `.gitignore`.
- [x] Créer la charte graphique et les logos vectoriels dans `/logos/` :
  - [x] [`logos/LOGO.md`](../logos/LOGO.md)
  - [x] [`logos/san_framework_logo.svg`](../logos/san_framework_logo.svg)
  - [x] [`logos/san_framework_icon.svg`](../logos/san_framework_icon.svg)
  - [x] [`logos/san_framework_dark.svg`](../logos/san_framework_dark.svg)
  - [x] [`logos/LOGO_ASCII.txt`](../logos/LOGO_ASCII.txt) (réservé au terminal CLI)
- [x] Créer [`LICENSE`](../LICENSE) (Licence MIT Alexsan.pro).
- [x] Initialiser [`CHANGELOG.md`](../CHANGELOG.md) et [`CHANGELOG.en.md`](../CHANGELOG.en.md) (Keep a Changelog).
- [x] Initialiser le dossier produit `/src/` et l'espace des roadmaps archivées `/roadmaps/archives/`.
- [x] Configurer le dépôt distant GitHub et synchroniser (`git push -u origin main`).

---

## PHASE 3 : PACKAGING DU SOCLE D'ONBOARDING & CADRAGE DANS `src/skills/`

- [x] Implémenter le skill exécutable `src/skills/san_init/` :
  - [x] `SKILL.md` (instructions exécutables reconnues par Antigravity, trigger, découverte récursive).
  - [x] `scripts/git_ai_hygiene.sh` (purge des configs tierces, désindexation `git rm --cached`, verrouillage `.gitignore` et `.git/info/exclude`).
  - [x] `scripts/svg_to_png.mjs` (déclinaison multi-résolution des logos et favicons via Sharp).
  - [x] `templates/rules/BRAND_TEMPLATE.md` (design tokens, manifeste sensoriel, courbes cinétiques).
  - [x] `templates/rules/PRODUCT_TEMPLATE.md` (vision produit, persona, proposition de valeur).
  - [x] `templates/rules/PROJECT_TEMPLATE.md` (stack technique, politique de tests, routage des modèles).
  - [x] `templates/rules/API_TEMPLATE.md` (standards REST/WebSockets, format JSON).
  - [x] `templates/GEMINI_INDEX_TEMPLATE.md` (table de routage maître `.agents/GEMINI.md`).
- [x] Implémenter le skill exécutable `src/skills/san_brainstorming/` :
  - [x] `SKILL.md` (processus socratique, questionnaire au dev, prompt d'idéation).
  - [x] `references/ideation_scoring_matrix.md` (grille 40 points : Impact, Effort, Terrain Afrique, Risques).
  - [x] `references/congo_market_signals.md` (réalités terrain, Mobile Money, usages WhatsApp, data coûteuse).
  - [x] `templates/IDEA_TEMPLATE.md` (gabarit pour `/roadmaps/ideas/[THEME]_[DATE].md`).
- [x] Implémenter le skill exécutable `src/skills/san_planner/` :
  - [x] `SKILL.md` (découpage séquentiel par phases, règles d'auto-nettoyage, critères de complétion 100 %).
  - [x] `templates/ROADMAP_TEMPLATE.md` (squelette normé de roadmap avec tests obligatoires).
  - [x] `templates/CHANGELOG_TEMPLATE.md` (squelette initial `CHANGELOG.md` selon Keep a Changelog).
  - [x] `scripts/archive_roadmap.sh` (script bash vérifiant que 100 % des cases sont cochées avant archivage).
- [x] Tests de la Phase 3 :
  - [x] Tester `git_ai_hygiene.sh` sur un dépôt Git factice et vérifier la propreté de l'index (`tests/phase3/test_git_ai_hygiene.sh`).
  - [x] Tester `archive_roadmap.sh` (rejet si cases non cochées, succès si 100 % coché) (`tests/phase3/test_archive_roadmap.sh`).

---

## PHASE 4 : PACKAGING DES SOUS-SKILLS TRANSVERSAUX D'EXÉCUTION DANS `src/skills/`

> Note : Chez le client, Antigravity découvre tous les modules dans `skills/`. Les sous-skills sont donc packagés comme des modules natifs dans `src/skills/`.

- [x] Implémenter le skill exécutable `src/skills/san_subagent_manager/` :
  - [x] `SKILL.md` (règles de calibrage, sélection `flash` vs `inherit`, least-privilege).
  - [x] `templates/SUBAGENT_PROMPT_TEMPLATE.md` (structure de prompt fermé anti-hallucination).
- [x] Implémenter le skill exécutable `src/skills/san_searcher/` :
  - [x] `SKILL.md` (directives de scraping, pinning des versions via `package.json`/`composer.json`).
  - [x] `scripts/doc_scraper.sh` (extraction ciblée des documentations officielles).
  - [x] `templates/RESEARCH_NOTE_TEMPLATE.md` (fiche de synthèse canonique `docs/research/*.md`).
- [x] Implémenter le skill exécutable `src/skills/san_doc_keeper/` :
  - [x] `SKILL.md` (protocole SemVer, mise à jour de `README.md` et `.agents/rules/`).
  - [x] `scripts/changelog_helper.sh` (script d'insertion automatique d'entrées de changelog).
- [x] Implémenter le skill exécutable `src/skills/san_copywriter/` :
  - [x] `SKILL.md` (règles de voix UX, formatage devises FCFA/XAF/USD, repères urbains).
  - [x] `references/local_copy_guidelines.md` (exemples réels d'états vides, bannières d'erreur en 3 volets).
  - [x] `scripts/check_lorem.sh` (linter bash traquant le faux texte dans le code).
- [x] Implémenter le skill exécutable `src/skills/san_design_tokens/` :
  - [x] `SKILL.md` (règles d'invariance des tokens, conversion classes Tailwind / CSS Variables).
  - [x] `scripts/build_tokens.mjs` (compilateur de tokens `BRAND.md` vers TS/Tailwind/CSS).
  - [x] `scripts/audit_magic_values.sh` (scanner de valeurs magiques et couleurs arbitraires).
- [x] Implémenter le skill exécutable `src/skills/san_exporter/` :
  - [x] `SKILL.md` (directives de capture déterministe avec attente `document.fonts.ready`).
  - [x] `scripts/export_png.mjs` (script Playwright multi-résolutions pour captures d'écran stores et affiches).
- [x] Tests de la Phase 4 :
  - [x] Valider l'exécution de `check_lorem.sh` sur un fichier contenant du faux texte (`tests/phase4/test_phase4.sh`).
  - [x] Valider la compilation d'un fichier de tokens avec `build_tokens.mjs` (`tests/phase4/test_phase4.sh`).

---

## PHASE 5 : PACKAGING DU PÔLE CONCEPTION VISUELLE & FULL-STACK DANS `src/skills/`

- [x] Implémenter le skill exécutable `src/skills/san_designer/` :
  - [x] `SKILL.md` (workflow `/ux-scan`, scoring `/10`, contraintes WCAG AA plein soleil).
  - [x] `references/audit_criteria.md` (grilles d'évaluation psychologie cognitive, contexte local et UI).
  - [x] `templates/device_frames.html` (cadres réalistes : Dynamic Island, status bar, encoches).
- [x] Implémenter le skill exécutable `src/skills/san_ux_ui_expert/` :
  - [x] `SKILL.md` (gestion des 5 états UI obligatoires, micro-interactions 60 fps, offline queue).
  - [x] `references/anti_ai_taste_rules.md` (matrice négative des tics graphiques IA interdits).
  - [x] `references/client_resilience_domains.md` (gestion MMKV/SQLite, retries avec `Idempotency-Key`).
  - [x] `scripts/front_quality_gate.sh` (script automatisé : `tsc --noEmit`, tests `Jest`, scan bundle).
  - [x] `templates/FRONT_SECURITY_PERF_REPORT.md` (rapport scoré sur /100).
- [x] Implémenter le skill exécutable `src/skills/san_backend_expert/` :
  - [x] `SKILL.md` (protocole *Contract-First*, verrous atomiques Redis, contrôleurs fins SOLID).
  - [x] `references/backend_stack_alexsan.md` (standards Laravel & AdonisJS, typage strict).
  - [x] `references/resilience_and_domains.md` (gestion Mobile Money, réconciliation cron, webhook HMAC).
  - [x] `scripts/backend_quality_gate.sh` (script automatisé : `phpstan`/`tsc`, tests `Pest`/`Japa`, scan N+1).
  - [x] `templates/SECURITY_REPORT_TEMPLATE.md` (modèle d'audit pentest OWASP API).
- [x] Implémenter le skill exécutable `src/skills/san_executer/` :
  - [x] `SKILL.md` (alias `san_execute`, moteur de triage Full-Stack, orchestration des experts).
  - [x] `references/orchestration_matrix.md` (arbre de décision BACK_ONLY, FRONT_ONLY, FULL_STACK).
  - [x] `references/contract_first_protocol.md` (synchronisation obligatoire des fichiers `.bru` et endpoints).
  - [x] `scripts/e2e_verification_gate.sh` (script global vérifiant tests front + back avant livraison).
- [x] Tests de la Phase 5 :
  - [x] Vérifier que `front_quality_gate.sh` et `backend_quality_gate.sh` retournent bien un exit code `1` en cas d'erreur simulée (`tests/phase5/test_phase5.sh`).

---

## PHASE 6 : PACKAGING DU PÔLE QUALITÉ, DEVOPS, LÉGAL & CROISSANCE DANS `src/skills/`

- [ ] Implémenter le skill exécutable `src/skills/san_qa_security_expert/` :
  - [ ] `SKILL.md` (responsable unique QA/Sécurité/Perf, verdict binaire `LIVRABLE`/`NON LIVRABLE`).
  - [ ] `references/owasp_unified_checklist.md` (OWASP Web, API et Mobile Top 10 consolidés).
  - [ ] `references/perf_benchmarks.md` (seuils stricts : Core Web Vitals, taille APK < 25Mo, RAM, p95).
  - [ ] `references/testing_protocols.md` (protocoles E2E, dégradation réseau 3G simulée).
  - [ ] `scripts/qa_security_gate.sh` (script global d'audit de sécurité, CVEs et tests E2E).
  - [ ] `templates/QA_REPORT_TEMPLATE.md`
  - [ ] `templates/SECURITY_REPORT_TEMPLATE.md`
  - [ ] `templates/PERF_REPORT_TEMPLATE.md`
- [ ] Implémenter le skill exécutable `src/skills/san_devops_expert/` :
  - [ ] `SKILL.md` (administration VPS/CloudPanel/Mailcow, réversibilité, principe de sauvegarde testée).
  - [ ] `references/cloudpanel_and_vps.md` (configurations Nginx reverse proxy, Supervisor, PHP workers).
  - [ ] `references/mailcow_and_deliverability.md` (alignement SPF, DKIM 2048b, DMARC, rDNS PTR).
  - [ ] `references/backup_and_restore_protocols.md` (sauvegarde 3-2-1 et tests de restauration).
  - [ ] `scripts/infra_health_check.sh` (script de contrôle SSL, DNS, ports, disque, conteneurs).
  - [ ] `templates/INFRA_TEMPLATE.md` (`docs/INFRA.md`).
  - [ ] `templates/RUNBOOK_TEMPLATE.md` (`docs/RUNBOOKS.md`).
- [ ] Implémenter le skill exécutable `src/skills/san_store_legal_expert/` :
  - [ ] `SKILL.md` (conformité Play/App Store, anti-rejet, vérité du code, honnêteté juridique).
  - [ ] `references/store_rejection_patterns.md` (suppression de compte, compte test, justifications permissions).
  - [ ] `scripts/scan_app_permissions.sh` (extraction automatique des permissions et SDKs dans le code).
  - [ ] `templates/STORE_CHECKLIST_TEMPLATE.md` (`docs/STORE_CHECKLIST.md`).
  - [ ] `templates/PRIVACY_POLICY_TEMPLATE.md` (`docs/PRIVACY_POLICY.md`).
  - [ ] `templates/TERMS_TEMPLATE.md` (`docs/TERMS.md`).
  - [ ] `templates/DATA_MAP_TEMPLATE.md` (`docs/DATA_MAP.md`).
- [ ] Implémenter le skill exécutable `src/skills/san_growth_expert/` :
  - [ ] `SKILL.md` (SEO local Afrique/Congo, ASO stores, plan de tracking unifié, zéro faux avis).
  - [ ] `references/local_seo_congo.md` (intentions de recherche locales, données structurées Schema.org).
  - [ ] `references/aso_playbook.md` (fiches Play Store/App Store, storyboards de captures).
  - [ ] `references/tracking_taxonomy.md` (nommage `snake_case`, Firebase Analytics, Meta Pixel).
  - [ ] `scripts/verify_tracking_and_seo.sh` (validation automatique du balisage et sitemap).
  - [ ] `templates/TRACKING_PLAN_TEMPLATE.md` (`docs/TRACKING_PLAN.md`).
  - [ ] `templates/STORE_LISTING_TEMPLATE.md` (`docs/STORE_LISTING.md`).
- [ ] Tests de la Phase 6 :
  - [ ] Tester `scan_app_permissions.sh` sur un faux `AndroidManifest.xml`.
  - [ ] Tester `infra_health_check.sh` sur environnement local.

---

## PHASE 7 : MOTEUR D'INSTALLATION UNIVERSEL CLI (`npx @alexsan/agy-framework init`)

- [ ] Configurer `package.json` à la racine pour la distribution npm/npx :
  - [ ] Déclarer le binaire `bin: { "agy-framework": "src/cli/index.js" }`.
  - [ ] Définir les dépendances nécessaires (commander/clack/prompts, chalk/picocolors).
- [ ] Développer `src/cli/index.js` (Point d'entrée du CLI) :
  - [ ] Afficher la bannière ASCII officielle issue de [`logos/LOGO_ASCII.txt`](../logos/LOGO_ASCII.txt).
  - [ ] Proposer le menu interactif :
    - Mode d'installation : Local (`<projet>/.agents/`) ou Global (`~/.gemini/antigravity-cli/skills/`).
    - Sélection des skills : « Tous les skills (Recommandé) » ou sélection granulaire par cases à cocher.
  - [ ] Supporter les drapeaux CLI : `--local`, `--global`, `--all`, `--skills=init,planner,qa`.
- [ ] Développer `src/cli/installer.js` (Moteur de déploiement) :
  - [ ] Copie des modules choisis depuis `src/skills/` vers la cible (`.agents/skills/`).
  - [ ] Fusion intelligente avec un `.agents/` existant (ne pas écraser les règles métier de l'utilisateur).
  - [ ] Injection automatique de `/.agents/` dans `.gitignore` et `.git/info/exclude`.
  - [ ] Purge des résidus d'anciens agents (`CLAUDE.md`, `.cursorrules`, etc.).
  - [ ] Message de succès final avec guide de démarrage immédiat.

---

## PHASE 8 : VALIDATION GLOBALE & TESTS D'INTÉGRATION END-TO-END (E2E)

- [ ] Test d'intégration 1 : Déploiement en mode `--local` sur un projet React / Next.js vierge :
  - [ ] Vérifier la création de `.agents/skills/` et `.agents/rules/`.
  - [ ] Vérifier qu'Antigravity CLI découvre bien les skills avec `agy skills list` ou dans le prompt.
- [ ] Test d'intégration 2 : Déploiement en mode `--global` et vérification de la présence dans `~/.gemini/`.
- [ ] Test d'intégration 3 : Vérification de la purge Git (`git status` sur le projet cible ne doit afficher aucun fichier de `.agents/`).
- [ ] Clôture de la roadmap :
  - [ ] Contrôle physique de 100 % des cases cochées.
  - [ ] Mise à jour du `CHANGELOG.md` et `CHANGELOG.en.md` (Release v1.0.0).
  - [ ] Déplacement de ce fichier vers `/roadmaps/archives/MVP_BUILD_FRAMEWORK_23102026.md`.
  - [ ] Commit et push sur GitHub.
