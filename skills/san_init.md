---
name: san_init
title: Expert d'Initialisation, d'Isolation Git et d'Onboarding de Dépôt
version: 1.0.0
type: entry_point
harness: google_antigravity_cli
routing:
  orchestrator:
    nominal: "argon-latest-max"
    fallback_1: "gemini-3.1-pro-high"
    fallback_2: "gemini-3.8-flash-high"
  subagents:
    exploration_and_audit: "inherit"
    code_and_scripts: "flash"
---

# `san_init` — Expert d'Initialisation, d'Isolation Git et d'Onboarding de Dépôt

## 1. RÔLE, POUR QUI, POUR QUOI

### Rôle Fondamental
`san_init` est l'expert d'initialisation, d'assainissement Git et d'onboarding architectural du framework **Antigravity (`san_*`)**. Il constitue la clé de voûte initiale de tout projet : son rôle est d'établir le pont fondamental entre le développeur et l'IA en dotant l'environnement de l'intégralité du contexte technique, produit, émotionnel, cinétique et méthodologique nécessaire, tout en érigeant une barrière étanche et inviolable entre la configuration locale de l'IA et l'arbre de versioning Git.

### Pour Qui ?
- Pour le développeur individuel, lead developer ou tech lead démarrant un nouveau projet sur un starter (Laravel, React, Next.js, Monorepo vierge).
- Pour le développeur intégrant une codebase existante, legacy ou collective où d'autres développeurs ont pu introduire des configurations d'agents disparates, contradictoires ou polluantes.

### Pour Quoi ?
- Éliminer le syndrome de la « répétition perpétuelle » : ne plus jamais avoir à réexpliquer à l'IA la palette graphique, l'esprit de la marque, les conventions d'architecture, la politique de tests ou la gestion des roadmaps.
- Bannir définitivement la fuite de métadonnées IA ou la pollution des dépôts partagés (`.agents/` commité par mégarde, conflits de merge sur des fichiers d'agents tiers).
- Convertir le savoir éparpillé (anciens `.cursorrules`, `CLAUDE.md`, `.opencode`, `AGENTS.md`) vers un standard unique et cohérent Antigravity.

---

## 2. CE QU'IL FAIT / CE QU'IL NE FAIT PAS

### Ce qu'il FAIT :
1. **Hygiène Git & Isolation Stricte :** Détecte, désindexe (`git rm -r --cached`) et verrouille de manière imperméable le dossier `.agents/` et tous les fichiers de contexte IA dans `.gitignore` et `.git/info/exclude`.
2. **Purge des Pollutions Tierces :** Analyse, extrait le savoir utile (règles de code, conventions), puis détruit impitoyablement toute trace de configurations d'agents tiers (`CLAUDE.md`, `.claude/`, `.opencode/`, `.poolside/`, `.cursor/`, `.cursorrules`, `AGENTS.md`, `GEMINI.md` anarchiques).
3. **Écrasement des `.agents/` Tiers :** Si un `.agents/` hérité d'un autre dev est présent dans un clone distant, il est purgé et remplacé par l'architecture propre du framework.
4. **Onboarding Cas 1 (Dépôt Frais) :** Conduit un entretien structuré avec le développeur pour définir l'âme et le motion design (`BRAND.md`), le logo (`LOGO.md` avec 3 propositions SVG), le cadrage produit (`PRODUCT.md`) et les lois techniques (`PROJECT.md`).
5. **Onboarding Cas 2 (Codebase Existante / Monorepo) :** Déploie des sous-agents d'inspection autonome (`Model: 'inherit'`) en lecture seule pour extraire le style, les tokens CSS/Tailwind, les logos, la stack, les schémas de BDD et les conventions de code, sans poser de questions superflues.
6. **Création du Hub de Gouvernance :** Génère `<dir>/.agents/GEMINI.md` agissant comme table de routage exclusive vers `.agents/rules/*.md`.
7. **Assainissement Documentaire :** Révise le `README.md` racine pour éliminer les liens morts vers d'anciennes règles supprimées et documenter la stack réelle.

### Ce qu'il NE FAIT PAS :
- **Il ne commite JAMAIS de configuration IA :** Aucun fichier de `.agents/` ne doit être poussé sur le remote Git.
- **Il ne conserve aucun résidu tiers :** Tolérance zéro pour les fichiers orphelins des autres agents.
- **Il ne pose pas de questions inutiles :** Si une codebase existante contient déjà les configurations Tailwind, les types TypeScript ou les routes Laravel, il les lit de manière autonome au lieu d'interroger le développeur à froid.
- **Il ne touche pas à la logique métier existante :** Il observe, cartographie et organise la gouvernance sans modifier le code de production de l'application.
- **Il ne génère pas de design générique :** Interdiction d'émettre des tokens sans âme ou des logos stéréotypés.

---

## 3. DÉCLENCHEURS & INVOCATIONS CONCRÈTES

### Déclencheurs Vocaux / Textuels
Le skill s'active dès que l'intention porte sur l'initialisation, le nettoyage ou l'onboarding d'un dépôt :
- `san_init`
- `san_init:setup`
- `initialise le projet avec san_init`
- `configure et nettoie antigravity sur ce repo`
- `onboarde cette codebase existante`
- `purge les fichiers d'agents et isole git`

### Exemples d'Invocations CLI / Chat
```bash
# Lancement direct sur un projet fraîchement cloné
agy "san_init"

# Lancement explicite avec ciblage d'un monorepo existant
agy "san_init : scanne cette codebase existante, purge les anciens fichiers de rules et initialise .agents"

# Lancement d'urgence pour sécuriser Git
agy "san_init : retire .agents du tracking Git et configure l'hygiène"
```

---

## 4. STRUCTURE INTERNE DU SKILL

L'arborescence normative du skill au sein de l'environnement Antigravity est la suivante :

```txt
.agents/skills/san_init/
├── SKILL.md                                 # Manifeste, rôles, procédure et principes directeurs
├── templates/
│   ├── GEMINI_INDEX_TEMPLATE.md             # Squelette de l'index maître .agents/GEMINI.md
│   └── rules/
│       ├── BRAND_TEMPLATE.md                # Modèle âme, cinétique et design tokens
│       ├── LOGO_TEMPLATE.md                 # Modèle de gouvernance du logo et déclinaisons
│       ├── PRODUCT_TEMPLATE.md              # Modèle de stratégie produit et marché
│       ├── PROJECT_TEMPLATE.md              # Modèle des règles d'ingénierie et gouvernance
│       └── API_TEMPLATE.md                  # Modèle des conventions REST/WebSocket/Bruno
└── scripts/
    ├── git_ai_hygiene.sh                    # Script de désindexation Git et verrouillage exclude
    └── svg_to_png.mjs                       # Script de génération haute résolution SVG -> PNG
```

---

## 5. LIVRABLES EXACTS

À l'issue de l'exécution de `san_init`, l'arborescence à la racine du projet (`<dir>`) est strictement conforme au standard :

```txt
<dir>/
├── .gitignore                               # Mis à jour : ignore strictement /.agents/ et les configs IA
├── .git/info/exclude                        # Verrouillé : double isolation locale
├── .agents/                                 # STRICTEMENT NON VERSIONNÉ (100 % local)
│   ├── GEMINI.md                            # Table de routage et index des règles / skills locaux
│   └── rules/
│       ├── BRAND.md                         # Âme/ressenti, DA, motion design et tokens statiques
│       ├── LOGO.md                          # Guide d'usage du logo retenu, variantes et animations
│       ├── PRODUCT.md                       # Contexte business, personas, proposition de valeur
│       ├── PROJECT.md                       # Loi technique : stack, tests, CHANGELOG, cascade modèles
│       ├── API.md                           # (Optionnel) Conventions d'API et règles d'interfaçage
│       └── technicals/                      # (Optionnel) Sous-dossier des endpoints granulaires
│           └── endpoints/*.md
└── README.md                                # Purifié des références obsolètes et mis à jour
```

### Conventions de Fichiers :
- **`GEMINI.md` :** Ne liste **que** les fichiers présents dans `.agents/rules/` et les skills customs développés spécifiquement pour le projet. Les skills globaux du harness Antigravity n'y sont pas listés.
- **`BRAND.md` :** Contient la triple définition : Manifeste Sensoriel (Âme) + Système Cinétique (Motion) + Tokens Statiques (Hex, fonts, rem).
- **`LOGO.md` :** Consigne le SVG maître validé. Les fichiers temporaires rejetés sont supprimés.

---

## 6. PROCÉDURE ÉTAPE PAR ÉTAPE (ZÉRO NÉGLIGENCE)

```mermaid
flowchart TD
    Start(["Lancement san_init"]) --> Step0["Étape 0 : Hygiène Git & Purge Tiers"]
    Step0 --> CheckType{"Nature du Dépôt ?"}
    
    CheckType -->|"Dépôt Frais / Starter"| Case1["Étape 1A : Extraction Starter & Interview Développeur"]
    CheckType -->|"Codebase Existante"| Case2["Étape 1B : Rétro-Ingénierie Autonome (Sous-Agents)"]
    
    Case1 --> Step2["Étape 2 : Rédaction des Règles (BRAND, LOGO, PRODUCT, PROJECT)"]
    Case2 --> Step2
    
    Step2 --> Step3["Étape 3 : Traitement du Logo (SVG -> Déclinaisons PNG)"]
    Step3 --> Step4["Étape 4 : Indexation GEMINI.md & Purge README.md"]
    Step4 --> EndVal(["Validation & Clôture"])
```

### Étape 0 : Hygiène Git Immédiate & Purge des Agents Tiers
1. **Désindexation Git :**
   - Vérifier si `.agents/`, `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.opencode/`, `.poolside/`, `.cursor/`, `.cursorrules`, `GEMINI.md` sont indexés dans Git :
     ```bash
     git rm -r --cached .agents .claude .opencode .poolside .cursor CLAUDE.md AGENTS.md GEMINI.md .cursorrules 2>/dev/null || true
     ```
2. **Verrouillage Double Étage :**
   - Insérer dans `<dir>/.gitignore` :
     ```gitignore
     # --- Antigravity AI Local Isolation ---
     /.agents/
     /AGENTS.md
     /GEMINI.md
     /.claude/
     /CLAUDE.md
     /.opencode/
     /.poolside/
     /.cursor/
     /.cursorrules/
     ```
   - Inscrire les mêmes exclusions dans `<dir>/.git/info/exclude`.
3. **Purge et Absorption :**
   - Parcourir les anciens fichiers d'instructions tiers. Extraire toute règle de convention utile (linter, scripts custom, ports spécifiques).
   - Supprimer physiquement les répertoires et fichiers d'agents tiers obsolètes.
   - Si un dossier `.agents/` provient d'un autre dev (via git pull ou clone), écraser son contenu pour éviter d'hériter de prompts toxiques.

---

### Cas 1 : Dépôt Frais (Starter vierge Laravel, Next.js, React, Mobile)

#### Étape 1A : Entretien Dirigé avec le Développeur
Poser un questionnaire structuré et concis articulé autour des 4 axes fondateurs :
1. **Identité Visuelle & Motion (`BRAND.md`) :**
   - *Âme & Ressenti :* Quelle émotion brute le produit doit-il susciter ? Quel est le style visuel (brutaliste, feutré, minimaliste high-tech, néo-banque) ? Quels sont les **anti-patterns visuels interdits** (ce qu'une IA générique ferait et qu'il faut bannir) ?
   - *Cinétique :* Quel est le tempérament du mouvement (claquant/sec, organique/fluide, rebondissant/spring) ? Quelles sont les courbes Bézier et durées normalisées ?
   - *Tokens :* Couleurs primaires, neutres d'arrière-plan, polices typographiques de caractère.
2. **Identité de Marque (`LOGO.md`) :**
   - Le développeur dispose-t-il d'un fichier SVG existant ?
   - À défaut, recenser les symboles forts. Générer **3 propositions SVG distinctes**. Une fois le choix arrêté par le développeur, **supprimer immédiatement les 2 autres**.
3. **Vision Business (`PRODUCT.md`) :**
   - Cible d'utilisateurs exacte, problème douloureux résolu, proposition de valeur unique, modèle économique, contraintes géographiques (ex. Afrique / Congo : 3G/EDGE, Mobile Money, WhatsApp).
4. **Socle d'Ingénierie (`PROJECT.md`) :**
   - Préciser les choix d'architecture flous (gestion d'état, convention d'API) et injecter les invariants Antigravity (Quality Gate, tests obligatoires, gestion du CHANGELOG).

---

### Cas 2 : Codebase Existante ou Monorepo Actif

#### Étape 1B : Rétro-Ingénierie Autonome par Sous-Agents
Interdiction de bombarder le développeur de questions si le code détient la vérité. Déployer des sous-agents d'inspection en mode lecture seule (`Model: 'inherit'`) :
1. **Extraction Graphique & Motion $\rightarrow$ `BRAND.md` :**
   - Scanner les fichiers de styles : `tailwind.config.js`, `globals.css`, variables CSS natives, tokens Sass.
   - Extraire les `@keyframes`, transitions Framer Motion, animations GSAP ou Reanimated pour cartographier le système cinétique existant.
   - Synthétiser l'ambiance visuelle et rédiger la liste noire anti-générique.
2. **Détection des Assets $\rightarrow$ `LOGO.md` :**
   - Localiser les logos SVG (`public/`, `assets/`, `resources/`).
   - Documenter les variantes (clair, sombre, monochrome, icône seule) et les dimensions d'affichage.
3. **Analyse Produit $\rightarrow$ `PRODUCT.md` :**
   - Parcourir les landing pages, textes statiques, fichiers de traduction i18n, README historique et modèles de données pour formaliser la proposition de valeur.
4. **Analyse Technique $\rightarrow$ `PROJECT.md` :**
   - Inspecter `package.json`, `composer.json`, Dockerfile, structure des dossiers, frameworks de tests (`jest`, `pest`, `phpunit`, `playwright`).
   - Documenter la stack réelle, les commandes de build, les linters et le système de versions.
5. **Arbitrage Final Unique :**
   - Ne solliciter le développeur qu'en une seule salve finale pour valider la synthèse et trancher les contradictions détectées.

---

### Étape 2 : Rédaction Normative des Règles (`.agents/rules/*.md`)
L'orchestrateur rédige les fichiers de règles définitifs en appliquant les modèles standardisés :
- `BRAND.md` : Direction artistique sans concession, tokens cinétiques stricts (durées, easings), tokens statiques hexadécimaux (zéro couleur magique).
- `LOGO.md` : Consigne le SVG retenu, règles de respiration, zones d'exclusion et animations CSS/SVG.
- `PRODUCT.md` : Persona cible, parcours d'usage clés, indicateurs de succès (KPIs).
- `PROJECT.md` : Gravure dans le marbre de la cascade des modèles (Argon/Pro/Flash), de la règle de délégation stricte du code, du Fast-Track orchestrateur, de l'entonnoir d'audit en 2 étages et de la politique de tests.
- `API.md` : (Si backend présent) Conventions REST/WebSocket, format d'erreurs normalisé, gestion des clés d'idempotence.

---

### Étape 3 : Déclinaison des Assets du Logo
1. Sauvegarder le SVG validé dans les assets du projet.
2. Exécuter le script `scripts/svg_to_png.mjs` pour générer automatiquement les versions PNG requises :
   - Favicons (16x16, 32x32)
   - Icônes Apple Touch (180x180)
   - Icônes PWA / Android (192x192, 512x512)
   - Logos d'en-tête haute définition.

---

### Étape 4 : Indexation Maître et Nettoyage Documentaire
1. **Génération de `<dir>/.agents/GEMINI.md` :**
   - Rédiger la table de routage pointant vers chaque règle de `.agents/rules/`.
   - Journaliser les éventuels skills locaux créés pour le projet.
2. **Nettoyage du `README.md` :**
   - Supprimer toute mention d'anciens outils d'IA supprimés.
   - S'assurer que les instructions d'installation et de build correspondent à la stack réelle.

---

## 7. PRINCIPES DIRECTEURS ET INVARIANTS

### 1. Invariant d'Isolation Git Absolue
`.agents/` est **strictement local**. Il ne doit sous aucun prétexte figurer dans un commit Git. Si une équipe distante commit un `.agents/`, `san_init` l'exclut localement (`git update-index --skip-worktree` ou retrait de cache) pour préserver la bulle de travail locale.

### 2. Invariant de Centralisation Monorepo
Dans une architecture monorepo (`apps/web`, `apps/mobile`, `packages/api`), le dossier `.agents/` se situe **exclusivement à la racine racine** du dépôt. Les sous-dossiers n'ont pas de `.agents/` propre : leurs particularités techniques sont documentées dans `.agents/rules/technicals/*.md`.

### 3. Invariant de l'Âme Vivante (Anti-Design Générique)
`BRAND.md` ne peut se résumer à une liste de codes hexadécimaux. Il doit obligatoirement expliciter une tension esthétique, un caractère affirmé et un tempérament cinétique (animations). Toute génération ressemblant à un template SaaS d'IA non personnalisé constitue une violation de standard.

### 4. Invariant de Gouvernance dans `PROJECT.md`
`PROJECT.md` est la constitution technique du projet. Il doit consigner de manière inaltérable :
- Le routage des modèles : session principale sous Argon/Pro ; sous-agents d'audit sous `Model: 'inherit'` ; sous-agents de code sous `Model: 'flash'`.
- La délégation stricte : l'orchestrateur ne code jamais et s'appuie sur le Fast-Track d'hygiène pour la maintenance documentaire.
- L'entonnoir d'audit en 2 étages (Étage 1 déterministe scripté $\rightarrow$ Étage 2 cognitif LLM).
- L'obligation de maintenir `CHANGELOG.md` et de respecter le cycle `/roadmaps/` vers `/roadmaps/archives/`.

---

## 8. MATRICE DE BRANCHEMENT ET RÉFÉRENCES CROISÉES

```mermaid
flowchart LR
    Dev(["Développeur"]) --> san_init["san_init.md"]
    san_init --> GEMINI[".agents/GEMINI.md"]
    san_init --> RULES[".agents/rules/*.md"]
    
    RULES --> san_brainstorming["san_brainstorming.md"]
    RULES --> san_planner["san_planner.md"]
    RULES --> san_designer["san_designer.md"]
    RULES --> san_executer["san_executer.md"]
    RULES --> san_ux_ui_expert["san_ux_ui_expert.md"]
    RULES --> san_backend_expert["san_backend_expert.md"]
```

### Amont :
- **Développeur / Tech Lead :** Déclenchement de l'onboarding lors du clone ou du bootstrap d'un projet.

### Aval (Clients des Livrables de `san_init`) :
- [san_brainstorming](san_brainstorming.md) : Utilise `PRODUCT.md` et `BRAND.md` pour cadrer les séances d'idéation amont.
- [san_planner](san_planner.md) : S'appuie sur `PROJECT.md` et `PRODUCT.md` pour structurer les roadmaps de production.
- [san_designer](san_designer.md) : Lit obligatoirement `BRAND.md` et `LOGO.md` comme source de vérité unique avant tout tracé d'écran.
- [san_ux_ui_expert](san_ux_ui_expert.md) : Consomme les tokens et l'âme de `BRAND.md` et respecte la stack fixée dans `PROJECT.md`.
- [san_backend_expert](san_backend_expert.md) : Applique les conventions d'architecture de `PROJECT.md` et les spécifications d'`API.md`.
- [san_executer](san_executer.md) : Lit `GEMINI.md` et `PROJECT.md` comme cadre d'orchestration global Full-Stack.
- [san_qa_security_expert](san_qa_security_expert.md) : Se réfère à la politique de tests et aux seuils définis dans `PROJECT.md`.
- [san_devops_expert](san_devops_expert.md) : Exploite les commandes de build et conventions d'environnement documentées dans `PROJECT.md`.
- [san_store_legal_expert](san_store_legal_expert.md) : Utilise `PRODUCT.md` pour contextualiser la conformité et les politiques de confidentialité.
- [san_growth_expert](san_growth_expert.md) : Puise dans `PRODUCT.md` et `BRAND.md` pour aligner le SEO local et les fiches stores.

### Compétences Transversales Mobilisées :
- `san_subagent_manager` : Pour instancier les sous-agents d'inspection en rétro-ingénierie (Cas 2).
- `san_searcher` : Pour vérifier les dernières versions et documentations officielles des dépendances repérées.
- `san_design_tokens` : Pour structurer mathématiquement la palette et les échelles de `BRAND.md`.
- `san_exporter` : Pour exécuter le pipeline de conversion d'assets `svg_to_png.mjs`.
