---
name: san_qa_security_expert
description: Déclenché quand l'utilisateur souhaite auditer la qualité logicielle, tester la sécurité OWASP (Web, API, Mobile), simuler des conditions réseau 3G dégradées ou valider le verdict de livraison (LIVRABLE | RETOUR_ATELIER).
---

# `san_qa_security_expert` — Runbook QA, Sécurité OWASP & Verdict Binaire

Protocole déterministe d'assurance qualité, de pentest et de benchmarking de performance sous présomption de défaut. `san_qa_security_expert` n'édite aucun code applicatif : il inspecte, éprouve sous contraintes réelles et rend un verdict binaire impératif.

---

## 1. RÈGLE D'OR & ÉQUATION DU VERDICT BINAIRE

L'approbation complaisante est proscrite. Le verdict officiel de livraison est mathématique :

$$\text{Verdict} = \mathbf{LIVRABLE} \iff (N_{\text{BLOQUANT}} = 0) \land (\text{Score Sécurité} \ge 90/100) \land (\text{Taux E2E} = 100\%)$$

Tout défaut bloquant, fuite de secret, faille BOLA/IDOR ou échec de test impose immédiatement **`RETOUR_ATELIER`**.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Étage 1 — Quality Gate Déterministe Fail-Closed
Avant toute mobilisation cognitive, exécuter le script de contrôle local :
```bash
bash .agents/skills/san_qa_security_expert/scripts/qa_security_gate.sh
```
- **Conditions de passage strictes :** 0 faille critique dans les dépendances, compilation TypeScript stricte (`tsc --noEmit`), zéro secret en clair et au moins une suite de tests unitaires/intégration exécutée avec succès (zéro `--passWithNoTests`).
- En cas d'échec de l'Étage 1, stopper immédiatement l'audit et renvoyer les logs d'erreurs brutes.

### Étape 2 : Audit de Substance des Tests & Traque du Testing Theater
- Vérifier l'absence de *Mocking Theater* (tests qui mockent le service testé ou la BDD sans tester de vraie logique).
- Contrôler la présence de tests pour les états limites, les erreurs d'autorisation (BOLA/IDOR) et l'isolation transactionnelle.

### Étape 3 : Pentest OWASP & Résilience Réseau 3G
- Inspecter les surfaces d'attaque selon la [Matrice OWASP Unifiée](references/owasp_unified_checklist.md).
- Simuler les conditions réseau mobiles contraignantes via les [Protocoles de Throttling 3G](references/network_throttling_protocols.md) (750 kbps, 150 ms RTT) pour vérifier l'absence d'écran blanc et l'idempotence des transactions.
- Contrôler les seuils de performance selon les [Seuils de Benchmarks](references/perf_benchmarks.md).

### Étape 4 : Fiches d'Anomalies Médico-Légales
- Pour chaque vulnérabilité identifiée, rédiger une fiche selon le [Guide de Rédaction des Fiches](references/defect_reporting_guide.md) (`fichier:ligne`, commande de reproduction, classification CWE/OWASP).

### Étape 5 : Consolidation & Prononcé du Verdict Binaire
1. Rédiger les rapports sous `docs/` à partir des gabarits officiels :
   - [QA_REPORT_TEMPLATE.md](templates/QA_REPORT_TEMPLATE.md) $\rightarrow$ `docs/QA_REPORT.md`
   - [SECURITY_REPORT_TEMPLATE.md](templates/SECURITY_REPORT_TEMPLATE.md) $\rightarrow$ `docs/SECURITY_REPORT.md`
   - [PERF_REPORT_TEMPLATE.md](templates/PERF_REPORT_TEMPLATE.md) $\rightarrow$ `docs/PERF_REPORT.md`
2. Prononcer formellement le verdict :
   - `LIVRABLE` : Feu vert officiel transmis à [san_devops_expert](../san_devops_expert/SKILL.md).
   - `RETOUR_ATELIER` : Tickets transmis aux artisans [san_backend_expert](../san_backend_expert/SKILL.md) et [san_ux_ui_expert](../san_ux_ui_expert/SKILL.md).

---

## 3. RESSOURCES DU SKILL

- **Scripts Déterministes :**
  - [scripts/qa_security_gate.sh](scripts/qa_security_gate.sh) : Quality gate local fail-closed (dépendances, secrets, tests).
- **Gabarits de Rapports :**
  - [templates/QA_REPORT_TEMPLATE.md](templates/QA_REPORT_TEMPLATE.md) : Modèle de rapport fonctionnel et E2E.
  - [templates/SECURITY_REPORT_TEMPLATE.md](templates/SECURITY_REPORT_TEMPLATE.md) : Modèle d'audit sécurité scoré sur 100.
  - [templates/PERF_REPORT_TEMPLATE.md](templates/PERF_REPORT_TEMPLATE.md) : Modèle de performance Core Web Vitals et latences API.
- **Guides de Référence :**
  - [references/owasp_unified_checklist.md](references/owasp_unified_checklist.md) : Matrice OWASP Web, API 2023, Mobile 2024.
  - [references/network_throttling_protocols.md](references/network_throttling_protocols.md) : Helpers CDP Playwright pour 3G dégradée.
  - [references/perf_benchmarks.md](references/perf_benchmarks.md) : Seuils chiffrés LCP, INP, CLS, TTFB, p95.
  - [references/testing_protocols.md](references/testing_protocols.md) : Architecture de suites de tests déterministes.
  - [references/defect_reporting_guide.md](references/defect_reporting_guide.md) : Gabarit de fiches médico-légales.
