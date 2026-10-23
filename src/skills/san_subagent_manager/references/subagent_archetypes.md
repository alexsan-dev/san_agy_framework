# ARCHÉTYPES CANONIQUES DE SOUS-AGENTS
# Framework Antigravity (`san_*`) — Moteur `san_subagent_manager`

Ce référentiel recense les 5 archétypes de sous-agents réutilisables au sein du framework Antigravity, leur modèle assigné, leur mission type et leurs contraintes spécifiques.

---

## 1. L'ARTISAN DE CODE ATOMIQUE (`atomic_coder`)
- **Modèle :** `flash`
- **Typage de mission :** Écriture de code métier unitaire, modèles Eloquent, contrôleurs d'API, composants React / React Native, hooks personnalisés, migrations SQL.
- **Entrées requises :** Contrat d'interface (DTO / Zod / Swagger), spécification des règles projet (`.agents/rules/`).
- **Livrable :** Fichier source créé/modifié + fichier de test unitaire associé.
- **Règle d'or :** 0% de code d'infrastructure ou de logique non demandée. Zéro `any`.

## 2. L'AUDITEUR CRITIQUE & PENTEST (`security_auditor`)
- **Modèle :** `inherit`
- **Typage de mission :** Analyse de flux d'authentification (Sanctum, JWT), validation d'autorisation (BOLA/IDOR), injections, robustesse face aux coupures réseau 3G/EDGE.
- **Entrées requises :** Codebase à auditer, matrice OWASP, spécification des menaces.
- **Livrable :** Rapport d'audit exhaustif avec niveau de criticité, preuve de concept (PoC) et plan de remédiation.
- **Règle d'or :** L'auditeur ne modifie aucun fichier. Il met en lumière les failles et fournit les recommandations précises.

## 3. L'ÉCLAIREUR DOCUMENTALISTE (`tech_searcher`)
- **Modèle :** `inherit`
- **Typage de mission :** Extraction chirurgicale de la documentation officielle d'un framework ou SDK tiers pour une version épinglée (ex: Laravel 11, Expo SDK 52).
- **Entrées requises :** Nom de la technologie, version locale épinglée, cas d'usage ciblé.
- **Livrable :** Fiche de recherche dense dans `docs/research/` ou retour direct par `send_message`.
- **Règle d'or :** Whitelist stricte de domaines officiels, décontamination HTML intégrale (zéro bruit de navigation).

## 4. LE SCRIPTEUR D'AUTOMATISATION & DEVOPS (`devops_scripter`)
- **Modèle :** `flash`
- **Typage de mission :** Écriture de Dockerfile multi-stage, docker-compose.yml, scripts Bash d'hygiène, pipelines CI/CD GitHub Actions.
- **Entrées requises :** Manifestes du projet (`package.json`, `composer.json`, `go.mod`), contraintes de déploiement.
- **Livrable :** Fichier de configuration ou script testé avec `bash -n` ou `docker compose config`.
- **Règle d'or :** Scripts Bash avec `set -euo pipefail`, images Docker légères et sécurisées (non-root user).

## 5. L'ANALYSTE ERGONOMIQUE & PSYCHOLOGIQUE (`ux_cognitive_analyst`)
- **Modèle :** `inherit`
- **Typage de mission :** Revue ergonomique de parcours utilisateur, audit des 5 états UI (vide, chargement, erreur, succès, dégradé), friction cognitive et adaptation culturelle.
- **Entrées requises :** Maquettes Penpot, composants d'écrans, personas et règles de marque (`BRAND.md`).
- **Livrable :** Synthèse d'évaluation heuristique avec suggestions de micro-interactions 60 fps et micro-copie rassurante.
- **Règle d'or :** Focalisation sur la clarté mentale et l'accessibilité sur connexions mobiles contraignantes.
