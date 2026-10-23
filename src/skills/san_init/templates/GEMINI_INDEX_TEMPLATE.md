# TABLE DE ROUTAGE PRINCIPALE ANTIGRAVITY (`GEMINI.md`)

> **Index Souverain Local :** Ce fichier constitue la table de routage exclusive lue par le harness Antigravity CLI lors de l'initialisation de session. Il référence les règles locales, les compétences et l'historique opérationnel du projet.
> **Note d'isolation Git :** Ce fichier est strictement confiné à la machine locale et ne doit jamais être commité sur le dépôt distant.

---

## 1. RÈGLES DE GOUVERNANCE DU PROJET (`.agents/rules/`)

L'agent Antigravity charge et applique les règles normatives suivantes :

* **[PROJECT.md](.agents/rules/PROJECT.md) :** Constitution technique, conventions de langage, politique stricte de tests et routage des modèles LLM (`flash` vs `inherit`).
* **[PRODUCT.md](.agents/rules/PRODUCT.md) :** Cadrage stratégique, personas cibles, proposition de valeur unique (UVP) et contraintes terrains marchés émergents (3G, Mobile Money, offline).
* **[BRAND.md](.agents/rules/BRAND.md) :** Manifeste sensoriel, directives Anti-AI Taste, système cinétique 60 fps et design tokens chromatiques / typographiques.
* **[LOGO.md](.agents/rules/LOGO.md) :** Guide d'utilisation du logo vectoriel maître et inventaire des déclinaisons d'assets matriciels (favicons, PWA, splash screens).
* **[API.md](.agents/rules/API.md) :** Spécifications des contrats REST & WebSockets, enveloppe JSON canonique `{ success, data, error, meta }`, verrou d'idempotence et suite Bruno.

---

## 2. CONTRATS D'ENDPOINTS TECHNIQUES (`.agents/rules/technicals/endpoints/`)

Les spécifications détaillées de chaque route communicante de l'application sont cartographiées individuellement :
* Les contrats modulaires par domaine métier se situent dans `.agents/rules/technicals/endpoints/*.md`.
* L'orchestrateur consulte ces fichiers ciblés via `rules.json` pour éviter la dilution de la fenêtre de contexte.

---

## 3. SUIVI OPÉRATIONNEL & ROADMAPS (`roadmaps/`)

* **Roadmap Active en Cours :** `roadmaps/[NOM_ROADMAP_ACTIVE].md`
* **Archives des Roadmaps Acheveés (100% cochées) :** `roadmaps/archives/`
* **Idéations & Brainstorming :** `roadmaps/ideas/`

---

## 4. HISTORIQUE & JOURNAL DE BORD (`CHANGELOG.md`)

* **[CHANGELOG.md](CHANGELOG.md) :** Suivi chronologique cartésien de chaque version selon la convention *Keep a Changelog* (Ajouts, Modifications, Dépréciations, Suppressions, Correctifs de Sécurité).

---

## 5. SKILLS LOCAUX SPÉCIFIQUES AU PROJET (`.agents/skills/`)

Les modules Antigravity actifs et personnalisés pour ce projet sont répertoriés ci-dessous :
* **san_init :** Initialisation chirurgicale, hygiène Git et isolation locale.
* *(D'autres skills du framework san_* ou spécifiques au projet peuvent être ajoutés ici)*.
