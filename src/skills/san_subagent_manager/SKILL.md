---
name: san_subagent_manager
description: Déclenché quand l'utilisateur souhaite concevoir, calibrer ou superviser des sous-agents chirurgicaux au moindre privilège, avec dialectique 2-approches et présomption de défaut.
---

# `san_subagent_manager` — Runbook de Calibrage et Supervision de Sous-Agents

Protocole déterministe pour armer, calibrer et superviser les sous-agents éphémères du framework Antigravity (`san_*`), selon les principes de moindre privilège, de sélection rigoureuse de modèle (`flash` vs `inherit`/`pro`), de dialectique technique préalable et de réveil événementiel sans polling.

---

## 1. RÈGLES D'OR DU SOUS-AGENT v2.0

1. **Routage Cognitif Strict :**
   - Implémentation atomique / code / tests ciblés $\rightarrow$ `Model: 'flash'`.
   - Audit critique / sécurité OWASP / architecture / pre-mortem $\rightarrow$ `Model: 'inherit'` ou `'pro'`.
2. **Moindre Privilège (*Least Privilege*) :** Zéro outil superflu. Pas d'accès web pour du code local, interdiction absolue des outils de récursion agentique (`invoke_subagent`, `define_subagent`).
3. **Dialectique Avant Frappe :** Tout agent de création doit confronter au moins 2 approches techniques viables avant d'éditer le moindre fichier.
4. **Présomption de Défaut :** Tout agent d'audit opère sous présomption d'insuffisance et rend un verdict binaire `LIVRABLE | RETOUR_ATELIER`.
5. **Asynchronisme Événementiel (*Zero Polling*) :** L'orchestrateur termine son tour immédiatement après `invoke_subagent`. Le sous-agent rend compte exclusivement via `send_message`.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Qualification et Découpage SRP
- Vérifier que la mission ne poursuit qu'un **seul objectif atomique**.
- Si la tâche mêle backend, frontend et infrastructure, découper en sous-missions séquentielles ou parallèles distinctes.
- Déclarer explicitement la liste fermée des fichiers `INPUTS` (lecture seule) et `OUTPUTS` (création/modification exclusive).

### Étape 2 : Sélection du Modèle et des Outils
- Consulter la [Matrice de Moindre Privilège](references/least_privilege_matrix.md) pour figer les outils autorisés.
- Choisir le modèle adéquat selon le catalogue des [Archétypes de Sous-Agents](references/subagent_archetypes.md).
- Valider la syntaxe du prompt via le script [validate_subagent_spec.sh](scripts/validate_subagent_spec.sh).

### Étape 3 : Instanciation du Sous-Agent
- Utiliser le gabarit normé adapté :
  - Mission de création ou code : [SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md) ou [ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md).
  - Mission d'audit critique ou QA : [AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md).
- Renseigner `PARENT_CONVERSATION_ID`, la clause de dialectique 2-approches ou de présomption de défaut, et la `VALIDATION_COMMAND` obligatoire.
- Déclencher l'outil :
  ```json
  invoke_subagent({
    "Role": "Artisan Backend SQLite",
    "TypeName": "self",
    "Model": "flash",
    "Prompt": "<prompt fermé compilé>"
  })
  ```
- Terminer immédiatement le tour de parole de l'orchestrateur (`end turn`).

### Étape 4 : Reddition et Clôture Déterministe
1. Réception du rapport dans le bus de messages via `send_message` (statut `SUCCÈS_TOTAL`, `ÉCHEC_PARTIEL`, `BLOCAGE` ou verdict `LIVRABLE` / `RETOUR_ATELIER`).
2. Vérifier la preuve d'exécution physique (commande de validation retournant exit code 0).
3. Si le résultat est conforme, détruire immédiatement le sous-agent éphémère pour libérer la mémoire :
   ```json
   manage_subagents({"Action": "kill", "ConversationIds": ["<id>"]})
   ```
4. Si `RETOUR_ATELIER` ou échec, relancer une passe corrective ciblée avec les coordonnées exactes des anomalies.

---

## 3. RESSOURCES DU SKILL

- **Scripts :**
  - [scripts/validate_subagent_spec.sh](scripts/validate_subagent_spec.sh) : Validateur de prompt fermé et d'adéquation de modèle.
- **Modèles de Prompts :**
  - [templates/SUBAGENT_PROMPT_TEMPLATE.md](templates/SUBAGENT_PROMPT_TEMPLATE.md) : Gabarit universel fermé avec dialectique 2-approches.
  - [templates/ATOMIC_CODER_PROMPT.md](templates/ATOMIC_CODER_PROMPT.md) : Gabarit pour codeur atomique (`flash`).
  - [templates/AUDITOR_PROMPT.md](templates/AUDITOR_PROMPT.md) : Gabarit inquisiteur avec présomption de défaut et verdict binaire.
- **Guides de Référence :**
  - [references/least_privilege_matrix.md](references/least_privilege_matrix.md) : Attribution des outils par typologie.
  - [references/subagent_archetypes.md](references/subagent_archetypes.md) : Catalogue des archétypes spécialisés.
  - [references/prompt_engineering_standards.md](references/prompt_engineering_standards.md) : Standards de prompt engineering anti-hallucination.
