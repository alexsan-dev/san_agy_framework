# PLAN D'EXÉCUTION : `san-agy` v2.2.0 — Dual-Harness (`Antigravity` + `OpenCode V2`), Dé-Lobotomisation Cognitive & `san_transcriber`

> **Statut :** EN EXÉCUTION (`SWARM` PARALLÈLE)  
> **Version Cible :** `2.2.0`  
> **Origine :** Audit externe `HY4` (5 réserves) + Autopsie forensique du projet `africa_sport_pronostics` (`938c65ce`) + Besoin `san_transcriber` & CLI `san-framework models`.

---

## Section 0 : Autopsie Forensique (`africa_sport_pronostics`), Mini-ADR & Contrats Gelés

### 0.1 Autopsie Factuelle : Pourquoi `Argon 4` a agi mécaniquement sur `africa_sport_pronostics` (`938c65ce`)
L'inspection directe de `transcript.jsonl` (`brain/938c65ce-e977-4510-b27c-fa38ba2297d8`, steps `32` à `272`) a révélé **3 bugs systémiques du framework v2.1.0** qui ont court-circuité l'intelligence native d'`Argon 4` :

1. **Délégation prématurée du cadrage à un worker aveugle (`steps 159 → 171 → 211`) :**
   - `AGENTS.md` ordonnait : *« Zéro Solo-Coding : Délègue en parallèle mécaniquement sans jamais demander à l'utilisateur »* et `san_planner/SKILL.md` démarrait directement par *« Étape 1 : Spawner `san-researcher` via `swarm` → Étape 2 : Spawner `san-architect` via `swarm` »* sans aucune étape d'alignement utilisateur (`ask_question`).
   - Conséquence : Dès que l'utilisateur a demandé les 4 roadmaps du Chantier 1 (`step 159`), `Argon 4` a immédiatement délégué la rédaction des 4 roadmaps au worker `architect-roadmaps` (`step 171`). Or un worker `swarm` d'arrière-plan **ne peut pas utiliser `ask_question` pour parler à l'utilisateur** ! Il a donc inventé les choix UI (maintien d'Ant Design/DaisyUI) sans poser une seule question.
2. **Inspection CSS au lieu de vraies captures Playwright sur `https://mastra.ai` (`steps 219 → 245`) :**
   - Ni `san_planner` ni `san_designer` n'imposaient de capturer les pixels réels d'une URL de référence avant de rédiger `BRAND.md` ou une roadmap UI.
   - De plus, `export_png.mjs` ne supportait que `--input=<fichier.html>` (pas `--url=<https://...>`) et échouait si `playwright` n'était pas installé dans le `node_modules` local du projet cible (`step 240`). `Argon 4` s'est donc rabattu sur un `curl` des variables CSS (`--ds-*`) jusqu'à ce que l'utilisateur lui demande explicitement : *« tu n'as pas pris de vrais photos pour t'inspiré ? »* (`step 239`).
3. **Boucle de faux positifs dans `stop_guard.mjs` (`steps 53, 147, 236, 270`) :**
   - `stop_guard.mjs` exécutait `git status --porcelain -uall` sur tout le dépôt. Comme le dépôt avait déjà des fichiers modifiés/non suivis (et que `design/` ou `logos/` n'étaient pas exemptés), `stop_guard.mjs` bloquait `Argon 4` à chaque fin de tour même quand il ne faisait qu'éditer `roadmaps/*.md` ou `BRAND.md`. `Argon 4` a dû gaspiller 4 étapes à forger manuellement `.agents/cache/last-gate-status.json` avec `node -e` juste pour avoir le droit de répondre à l'utilisateur !

### 0.2 Mini-ADR : Architecture Dual-Harness (`Antigravity` + `OpenCode V2`)
- **Option A (Rejetée) : Deux branches / deux templates séparés (`AGENTS.agy.md` vs `AGENTS.opencode.md`).** Double la maintenance et diverge dès la première mise à jour.
- **Option B (Retenue) : Constitution Unifiée Bi-Harnais + Profil Exécuteur Unifié (`.agents/models.json` + `opencode.json` `"agents"`).**
  - Une seule constitution souveraine qui détecte/expose les 2 primitives d'orchestration :
    - **Sous Google Antigravity (`agy`) :** `swarm(action: "add", model: "<agy_executor>", ...)`
    - **Sous OpenCode V2 (`opencode v2.2.7+`) :** `subagent({ agent: "san-...", prompt: "..." })` adossé à la clé `"agents"` générée nativement dans `opencode.json`.
  - Une commande dédiée `san-framework models` permettant de définir en 1 seconde le **Modèle Exécuteur Unifié** des 8 sous-agents (`opencode-go/deepseek-v4-pro`, `opencode-go/qwen3.8-flash`, `opencode-go/glm-5.3-flash`, `gemini-4-hydrogen-xhigh`, etc.) pendant que le thread principal reste sur l'Orchestrateur (`hy4`, `Argon 4`).

---

## CHANTIER 1 : Moteur Dual-Harness & Commande `san-framework models` (Réserve HY4 #1)
- [x] **1.1 Configuration `.agents/models.json` & Générateur `opencode.json` V2 (`src/cli/installer.js`) :**
  - Créer le gestionnaire de profil modèle (`.agents/models.json`) avec défauts intelligents :
    - `agy.orchestrator`: `"gemini-4-argon-high"`, `agy.executor`: `"gemini-4-hydrogen-xhigh"`
    - `opencode.orchestrator`: `"opencode-go/hy4"`, `opencode.executor`: `"opencode-go/deepseek-v4-pro"`
  - Mettre à jour `mergeOpencodeConfig()` dans `src/cli/installer.js` pour générer la section `"agents"` native OpenCode V2 (`mode: "subagent"`, `description`, `model`, `system`, `permissions`) pour les 8 sous-agents `san-*`, validée par `opencode debug agents`.
- [x] **1.2 Commande CLI `san-framework models` (`src/cli/index.js` & `src/cli/installer.js`) :**
  - Supporter `san-framework models` (affichage + mode interactif TTY), `san-framework models --opencode=<model>`, `san-framework models --agy=<model>`, `san-framework models --set=<model>`, et synchronisation immédiate de `.agents/models.json`, `.agents/agents/san-*.md`, `.agents/rules/PROJECT.md` et `opencode.json`.
- [x] **1.3 Éradication du couplage mono-vendor dans les 8 Agents & 19 Skills :**
  - Remplacer les injonctions exclusives `gemini-4-hydrogen-xhigh` / `swarm` par la syntaxe Dual-Harness (`Antigravity: swarm(...)` | `OpenCode V2: subagent({ agent: "san-..." })` utilisant le modèle exécuteur configuré via `san-framework models`).

## CHANTIER 2 : Dé-Lobotomisation Cognitive & Réparation des Hooks (`A3`)
- [x] **2.1 Réparation chirurgicale de `src/hooks/scripts/stop_guard.mjs` :**
  - Exempter `design/**`, `logos/**`, `.opencode/**`, `opencode.json`, `opencode.jsonc`, `.gitignore`, `*.md`, `*.mdx`, `*.txt`, `roadmaps/**`, `docs/**`, `.agents/**`.
  - Filtrer les fichiers modifiés par `mtimeMs` (ignorer les fichiers sales préexistants modifiés il y a plus de 10 minutes ou avant le dernier `last-gate-status.json`) pour éliminer 100 % des faux positifs lors de la planification et du cadrage.
- [x] **2.2 Souveraineté Cognitive dans `AGENTS_INDEX_TEMPLATE.md`, `PROJECT_TEMPLATE.md` & `pre_invocation.mjs` :**
  - Remplacer l'injonction aveugle *« sans jamais demander à l'utilisateur »* par la **Règle d'Alignement Socratique & Visuel** : l'Orchestrateur (`Argon 4` / `HY4`) aligne lui-même les choix structurants avec l'utilisateur (`ask_question` / `question`) et inspecte les références visuelles (`export_png.mjs --url`) **avant** de déléguer la rédaction de roadmaps ou le codage aux sous-agents.
- [x] **2.3 Mise à jour de `san_planner/SKILL.md`, `san_brainstorming/SKILL.md` & `san_designer/SKILL.md` :**
  - Intégrer l'**Étape 0 (Alignement Socratique & Capture Réelle Playwright des URLs d'inspiration `--url`)** dans `san_planner` et `san_designer`.

## CHANTIER 3 : Nouveau 19e Skill `san_transcriber` — Relais Sceptique (`A2`)
- [x] **3.1 Création de `src/skills/san_transcriber/` :**
  - `SKILL.md` (<= 130 lignes) : Protocole de génération de transcript de fin de quota dans `roadmaps/transcripts/TRANSCRIPT_<ROADMAP>_<DATE>.md`.
  - `scripts/transcript_helper.mjs` : Générateur et validateur déterministe de transcript lié aux roadmaps actives (`roadmaps/*.md`), collectant l'état Git, la progression des cases `- [x]` / `- [ ]` et injectant les sections obligatoires de doute méthodique.
  - `templates/TRANSCRIPT_TEMPLATE.md` : Gabarit normatif avec section **Protocole de Relais Sceptique (Doubt & Verify)** poussant l'agent entrant à auditer et remettre en question le travail du premier agent.
- [x] **3.2 Détection au démarrage dans `src/hooks/scripts/session_start.mjs` :**
  - Détecter automatiquement le transcript le plus récent dans `roadmaps/transcripts/*.md` et l'annoncer dans la bannière `[SAN.AGY CONSTITUTION v2.2]` au démarrage de session.

## CHANTIER 4 : Déduplication des Scripts, `--url` dans `export_png.mjs` & Hygiène (Réserves HY4 #3, #4, #5)
- [x] **4.1 Mode Capture Web Live `--url` & Résolution Playwright Universelle dans `export_png.mjs` :**
  - Ajouter `--url=<https://...>` (et `--full-page`) à `export_png.mjs` pour capturer directement de vraies pages web d'inspiration en multi-viewports (`desktop`, `mobile`, `tablet`).
  - Étendre `loadPlaywright()` pour chercher automatiquement Playwright dans le projet, dans le framework global (`san_agy_framework/node_modules`) et dans `~/.npm/_npx`, avec lancement automatique du binaire Chromium de `~/.cache/ms-playwright` si nécessaire.
  - Synchroniser à l'octet près `src/skills/san_designer/scripts/export_png.mjs` et `src/skills/san_exporter/scripts/export_png.mjs`.
- [x] **4.2 Unification 100 % identique de `archive_roadmap.sh` et `svg_to_png.mjs` :**
  - Unifier `src/skills/san_planner/scripts/archive_roadmap.sh` et `src/skills/san_doc_keeper/scripts/archive_roadmap.sh` (zéro divergence `cmp -s`).
  - Unifier `src/skills/san_init/scripts/svg_to_png.mjs` et `src/skills/san_exporter/scripts/svg_to_png.mjs` (zéro divergence `cmp -s`).
- [x] **4.3 Synchronisation des 19 Wrappers `skills/*.md` & `sub-skills/*.md` + `.gitignore` :**
  - Régénérer les 19 fichiers `skills/*.md` et `sub-skills/*.md` en `version: "2.2.0"` (Dual-Harness).
  - Ajouter `__pycache__/`, `*.py[cod]` dans `.gitignore` et `git_ai_hygiene.sh`.

## CHANTIER 5 : Release `v2.2.0`, Suite de Tests & Déploiement sur les Projets Réels
- [x] **5.1 Bump `2.2.0` (`package.json`, `plugin.json`, `whats_new.js`, `README.md`, `README.en.md`, `CHANGELOG.md`, `CHANGELOG.en.md`)**
- [x] **5.2 Suite de tests `npm test` 100 % verte + `opencode debug agents` certifié**
- [x] **5.3 Déploiement et vérification (`san-framework update` + `san-framework doctor`) sur `ibs_suite_web` et `africa_sport_pronostics`**
