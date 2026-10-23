# MATRICE DU MOINDRE PRIVILÈGE (LEAST PRIVILEGE TOOLING MATRIX)
# Framework Antigravity (`san_*`) — Moteur `san_subagent_manager`

Le principe du moindre privilège impose de ne concéder à un sous-agent que les outils strictement indispensables à la réalisation immédiate de sa mission. Cette restriction drastique garantit :
1. **L'étanchéité du contexte :** Pas de dispersion ou d'appels d'outils hors sujet.
2. **La sécurité de la codebase :** Pas de modifications destructrices involontaires.
3. **L'économie de tokens :** Moins d'outils disponibles = moins de descriptions d'outils chargées dans la fenêtre d'attention.

---

## 1. MATRICE D'ATTRIBUTION DES OUTILS PAR ARCHÉTYPE

| Outil Antigravity | Codeur Atomique (`flash`) | Auditeur Qualité / OWASP (`inherit`) | Documentaliste Searcher (`inherit`) | Scripteur DevOps (`flash`) | Règle Impérative |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `read_file` | ✅ Activé | ✅ Activé | ✅ Activé | ✅ Activé | Lecture de contexte autorisée sur chemins définis. |
| `write_file` | ✅ Activé | ❌ **PROSCRIT** | ⚠️ Activé (`docs/`) | ✅ Activé | Un auditeur ne modifie aucun code source applicatif. |
| `edit_file` | ✅ Activé | ❌ **PROSCRIT** | ❌ **PROSCRIT** | ✅ Activé | Réservé à l'artisan d'implémentation. |
| `run_command` | ✅ Activé | ✅ Activé (Tests/Audit) | ⚠️ Restreint | ✅ Activé | Limité aux tests locaux ou inspections statiques. |
| `send_message` | ✅ **OBLIGATOIRE** | ✅ **OBLIGATOIRE** | ✅ **OBLIGATOIRE** | ✅ **OBLIGATOIRE** | Unique canal officiel de reddition de comptes. |
| `search_web` | ❌ **PROSCRIT** | ❌ **PROSCRIT** | ✅ Activé (Whitelist) | ❌ **PROSCRIT** | Interdiction de navigation web sauvage en plein codage. |
| `invoke_subagent` | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | **Zéro récursion.** Un sous-agent ne peut enfanter d'agent. |
| `define_subagent` | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | Seul l'orchestrateur configure des types d'agents. |
| `manage_subagents` | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | ❌ **INTERDIT** | Le cycle de vie est exclusivement géré par le parent. |

---

## 2. CONFIGURATIONS CONCRÈTES POUR `invoke_subagent`

### Profil 1 : Artisan de Code (`flash`)
```json
{
  "Role": "Backend Service Implementer",
  "Model": "flash",
  "TypeName": "self",
  "Prompt": "[PROMPT_HERMETIQUE]"
}
```
*Capacités :* `read_file`, `write_file`, `edit_file`, `run_command`, `send_message`.

### Profil 2 : Auditeur Statique / Sécurité (`inherit`)
```json
{
  "Role": "OWASP Security Auditor",
  "Model": "inherit",
  "TypeName": "research",
  "Prompt": "[PROMPT_HERMETIQUE]"
}
```
*Capacités :* `read_file`, `run_command` (pour `npm test`, linters), `send_message`.
*Protection :* Outils d'écriture neutralisés, empêchant toute régression silencieuse.
