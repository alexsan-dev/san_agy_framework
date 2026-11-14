---
name: san_subagent_manager
description: Déclenché quand l'utilisateur souhaite concevoir, calibrer ou superviser des sous-agents chirurgicaux au moindre privilège, avec dialectique 2-approches et présomption de défaut.
---

# `san_subagent_manager` — Runbook de Calibrage et Supervision de Workers `Swarm`

Protocole déterministe v2.1 pour armer, calibrer et superviser les workers spécialisés du framework Antigravity (`san_*`), selon la doctrine **Orchestrateur Souverain (`Argon` / `Carbon`)**, le moindre privilège, la dialectique technique préalable et le réveil événementiel sans polling.

---

## 1. DOCTRINE ORCHESTRATEUR SOUVERAIN & RÈGLES D'OR v2.1

1. **Autonomie Mécanique (`Argon` / `Carbon`) :** L'Orchestrateur du thread principal prend l'initiative mécanique de déléguer en parallèle sans jamais demander à l'utilisateur de taper `/model` ni le nom d'un sous-agent.
2. **Vérité Technique Antigravity CLI v1.5.8 :**
   - **Interdiction formelle** d'appeler `invoke_subagent(Model: "inherit")` quand le thread principal tourne sur `Argon` ou `Carbon` (sanctuarisation du quota hebdomadaire).
   - `invoke_subagent` bascule silencieusement sur `gemini-3.8-flash-tiered` : router toute délégation vers l'outil natif **`swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)`** (ou **`agy -p --model gemini-4-hydrogen-xhigh`**) afin d'exécuter réellement sur **Gemini 4 Hydrogen (XHigh)**.
   - Les définitions `src/agents/*.md` conservent `model: "pro"` dans le frontmatter YAML uniquement pour compatibilité ascendante du parser CLI.
3. **Moindre Privilège (*Least Privilege*) :** Zéro outil superflu. Interdiction absolue des outils de récursion agentique (`invoke_subagent`, `define_subagent`) pour les workers.
4. **Dialectique Avant Frappe :** Tout agent de création confronte au moins 2 approches techniques viables avant d'éditer le moindre fichier.
5. **Présomption de Défaut :** Tout agent d'audit opère sous présomption d'insuffisance et rend un verdict binaire `LIVRABLE | RETOUR_ATELIER`.
6. **Asynchronisme Événementiel (*Zero Polling*) :** Après `swarm(action: "add", ...)`, attendre via `swarm_wait` sans boucle de polling.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Qualification SRP & Lecture Map-First
- Vérifier que la mission poursuit un **objectif atomique** (ou paralléliser par périmètre disjoint).
- Consulter `.agents/cache/REPO_MAP.md` (Map-First) et déclarer la liste fermée `INPUTS` (lecture) et `OUTPUTS` (écriture exclusive).

### Étape 2 : Sélection des Privilèges & Validation
- Consulter la [Matrice de Moindre Privilège](references/least_privilege_matrix.md) et les [Archétypes de Sous-Agents](references/subagent_archetypes.md).
- Valider toute spécification d'agent ou prompt via [validate_subagent_spec.sh](scripts/validate_subagent_spec.sh) (`gemini-4-hydrogen-xhigh`).

### Étape 3 : Instanciation via `swarm` (`gemini-4-hydrogen-xhigh`)
- Utiliser les gabarits normés : [SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md), [ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md) ou [AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md).
- Spawner le worker épinglé explicitement sur `gemini-4-hydrogen-xhigh` :
  ```json
  swarm({
    "action": "add",
    "name": "coder-back",
    "model": "gemini-4-hydrogen-xhigh",
    "brief": "<mission atomique, périmètre exclusif INPUTS/OUTPUTS, commande de validation>"
  })
  ```
- Utiliser `workspace: "share"` si plusieurs workers éditent en parallèle sur des fichiers distincts ou nécessitent un worktree isolé, puis appeler `swarm_wait`.

### Étape 4 : Reddition et Clôture Déterministe
1. Réception du rapport (`post_message` / `send_message`) avec statut `SUCCÈS_TOTAL`, `BLOCAGE` ou verdict `LIVRABLE` / `RETOUR_ATELIER`.
2. Vérifier la preuve d'exécution physique (`exit 0`, `.agents/cache/last-gate-status.json` si code applicatif).
3. Une fois le livrable intégré, libérer le worker : `swarm({"action": "kill", "name": "<name>"})`.
4. Si `RETOUR_ATELIER`, relancer une passe corrective ciblée avec les coordonnées exactes des anomalies.

---

## 3. RESSOURCES DU SKILL

- **Scripts :**
  - [scripts/validate_subagent_spec.sh](scripts/validate_subagent_spec.sh) : Validateur de spécification d'agent/prompt (`gemini-4-hydrogen-xhigh`, anti-`inherit`).
- **Modèles de Prompts :**
  - [templates/SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md) : Gabarit universel fermé avec dialectique 2-approches.
  - [templates/ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md) : Gabarit pour codeur atomique.
  - [templates/AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md) : Gabarit inquisiteur avec présomption de défaut et verdict binaire.
- **Guides de Référence :**
  - [references/least_privilege_matrix.md](references/least_privilege_matrix.md) : Attribution des outils par typologie.
  - [references/subagent_archetypes.md](references/subagent_archetypes.md) : Catalogue des 8 archétypes spécialisés.
  - [references/prompt_engineering_standards.md](references/prompt_engineering_standards.md) : Standards de prompt engineering anti-hallucination.
