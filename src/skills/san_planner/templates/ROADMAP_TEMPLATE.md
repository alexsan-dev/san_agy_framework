# ROADMAP : [PHASE_DE_PROJET] — [PROBLEMATIQUE]

> **Fichier :** `/roadmaps/[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md`  
> **Date de création :** JJ/MM/AAAA  
> **Statut :** EN COURS (Auto-nettoyage actif)  
> **Profil Projet :** [emerging_market_3g | global_saas | mobile_consumer | cli_devtools | api_platform]  
> **Stack Technique :** [Stack détectée par san_init, ex: Laravel 11 + React 19 + Redis]  
> **Objectif Mesurable :** [Description concise en 2 phrases de l'impact attendu et vérifiable].

---

## SECTION 0 : MINI-ADR, PRE-MORTEM, CONTRACT-FIRST & FITNESS FUNCTIONS (`san-architect`)

### 1. Comparatif de 2 Architectures Viables
*Confrontation objective de 2 architectures réalistes aux compromis lucides (interdiction de l'option épouvantail).*

| Critère d'Arbitrage | Option A : [Nom de l'Architecture A] | Option B : [Nom de l'Architecture B] |
| :--- | :--- | :--- |
| **Description du pattern** | [Ex: Transaction script + Service direct] | [Ex: Domain-Driven / Event Outbox] |
| **Avantages clés** | [Simplicité, rapidité, zéro middleware tiers] | [Découplage fort, auditabilité, scalabilité] |
| **Inconvénients & concessions** | [Couplage temporel, réessais synchrones] | [Complexité d'infrastructure, latence éventuelle] |
| **Effort de mise en œuvre** | [Faible à moyen (24-48h)] | [Moyen à élevé (3-5 jours)] |
| **Risques d'exploitation** | [Surcharge BDD en pic de charge] | [Désynchronisation éventuelle des files d'attente] |

> **Décision retenue :** [Option retenue] — *Justification :* [Raison factuelle du choix adapté au PROJECT_PROFILE].

### 2. Pre-Mortem : Anticipation des 3 Risques Majeurs d'Échec
1. **Risque 1 (Point de rupture / Défaillance critique) :** [Scénario où le système plante] $\rightarrow$ *Mitigation :* [Garde-fou architectural prévu].
2. **Risque 2 (Concurrence / Cohérence des données) :** [Condition de course ou conflit d'écriture] $\rightarrow$ *Mitigation :* [Verrou atomique / Idempotency-Key / Transaction].
3. **Risque 3 (Réseau dégradé / Timeout tiers) :** [Panne de passerelle ou latence extrême] $\rightarrow$ *Mitigation :* [Circuit breaker / Outbox locale / Dégradation gracieuse].

### 3. Architecture Contract-First & Architectural Fitness Functions
- **Contrats Partagés à Geler avant Codage Parallèle :**
  - Spécification API : `openapi.yaml` (OpenAPI 3.1) + requêtes `bruno/`.
  - Schémas Runtime Partagés : `src/contracts/*.ts` (**Zod** / **TypeBox**) générés et verrouillés avant de spawner `san-coder-back` et `san-coder-front`.
- **Architectural Fitness Functions (Vérifiées au Quality Gate) :**
  - **Étanchéité inter-modules :** [Règle d'importation stricte, ex: zéro import direct entre modules internes hors façade/contrat].
  - **Absence de cycles :** [Commande de détection de dépendances circulaires, ex: `npx madge --circular src/`].
  - **Budgets techniques :** [Composants `< 220` lignes, services `< 200` lignes, latence API p95 `< 100ms`, cibles tactiles `>= 44x44px`].

---

## 1. RÈGLES D'AUTO-NETTOYAGE & DIRECTIVES DE PREUVE

- [ ] **PREUVE PAR LE CODE AVANT COCHAGE :** Interdiction absolue de cocher une case `- [x]` sans avoir vérifié le code réel dans l'espace de travail ou constaté l'exécution concluante d'un test automatisé. Tout doute impose de laisser la case décochée.
- [ ] **ACTIONS HORS-CODEBASE :** Pour toute tâche externe (ex: création d'un compte marchand MTN/Airtel, obtention de clé API tierce, validation d'un certificat TLS/DNS), poser directement la question au développeur avant de cocher.
- [ ] **CONDITIONS D'ARCHIVAGE (TOUT OU RIEN) :** Le fichier ne peut être déplacé dans `/roadmaps/archives/` QUE si 100 % des cases sont cochées et prouvées. Le script `scripts/archive_roadmap.sh` bloque toute tentative prématurée avec un code d'erreur 1.
- [ ] **FAST-TRACK D'HYGIÈNE ORCHESTRATEUR :** L'orchestrateur coche les cases prouvées, met à jour `CHANGELOG.md` et déclenche l'archivage sans mobiliser de sous-agent superflu.

---

## 2. CONTEXTE & AUDIT PRÉALABLE

* **Diagnostic UX & Cognitif (`san-researcher` / `san-designer-worker`) :**
  - Frictions identifiées : [Points de friction cognitifs ou ergonomiques détectés]
  - Charge mentale : [Simplifications appliquées pour minimiser les hésitations utilisateur]
  - Parcours optimisé : [Nombre d'étapes réduit, feedback clair, progression visualisable]
* **Diagnostic Technique & Clean Code (`san-architect`) :**
  - Architecture & SOLID : [Découpage en Services/Actions, respect du principe de responsabilité unique]
  - Frontières & Fitness Functions : [Frontières de modules et règles d'étanchéité]
  - Sécurité amont : [Contrôle d'accès BOLA/IDOR, validation stricte des entrées via Zod/TypeBox/FormRequest]

---

## PHASE 1 : ARCHITECTURE CONTRACT-FIRST, SCHÉMAS GELÉS & FITNESS FUNCTIONS
> *Règle d'étanchéité : Les contrats partagés (OpenAPI 3.1 / Zod / TypeBox) et les tests de Fitness Functions doivent être gelés et validés à 100 % AVANT tout codage parallèle Front/Back en Phases 2 & 3.*

- [ ] **1.1 Modélisation de Données :** Créer les migrations de base de données avec index appropriés et contraintes d'intégrité dans `database/migrations/` (ou schéma équivalent).
- [ ] **1.2 Spécification Contract-First (OpenAPI 3.1 + Zod / TypeBox) :** Générer et geler le contrat OpenAPI 3.1 (`openapi.yaml`), les schémas partagés Zod/TypeBox (`src/contracts/`) et `.agents/rules/technicals/endpoints/[domaine]_[action].md` (statuts HTTP 200/400/401/422/429/500, en-tête obligatoire `Idempotency-Key`).
- [ ] **1.3 Collection Bruno :** Rédiger les requêtes de test automatisées et assertions contractuelles dans `bruno/[domaine]/[action].bru`.
- [ ] **1.4 Architectural Fitness Functions Automatisées :** Mettre en place les tests vérifiant l'étanchéité inter-modules, l'absence de cycles de dépendances et les budgets techniques.
- [ ] **1.5 Gel & Validation des Contrats :** Exécuter la compilation des types (`tsc --noEmit` ou équivalent) et les tests de contrats/fitness pour certifier le socle hermétique (`exit 0`).

---

## PHASE 2 : LOGIQUE MÉTIER & BACKEND CORE
> *Règle d'étanchéité : Les tests unitaires et d'intégration serveur doivent être 100% au vert avant de valider l'intégration finale.*

- [ ] **2.1 Services Applicatifs :** Implémenter la logique métier isolée dans des Services / Actions autonomes conformes aux contrats gelés en Phase 1.
- [ ] **2.2 Contrôleurs & Middlewares :** Implémenter la validation stricte des payloads (`FormRequest`, Zod ou TypeBox), l'authentification et le rate limiting.
- [ ] **2.3 Traitements Asynchrones & Webhooks :** Mettre en place les files d'attente Redis pour les tâches lourdes et sécuriser les webhooks (vérification de signature HMAC, replay protection).
- [ ] **2.4 Tests Unitaires & Intégration Serveur :** Exécuter la suite de tests backend dédiée et valider 100% de réussite :
  - *Commande validante :* `[COMMANDE_TESTS_BACKEND, ex: php artisan test --parallel ou pnpm test]`
- [ ] **2.5 Exécution Collection Bruno :** Valider la conformité runtime des endpoints via la commande CLI Bruno (`bru run bruno/`).

---

## PHASE 3 : INTERFACE CLIENT, STUDIO DUEL UI & EXPÉRIENCE UTILISATEUR
> *Règle d'étanchéité : Standard UI 5 États, Motion System, cibles tactiles >= 44x44px et audit géométrique DOM doivent être validés avant la Phase 4.*

- [ ] **3.1 Studio Duel UI (Écrans Clés) :** Produire 2 directions artistiques parallèles (`option-a` vs `option-b` via `swarm` ou `san_swarm` selon `.agents/models.json`), exporter en multi-viewports (`export_png.mjs --viewports=mobile,tablet,desktop --audit-dom`) et arbitrer visuellement via `san-qa-auditor`.
- [ ] **3.2 Standard UI 5 États Non-Destructifs :** Implémenter chaque vue avec les 5 états invariants :
  - *`Empty` :* Illustration ou micro-copie empathique guidant immédiatement vers l'action première.
  - *`Skeleton Cold-Start` :* Squelette géométrique (`CLS < 0.05`) réservé exclusivement au chargement initial à froid.
  - *`Populated` :* Rendu complet, lisible et hiérarchisé en 3 plans.
  - *`Stale-While-Revalidate` :* Conservation stricte des données existantes lors d'un refetch/filtre/tri + indicateur discret non bloquant.
  - *`Error` :* Message explicite orienté solution avec bouton `Réessayer` sans détruire les données déjà affichées.
- [ ] **3.3 Motion System, Accessibilité & Tokens :** Appliquer les design tokens de `BRAND.md`, transitions d'entrée `cubic-bezier` (`transform`/`opacity` uniquement), `@media (prefers-reduced-motion: reduce)`, cibles tactiles `>= 44x44px`, `font-variant-numeric: tabular-nums` et `focus-visible`.
- [ ] **3.4 Branchement API Contract-First :** Raccorder l'interface au client API en exploitant strictement les schémas Zod/TypeBox/OpenAPI gelés en Phase 1 (zéro type `any`).
- [ ] **3.5 Tests Frontend & Composants :** Valider les 5 états et interactions clés via la suite de tests frontend :
  - *Commande validante :* `[COMMANDE_TESTS_FRONTEND, ex: pnpm test ou yarn test]`

---

## PHASE 4 : RÉSILIENCE E2E & RÉSEAU DÉGRADÉ
> *Règle d'étanchéité : Tolérance prouvée aux conditions réseau difficiles (Marchés émergents / 3G instable).*

- [ ] **4.1 Verrou d'Idempotence :** Vérifier que chaque soumission critique transmet une `Idempotency-Key` unique et que les retries ne créent aucun effet de bord ni doublon en base de données.
- [ ] **4.2 File d'Attente Hors-Ligne (Offline Outbox) :** Vérifier la mise en mémoire locale des requêtes (SQLite / MMKV / IndexedDB) en cas de déconnexion réseau et leur rejeu ordonné automatique dès retour de la connectivité.
- [ ] **4.3 Gestion des Erreurs Réseau & Jitter :** Valider l'implémentation de retries exponentiels temporisés avec jitter et l'affichage d'un toast non intrusif informant l'utilisateur sans bloquer l'écran.
- [ ] **4.4 Validation Dégradée E2E :** Exécuter un test de scénario réel sous simulation de bande passante dégradée (Fast 3G / perte de paquets).

---

## PHASE 5 : ENTONNOIR D'ASSURANCE QUALITÉ, FITNESS FUNCTIONS & SÉCURITÉ
> *Règle d'étanchéité : Score de sécurité >= 90/100, Fitness Functions 100% vertes, 0 défaut géométrique DOM, p95 < 100ms.*

- [ ] **5.1 Étage 1 (Quality Gate & Fitness Functions) :** Lancer le script global d'assurance qualité + tests d'étanchéité inter-modules, d'absence de cycles et de budgets techniques (`exit 0`).
  - *Commande validante :* `[COMMANDE_E2E, ex: pnpm exec playwright test ou bash scripts/e2e_verification_gate.sh]`
- [ ] **5.2 Étage 2 (Audit OWASP, Substance & Géométrie DOM) :** Vérifier l'étanchéité des autorisations (BOLA/IDOR, XSS, CSRF, CSP/HSTS), l'absence de *Mocking Theater*, et la propreté multi-viewports (`export_png.mjs --viewports=mobile,tablet,desktop --audit-dom`).
- [ ] **5.3 Métriques de Performance :** Valider un temps de réponse API p95 inférieur à 100 ms sur les routes critiques et vérifier les métriques Core Web Vitals (LCP < 2.5s, CLS < 0.05).

---

## PHASE 6 : FAST-TRACK DOCUMENTAIRE & CLÔTURE INDUSTRIELLE
> *Règle d'étanchéité : Aucune roadmap n'est archivée sans scénario manuel validé et CHANGELOG.md mis à jour.*

- [ ] **6.1 Scénario de Test Manuel Développeur :** Rédiger ci-dessous le parcours pas-à-pas permettant au développeur de tester et valider la fonctionnalité en moins de 3 minutes :
  1. *Étape 1 :* [Action précise de préparation / navigation]
  2. *Étape 2 :* [Action de saisie / interaction avec données de test]
  3. *Étape 3 :* [Résultat attendu et vérification visuelle / réseau]
- [ ] **6.2 Mise à Jour de CHANGELOG.md :** Consigner exhaustivement les nouveautés dans le fichier `CHANGELOG.md` à la racine (sections `Added`, `Changed`, `Fixed`) sous la version appropriée.
- [ ] **6.3 Vérification Exhaustive & Archivage Déterministe :** Exécuter le script d'archivage officiel pour contrôler qu'aucune tâche n'est orpheline :
  ```bash
  bash .agents/skills/san_planner/scripts/archive_roadmap.sh [CHEMIN_DU_FICHIER]
  ```
