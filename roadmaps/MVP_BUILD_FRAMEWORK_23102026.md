# ROADMAP — MVP BUILD FRAMEWORK `san_agy_framework` (23/10/2026)

> **Fichier :** `/roadmaps/MVP_BUILD_FRAMEWORK_23102026.md`  
> **Statut :** EN COURS (PHASE 2 ACHEVÉE, PASSAGE PHASE 3)  
> **Responsable :** `san_executer` & `san_planner`  
> **Convention de nommage :** `[PHASE]_[PROBLEMATIQUE]_[DATE].md` (format JJMMAAAA)

---

## CONSIGNES D'AUTO-NETTOYAGE & D'HYGIÈNE STRICTE

- [ ] **Vérification avant cochage :** Ne cocher une tâche `- [x]` QUE si le code, le fichier ou le test correspondant existe physiquement et a été vérifié.
- [ ] **Fast-Track Orchestrateur :** L'orchestrateur coche lui-même les tâches vérifiées, met à jour `CHANGELOG.md` et déplace la roadmap vers `/roadmaps/archives/` une fois validée à 100 %.
- [ ] **Délégation d'implémentation :** L'écriture des scripts et modules dans `src/` est déléguée à des sous-agents atomiques en `Model: 'flash'`.
- [ ] **Condition d'archivage :** Seule une roadmap dont 100 % des cases sont cochées et validées peut être déplacée dans `/roadmaps/archives/`.

---

## PHASE 1 : SPÉCIFICATIONS, CARTOGRAPHIE & ARCHITECTURE GLOBALE

- [x] Définir les 11 compétences directrices dans `/skills/` :
  - [x] [`san_init.md`](../skills/san_init.md)
  - [x] [`san_brainstorming.md`](../skills/san_brainstorming.md)
  - [x] [`san_planner.md`](../skills/san_planner.md)
  - [x] [`san_designer.md`](../skills/san_designer.md)
  - [x] [`san_ux_ui_expert.md`](../skills/san_ux_ui_expert.md)
  - [x] [`san_backend_expert.md`](../skills/san_backend_expert.md)
  - [x] [`san_executer.md`](../skills/san_executer.md)
  - [x] [`san_qa_security_expert.md`](../skills/san_qa_security_expert.md)
  - [x] [`san_devops_expert.md`](../skills/san_devops_expert.md)
  - [x] [`san_store_legal_expert.md`](../skills/san_store_legal_expert.md)
  - [x] [`san_growth_expert.md`](../skills/san_growth_expert.md)
- [x] Définir les 6 sous-skills transversaux dans `/sub-skills/` :
  - [x] [`san_subagent_manager.md`](../sub-skills/san_subagent_manager.md)
  - [x] [`san_searcher.md`](../sub-skills/san_searcher.md)
  - [x] [`san_doc_keeper.md`](../sub-skills/san_doc_keeper.md)
  - [x] [`san_copywriter.md`](../sub-skills/san_copywriter.md)
  - [x] [`san_design_tokens.md`](../sub-skills/san_design_tokens.md)
  - [x] [`san_exporter.md`](../sub-skills/san_exporter.md)
- [x] Structurer [`README.md`](../README.md) en index maître cartographique avec diagramme Mermaid.
- [x] Purger toute référence à des projets privés (`koteka`, `vunette`) pour garantir une stricte universalité.

---

## PHASE 2 : IDENTITÉ VISUELLE, GOUVERNANCE LOCALE & OUTILLAGE DU DÉPÔT

- [x] Initialiser Git sur la branche `main` et verrouiller `.gitignore`.
- [x] Créer la charte graphique et les logos vectoriels dans `/logos/` :
  - [x] [`logos/LOGO.md`](../logos/LOGO.md)
  - [x] [`logos/san_framework_logo.svg`](../logos/san_framework_logo.svg)
  - [x] [`logos/san_framework_icon.svg`](../logos/san_framework_icon.svg)
  - [x] [`logos/san_framework_dark.svg`](../logos/san_framework_dark.svg)
- [x] Initialiser [`CHANGELOG.md`](../CHANGELOG.md) selon la norme Keep a Changelog.
- [x] Délimiter l'espace distribuable client dans [`src/`](../src/README.md) (frontière entre nos sources et ce que le client reçoit).
- [x] Créer l'espace des roadmaps et archives (`/roadmaps/archives/`).

---

## PHASE 3 : PACKAGING EXÉCUTABLE DU PREMIER SKILL PIVOT DANS `src/` (`san_init`)

- [ ] Créer l'arborescence exécutable `src/skills/san_init/` :
  - [ ] `src/skills/san_init/SKILL.md` (manifeste exécutable reconnu nativement par Antigravity).
  - [ ] `src/skills/san_init/scripts/git_ai_hygiene.sh` (script de désindexation et verrouillage `.gitignore`).
  - [ ] `src/skills/san_init/scripts/svg_to_png.mjs` (générateur d'icônes et favicons).
  - [ ] `src/skills/san_init/templates/rules/BRAND_TEMPLATE.md`
  - [ ] `src/skills/san_init/templates/rules/PRODUCT_TEMPLATE.md`
  - [ ] `src/skills/san_init/templates/rules/PROJECT_TEMPLATE.md`
  - [ ] `src/skills/san_init/templates/rules/API_TEMPLATE.md`
  - [ ] `src/skills/san_init/templates/GEMINI_INDEX_TEMPLATE.md`
- [ ] Tests de la Phase 3 :
  - [ ] Tester `git_ai_hygiene.sh` sur un dossier Git factice pour vérifier la désindexation de `.agents/`.
  - [ ] Valider la syntaxe Markdown des templates.

---

## PHASE 4 : PACKAGING DES SKILLS DE QUALITÉ & EXPLOITATION DANS `src/`

- [ ] Implémenter le module exécutable `src/skills/san_qa_security_expert/` :
  - [ ] `SKILL.md`
  - [ ] `scripts/qa_security_gate.sh`
  - [ ] `templates/QA_REPORT_TEMPLATE.md`
  - [ ] `templates/SECURITY_REPORT_TEMPLATE.md`
  - [ ] `templates/PERF_REPORT_TEMPLATE.md`
- [ ] Implémenter le module exécutable `src/skills/san_devops_expert/` :
  - [ ] `SKILL.md`
  - [ ] `scripts/infra_health_check.sh`
  - [ ] `templates/INFRA_TEMPLATE.md`
  - [ ] `templates/RUNBOOK_TEMPLATE.md`
- [ ] Tests de la Phase 4 :
  - [ ] Vérifier l'exécution du script `qa_security_gate.sh` (sortie avec code retour d'erreur si test rouge).
  - [ ] Valider la détection des failles OWASP mockées.

---

## PHASE 5 : CLI D'INSTALLATION UNIVERSEL (`npx @alexsan/agy-framework init`)

- [ ] Créer `package.json` à la racine pour déclarer le binaire `agy-framework` / `alexsan-framework`.
- [ ] Coder `src/cli/index.js` et `src/cli/installer.js` :
  - [ ] Support du flag `--local` (Option A : installe tout dans `<projet>/.agents/skills/`).
  - [ ] Support du flag `--global` (Option B : installe les skills dans `~/.gemini/antigravity-cli/skills/` et les règles dans `<projet>/.agents/rules/`).
- [ ] Test d'intégration bout-en-bout (End-to-End) :
  - [ ] Déployer sur un dépôt test vierge (ex: `/tmp/test-codebase-react`).
  - [ ] Vérifier qu'Antigravity CLI découvre bien les skills et les règles sans erreur de parsing.

---

## JOURNAL DES DÉCISIONS ARCHITECTURALES

* **23/10/2026 :** Séparation stricte entre les spécifications cartésiennes du framework (`skills/`, `sub-skills/`) et les modules exécutables distribuables (`src/`).
* **23/10/2026 :** Unification du contrôle qualité sous `san_qa_security_expert` pour décharger les développeurs de l'auto-complaisance.
* **23/10/2026 :** Mise en place des logos vectoriels officiels et initialisation de Git avec verrouillage de branche `main`.
