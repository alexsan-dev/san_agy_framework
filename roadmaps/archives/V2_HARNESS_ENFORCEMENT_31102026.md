# ROADMAP D'ARCHITECTURE v2.0 — HARNESS DÉTERMINISTE, ÉRADICATION DU TESTING THEATER & INGÉNIERIE DU DOUTE CONTRADICTOIRE (`san_*`)

> **Fichier :** `/roadmaps/V2_HARNESS_ENFORCEMENT_31102026.md`  
> **Statut :** EN COURS (PHASE 1 ACHEVÉE ET VALIDÉE À 100 % — PAUSE AVANT PHASE 2)  
> **Date :** 31/10/2026  
> **Cible Version :** `v2.0.0` (Refonte Majeure + Migration non-destructive `update` depuis `v1.x`)  
> **Double Ambition :**  
> 1. **Obéissance Mécanique (Zéro Friction de Prompt) :** L'utilisateur exprime uniquement **QUOI** construire/planifier/designer ; le framework impose mécaniquement **COMMENT** l'orchestrer (recherche, sous-agents atomiques, contrats, gates).  
> 2. **Excellence Cognitive & Créative Maximale (Zéro Médiocrité du 1er Jet) :** Implanter l'**Ingénierie Psychologique du Doute Contradictoire** (*Pre-Mortem*, *Dialectique 2-Approches*, *Avocat du Diable* et *Boucle Visuelle Multimodale sur Pixels Réels*) pour forcer les agents à rejeter les solutions plates/banales et converger vers la meilleure architecture, le meilleur code et le meilleur design.

---

## CONSIGNES D'EXÉCUTION POUR L'ORCHESTRATEUR (OBLIGATOIRES)

* **Délégation Atomique Stricte :** L'orchestrateur délègue chaque lot de création/refonte à des sous-agents atomiques via `invoke_subagent`, puis vérifie physiquement chaque livrable et chaque test avant de cocher `- [x]`.
* **Étanchéité des Phases :** Interdiction absolue d'entamer la Phase $N+1$ tant que le script de validation de la Phase $N$ ne retourne pas `exit code 0`.
* **Validation Officielle Google Antigravity :** Le bundle final doit passer `agy plugin validate --strict --json` avec **0 erreur, 0 warning et 0 finding**.
* **Fast-Track d'Hygiène :** Seul l'orchestrateur coche `- [x]` après preuve d'exécution, met à jour `CHANGELOG.md` / `CHANGELOG.en.md`, et archive la roadmap via `archive_roadmap.sh` en Phase 7.

---

## SYNTHÈSE DES DEUX AUDITS FONDATEURS (HARNESS + LOGIQUE & QUALITÉ)

### Volet A — Pourquoi les règles d'orchestration étaient ignorées (Audit Moteur Antigravity)
1. **Silent Discard sur `.agents/rules/*.md` :** Aucun frontmatter YAML (`trigger:`) $\rightarrow$ Antigravity ignorait 100 % des 5 fichiers de règles.
2. **Absence de `AGENTS.md` racine par défaut & `rules.json` fictif :** Pas de constitution `always_on` active à la racine du projet.
3. **Zéro Sous-Agent Natif (`.agents/agents/*.md`) & Zéro Hook (`.agents/hooks.json`) :** Tout reposait sur des textes passifs de 300 à 629 lignes à la 3ème personne.

### Volet B — Pourquoi le résultat pouvait rester moyen malgré les skills (Audit Logique, Design & Scripts)
1. **Complaisance du 1er Jet (*First-Draft Sycophancy*) :** Les sous-agents exécutaient docilement la première idée venue sans comparer d'alternatives (modèles backend anémiques, composants React monolithiques de 500 lignes, Option C "épouvantail" dans le brainstorming).
2. **Audit Design Aveugle & Cliché "Dark Slate + Ambre" :** `/ux-scan` notait du code HTML texte sans jamais regarder le rendu PNG réel avec un modèle vision, et tous les templates forçaient le même thème figé `bg-slate-900` + `amber-500` + `select-none`, avec des `if (loading) return <Skeleton/>` détruisant le DOM au moindre filtre.
3. **"Testing Theater" & Scripts Fail-Open :** `qa_security_gate.sh` passait `--passWithNoTests` (succès avec 0 test !), `backend_quality_gate.sh` retournait `exit 0` avec `[0/4]` outils installés et crashait hors Laravel/Adonis, `front_quality_gate.sh` étouffait les failles via `|| true`, `build_tokens.mjs` hardcodait spacing/radii et sortait en `exit(0)` malgré un échec WCAG, et `DEPLOYMENT_WORKFLOW.yml` appelait `.agents/` (pourtant gitignoré !) en CI GitHub Actions.
4. **Biais Rigide Hors-Sujet :** `score_idea.py` appliquait un VETO automatique si le critère `3G / Mobile Money < 4/10`, rejetant à tort un SaaS B2B ou un outil CLI.

---

## PHASE 1 : CONSTITUTION PERMANENTE (`AGENTS.md`), PROFILS CONTEXTUELS & RÈGLES `.agents/rules/*.md` VALIDES

> **Objectif :** Activer à 100 % le chargement natif des règles Antigravity et inscrire dans le marbre à la fois la discipline d'orchestration et la doctrine de remise en question systématique.

- [x] **1.1. Refondre `src/skills/san_init/templates/AGENTS_INDEX_TEMPLATE.md` (déployé en `<projet>/AGENTS.md` sans frontmatter YAML $\rightarrow$ `always_on` natif Antigravity & opencode) :**
  - [x] Conserver le marqueur `<!-- san_* context (generated) -->` (compatible Smart Merge) et maintenir la taille totale $< 4\text{ KB}$ (mesuré à 3 984 octets post-génération avec les 17 compétences).
  - [x] Imposer les **6 Lois d'Airain de l'Orchestrateur (`MANDATORY ORCHESTRATOR CONSTITUTION`)** :
    1. **Zéro Solo-Coding :** Sur toute tâche de feature, architecture, design, refonte ou audit, l'agent principal **ne code pas en ligne** (hors micro-retouche triviale $\le 5$ lignes sur 1 fichier explicitement demandée).
    2. **Reconnaissance Factuelle Préalable :** Toujours lancer `san-researcher` via `invoke_subagent` avant de planifier ou coder sur une zone non cartographiée.
    3. **Sous-Agents Atomiques :** 1 responsabilité atomique = 1 sous-agent dédié (`san-coder-back`, `san-coder-front`, `san-designer-worker`, `san-ops-devops`, `san-growth-legal`). Paralléliser les tâches indépendantes (`invoke_subagent` concurrents ou `run_workflow`).
    4. **Doctrine du Doute Contradictoire (*Anti-First-Draft Mediocrity*) :** Interdiction d'accepter un premier jet plat ou anémique. Toute architecture passe par un *Pre-Mortem* (`san-architect`), tout écran par une critique visuelle sur pixels réels, et tout lot de code par un audit sceptique indépendant (`san-qa-auditor`).
    5. **Contract-First Adaptatif :** Verrouiller le contrat de données (OpenAPI 3.1 / Schémas Zod / Protobuf + tests d'API Bruno ou natifs) avant d'intégrer l'interface consommatrice.
    6. **Preuve par le Code Fail-Closed :** Aucune tâche `- [x]` n'est cochée sans exécution réelle d'un test/gate retournant `exit 0`.
  - [x] Inclure la **Table de Routage Automatique d'Intention** (mappant automatiquement toute demande naturelle vers `san_brainstorming`, `san_planner`, `san_designer`, `san_executer`, `san_qa_security_expert`, `san_devops_expert`, `san_store_legal_expert`, `san_growth_expert`).
- [x] **1.2. Synchroniser `src/skills/san_init/templates/GEMINI_INDEX_TEMPLATE.md` :**
  - [x] L'aligner sur la même Constitution v2.0 pour servir de `rules/AGENTS.md` dans le bundle Plugin global.
- [x] **1.3. Ajouter les Frontmatters YAML Officiels & Profils Contextuels aux 5 templates dans `src/skills/san_init/templates/rules/` :**
  - [x] `PROJECT_TEMPLATE.md` : Ajouter `trigger: always_on`, condenser $< 8\text{ KB}$, documenter le **Profil Contextuel du Projet** (`PROJECT_PROFILE: global_saas | emerging_market_3g | mobile_consumer | cli_devtools | api_platform`) et le routage cognitif (`pro` pour architecture/modélisation critique/audit sceptique, `flash` pour implémentation atomique cadrée et exploration).
  - [x] `PRODUCT_TEMPLATE.md` : Ajouter `trigger: model_decision` + `description: "Load when scoping product features, user flows, personas, business invariants, or market constraints."` Rendre la section contraintes terrain **modulaire selon `PROJECT_PROFILE`** (activer 3G/Mobile Money/Offline Outbox si `emerging_market_3g` ou `mobile_consumer` pertinent, sinon activer les invariants SaaS/CLI/Enterprise adaptés).
  - [x] `BRAND_TEMPLATE.md` : Ajouter `trigger: glob` + `globs: "*.tsx, *.jsx, *.vue, *.svelte, *.html, *.css, *.scss, *tailwind*"` + `description: "UI design tokens, artistic direction archetype, typography tension, non-destructive 5 UI states, A11y, and 60fps motion."` Ajouter le choix explicite d'un **Archétype Esthétique** (pour briser le moule unique Dark Slate/Ambre).
  - [x] `API_TEMPLATE.md` : Ajouter `trigger: glob` + `globs: "*controller*, *Controller*, *route*, *api*, *.bru, *openapi*, *schema*, *dto*, *migration*"` + `description: "API contract standards (OpenAPI/Zod/Bruno), JSON envelope, DB transactions, and idempotency."` Neutraliser les exemples codés en dur pour rester universel tout en gardant un exemple concret paramétrable.
  - [x] `LOGO_TEMPLATE.md` : Ajouter `trigger: glob` + `globs: "*logo*, *icon*, *favicon*, *manifest*, *.svg"` + `description: "Master vector logo rules and multi-resolution icon asset guidelines."`
- [x] **1.4. Supprimer `src/skills/san_init/templates/rules_json_template.json` :**
  - [x] Supprimer ce fichier obsolète non reconnu par Antigravity et nettoyer ses références.
- [x] **1.5. Test automatisé Phase 1 (`tests/v2/test_phase1_rules.sh`) :**
  - [x] Vérifier l'absence de frontmatter sur `AGENTS_INDEX_TEMPLATE.md`, la présence et la syntaxe exacte des frontmatters YAML sur les 5 templates de règles, la taille $< 18\text{ KB}$ par fichier, et la suppression de `rules_json_template.json` (67/67 assertions au vert, exit code 0).

---

## PHASE 2 : LES 8 SOUS-AGENTS NATIFS & INGÉNIERIE PSYCHOLOGIQUE DU DOUTE (`src/agents/*.md`)

> **Objectif :** Créer dans `src/agents/` de vrais sous-agents natifs Antigravity câblés avec des **mécanismes psychologiques anti-complaisance** : chaque bâtisseur doit justifier son choix face à une alternative rejetée (*Dialectique Avant Frappe*), et chaque auditeur opère sous **Présomption d'Insuffisance** (*Avocat du Diable*).

- [x] **2.1. Créer `src/agents/san-researcher.md` (Éclaireur Factuel & Comparateur d'Approches) :**
  - [x] YAML : `name: san-researcher`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "sandbox"`, `skills: ["skills/san_searcher"]`.
  - [x] Outils lecture/recherche uniquement (zéro `write_file`/`edit_file`).
  - [x] Psychologie & Livrable : Ne jamais recommander une piste unique aveugle. Extraire les versions réelles du repo, inspecter les patterns existants (y compris discussions/RFCs officielles pertinentes au-delà d'une whitelist fermée), et livrer un brief $< 450$ mots contenant une **matrice comparative d'au moins 2 approches techniques** avec leurs compromis réels (complexité, performance, maintenabilité).
- [x] **2.2. Créer `src/agents/san-architect.md` (Architecte Principal & Avocat du Diable Pre-Mortem) :**
  - [x] YAML : `name: san-architect`, `mainAgent: false`, `subagent: true`, `model: "pro"`, `commandExecutionPolicy: "off"`.
  - [x] Lecture seule stricte.
  - [x] **Mécanisme Psychologique "Pre-Mortem & Red-Team Architectural" :**
    1. *Exercice Pre-Mortem obligatoire :* « Nous sommes 6 mois après la mise en production et cette feature a causé un incident majeur ou un rejet utilisateur massif. Quelles sont les **3 causes structurelles exactes** qui l'ont fait échouer ? »
    2. *Chasse à l'Anémie & au Couplage :* Rejeter tout design à base de *God Controllers* ou modèles anémiques ; définir les frontières de domaine (Entities, Value Objects, Services/Actions atomiques, transactions BDD, indexation).
    3. *ADR (Architecture Decision Record) :* Confronter honnêtement **2 architectures viables** (sans jamais inventer une Option C "épouvantail" caricaturale) avant de trancher.
- [x] **2.3. Créer `src/agents/san-designer-worker.md` (Directeur Artistique Code-Only & Artisans UI) :**
  - [x] YAML : `name: san-designer-worker`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_design_tokens", "skills/san_copywriter", "skills/san_exporter"]`.
  - [x] **Mécanisme Anti-Platitude Esthétique :**
    1. Avant de coder la maquette `/design/*.html`, déclarer l'archétype visuel issu de `BRAND.md`, la **hiérarchie focale en 3 plans** (1 élément Héro dominant, 1 plan de données structuré, 1 plan secondaire silencieux), la **tension typographique** (contraste fort Display vs Micro-labels uppercase + `tabular-nums` sur tous les chiffres), et le **rythme Gestalt** (espacement interne $<$ espacement inter-groupe $<$ respiration de section).
    2. Interdiction du cliché automatique `bg-slate-900` + `amber-500` sauf si `BRAND.md` l'exige explicitement ; interdiction de `select-none` sur `<body>` ; obligation d'anneaux `focus-visible` accessibles.
    3. Générer systématiquement le rendu PNG via Playwright (`export_png.mjs`) en fin de tâche pour permettre l'inspection visuelle réelle.
- [x] **2.4. Créer `src/agents/san-coder-back.md` (Artisan Atomique Backend, Domaine & Contrats) :**
  - [x] YAML : `name: san-coder-back`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_backend_expert"]`.
  - [x] **Protocole "Dialectique Avant Frappe" :**
    1. Identifier et écarter explicitement l'approche naïve (ex: logique métier dans le contrôleur, écriture multi-tables sans transaction, requête N+1 en boucle, test qui mocke la BDD).
    2. Coder **1 seule unité atomique** propre, typée strictement, encapsulée en transaction si écritures multiples, avec classes $< 200$ lignes et méthodes $< 40$ lignes.
    3. Écrire de **vrais tests d'intégration/domaine** (interdiction du *Mocking Theater* qui mocke le service testé ; inclure au moins 1 cas nominal + 2 cas aux limites/erreurs d'autorisation ou concurrence) et exécuter la commande de test avant de répondre.
- [x] **2.5. Créer `src/agents/san-coder-front.md` (Artisan Atomique Frontend Web & Mobile) :**
  - [x] YAML : `name: san-coder-front`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_ux_ui_expert", "skills/san_copywriter", "skills/san_design_tokens"]`.
  - [x] **Protocole d'Excellence UI & Accessibilité :**
    1. Découpage modulaire strict ($< 220$ lignes par fichier composant ; extraire sous-composants et hooks métiers).
    2. **Chorégraphie Non-Destructive des 5 États (*Stale-While-Revalidate*) :** Interdiction de détruire les données déjà affichées avec un `if (loading) return <Skeleton/>` brutal lors d'un refetch/filtre ; conserver les données visibles avec indicateur de rafraîchissement non bloquant, et afficher une bannière/toast d'erreur actionnable même quand `data.length > 0`.
    3. **Accessibilité Clavier & Sémantique Non-Négociable :** Zéro `<div onClick>` sans sémantique `<button>` native, focus clavier `focus-visible:ring-2`, labels explicites et `tabular-nums`. Exécuter `tsc --noEmit` + tests avant de conclure.
- [x] **2.6. Créer `src/agents/san-qa-auditor.md` (Inquisiteur Sceptique QA, Sécurité, Perf & Critique Visuel Multimodal) :**
  - [x] YAML : `name: san-qa-auditor`, `mainAgent: false`, `subagent: true`, `model: "pro"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_qa_security_expert"]`.
  - [x] **Indépendance Mécanique :** Aucun droit d'éditer le code applicatif (pas de `edit_file` ; il inspecte, exécute les tests/gates, lit les captures PNG via `read_file` et juge).
  - [x] **Psychologie d'Inquisiteur ("Présomption de Défaut — Soulève le Doute") :**
    * Consigne système : *« Toute validation complaisante est une faute grave. Pars du principe que le premier jet contient au moins un vice caché d'architecture, un test superficiel, une faille d'état limite ou une médiocrité visuelle. »*
    * **4 Angles d'Attaque Obligatoires :**
      1. *Audit de Substance des Tests :* Traquer et rejeter les tests tautologiques (*Mocking Theater*, assertions vides `toBeTruthy()`), l'absence de cas d'erreur/concurrence, ou l'absence de transactions BDD.
      2. *Audit de Design & Critique Multimodale sur Pixels Réels :* Lorsqu'une interface ou maquette est livrée (PNG disponible), lire l'image avec `read_file` et critiquer la hiérarchie visuelle, l'équilibre des masses, l'alignement, la lisibilité et l'âme graphique.
      3. *Audit d'Architecture & Clean Code :* Signaler tout fichier fourre-tout ($> 250$ lignes), couplage fort, valeur magique ou `<div onClick>` inaccessible.
      4. *Audit Sécurité OWASP & Performance :* BOLA/IDOR, secrets, injections, N+1, fuites d'effets.
    * Retourner : (a) **Questions de doute & défis architecturaux**, (b) **Liste numérotée des défauts (`fichier:ligne` + sévérité `BLOQUANT` / `ÉLEVATION_QUALITÉ`)**, (c) Verdict binaire `LIVRABLE` ou `RETOUR_ATELIER`.
- [x] **2.7. Créer `src/agents/san-ops-devops.md` :**
  - [x] YAML : `name: san-ops-devops`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_devops_expert"]`. Multi-stacks (Docker, Node/Next standalone, Go, Python, PHP/CloudPanel, Mailcow optionnel), réversibilité et backups testés.
- [x] **2.8. Créer `src/agents/san-growth-legal.md` :**
  - [x] YAML : `name: san-growth-legal`, `mainAgent: false`, `subagent: true`, `model: "flash"`, `commandExecutionPolicy: "auto"`, `skills: ["skills/san_store_legal_expert", "skills/san_growth_expert", "skills/san_copywriter"]`. Conformité stores dérivée du code réel, légal sans promesse mensongère, SEO/ASO/Tracking.
- [x] **2.9. Test automatisé Phase 2 (`tests/v2/test_phase2_agents.sh`) :**
  - [x] Valider les 8 fichiers `src/agents/*.md` via `agy plugin validate --strict --json` (`agents == 8`, 0 erreur, 138/138 assertions au vert) et vérifier la présence des clauses *Dialectique Avant Frappe* / *Pre-Mortem* / *Présomption de Défaut* / *send_message*.

---

## PHASE 3 : GARDE-FOUS MÉCANIQUES DU CYCLE DE VIE (`src/hooks/hooks.json` & SCRIPTS)

> **Objectif :** Câbler les hooks natifs d'Antigravity pour injecter automatiquement la posture d'orchestration ET le réflexe de remise en question à chaque tour utile, sans polluer l'historique.

- [x] **3.1. Créer `src/hooks/hooks.json` :**
  - [x] Configurer `SessionStart` (`node ./hooks/scripts/session_start.mjs`), `PreInvocation` (`node ./hooks/scripts/pre_invocation.mjs`) et `PreToolUse` (`matcher: "write_file|edit_file"`, `node ./hooks/scripts/pre_tool_guard.mjs`) avec `timeout: 5`.
- [x] **3.2. Développer `src/hooks/scripts/session_start.mjs` :**
  - [x] Détecter la roadmap active dans `roadmaps/*.md`, l'état d'initialisation de `.agents/rules/PROJECT.md` et le `PROJECT_PROFILE`.
  - [x] Injecter un `systemMessage` concis activant les 8 sous-agents `san-*` et la règle d'or : *Intent-Only User Prompting + Mandatory Doubt & Challenge Gate*.
- [x] **3.3. Développer `src/hooks/scripts/pre_invocation.mjs` :**
  - [x] Sur toute requête de conception, planification, design, codage ou audit dans `lastUserInput`, injecter un `ephemeralMessage` ($< 110$ tokens, auto-supprimé après le tour) :
    *« [SAN.AGY ENFORCER] (1) Never solo-code features inline: delegate exploration to `san-researcher`, architecture pre-mortem to `san-architect`, atomic implementation to `san-coder-*` / `san-designer-worker`. (2) Reject mediocre first drafts: challenge assumptions with `san-qa-auditor` (and visual PNG inspection for UI) + fail-closed gate scripts before checking `[x]`. »*
- [x] **3.4. Développer `src/hooks/scripts/pre_tool_guard.mjs` :**
  - [x] Bloquer (`"decision": "deny"`) l'écriture dans `/roadmaps/archives/` si une case tâche `- [ ]` subsiste.
  - [x] Bloquer (`"decision": "deny"`) l'injection de `Lorem ipsum` / `dolor sit amet` dans les dossiers applicatifs et `/design/`.
  - [x] Retourner `{"decision": "ask"}` dans tous les cas conformes afin de respecter scrupuleusement les permissions utilisateur d'Antigravity.
- [x] **3.5. Test automatisé Phase 3 (`tests/v2/test_phase3_hooks.sh`) :**
  - [x] Tester les 3 scripts en conditions réelles (flux `stdin` JSON camelCase, validation JSON `stdout`, latence $< 150\text{ms}$, test `deny` et `ask`).

---

## PHASE 4 : DURCISSEMENT CHIRURGICAL DES SCRIPTS & TEMPLATES (FIN DU "TESTING THEATER")

> **Objectif :** Corriger les **12 vulnérabilités techniques et logiques** identifiées par l'audit profond dans `src/skills/*/scripts/` et `templates/` pour que les Quality Gates soient réellement infalsifiables, universels et moteurs d'excellence.

- [x] **4.1. Éradiquer le mode "Fail-Open" dans les 3 Quality Gates principaux :**
  - [x] `src/skills/san_qa_security_expert/scripts/qa_security_gate.sh` :
    * **Supprimer `-- --passWithNoTests`** ! Si aucun test automatisé n'existe ou n'est exécuté (`TESTS_FOUND == 0`), incrémenter `ERRORS` et retourner `exit 1`.
    * Étendre la détection de secrets aux URLs de connexion BDD avec mot de passe (`(postgres|mysql|mongodb|redis)://[^:]+:[^@]+@`), secrets webhooks (`whsec_`), clés Stripe/API génériques et tokens codés en dur.
  - [x] `src/skills/san_backend_expert/scripts/backend_quality_gate.sh` :
    * Supprimer le faux succès `[0/4 ÉTAPES AU VERT] -> exit 0` : exiger `TOTAL_CHECKS > 0` et `PASSED_CHECKS == TOTAL_CHECKS` (mode **Fail-Closed**).
    * Étendre la détection et l'exécution de stack au-delà de Laravel/AdonisJS : supporter **Node/TypeScript (NestJS, Express, Fastify via `package.json`)**, **Python (`pyproject.toml` $\rightarrow$ `ruff`/`mypy` + `pytest`)** et **Go (`go.mod` $\rightarrow$ `go vet` + `go test ./...`)**.
    * Ajouter un contrôle d'hygiène architecturale détectant les *God Files* ($> 300$ lignes dans Controllers/Services) et l'oubli de `declare(strict_types=1);` sur PHP.
  - [x] `src/skills/san_ux_ui_expert/scripts/front_quality_gate.sh` :
    * Retirer le `|| true` qui masquait les vulnérabilités `high/critical` de l'audit de dépendances (ou le rendre bloquant sur `critical`).
    * Remplacer le `grep addEventListener` naïf (source de faux positifs et faux négatifs) par une analyse ciblée des `useEffect` sans fonction de cleanup et une alerte sur les composants monolithiques ($> 300$ lignes) ou les `<div onClick` inaccessibles sans `role`/`tabIndex`.
  - [x] `src/skills/san_executer/scripts/e2e_verification_gate.sh` :
    * Ne plus déclarer `BRUNO_STATUS="PASS"` sur un simple `grep` statique si `bru` n'a rien exécuté (marquer `STATIC_ONLY_UNVERIFIED` et exiger qu'au moins une suite de tests d'intégration API réelle — Bruno, Supertest, Pest HTTP, Pytest ou Go httptest — ait tourné avec `exit 0`).
- [x] **4.2. Corriger les scripts Design Tokens, Export, Copy, Search & Archivage :**
  - [x] `src/skills/san_design_tokens/scripts/build_tokens.mjs` :
    * Parser réellement les sections `spacing`, `radii` et `typography` de `BRAND.md` (avec fallback propre sur les valeurs par défaut si absentes) au lieu de les ignorer, isoler le parsing hexadécimal aux seules colonnes Mode Sombre / Mode Clair, tester aussi le contraste des boutons primaires, et retourner **`process.exit(1)`** si un contraste critique échoue ($< 3:1$, ou $< 4.5:1$ en mode `--strict`).
  - [x] `src/skills/san_design_tokens/scripts/audit_magic_values.sh` :
    * Autoriser les dimensions structurelles légitimes d'accessibilité (`min-h-[44px]`, `min-w-[44px]`) et les canvas de mockup dans `/design/`, tout en détectant les classes de couleurs Tailwind génériques interdites hors tokens (`bg-purple-*`, `bg-indigo-*`, `from-purple-*`, `via-indigo-*`) et les `z-[999*]`.
  - [x] `src/skills/san_designer/scripts/export_png.mjs` & `src/skills/san_exporter/scripts/export_png.mjs` :
    * Unifier le parser `CANVAS_SPEC` (accepter `width=1080` avec ou sans `px`, ainsi que `target=playstore|appstore|web`) et servir le dossier local via un micro-serveur HTTP éphémère Node `http.createServer` sur `127.0.0.1:0` (port libre aléatoire) au lieu de `file://` pour éviter tout blocage CORS des polices et CSS locaux !
  - [x] `src/skills/san_copywriter/scripts/check_lorem.sh` :
    * Retirer les mots courts sources de faux positifs en français (`tata`, `toto`, `titi`, et l'attribut HTML `placeholder="..."`), tout en gardant la détection stricte de `lorem ipsum`, `dolor sit amet`, `consectetur adipiscing`, `john doe`, `jane doe`, `foo bar baz`, `todo: replace text`.
  - [x] `src/skills/san_searcher/scripts/detect_stack_versions.sh` & `doc_scraper.sh` :
    * Implémenter réellement la sortie JSON valide de `detect_stack_versions.sh --json` !
    * Corriger la duplication des 4 arguments Node dans `doc_scraper.sh:203` et remplacer le blocage rigide hors-whitelist en mode non-TTY par un avertissement tracé permettant d'extraire aussi les docs GitHub/MDN/communautaires.
- [x] **4.3. Corriger les scripts Brainstorming, Hygiène Git & DevOps :**
  - [x] `src/skills/san_brainstorming/scripts/score_idea.py` :
    * Ajouter `--profile {emerging_market,global_saas,mobile_consumer,cli_devtools,api_platform}` (défaut `global_saas`). En profil `emerging_market`, conserver le pilier *Résilience Terrain 3G/MoMo* ; dans les autres profils, adapter ce pilier en *Adéquation Workflow, Friction d'Adoption & Résilience Opérationnelle* afin de ne jamais disqualifier absurde un SaaS ou une CLI.
  - [x] `src/skills/san_init/scripts/git_ai_hygiene.sh` :
    * **Fin de la destruction aveugle :** Au lieu de `rm -rf` définitif sur `CLAUDE.md`, `.cursorrules`, `.cursor`, etc., déplacer proprement tout fichier tiers détecté dans `.agents/backups/legacy-ai-configs/<timestamp>/` (100 % récupérable si un coéquipier en avait besoin !) avant désindexation Git optionnelle.
  - [x] `src/skills/san_devops_expert/templates/DEPLOYMENT_WORKFLOW.yml`, `infra_health_check.sh` & `verify_tracking_and_seo.sh` :
    * Dans `DEPLOYMENT_WORKFLOW.yml` : ne plus jamais référencer `.agents/skills/...` (absent en CI car gitignoré !), mais exécuter les suites natives du projet (`npm run lint`, `npm test`, `composer test`, `go test`) ou `npx -y github:alexsan-dev/san_agy_framework`. Fournir des jobs adaptables Node / PHP / Docker.
    * Dans `infra_health_check.sh` et `verify_tracking_and_seo.sh` : retirer `alexsan.pro` codé en dur (exiger un domaine/URL ou cibler `http://localhost:3000` / dossier statique `dist/`|`out/`|`public/` en local) et rendre le check Mailcow optionnel via `--with-mail`.
- [x] **4.4. Élever les Templates UI de Référence (`FIVE_STATES_COMPONENT.tsx` & `mockup_standalone.html`) :**
  - [x] Refondre `src/skills/san_ux_ui_expert/templates/FIVE_STATES_COMPONENT.tsx` : implémenter le vrai pattern **Stale-While-Revalidate non-destructif**, éléments `<button>` accessibles clavier (`focus-visible:ring-2`), `aria-live="polite"`, `tabular-nums`, et découpage propre en sous-composants clairs.
  - [x] Refondre `src/skills/san_designer/templates/mockup_standalone.html` : retirer `select-none` sur `<body>`, consommer des CSS variables `--color-*` issues de `BRAND.md` (fini le hardcoding universel `slate-900`/`amber-500`), et démontrer une vraie tension typographique et un rythme spatial Gestalt.
- [x] **4.5. Test automatisé Phase 4 (`tests/v2/test_phase4_hardened_scripts.sh`) :**
  - [x] Vérifier : (a) `qa_security_gate.sh` échoue (`exit 1`) sur un repo sans test, (b) `backend_quality_gate.sh` échoue (`exit 1`) si 0 check exécuté et supporte Node/Python/Go, (c) `detect_stack_versions.sh --json` émet un JSON valide, (d) `score_idea.py --profile cli_devtools` fonctionne sans faux VETO 3G, (e) `git_ai_hygiene.sh` sauvegarde dans `.agents/backups/` au lieu de détruire, (f) `build_tokens.mjs --strict` échoue sur mauvais contraste WCAG.

---

## PHASE 5 : REFONTE DES 17 `SKILL.md` EN "IMPERATIVE RUNBOOKS" ($\le 130$ LIGNES) AVEC BOUCLE D'EXCELLENCE

> **Objectif :** Réécrire les 17 `SKILL.md` en protocoles impératifs courts ($\le 130$ lignes), déclenchés automatiquement par l'intention utilisateur, et intégrant systématiquement la **Boucle Recherche $\rightarrow$ Création $\rightarrow$ Doute Contradictoire $\rightarrow$ Raffinement**.

- [x] **5.1. Refondre le Pôle Stratégie & Planification (`san_init`, `san_brainstorming`, `san_planner`) :**
  - [x] `san_init/SKILL.md` : Rétro-ingénierie via `san-researcher` (`detect_stack_versions.sh --json`), détermination du `PROJECT_PROFILE` et de l'archétype esthétique `BRAND.md` via `ask_question`, génération complète de `<racine>/AGENTS.md` et `.agents/rules/*.md`.
  - [x] `san_brainstorming/SKILL.md` : Parallélisation `san-researcher` + `san-architect` (*Pre-Mortem*), confrontation de **3 vraies pistes viables** aux compromis honnêtes (interdiction de l'Option C épouvantail !), scoring profilé `score_idea.py --profile ...`.
  - [x] `san_planner/SKILL.md` :
    1. Spawner `san-researcher` (état réel du code, BDD, tests).
    2. Spawner `san-architect` (`model: "pro"`) pour produire un **mini-ADR (2 architectures comparées + Pre-Mortem des 3 risques d'échec)** intégré en Section 0 de la roadmap !
    3. Adapter les phases au `PROJECT_PROFILE` (tranches verticales *Tracer Bullet* autorisées, résilience 3G/MoMo si profil pertinent, contrat OpenAPI/Zod/Bruno adapté).
- [x] **5.2. Refondre le Pôle Design & Exécution (`san_designer`, `san_executer`, `san_backend_expert`, `san_ux_ui_expert`) :**
  - [x] `san_designer/SKILL.md` (**Boucle Visuelle Multimodale Obligatoire**) :
    1. Spawner `san-designer-worker` pour créer la maquette HTML basée sur l'archétype de `BRAND.md`.
    2. Exporter immédiatement en PNG via `export_png.mjs` (serveur HTTP local éphémère).
    3. **Étape de Doute Visuel Obligatoire :** Spawner `san-qa-auditor` (`model: "pro"`) qui **lit le fichier `.png` avec `read_file`**, identifie au moins 3 axes d'élévation visuelle (équilibre des masses, contraste typographique, alignement, anti-platitude), puis relancer 1 passe de raffinement sur `san-designer-worker` avant livraison !
  - [x] `san_executer/SKILL.md` (**Boucle Dialectique & Inquisiteur QA**) :
    1. Lire la roadmap active (ou déclencher `san_planner` si feature complexe sans plan).
    2. Déléguer chaque tâche atomique à `san-coder-back` ou `san-coder-front` (avec obligation de *Dialectique 2 Approches* dans leur prompt). Pour les modèles de domaine complexes ou migrations critiques, autoriser l'orchestrateur à invoquer `Model: 'pro'` / `'inherit'`.
    3. Passer l'Étage 1 Fail-Closed (`backend_quality_gate.sh` / `front_quality_gate.sh` / `e2e_verification_gate.sh`).
    4. Passer l'Étage 2 Sceptique : spawner `san-qa-auditor` (`model: "pro"`). Si `RETOUR_ATELIER` ou si des améliorations structurelles majeures sont soulevées $\rightarrow$ itérer avec le codeur atomique jusqu'au verdict `LIVRABLE`.
  - [x] Condenser `san_backend_expert/SKILL.md` et `san_ux_ui_expert/SKILL.md` ($\le 120$ lignes chacun, tout le détail déplacé proprement dans leurs dossiers `references/`).
- [x] **5.3. Refondre le Pôle Qualité, Ops, Légal, Growth & les 6 Toolkits Transversaux :**
  - [x] Réécrire en Runbooks impératifs ($\le 120$ lignes) : `san_qa_security_expert`, `san_devops_expert`, `san_store_legal_expert`, `san_growth_expert`, ainsi que `san_subagent_manager` (mettre à jour `SUBAGENT_PROMPT_TEMPLATE.md` et `AUDITOR_PROMPT.md` avec la clause *2-Approach Tradeoff* et *Presumption of Flaws*), `san_searcher` (mettre à jour `RESEARCH_NOTE_TEMPLATE.md` avec tableau multi-options), `san_copywriter`, `san_design_tokens`, `san_exporter`, `san_doc_keeper`.
- [x] **5.4. Synchroniser la documentation d'atelier (`skills/*.md` & `sub-skills/*.md`) :**
  - [x] Mettre à jour ou aligner les en-têtes d'architecture dans `skills/` et `sub-skills/` pour refléter la v2.0.
- [x] **5.5. Test automatisé Phase 5 (`tests/v2/test_phase5_skills.sh`) :**
  - [x] Vérifier que les **17 `src/skills/*/SKILL.md` font chacun $\le 130$ lignes**, ont des descriptions orientées déclenchement d'intention, des liens relatifs 100 % valides, et zéro mention privée interdite (`koteka`, `vunette`).

---

## PHASE 6 : PACKAGING PLUGIN NATIF (`plugin.json`) & MISE À NIVEAU DU CLI (`init`, `update`, `doctor`)

> **Objectif :** Permettre l'installation et la mise à jour transparente des 4 couches v2.0 en une seule commande CLI (`init`, `update`, `doctor`), compatible Antigravity CLI, Antigravity 2.0/IDE et `opencode`.

- [x] **6.1. Créer `src/plugin/plugin.json` & `src/plugin/assets/logo.svg` :**
  - [x] Manifeste `plugin.json` v2.0.0 (`name: "san-framework"`, `displayName`, `description`, `logo: "assets/logo.svg"`, `suggestedPrompts`) + copie de `logos/san_framework_icon.svg` vers `src/plugin/assets/logo.svg`.
- [x] **6.2. Mettre à niveau `src/cli/installer.js` & `src/cli/index.js` :**
  - [x] **`init --local` :** Déploie `.agents/skills/`, `.agents/agents/` (8 sous-agents), `.agents/rules/` (5 règles avec Smart Merge injectant le frontmatter YAML manquant sans écraser le texte existant), `.agents/hooks.json` + `.agents/hooks/scripts/*.mjs` (`chmod +x`), et `<projet>/AGENTS.md` à la racine par défaut. Isoler `/.agents/` et `/AGENTS.md` dans `.gitignore` et `.git/info/exclude` **sans jamais supprimer `<projet>/AGENTS.md`** lors de l'hygiène, et sauvegarder les configs tierces dans `.agents/backups/` au lieu de les détruire. Supprimer l'ancien `.agents/rules.json`.
  - [x] **`init --global` :** Assemble le Plugin complet validé dans `~/.gemini/antigravity-cli/plugins/san-framework/` (et `~/.gemini/config/plugins/san-framework/` si présent).
  - [x] **`update` :** Migre en 1 seconde tout projet v1.0 vers v2.0 (ajoute les frontmatters YAML aux règles existantes en conservant les textes métier du dev, installe les 8 sous-agents et les 3 hooks, met à jour les 17 skills, régénère `AGENTS.md`, nettoie `rules.json`, et met à jour `opencode.json` si présent ou si `--opencode`).
  - [x] **`doctor` (Nouvelle commande CLI) :** Contrôle les 6 piliers de santé v2.0 sur n'importe quel repo cible (`AGENTS.md` racine, frontmatters YAML des règles, 8 sous-agents `.agents/agents/`, `hooks.json` + scripts exécutables, 17 skills compacts, étanchéité Git) et affiche un diagnostic clair avec code retour `0` ou `1`.
  - [x] Mettre à jour `package.json` en `"version": "2.0.0"`.

---

## PHASE 7 : VALIDATION OFFICIELLE `agy plugin validate --strict`, E2E & CLÔTURE v2.0.0

> **Objectif :** Prouver de bout en bout par des tests automatisés infalsifiables que l'architecture v2.0 fonctionne à 100 % et clôturer proprement la release.

- [x] **7.1. Aligner les suites de tests existantes (`tests/phase3` à `tests/phase9`) sur les invariants v2.0 :**
  - [x] Adapter les assertions modifiées par la v2.0 (ex: sauvegarde non-destructive dans `.agents/backups/` au lieu de suppression brute dans `test_git_ai_hygiene.sh`, suppression de `rules.json`, `AGENTS.md` généré par défaut, bundle plugin global).
- [x] **7.2. Créer et exécuter `tests/v2/test_e2e_v2_harness.sh` (intégré à `npm test`) :**
  - [x] **Assertion 1 :** `agy plugin validate <global_plugin_dir>/san-framework --strict --json` retourne `exit 0`, `agents: 8`, `hooks: 1`, `rules >= 1`, `skills: 17`, et **`findings: []` (0 warning/note)**.
  - [x] **Assertion 2 :** Déploiement `--local --all` sur projet Next.js vierge + `node src/cli/index.js doctor` == `exit 0` + `git status --porcelain` 100 % vide.
  - [x] **Assertion 3 :** Migration `v1.0 -> v2.0` via `update` sur un repo ayant un `BRAND.md` personnalisé sans frontmatter $\rightarrow$ frontmatter `trigger: glob` injecté ET texte client 100 % intact + `doctor` vert.
  - [x] **Assertion 4 :** Exécution bout-en-bout des 3 hooks et des Quality Gates Fail-Closed.
  - [x] Exécuter `npm test` global (toutes phases + v2) $\rightarrow$ **100 % VERT (`exit 0`)**.
- [x] **7.3. Mettre à jour `README.md`, `README.en.md`, `CHANGELOG.md` & `CHANGELOG.en.md` :**
  - [x] Documenter l'Architecture v2.0 à 4 couches, l'Ingénierie du Doute Contradictoire (*Pre-Mortem*, *Dialectique 2 Approches*, *Visual Vision Loop*, *Inquisiteur QA*), les Profils Contextuels de projet, et les commandes `init`, `update`, `doctor`.
- [x] **7.4. Archivage Déterministe & Release Git `v2.0.0` :**
  - [x] Vérifier 100 % des cases `- [x]`, archiver dans `roadmaps/archives/V2_HARNESS_ENFORCEMENT_31102026.md` via `archive_roadmap.sh`, commiter et pousser sur `origin main`.
