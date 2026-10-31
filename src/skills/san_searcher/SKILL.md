---
name: san_searcher
description: Déclenché quand l'utilisateur ou un agent a besoin d'investiguer la documentation officielle, extraire des spécifications techniques fiables ou comparer des patterns d'architecture sans polluer le contexte.
---

# `san_searcher` — Documentaliste de Haute Précision, Veilleur Technique et Sas Anti-Pollution

Ce runbook impératif régit la recherche documentaire chirurgicale, le pinning de versions logicielles et l'étanchéité contextuelle (*Context Shielding*) du framework **Antigravity (`san_*`)**. Il isole l'orchestrateur du bruit web et produit des synthèses canoniques denses.

---

## Protocole d'Exécution Séquentiel (Runbook)

```mermaid
flowchart LR
    E1["1. Pinning Stack\n(detect_stack_versions.sh --json)"] --> E2["2. Requête Ciblée\n(Whitelist Domaines)"]
    E2 --> E3["3. Décontamination\n(doc_scraper.sh)"]
    E3 --> E4["4. Fiche Canonique\n(Tableau Multi-Options)"]
    E4 --> E5["5. Restitution Étanche\n(send_message Sobre)"]
```

### Étape 1 : Détection Déterministe & Pinning de Versions
1. Avant toute recherche, exécuter le script de diagnostic local :
   ```bash
   bash scripts/detect_stack_versions.sh --json
   ```
2. Figer les versions majeures et mineures installées (`package.json`, `composer.json`, `go.mod`, `Dockerfile`).
3. Consulter les [Lignes Directrices de Matrice de Versions](references/version_matrix_guidelines.md). Toute documentation relative à une version différente est disqualifiée.

### Étape 2 : Requête Experte Restreinte par Whitelist
1. Effectuer la recherche web ciblée via `search_web` en imposant impérativement le paramètre `domain`.
2. Puiser exclusivement dans la [Whitelist des Autorités Officielles](references/official_authorities.md) (`react.dev`, `laravel.com`, `docs.expo.dev`, `tailwindcss.com`, `owasp.org`, `developer.mozilla.org`, etc.).
3. Formuler des requêtes denses : `nom_framework + version_exacte + composant_précis + official documentation`.

### Étape 3 : Sas de Décontamination Documentaire
1. Utiliser le script [doc_scraper.sh](scripts/doc_scraper.sh) pour aspirer la ressource officielle sans balisage parasite :
   ```bash
   bash scripts/doc_scraper.sh "<URL_OFFICIELLE>" "<SUJET>"
   ```
2. Le scraper élimine l'intégralité du bruit (`<head>`, `<nav>`, `<aside>`, bannières, trackers) et extrait le markdown technique utile.

### Étape 4 : Rédaction de la Fiche Canonique Multi-Options
1. Structurer la synthèse dans `docs/research/TECH_INVESTIGATION_[DOMAINE]_[JJMMAAAA].md` depuis [RESEARCH_NOTE_TEMPLATE.md](templates/RESEARCH_NOTE_TEMPLATE.md).
2. **Tableau Comparatif Multi-Options Obligatoire :** Renseigner systématiquement la balance objective :
   - Approche / Pattern
   - Avantages Clés
   - Inconvénients & Concessions
   - Risques Identifiés
   - Effort Estimé
   - Verdict (Recommandé / Recevable / Écarté)
3. Fournir le snippet de référence 100 % typé compatible avec la version locale du projet.

### Étape 5 : Restitution Étanche vers l'Appelant
1. Transmettre la conclusion synthétique à l'agent appelant via `send_message` (ou sortie directe pour l'utilisateur).
2. Ne jamais injecter de dumps HTML bruts ou de logs verbeux dans le fil de discussion principal.

---

## Invariants Non Négociables
1. **Primauté de la Documentation Éditeur :** Seules les sources officielles font autorité (StackOverflow et forums non corroborés sont proscrits).
2. **Zéro Bruit Contextuel :** Tout contenu externe passe obligatoirement par le sas de décontamination avant restitution.
3. **Vérité de Version :** Toute solution proposée doit être prouvée compatible avec la version exacte inspectée à l'Étape 1.
