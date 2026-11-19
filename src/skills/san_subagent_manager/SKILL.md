---
name: san_subagent_manager
description: Déclenché quand l'utilisateur souhaite concevoir, calibrer ou superviser des sous-agents chirurgicaux au moindre privilège, avec dialectique 2-approches et présomption de défaut.
---

# `san_subagent_manager` — Calibrage et Supervision de Workers Dual-Harness (`swarm` | `san_swarm`)

Protocole v3.0 pour armer, calibrer et superviser les 8 workers spécialisés **SAN AI Harness (`san_*`)**, pilotés par `.agents/models.json` (`san-harness models`), le moindre privilège et la dialectique technique préalable.

---

## 1. DOCTRINE DUAL-HARNESS & RÈGLES D'OR v3.0

1. **Orchestrateur Libre (`/model`) :** L'orchestrateur utilise le `/model` choisi par l'utilisateur (`inherit-user-model`) et délègue sans demander quel nom de modèle ou d'agent choisir.
2. **Vérité Technique Dual-Harness (`.agents/models.json` via `san-harness models`) :**
   - **Antigravity (`swarm`) :** Déléguez vers `swarm(action: "add", model: "<agy.executor>", ...)` (configuré dans `.agents/models.json`). Éviter `invoke_subagent(Model: "inherit")` sur les workers pour préserver le quota de l'orchestrateur.
   - **OpenCode V2.3 (`san_swarm` / `subagent`) :** Utiliser `san_swarm(action: "dispatch", ...)` (affichage tableau Swarm Board + progrès live) ou `subagent`, alimentés par `<opencode.executor>` dans `.agents/models.json` / `opencode.json`.
   - **Compatibilité Frontmatter CLI :** Les définitions `src/agents/*.md` conservent `model: "pro"` dans le frontmatter YAML pour compatibilité du parser Antigravity CLI.
3. **Moindre Privilège (*Least Privilege*) :** Zéro outil superflu. Interdiction absolue des outils de récursion agentique (`invoke_subagent`, `define_subagent`) pour les workers.
4. **Dialectique Avant Frappe :** Tout agent de création confronte au moins 2 approches techniques viables avant d'éditer le moindre fichier.
5. **Présomption de Défaut :** Tout agent d'audit opère sous présomption d'insuffisance et rend un verdict binaire `LIVRABLE | RETOUR_ATELIER`.
6. **Asynchronisme Événementiel (*Zero Polling*) :** Après `swarm(action: "add", ...)`, attendre via `swarm_wait` sans boucle de polling.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Qualification SRP & Lecture Ciblée
- Vérifier que la mission poursuit un **objectif atomique** (ou paralléliser par périmètre disjoint).
- Déclarer la liste fermée `INPUTS` (lecture) et `OUTPUTS` (écriture exclusive) en s'appuyant sur `.agents/rules/*.md`.

### Étape 2 : Sélection des Privilèges & Validation
- Consulter la [Matrice de Moindre Privilège](references/least_privilege_matrix.md) et les [Archétypes de Sous-Agents](references/subagent_archetypes.md).
- Valider toute spécification d'agent ou prompt via [validate_subagent_spec.sh](scripts/validate_subagent_spec.sh) (`unified-executor` ou `<provider>/<model>`).

### Étape 3 : Instanciation Dual-Harness (`swarm` | `san_swarm`)
- Utiliser les gabarits normés : [SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md), [ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md) ou [AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md).
- **Sous Antigravity (`swarm`) :** Spawner le worker sur `<agy.executor>` issu de `.agents/models.json` :
  ```json
  swarm({
    "action": "add",
    "name": "coder-back",
    "model": "<agy.executor>",
    "brief": "<mission atomique, périmètre exclusif INPUTS/OUTPUTS, commande de validation>"
  })
  ```
- **Sous OpenCode V2.3 (`san_swarm`) :** Dispatch parallèle via `san_swarm(action: "dispatch", waveTitle: "...", tasks: [...])` pour générer la vue tableau Swarm Board.
- Utiliser `workspace: "share"` sous AGY si plusieurs workers éditent en parallèle sur des fichiers distincts, puis appeler `swarm_wait`.

### Étape 4 : Reddition et Clôture Déterministe
1. Réception du rapport (`post_message` / `send_message` / tableau `san_swarm`) avec statut `SUCCÈS_TOTAL`, `BLOCAGE` ou verdict `LIVRABLE` / `RETOUR_ATELIER`.
2. Vérifier la preuve d'exécution physique (`exit 0` des tests).
3. Une fois le livrable intégré sous AGY, libérer le worker : `swarm({"action": "kill", "name": "<name>"})`.
4. Si `RETOUR_ATELIER`, relancer une passe corrective ciblée avec les coordonnées exactes des anomalies.

---

## 3. RESSOURCES DU SKILL

- **Scripts :**
  - [scripts/validate_subagent_spec.sh](scripts/validate_subagent_spec.sh) : Validateur de spécification d'agent/prompt Dual-Harness.
- **Modèles de Prompts :**
  - [templates/SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md) : Gabarit universel fermé avec dialectique 2-approches.
  - [templates/ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md) : Gabarit pour codeur atomique.
  - [templates/AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md) : Gabarit inquisiteur avec présomption de défaut et verdict binaire.
- **Guides de Référence :**
  - [references/least_privilege_matrix.md](references/least_privilege_matrix.md) : Attribution des outils par typologie.
  - [references/subagent_archetypes.md](references/subagent_archetypes.md) : Catalogue des 8 archétypes spécialisés.
  - [references/prompt_engineering_standards.md](references/prompt_engineering_standards.md) : Standards de prompt engineering anti-hallucination.
