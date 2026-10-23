# ROADMAP : [PHASE_DE_PROJET] — [PROBLEMATIQUE]

> **Fichier :** `/roadmaps/[PHASE]_[PROBLEMATIQUE]_[JJMMAAAA].md`  
> **Date de création :** JJ/MM/AAAA  
> **Statut :** EN COURS (Auto-nettoyage actif)  
> **Stack Technique :** [Stack détectée par san_init, ex: Laravel 11 + React 19 + Redis]  
> **Objectif Mesurable :** [Description concise en 2 phrases de l'impact attendu et vérifiable].

---

## 1. RÈGLES D'AUTO-NETTOYAGE & DIRECTIVES DE PREUVE

- [ ] **PREUVE PAR LE CODE AVANT COCHAGE :** Interdiction absolue de cocher une case `- [x]` sans avoir vérifié le code réel dans l'espace de travail ou constaté l'exécution concluante d'un test automatisé. Tout doute impose de laisser la case décochée.
- [ ] **ACTIONS HORS-CODEBASE :** Pour toute tâche externe (ex: création d'un compte marchand MTN/Airtel, obtention de clé API tierce, validation d'un certificat TLS/DNS), poser directement la question au développeur avant de cocher.
- [ ] **CONDITIONS D'ARCHIVAGE (TOUT OU RIEN) :** Le fichier ne peut être déplacé dans `/roadmaps/archives/` QUE si 100 % des cases sont cochées et prouvées. Le script `scripts/archive_roadmap.sh` bloque toute tentative prématurée avec un code d'erreur 1.
- [ ] **FAST-TRACK D'HYGIÈNE ORCHESTRATEUR :** L'orchestrateur coche les cases prouvées, met à jour `CHANGELOG.md` et déclenche l'archivage sans mobiliser de sous-agent superflu.

---

## 2. CONTEXTE & AUDIT PRÉALABLE

* **Diagnostic UX & Cognitif (`psychologist_market_expert`) :**
  - Frictions identifiées : [Points de friction cognitifs ou ergonomiques détectés]
  - Charge mentale : [Simplifications appliquées pour minimiser les hésitations utilisateur]
  - Parcours optimisé : [Nombre d'étapes réduit, feedback clair, progression visualisable]
* **Diagnostic Technique & Clean Code (`technical_market_expert`) :**
  - Architecture & SOLID : [Découpage en Services/Actions, respect du principe de responsabilité unique]
  - Requêtes & Performance : [Prévention des requêtes N+1, stratégie d'indexation BDD, cache Redis]
  - Sécurité amont : [Contrôle d'accès BOLA/IDOR, validation stricte des entrées via Zod/FormRequest]

---

## PHASE 1 : FONDATIONS, MODÉLISATION & CONTRATS D'API (Contract-First)
> *Règle d'étanchéité : Cette phase doit être validée à 100% avant d'aborder la Phase 2.*

- [ ] **1.1 Modélisation de Données :** Créer les migrations de base de données avec index appropriés et contraintes d'intégrité dans `database/migrations/` (ou schéma équivalent).
- [ ] **1.2 Spécification des Contrats d'Endpoints :** Rédiger le contrat d'API dans `.agents/rules/technicals/endpoints/[domaine]_[action].md` (types d'entrée Zod, formats JSON de sortie, statuts HTTP 200/400/401/422/429/500, en-tête obligatoire `Idempotency-Key`).
- [ ] **1.3 Collection Bruno :** Rédiger les requêtes de test automatisées et assertions contractuelles dans `bruno/[domaine]/[action].bru`.
- [ ] **1.4 Types TypeScript / DTOs :** Définir et exporter les types/interfaces stricts partagés dans `src/types/` (ou DTOs équivalents backend/frontend).
- [ ] **1.5 Validation des Contrats :** Exécuter la compilation des types (`tsc --noEmit` ou équivalent) et vérifier que les contrats sont hermétiques.

---

## PHASE 2 : LOGIQUE MÉTIER & BACKEND CORE
> *Règle d'étanchéité : Les tests unitaires et d'intégration serveur doivent être 100% au vert avant d'aborder la Phase 3.*

- [ ] **2.1 Services Applicatifs :** Implémenter la logique métier isolée dans des Services / Actions autonomes en conformité stricte avec SOLID.
- [ ] **2.2 Contrôleurs & Middlewares :** Implémenter la validation stricte des payloads (`FormRequest` ou schémas Zod), l'authentification et le rate limiting.
- [ ] **2.3 Traitements Asynchrones & Webhooks :** Mettre en place les files d'attente Redis pour les tâches lourdes et sécuriser les webhooks (vérification de signature HMAC, replay protection).
- [ ] **2.4 Tests Unitaires & Intégration Serveur :** Exécuter la suite de tests backend dédiée et valider 100% de réussite :
  - *Commande validante :* `[COMMANDE_TESTS_BACKEND, ex: php artisan test --parallel ou pnpm test]`
- [ ] **2.5 Exécution Collection Bruno :** Valider la conformité runtime des endpoints via la commande CLI Bruno (`bru run bruno/`).

---

## PHASE 3 : INTERFACE CLIENT & EXPÉRIENCE UTILISATEUR
> *Règle d'étanchéité : Les 5 états obligatoires et le respect strict de BRAND.md doivent être validés avant la Phase 4.*

- [ ] **3.1 Respect des 5 États Obligatoires :** Implémenter le composant d'interface avec gestion exhaustive des 5 états :
  - *État Idéal :* Rendu complet, lisible et fluide des données réelles.
  - *État Vide :* Illustration ou micro-copie empathique guidant immédiatement vers l'action première.
  - *État Chargement :* Skeleton animés à 60 fps calqués sur la géométrie exacte des composants finaux (zéro spinner bloquant plein écran).
  - *État Erreur :* Message explicite orienté solution, sans jargon technique, doté d'un bouton de nouvelle tentative (`Retry`).
  - *État Succès / Hors-ligne :* Feedback visuel instantané (toast, badge statut ou bannière discrète).
- [ ] **3.2 Tokens & Mouvement :** Appliquer exclusivement les design tokens de `BRAND.md` (typographie, couleurs primaires/secondaires, espacements) et les courbes d'accélération normalisées (zéro valeur magique CSS).
- [ ] **3.3 Branchement API Typé :** Raccorder l'interface au client API en exploitant strictement les types exportés en Phase 1 (zéro type `any`).
- [ ] **3.4 Tests Frontend & Composants :** Valider le montage, le rendu et les interactions clés via la suite de tests frontend :
  - *Commande validante :* `[COMMANDE_TESTS_FRONTEND, ex: pnpm test ou yarn test]`

---

## PHASE 4 : RÉSILIENCE E2E & RÉSEAU DÉGRADÉ
> *Règle d'étanchéité : Tolérance prouvée aux conditions réseau difficiles (Afrique / Marchés émergents / 3G instable).*

- [ ] **4.1 Verrou d'Idempotence :** Vérifier que chaque soumission critique transmet une `Idempotency-Key` unique et que les retries ne créent aucun effet de bord ni doublon en base de données.
- [ ] **4.2 File d'Attente Hors-Ligne (Offline Outbox) :** Vérifier la mise en mémoire locale des requêtes (SQLite / MMKV / IndexedDB) en cas de déconnexion réseau et leur rejeu ordonné automatique dès retour de la connectivité.
- [ ] **4.3 Gestion des Erreurs Réseau & Jitter :** Valider l'implémentation de retries exponentiels temporisés avec jitter et l'affichage d'un toast non intrusif informant l'utilisateur sans bloquer l'écran.
- [ ] **4.4 Validation Dégradée E2E :** Exécuter un test de scénario réel sous simulation de bande passante dégradée (Fast 3G / perte de paquets).

---

## PHASE 5 : ENTONNOIR D'ASSURANCE QUALITÉ & SÉCURITÉ
> *Règle d'étanchéité : Score de sécurité >= 90/100, temps de réponse p95 < 100ms et zéro vulnérabilité critique.*

- [ ] **5.1 Étage 1 (Quality Gate Déterministe) :** Lancer le script global d'assurance qualité (`scripts/e2e_verification_gate.sh` ou suite E2E du projet). Tout échec doit être corrigé avant de poursuivre.
  - *Commande validante :* `[COMMANDE_E2E, ex: pnpm exec playwright test ou bash scripts/e2e_verification_gate.sh]`
- [ ] **5.2 Étage 2 (Audit OWASP & Pentest) :** Vérifier l'étanchéité des autorisations (prévention stricte BOLA / IDOR, échappement contextuel XSS, protection CSRF, en-têtes CSP/HSTS).
- [ ] **5.3 Métriques de Performance :** Valider un temps de réponse API p95 inférieur à 100 ms sur les routes critiques et vérifier les métriques Core Web Vitals (LCP < 2.5s, CLS < 0.1).

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
