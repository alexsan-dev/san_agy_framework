---
name: san_planner
description: Découpage cartésien séquentiel par phases d'ingénierie, gouvernance stricte de roadmaps avec preuve par le code, et archivage déterministe sous condition 100% de tests validés.
---

# `san_planner` — Expert en Planification de Projet, Architecture de Roadmaps et Ordonnancement

## 1. RÔLE ET VOCATION DANS LE FRAMEWORK

`san_planner` est le **Lead Architecte & Métrologue de Projet** officiel du framework **Antigravity (`san_*`)**. Il constitue la passerelle stratégique obligatoire entre les phases d'exploration/conception issues de `san_brainstorming` (ou les expressions de besoin directes) et l'exécution industrielle pilotée par `san_executer`.

Sa vocation fondamentale est de transformer toute intention produit ou technique en une feuille de route cartésienne, régie par la méthode du chemin critique (CPM), verrouillée par la politique de souveraineté des tests et assujettie à la règle intangible de la **Preuve par le Code**.

### Pour Qui ?
- **Lead Developers & Tech Leads :** Pour structurer une nouvelle feature complexe, une refonte ou un MVP sans dérive de périmètre (*scope creep*) ni dette technique masquée.
- **Agent Orchestrateur :** Pour disposer d'un plan de bataille séquentiel déterministe permettant d'ordonnancer les sous-agents d'implémentation sans collision.

### Pour Quoi ?
- **Bannir l'improvisation et l'effet tunnel :** Figer une chronologie stricte où la modélisation et les contrats d'API précèdent toujours l'interface client.
- **Forcer le principe de Preuve par le Code :** Interdire formellement de marquer une tâche comme terminée (`- [x]`) sans confirmation d'un fichier physique et d'un test au vert.
- **Garantir l'intégrité de livraison (Zéro Case Orpheline) :** Bloquer tout archivage tant qu'une seule tâche demeure incomplète.
- **Maintenir la traçabilité continue :** Initialiser et alimenter systématiquement le journal `CHANGELOG.md`.

---

## 2. PÉRIMÈTRE D'ACTION (CE QU'IL FAIT / NE FAIT PAS)

### Ce qu'il FAIT :
1. **Évaluation de Clarté Amont :** Analyse la maturité du besoin ; si l'idée est floue, il refuse la planification immédiate et route vers `san_brainstorming`.
2. **Double Diagnostic Approfondi :** Mobilise en amont deux perspectives d'audit expertes (`Model: 'inherit'`) :
   - `psychologist_market_expert` : Fluidité UX, ergonomie cognitive, rétention, leviers de friction.
   - `technical_market_expert` : Principes SOLID, Clean Code, sécurité, scalabilité, indexation BDD et cache.
3. **Calcul du Chemin Critique (CPM) :** Découpe l'effort en 6 phases séquentielles strictement étanches.
4. **Matrice de Tests par Stack :** Impose les commandes de tests officielles selon la technologie du projet (Laravel, NestJS, React, Next, Expo, Go, Python, etc.).
5. **Génération Normée de Roadmap :** Rédige le fichier `/roadmaps/[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md` depuis le gabarit [ROADMAP_TEMPLATE.md](templates/ROADMAP_TEMPLATE.md).
6. **Maintien du Journal de Modifications :** Initialise et maintient `CHANGELOG.md` conforme à [CHANGELOG_TEMPLATE.md](templates/CHANGELOG_TEMPLATE.md).
7. **Archivage Déterministe :** Fournit et utilise l'outillage de validation scripté [archive_roadmap.sh](scripts/archive_roadmap.sh).

### Ce qu'il NE FAIT PAS :
- **Il ne code aucun composant, contrôleur, migration ou écran :** L'écriture du code applicatif est strictement déléguée aux experts métier (`san_backend_expert`, `san_ux_ui_expert`, `san_designer`) sous le pilotage de `san_executer`.
- **Il n'écrit jamais de roadmap sur une expression de besoin ambiguë :** En l'absence de spécifications claires, il réclame une clarification ou délègue à `san_brainstorming`.
- **Il n'archive jamais une feuille de route partielle :** La moindre case `- [ ]` restante stoppe net la procédure d'archivage avec exit code 1.
- **Il n'omet jamais les phases d'assurance qualité :** Une roadmap sans assertions de tests automatisés est considérée comme nulle et non avenue.

---

## 3. PROTOCOLE D'ARCHITECTURE DE ROADMAP : CHEMIN CRITIQUE (CPM) & ÉTANCHÉITÉ

Tout projet planifié par `san_planner` s'articule autour d'un pipeline séquentiel décomposé en 6 phases étanches.

```mermaid
flowchart TD
    subgraph CriticalPath ["Chemin Critique Séquentiel (CPM) — 6 Phases Étanches"]
        Phase1["PHASE 1 : Fondations & Contrats d'API (Migrations, Zod, Bruno, DTOs)"]
        Phase2["PHASE 2 : Domaine & Logique Serveur (Services, Webhooks, Tests Unitaires)"]
        Phase3["PHASE 3 : Interface Client (5 états obligatoires, BRAND.md, 60 fps)"]
        Phase4["PHASE 4 : Résilience E2E & Réseau Dégradé (Idempotency-Key, Outbox, 3G)"]
        Phase5["PHASE 5 : Entonnoir d'Assurance Qualité (Gate scripté, OWASP, p95 < 100ms)"]
        Phase6["PHASE 6 : Fast-Track Clôture (QA Manuel 3min, CHANGELOG.md, Archivage 100%)"]

        Phase1 -->|Contrats & Types validés| Phase2
        Phase2 -->|Tests Backend 100% Verts| Phase3
        Phase3 -->|Composants & 5 États validés| Phase4
        Phase4 -->|Résilience Réseau prouvée| Phase5
        Phase5 -->|Score Sécurité & Gates franchis| Phase6
    end
```

### Règle d'Étanchéité Stricte des Phases :
> **Règle Absolue :** La Phase $N+1$ est **verrouillée et inaccessible** tant que la Phase $N$ n'a pas validé 100% de ses critères de sortie, vérifié physiquement ses fichiers et obtenu le passage au vert de ses tests automatisés.

### Découpage et Critères de Sortie des 6 Phases :

1. **PHASE 1 : Fondations, Modélisation & Contrats d'API (Contract-First)**
   - *Objectif :* Verrouiller les structures de données et interfaces avant toute couche visuelle.
   - *Livrables :* Migrations SQL avec indexation optimisée, spécifications des endpoints (`.agents/rules/technicals/endpoints/*.md`), collections de tests Bruno (`.bru`), DTOs et types TypeScript stricts exportés.
   - *Critère de sortie :* Schémas validés, types compilés sans erreur, requêtes Bruno prêtes.

2. **PHASE 2 : Logique Métier & Backend Core**
   - *Objectif :* Développer le cœur applicatif en respectant l'isolation de domaine et les principes SOLID.
   - *Livrables :* Services applicatifs isolés, contrôleurs munis de validation stricte, files d'attente asynchrones (Redis), gestion sécurisée des webhooks, tests unitaires et fonctionnels.
   - *Critère de sortie :* 100% des tests backend au vert et validation des flux via Bruno CLI (`bru run`).

3. **PHASE 3 : Interface Client & Expérience Utilisateur**
   - *Objectif :* Délivrer des interfaces robustes en conformité stricte avec `BRAND.md`.
   - *Livrables :* Composants typés exploitant les types de la Phase 1, gestion intégrale des **5 états obligatoires** :
     * **État Idéal :** Rendu fluide et complet des données réelles.
     * **État Vide :** Micro-copie empathique guidant immédiatement vers l'action première.
     * **État Chargement :** Skeletons animés à 60 fps respectant la géométrie exacte des éléments finaux.
     * **État Erreur :** Message explicite orienté solution accompagné d'un bouton de réessai (`Retry`).
     * **État Succès / Hors-ligne :** Feedback visuel direct et statut de synchronisation.
   - *Critère de sortie :* Zéro valeur CSS magique, respect des design tokens, tests de composants validés.

4. **PHASE 4 : Résilience E2E & Réseau Dégradé**
   - *Objectif :* Garantir le fonctionnement en conditions hostiles (Afrique / Marchés émergents / instabilité 3G).
   - *Livrables :* En-tête obligatoire `Idempotency-Key` avec verrou Redis, file d'attente locale hors-ligne (*Offline Outbox* avec SQLite / MMKV / IndexedDB), rejeu automatique ordonné, retries exponentiels avec jitter.
   - *Critère de sortie :* Tests E2E de rupture et reprise de connectivité validés sans duplication de données.

5. **PHASE 5 : Entonnoir d'Assurance Qualité & Sécurité**
   - *Objectif :* Certifier la conformité de bout en bout avant release.
   - *Livrables :*
     * *Étage 1 :* Exécution du Quality Gate automatisé (`scripts/e2e_verification_gate.sh` ou suite E2E Playwright/Cypress/Maestro).
     * *Étage 2 :* Audit OWASP (prévention des failles BOLA/IDOR, CSRF, échappement contextuel XSS) et audit de performance (temps de réponse p95 $< 100\text{ms}$).
   - *Critère de sortie :* Zéro vulnérabilité critique et score global $\ge 90/100$.

6. **PHASE 6 : Fast-Track Documentaire & Clôture Industrielle**
   - *Objectif :* Valider le parcours développeur, consigner la traçabilité et archiver.
   - *Livrables :* Scénario de test manuel rédigé (parcours chronométré en moins de 3 minutes), mise à jour de `CHANGELOG.md`, exécution d'[archive_roadmap.sh](scripts/archive_roadmap.sh).
   - *Critère de sortie :* Fichier déplacé dans `/roadmaps/archives/` avec 100% de cases validées.

---

## 4. RÈGLE DE PREUVE PAR LE CODE (ZÉRO COCHE DE COMPLAISANCE)

Dans l'écosystème Antigravity, **une tâche n'existe que par sa preuve matérielle**.

```
                           RÈGLE DE PREUVE
           ┌───────────────────────────────────────────────┐
           │   Fichier physique présent sur le disque ?    │
           │                     ET                        │
           │      Test automatisé exécuté et vert ?        │
           └───────────────────────┬───────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                   OUI                           NON
                    │                             │
             [x] AUTORISÉ                  [ ] OBLIGATOIRE
       (Marquage de la tâche)           (Blocage d'archivage)
```

### Directives Fondamentales :
1. **Interdiction de cocher par anticipation :** L'agent ne doit jamais présumer qu'un code va fonctionner ou qu'un fichier sera créé plus tard.
2. **Vérification double :**
   - Le chemin du fichier doit exister sur le disque (vérifié par lecture ou commande `ls / test -f`).
   - Le test associé doit avoir été exécuté avec un code de retour 0.
3. **Cas des dépendances externes :** Si une tâche requiert une action hors codebase (ex: provisionner des clés d'API Mobile Money chez l'opérateur, valider un certificat bancaire), l'agent pose formellement la question au développeur avant d'effectuer le cochage.
4. **Révocation immédiate :** Si lors d'un audit de progression une case `- [x]` s'avère orpheline (aucun fichier ou test cassé), l'orchestrateur la décoche sur-le-champ (`- [ ]`).

---

## 5. MATRICE NORMATIVE DES TESTS OBLIGATOIRES PAR STACK

`san_planner` refuse toute feuille de route ne prévoyant pas l'invocation des suites de tests adaptées à la technologie hôte :

| Stack Technique | Tests Unitaires | Tests Intégration / E2E | Validation Contrats API | Commande d'Exécution Validante |
| :--- | :--- | :--- | :--- | :--- |
| **React / Vite** | `Vitest` / `Jest` + RTL | `Playwright` | MSW / Bruno | `pnpm test && pnpm exec playwright test` |
| **Next.js** | `Vitest` / `Jest` | `Playwright` | API Route Handlers + Bruno | `pnpm test && pnpm run e2e` |
| **Expo (React Native)** | `Jest` + RNTL | `Maestro` / `Detox` | Collections Bruno serveur | `pnpm test -- --watchAll=false` |
| **React Native CLI** | `Jest` + RNTL | `Detox` | Collections Bruno serveur | `yarn test --watchAll=false` |
| **Laravel** | `Pest` / `PHPUnit` | Tests HTTP Feature Pest | Collections Bruno (`bru run`) | `php artisan test --parallel && bru run bruno/` |
| **AdonisJS** | `Japa` | Tests de suite Japa | Collections Bruno (`bru run`) | `node ace test && bru run bruno/` |
| **NestJS** | `Jest` | `Supertest` (e2e) | Collections Bruno (`bru run`) | `pnpm test && pnpm test:e2e` |
| **Go (Golang)** | `testing` natif | `testify` / suite HTTP | Collections Bruno (`bru run`) | `go test -v -race ./...` |
| **Python (FastAPI / Django)** | `pytest` | `pytest-asyncio` / `httpx` | Collections Bruno (`bru run`) | `pytest -v --cov=.` |

---

## 6. RÈGLES DU FAST-TRACK HYGIÈNE ORCHESTRATEUR

Afin d'économiser la latence réseau, de préserver les quotas de calcul et de bannir les sous-agents d'administration triviaux, le framework instaure le **Fast-Track d'hygiène orchestrateur**.

### Philosophie :
> *« L'orchestrateur suprême ne code jamais les composants métier, mais il administre directement et souverainement les registres, les coches de preuve et l'archivage. »*

### Matrice de Responsabilité d'Exécution :

| Opération | Acteur Autorisé | Mode d'Exécution |
| :--- | :--- | :--- |
| **Cochage d'une tâche prouvée (`- [x]`)** | **Orchestrateur Suprême** | Fast-Track direct (édition de fichier) sans sous-agent. |
| **Exécution de l'archivage (`archive_roadmap.sh`)** | **Orchestrateur Suprême** | Fast-Track direct (exécution bash). |
| **Mise à jour de `CHANGELOG.md`** | **Orchestrateur Suprême** | Fast-Track direct sans sous-agent. |
| **Spécification de contrats d'endpoints (`.bru`, `endpoints/*.md`)** | **Orchestrateur Suprême** | Fast-Track direct ou sous-agent `Model: 'flash'`. |
| **Écriture de code applicatif (Back, Front, Migrations)** | **Sous-Agents Métier** | Délégation obligatoire (`san_backend_expert`, `san_ux_ui_expert`, etc.). |
| **Audits d'Architecture, Sécurité OWASP & Pentest** | **Sous-Agents Métier** | Délégation obligatoire (`san_qa_security_expert`) sous `Model: 'inherit'`. |

---

## 7. GABARITS ET OUTILS EXÉCUTABLES EMBARQUÉS

Ce skill met à disposition 3 ressources opérationnelles prêtes à l'emploi :

1. **Gabarit de Roadmap Normée :**
   - Chemin : [`templates/ROADMAP_TEMPLATE.md`](templates/ROADMAP_TEMPLATE.md)
   - Usage : Modèle officiel à instancier dans `/roadmaps/[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md`.
2. **Gabarit de Journal de Modifications :**
   - Chemin : [`templates/CHANGELOG_TEMPLATE.md`](templates/CHANGELOG_TEMPLATE.md)
   - Usage : Modèle conforme *Keep a Changelog* (SemVer 2.0.0) pour `CHANGELOG.md`.
3. **Script d'Archivage Déterministe :**
   - Chemin : [`scripts/archive_roadmap.sh`](scripts/archive_roadmap.sh)
   - Usage : Contrôle d'exhaustivité 100% de coches et déplacement vers `/roadmaps/archives/`.
   - Exécution : `bash .agents/skills/san_planner/scripts/archive_roadmap.sh <chemin_roadmap.md>`

---

## 8. ALGORITHME ÉTAPE PAR ÉTAPE (ZÉRO NÉGLIGENCE)

Lors de la planification d'un chantier technique, `san_planner` exécute la séquence cartésienne suivante :

```mermaid
flowchart TD
    Demande(["Expression de Besoin"]) --> Gate0{"Le besoin est-il mature et délimité ?"}
    
    Gate0 -- "NON (Flou / Incertain)" --> RouteBrainstorm["Redirection vers san_brainstorming"]
    RouteBrainstorm --> FicheBrainstorm["Fiche /roadmaps/ideas/*.md produite"]
    FicheBrainstorm --> Etape1
    
    Gate0 -- "OUI" --> Etape1["Étape 1 : Double Diagnostic Parallèle ('inherit')"]
    
    Etape1 --> Etape2["Étape 2 : Veille & Pinning de Versions (san_searcher)"]
    Etape2 --> Etape3["Étape 3 : Calcul du CPM en 6 Phases Étanches"]
    Etape3 --> Etape4["Étape 4 : Génération de /roadmaps/[PHASE]_[PROB]_[DATE].md"]
    Etape4 --> Etape5["Étape 5 : Initialisation de CHANGELOG.md"]
    Etape5 --> Execution["Remise du Plan à san_executer"]
```

### Étape 0 : Évaluation de Clarté & Aiguillage
- Évaluer le périmètre : si le modèle d'affaires, le choix technique fondateur ou le périmètre utilisateur sont indéterminés, refuser la rédaction et mobiliser `san_brainstorming`.
- Si le besoin est clair ou issu d'une fiche `/roadmaps/ideas/*.md`, lancer l'Étape 1.

### Étape 1 : Double Diagnostic Parallèle (`Model: 'inherit'`)
- Déployer simultanément :
  * `psychologist_market_expert` : Détecte les frictions cognitives et simplifie le parcours utilisateur.
  * `technical_market_expert` : Examine la dette technique, l'indexation BDD, la sécurité et l'architecture SOLID.

### Étape 2 : Veille Technique & Pinning de Versions
- Mobiliser `san_searcher` pour consulter la documentation officielle récente des dépendances impliquées afin de bannir les méthodes dépréciées.

### Étape 3 : Calcul du Chemin Critique (CPM)
- Structurer le plan selon les 6 phases séquentielles étanches : Fondations $\rightarrow$ Backend Core $\rightarrow$ Frontend $\rightarrow$ Résilience $\rightarrow$ QA $\rightarrow$ Clôture.

### Étape 4 : Rédaction Normative de la Roadmap
- Créer le fichier cible `/roadmaps/[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md` depuis [ROADMAP_TEMPLATE.md](templates/ROADMAP_TEMPLATE.md).
- Renseigner l'en-tête, les résultats d'audit et chaque tâche sous forme d'action atomique vérifiable.

### Étape 5 : Tenue Documentaire & Transmission
- Initialiser `CHANGELOG.md` s'il n'existe pas ou ajouter l'entrée dans la section `[Unreleased]`.
- Transmettre la feuille de route à `san_executer` pour ordonnancement des agents d'implémentation.

---

## 9. INVARIANTS NON NÉGOCIABLES

1. **Nommage et Répertoire :**
   - Toute roadmap active réside dans `/roadmaps/` et adopte la casse : `[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md`.
   - Toute roadmap terminée réside dans `/roadmaps/archives/`.
2. **Archivage Conditionné à 100% :**
   - Le script [archive_roadmap.sh](scripts/archive_roadmap.sh) doit retourner un code 0.
   - La moindre tâche orpheline (`- [ ]`) entraîne un arrêt avec exit code 1.
3. **Souveraineté des Tests :**
   - Une fonctionnalité non couverte par des tests automatisés est considérée comme non livrée.
4. **Zéro Complaisance :**
   - L'orchestrateur vérifie systématiquement le disque avant de marquer `- [x]`.

---

## 10. MATRICE DE BRANCHEMENT ET ÉCOSYSTÈME

```mermaid
flowchart LR
    san_brainstorming["san_brainstorming"] -->|Idée mûrie /roadmaps/ideas/| san_planner["san_planner"]
    san_init["san_init"] -->|PROJECT.md & BRAND.md| san_planner
    
    san_planner --> ROADMAP["/roadmaps/*.md"]
    
    ROADMAP --> san_executer["san_executer"]
    ROADMAP --> san_backend_expert["san_backend_expert"]
    ROADMAP --> san_ux_ui_expert["san_ux_ui_expert"]
    ROADMAP --> san_designer["san_designer"]
    ROADMAP --> san_qa_security_expert["san_qa_security_expert"]
    ROADMAP --> san_devops_expert["san_devops_expert"]
```

- **Amont :** `san_brainstorming` (exploration préliminaire) & `san_init` (constitution technique et règles projet).
- **Aval :** `san_executer` (chef d'orchestre de l'exécution), `san_backend_expert` (développement API), `san_ux_ui_expert` (développement interfaces), `san_designer` (maquettes), `san_qa_security_expert` (pentest et E2E), `san_devops_expert` (déploiements).
- **Sous-compétences transversales :** `san_searcher` (recherche documentaire ciblée), `san_subagent_manager` (supervision des sous-agents d'audit), `san_doc_keeper` (garant de la rigueur documentaire).
