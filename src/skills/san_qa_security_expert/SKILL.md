---
name: san_qa_security_expert
description: Déclenché quand l'utilisateur souhaite auditer la qualité logicielle, tester la sécurité OWASP, vérifier les Fitness Functions, auditer le DOM ou valider le verdict (LIVRABLE | RETOUR_ATELIER).
---

# `san_qa_security_expert` — Inquisition Parallèle QA, Sécurité, Fitness & DOM v2.2

Protocole déterministe d'audit sous **Présomption de Défaut**. `san_qa_security_expert` n'édite aucun code applicatif : il consulte `.agents/cache/REPO_MAP.md` (Map-First), déploie 3 pistes d'inquisition parallèles et prononce un verdict binaire impératif.

---

## 1. ÉQUATION DU VERDICT BINAIRE & DOCTRINE DUAL-HARNESS v2.2

$$\text{Verdict} = \mathbf{LIVRABLE} \iff (N_{\text{BLOQUANT}} = 0) \land (\text{Score Sécurité} \ge 90/100) \land (\text{Taux E2E} = 100\%) \land \text{Fitness} \land \text{DOM}$$

- Tout défaut bloquant, secret fuité, faille BOLA/IDOR, violation de **Fitness Function**, anomalie géométrique DOM ou échec de test impose **`RETOUR_ATELIER`**.
- **Délégation Parallèle Dual-Harness :** Spawner les auditeurs (`san-qa-auditor`) via `swarm(action: "add", model: "gemini-4-hydrogen-xhigh")` ou `run_workflow` (`scripts/parallel_inquisition_workflow.py`) sous Antigravity, ou via **`subagent`** (`.agents/models.json`) sous OpenCode V2. `invoke_subagent(Model: "inherit")` est **INTERDIT** sur `Argon`/`Carbon`.

---

## 2. PROTOCOLE D'INQUISITION PARALLÈLE PAS À PAS

### Étape 1 : Étage 1 — Quality Gate Déterministe Fail-Closed
Avant toute mobilisation LLM, exécuter le contrôle local strict (zéro `--passWithNoTests`, zéro `|| true`) :
```bash
bash .agents/skills/san_qa_security_expert/scripts/qa_security_gate.sh
```
En cas d'échec (dépendances CVE, `tsc --noEmit`, secret en clair ou `TESTS_FOUND=0`), stopper immédiatement et renvoyer les logs bruts.

### Étape 2 : Fan-Out `parallel()` sur 3 Pistes (`run_workflow`)
Lancer [scripts/parallel_inquisition_workflow.py](scripts/parallel_inquisition_workflow.py) pour agréger un rapport JSON strict (`INQUISITION_REPORT_SCHEMA`) :
```python
import sys
sys.path.insert(0, ".agents/skills/san_qa_security_expert/scripts")
from parallel_inquisition_workflow import run_parallel_inquisition
report = await run_parallel_inquisition(args, WORKSPACES)
```
1. **Piste 1 — Sécurité OWASP, Secrets & Résilience 3G :**
   - Surfaces d'attaque selon [owasp_unified_checklist.md](references/owasp_unified_checklist.md) (BOLA/IDOR, injections, idempotence).
   - Simulation réseau 3G dégradée ([network_throttling_protocols.md](references/network_throttling_protocols.md)) et seuils [perf_benchmarks.md](references/perf_benchmarks.md).
2. **Piste 2 — Substance des Tests & Architectural Fitness Functions :**
   - Traque du *Mocking Theater* (aucun mock du SUT, assertions réelles, cas limites et rollback, [testing_protocols.md](references/testing_protocols.md)).
   - Contrôle des **Architectural Fitness Functions** : étanchéité inter-modules (domaine vs infra), zéro dépendance circulaire, plafonds de taille (`<= 220` lignes UI, `<= 200` lignes classe backend) et budgets de bundle.
3. **Piste 3 — Audit Géométrique DOM & Standard UI 5 États :**
   - Exécuter le linter géométrique Playwright multi-viewports ([export_png.mjs](../san_designer/scripts/export_png.mjs) v2.2 sur maquette HTML ou URL dev `--url`) :
     ```bash
     node .agents/skills/san_designer/scripts/export_png.mjs --file=design/mockup/ecran.html --viewports=mobile,tablet,desktop --audit-dom --strict-dom
     # Ou sur serveur local/preview live : --url=http://127.0.0.1:3000 --viewports=desktop,mobile --full-page --audit-dom --strict-dom
     ```
   - Vérifier zéro `horizontalOverflow`, zéro `boxCollisions`, cibles tactiles `>= 44x44px`, `tabular-nums`, `@media (prefers-reduced-motion: reduce)` et présence des **5 États UI** (`Empty`, `Skeleton Cold-Start`, `Populated`, `Stale-While-Revalidate`, `Error`).

### Étape 3 : Fiches Médico-Légales, Verdict & Verrou `stop_guard.mjs`
1. Consolider les défauts (`fichier:ligne`, CWE/règle, commande de repro) selon [defect_reporting_guide.md](references/defect_reporting_guide.md) dans :
   - [QA_REPORT_TEMPLATE.md](templates/QA_REPORT_TEMPLATE.md) $\rightarrow$ `docs/QA_REPORT.md`
   - [SECURITY_REPORT_TEMPLATE.md](templates/SECURITY_REPORT_TEMPLATE.md) $\rightarrow$ `docs/SECURITY_REPORT.md`
   - [PERF_REPORT_TEMPLATE.md](templates/PERF_REPORT_TEMPLATE.md) $\rightarrow$ `docs/PERF_REPORT.md`
2. Prononcer le verdict :
   - **`LIVRABLE` :** Écrire `.agents/cache/last-gate-status.json` (`passed: true`, `timestamp`) pour déverrouiller `stop_guard.mjs` et transmettre à [san_devops_expert](../san_devops_expert/SKILL.md).
   - **`RETOUR_ATELIER` :** Renvoyer les tickets bloquants à [san_backend_expert](../san_backend_expert/SKILL.md) et [san_ux_ui_expert](../san_ux_ui_expert/SKILL.md).

---

## 3. RESSOURCES DU SKILL

- [scripts/parallel_inquisition_workflow.py](scripts/parallel_inquisition_workflow.py) : Orchestration `run_workflow` 3 pistes (`INQUISITION_REPORT_SCHEMA`) + `--self-test` / `--dry-run`.
- [scripts/qa_security_gate.sh](scripts/qa_security_gate.sh) : Quality gate local fail-closed (CVE, `tsc`, secrets, tests réels).
- [export_png.mjs](../san_designer/scripts/export_png.mjs) : Capture multi-viewports & linter géométrique DOM (`--audit-dom`).
