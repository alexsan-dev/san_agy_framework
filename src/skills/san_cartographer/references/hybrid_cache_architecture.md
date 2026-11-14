# Architecture du Cache Hybride v2.0 & Injection de Contexte

Ce document définit les principes d'ingénierie, le modèle de données et les protocoles de synchronisation régissant le système de cache hybride et la cartographie déterministe de code source dans le framework **Antigravity (`san_*`)**.

---

## 1. Problématique & Raison d'Être

Dans les projets de taille intermédiaire ou complexe (100 à 5 000+ fichiers), l'exploration naïve d'une codebase par un agent IA présente deux écueils majeurs :
1. **L'aveuglement contextuel :** L'agent ne connaît pas l'organisation globale du dépôt, tente de deviner les chemins d'accès ou lance des commandes récursives lentes et coûteuses.
2. **L'explosion de tokens :** Lire des dizaines de fichiers complets pour trouver une signature de fonction sature la fenêtre contextuelle (30k à 100k tokens consommés inutilement), augmente la latence et accroît le risque d'hallucination.

Le moteur hybride `san_cartographer` résout cette tension par une séparation stricte entre **indexation déterministe locale** et **enrichissement sémantique à haute valeur ajoutée**.

---

## 2. Les Trois Couches du Cache Hybride

```
┌────────────────────────────────────────────────────────┐
│                   Dépôt Source                         │
└──────────────────────────┬─────────────────────────────┘
                           │ (Analyse statique sans LLM < 80ms)
                           ▼
┌────────────────────────────────────────────────────────┐
│   Couche 1 : Index Déterministe                        │
│   .agents/cache/repo-index.json                        │
│   - Hachages SHA-256, tailles, lignes                  │
│   - Symboles exportés avec plages #Lstart-Lend         │
│   - Graphe d'imports locaux                            │
└──────────────────────────┬─────────────────────────────┘
                           │
    ┌──────────────────────┴──────────────────────┐
    │                                             │
    ▼                                             ▼
┌───────────────────────────┐         ┌───────────────────────────┐
│ Couche 2 : Résumés IA     │         │ Couche 3 : Cartographie   │
│ .agents/cache/            │         │ .agents/cache/            │
│ semantic-summaries.json   │────┬───▶│ REPO_MAP.md               │
│ - Résumés métier denses   │    │    │ - Section 1 : Radar L1    │
│   par dossier (1-2 phrs)  │    │    │ - Section 2 : Carte L2    │
└───────────────────────────┘    │    └───────────────────────────┘
                                 │
                                 ▼
                     Agent / Orchestrateur
```

### Couche 1 : Index Déterministe (`.agents/cache/repo-index.json`)
- Généré en pur Node.js natif via `repo_mapper.mjs`.
- Zéro appel réseau, zéro inférence IA.
- Stocke pour chaque fichier analysé :
  - `hash` : Hachage SHA-256 court pour détection de modification sans recalcul complet.
  - `size` et `lineCount` : Poids et volume de lignes.
  - `language` : Langage normalisé (ex: `typescript`, `python`, `php`, `go`, `prisma`, `sql`).
  - `symbols` : Tableau d'objets décrivant chaque symbole public (fonctions, classes, interfaces, routes API, modèles BDD) avec sa plage exacte `[start, end]`.
  - `imports` : Chemins de dépendances importées localement.

### Couche 2 : Enrichissement Sémantique (`.agents/cache/semantic-summaries.json`)
- Conserve les synthèses fonctionnelles rédigées par des sous-agents d'exploration (`san-researcher`) ou manuellement par l'artisan.
- Structure clef-valeur associant un dossier (ou sous-système) à un résumé concis (1 à 2 phrases) décrivant sa responsabilité métier (ex: *"Gestion des transactions MoMo et webhooks de réconciliation"*).
- Persistant et découplé de l'index technique : si un fichier change dans le dossier, le résumé sémantique reste valide tant que la responsabilité métier globale demeure inchangée.

### Couche 3 : Cartographie Compilée (`.agents/cache/REPO_MAP.md`)
- Artefact Markdown consolidé combinant le Radar global et la cartographie détaillée par répertoire.
- Chaque symbole dispose d'un lien d'ancrage avec numéro de ligne exact (`fichier#Ldebut-Lfin`).
- Permet une inspection humaine immédiate et sert de base à la lecture chirurgicale des agents.

---

## 3. Protocole d'Injection à 2 Niveaux

Pour préserver au maximum les quotas de tokens, les agents du framework adoptent un modèle d'ingestion échelonné :

### Niveau 1 : Le Radar Compact (< 1.2 KB)
- **Quand ?** Au démarrage d'une session (`SessionStart`), dans les messages d'accueil ou en en-tête d'investigation.
- **Contenu :** 
  - Statistiques clés (nombre de fichiers, symboles recensés).
  - Répartition des langages en pourcentage.
  - Points d'entrée détectés (`src/index.ts`, `routes/api.php`, etc.).
  - Liste dense des domaines métier avec leur résumé sémantique (ou indicateur `⚠️ Non résumé`).
- **Coût :** Environ 250 à 350 tokens, soit moins de 0.2 % du contexte disponible.

### Niveau 2 : La Lecture Chirurgicale par Plages de Lignes
- **Quand ?** Lorsque l'agent doit intervenir sur un composant ou comprendre une implémentation.
- **Protocole :**
  1. L'agent consulte `REPO_MAP.md` ou lance `node scripts/repo_mapper.mjs --query <symbole>`.
  2. Le moteur retourne l'emplacement exact : ex. `src/services/billing.ts#L45-L78`.
  3. L'agent utilise `read_file(Path: "src/services/billing.ts", StartLine: 45, EndLine: 78)`.
  4. Seules les 34 lignes requises entrent dans le contexte au lieu des 900 lignes du fichier complet.

---

## 4. Rafraîchissement Temps Réel (`PostToolUse`)

Lorsqu'un agent modifie ou crée un fichier via `write_file` ou `edit_file`, le cache doit rester rigoureusement synchronisé avec l'état sur disque.

```bash
node scripts/repo_mapper.mjs --update-file <chemin_relatif>
```

- **Temps de traitement :** Moins de 25 millisecondes.
- **Opérations effectuées :**
  1. Relecture et reparsing exclusif du fichier modifié.
  2. Mise à jour de l'entrée correspondante dans `repo-index.json` (ou suppression si le fichier a été effacé).
  3. Recalcul instantané des totaux et points d'entrée.
  4. Réécriture atomique de `REPO_MAP.md`.
- **Résultat :** Les numéros de lignes des symboles dans `REPO_MAP.md` demeurent toujours exacts pour les opérations suivantes.
