---
id: IDEA-SAN_AGY_V2_1_HYDROGEN_STUDIO-14112026
theme: "SAN_AGY_V2_1_HYDROGEN_STUDIO"
date: "14/11/2026"
author: "Alexsan.pro via Antigravity san_brainstorming"
status: "VALIDÉ_POUR_ROADMAP"
selected_option: "Option C+A (Micro-Kernel Déclaratif & Exécution Parallèle Swarm Hydrogen XHigh)"
global_score_40: 36.6
go_no_go_verdict: "GO_MVP_VALIDÉ"
target_handover_skill: "san_planner"
---

# DOSSIER D'IDÉATION & CADRAGE STRATÉGIQUE — `san_agy_framework v2.1.0` (Hydrogen XHigh & Studio Engineering)

> **Fichier :** `/roadmaps/ideas/SAN_AGY_V2_1_HYDROGEN_STUDIO_14112026.md`  
> **Date d'arbitrage :** 14/11/2026  
> **Statut :** PROPOSÉ AU DÉVELOPPEUR  
> **Arbitre :** Tech Lead / Décideur Produit  
> **Module Source :** `san_brainstorming` (Framework Antigravity `san_*`)

---

## 1. PROBLÉMATIQUE RACINE & OPPORTUNITÉ ÉCOSYSTÈME

### 1.1 Le Point de Friction Douloureux
- **Constat Terrain :** L'écosystème Antigravity CLI 2.0+ et l'arrivée de **`gemini-4-hydrogen-xhigh`** rendent obsolètes le bridage statique `gemini-3.1-pro` / `gemini-3.8-flash` et l'orchestration manuelle des sous-agents.
- **Impact Opérationnel :**
  1. **Gaspillage de Quota Orchestrateur (`Argon` / `Carbon`) ou Downgrade Cognitif :** L'usage de `inherit` brûle le quota hebdomadaire précieux des modèles d'orchestration (`Argon` / `Carbon`), tandis que l'ancien routage `flash` dégrade la finesse du code et du design UI alors que **`gemini-4-hydrogen-xhigh`** partage le même pool glissant rapide.
  2. **Orchestration Manuelle Fragile :** Les appels séquentiels manuels à `invoke_subagent` dans `san_executer` et `san_qa_security_expert` n'exploitent pas l'outil natif **`run_workflow`** (pipelines Python typés par JSON Schema avec boucles multi-tours `coder ↔ qa-auditor`).
  3. **Absence de Verrou Mécanique de Fin de Tour (`Stop`) et de Visibilité Post-Update :** Aucun hook `Stop` n'empêche un agent de rendre la main sans Quality Gate vert, et aucune note **"What's New on san-agy"** n'informe le développeur ni l'agent des nouveautés lors d'un `npx san-agy update`.
  4. **Plafond de Verre Frontend/UI :** Un seul screenshot PNG statique sans audit géométrique DOM ni confrontation de directions artistiques (*Studio Duel UI*) laisse passer des débordements CSS, des cibles tactiles `< 44px` et des interfaces génériques.

### 1.2 Les 9 Piliers Retenus par le Développeur pour `v2.1.0`
1. **"What's New on san-agy"** : Note de release affichée dans le terminal lors d'un `npx san-agy update` (diff de versions + résumé des nouveautés) et injectée une seule fois au 1er `SessionStart` post-update via `.agents/cache/whats_new_pending.json`.
2. **Doctrine Modèles v2.1 (`100% gemini-4-hydrogen-xhigh`)** : Remplacement intégral de `3.1-pro` et `3.8-flash` par **`gemini-4-hydrogen-xhigh`** (`model: "pro"` dans le schéma Antigravity) sur les 8 sous-agents, et **interdiction stricte de `inherit`** sur les sous-agents pour sanctuariser le quota d'orchestration `Argon` / `Carbon`.
3. **Hook `Stop` (`stop_guard.mjs`) + Hooks API v2 (`systemMessage`)** : Bloquer la fin du tour (`decision: "continue"`) si du code applicatif a été modifié sans Quality Gate vert (`exit 0`), avec coupe-circuit anti-boucle infinie + migration de `pre_invocation.mjs` de `ephemeralMessage` vers `systemMessage`.
4. **Mode Héritage Léger (`.agents/skills.json` `"inherits"`)** : Option CLI (`--light` / `--inherit`) permettant de référencer les skills via `"inherits"` sans les dupliquer physiquement, tout en gardant `.agents/rules/` et `.agents/cache/` 100 % locaux au projet.
5. **Workflows Python Déterministes (`run_workflow` + JSON Schema)** : Scripts et patterns d'orchestration par le code pour `san_executer` et `san_qa_security_expert` (boucle automatique `coder ↔ qa-auditor` validée par JSON Schema strict via `finish`).
6. **Architecture Contract-First & Fitness Functions (`san-architect`)** : Contrats partagés exécutables (OpenAPI 3.1 / Zod / TypeBox) et tests automatisés de frontières inter-modules vérifiés au Quality Gate.
7. **`export_png.mjs` v2 (Multi-Viewports + Linter Géométrique DOM)** : Capture simultanée Mobile (`390×844`), Tablette (`820×1180`), Desktop (`1440×900`) + détection mathématique Playwright des overflows (`scrollWidth > clientWidth`), collisions de boîtes, cibles `< 44px` et contrastes réels.
8. **Mode "Studio Duel UI" (2 Directions Artistiques en parallèle)** : Spawner 2 `san-designer-worker` en parallèle avec 2 compositions distinctes sur l'écran clé (`option-a` vs `option-b`) + arbitrage visuel sur les PNG.
9. **Standard UI 5 États + Motion System** : Imposer les 5 états (`Empty`, `Skeleton Cold-Start`, `Populated`, `Stale-While-Revalidate`, `Error`) + tokens d'animation CSS (`cubic-bezier`, `prefers-reduced-motion`).

---

## 2. EXERCICE PRE-MORTEM (`san-architect`) — 3 CAUSES DE RUPTURE ANTICIPÉES

1. **Cause de rupture 1 — Boucle Infinie du Hook `Stop` (*Stop-Lockout Cascade*) :**
   - *Risque :* Si `stop_guard.mjs` refuse l'arrêt lors d'une session purement documentaire (édition de `README.md` / `roadmaps/`) ou sur un repo greenfield sans tests, l'agent boucle jusqu'à épuisement du quota.
   - *Parade intégrée :* Exemption automatique si aucun fichier de code source n'est modifié (`git status --porcelain`), respect du flag natif `continuationActive === true`, et coupe-circuit (*Circuit Breaker*) limité à 2 relances maximum.
2. **Cause de rupture 2 — Chemin Fantôme sur `.agents/skills.json` `"inherits"` & Schéma `model` :**
   - *Risque :* Un chemin `"inherits"` invalide casse le chargement des skills, et une valeur `model` non reconnue dans le frontmatter ou `invoke_subagent` bloque l'invocation.
   - *Parade intégrée :* Validation et fallback automatique dans `san-agy doctor` (vérification de l'existence de la source `"inherits"`), et double ancrage du modèle (`model: "pro"` + mention explicite `gemini-4-hydrogen-xhigh` et interdiction formelle de `inherit`).
3. **Cause de rupture 3 — Timeout Playwright Multi-Viewports sur `export_png.mjs` v2 :**
   - *Risque :* Ouvrir 3 navigateurs Chromium simultanés fait exploser la RAM et dépasse 30s.
   - *Parade intégrée :* Réutilisation d'une **unique instance Chromium** redimensionnée séquentiellement sur les 3 viewports (`--viewports=mobile,tablet,desktop`) + passe d'audit géométrique DOM via `page.evaluate()` en $< 200\text{ms}$ avec sortie JSON structurée.

---

## 3. COMPARATIF DES 3 OPTIONS D'ARCHITECTURE (`score_idea.py --profile cli_devtools`)

### Option C+A (Piste Recommandée) : Micro-Kernel Déclaratif & Socle Node/Python Natif Antigravity
* **Description :**
  - Combine la gouvernance déclarative (manifeste de version + `.agents/cache/whats_new_pending.json` + `.agents/skills.json` optionnel) avec des scripts Node.js ESM zéro-dépendance (`stop_guard.mjs`, `export_png.mjs` v2) et des templates de workflows Python natifs pour l'outil `run_workflow` d'Antigravity CLI (qui s'exécute directement dans le runner Python intégré d'Antigravity sans requérir de `venv` tiers).
* **Évaluation Matricielle sur 40 Points (`cli_devtools`) :**
  - Impact Business & Valeur : `9.5/10` (Poids 1.0 -> `9.50`)
  - Faisabilité & Simplicité : `8.5/10` (Poids 1.0 -> `8.50`)
  - Adéquation Workflow & Ops : `9.5/10` (Poids 1.2 -> `11.40`)
  - Risques & Dépendances : `9.0/10` (Poids 0.8 -> `7.20`)
* **Score Global :** **`36.60 / 40.00` (`91.5 %`) — GO MVP VALIDÉ (PRIORITÉ HAUTE)**

---

### Option A (Alternative) : Monoculture Node.js Pure Sans Scripts `run_workflow` Dédiés
* **Description :**
  - Implémente les hooks, le CLI et `export_png.mjs` v2 en Node.js pur, mais laisse l'agent écrire ses scripts `run_workflow` à la volée sans bibliothèque de schémas JSON ni templates Python pré-validés dans `san_executer` / `san_qa_security_expert`.
* **Évaluation Matricielle sur 40 Points (`cli_devtools`) :**
  - Impact Business & Valeur : `8.5/10` (Poids 1.0 -> `8.50`)
  - Faisabilité & Simplicité : `8.0/10` (Poids 1.0 -> `8.00`)
  - Adéquation Workflow & Ops : `8.5/10` (Poids 1.2 -> `10.20`)
  - Risques & Dépendances : `8.0/10` (Poids 0.8 -> `6.40`)
* **Score Global :** **`33.10 / 40.00` (`82.8 %`) — GO SECONDAIRE**

---

### Option B (Alternative Lourde) : Harnais Python Externe avec `.agents/.venv` et Pydantic
* **Description :**
  - Déploie un environnement virtuel Python `.agents/.venv` dans chaque projet cible pour exécuter les hooks et les Fitness Functions via Pydantic/Tree-sitter.
* **Faiblesses & Risques :**
  - Alourdit chaque projet de ~60 Mo et crée des frictions `externally-managed-environment` sur les projets Node/PHP/Go alors que l'outil `run_workflow` d'Antigravity CLI fournit déjà son propre runtime Python natif avec validation JSON Schema intégrée.
* **Score Global :** **`30.10 / 40.00` (`75.2 %`) — GO CONDITIONNEL / ÉCARTÉ AU PROFIT DE C+A**

---

## 4. MATRICE SYNTHÉTIQUE COMPARATIVE SUR 40 POINTS

| Critère d'Évaluation (`cli_devtools`) | Poids | Option C+A (Recommandée) | Option A (Node Pur) | Option B (Venv Python Lourd) |
| :--- | :---: | :---: | :---: | :---: |
| **1. Impact Qualité Code & UI** | Coef 1.0 (max 10) | **9.5** | 8.5 | 9.0 |
| **2. Faisabilité & Simplicité** | Coef 1.0 (max 10) | **8.5** | 8.0 | 6.5 |
| **3. Adéquation Workflow & Ops** | Coef 1.2 (max 12) | **11.40** (`9.5`) | 10.20 (`8.5`) | 9.00 (`7.5`) |
| **4. Maîtrise des Risques** | Coef 0.8 (max 8) | **7.20** (`9.0`) | 6.40 (`8.0`) | 5.60 (`7.0`) |
| **SCORE GLOBAL TOTAL / 40.0** | **100 %** | **36.60 / 40** | **33.10 / 40** | **30.10 / 40** |
| **Pourcentage Normalisé** | — | **91.5 %** | **82.8 %** | **75.2 %** |
| **Verdict Arbitrage** | — | **GO MVP PRIORITAIRE** | **ALTERNATIVE** | **ÉCARTÉ** |

---

## 5. BORDEREAU DE TRANSMISSION VERS `san_planner`

```yaml
handover_payload:
  theme: "SAN_AGY_V2_1_HYDROGEN_STUDIO"
  version_target: "2.1.0"
  validated_option: "Option C+A"
  scope_mvp:
    - "1. What's New on san-agy : Notes de release v2.1.0 affichées lors de npx san-agy update + injection unique au 1er SessionStart via .agents/cache/whats_new_pending.json"
    - "2. Doctrine Modèles v2.1 : 100% des 8 sous-agents sur gemini-4-hydrogen-xhigh (model: pro), suppression de 3.1-pro/3.8-flash et interdiction stricte de inherit pour protéger Argon/Carbon"
    - "3. Hook Stop (stop_guard.mjs) avec Circuit Breaker anti-boucle + migration de pre_invocation.mjs vers systemMessage (Hooks API v2)"
    - "4. Mode Héritage Léger (--light / .agents/skills.json inherits) dans src/cli/installer.js et support dans san-agy doctor"
    - "5. Workflows Python Déterministes (run_workflow + JSON Schema) intégrés à san_executer et san_qa_security_expert"
    - "6. Architecture Contract-First & Fitness Functions intégrées à san-architect et san_planner"
    - "7. export_png.mjs v2 : Capture Multi-Viewports (Mobile/Tablette/Desktop) + Linter Géométrique DOM Playwright (overflows, collisions, cibles <44px)"
    - "8. Mode Studio Duel UI (Variante A vs Variante B en parallèle) dans san_designer et san-designer-worker"
    - "9. Standard UI 5 États + Motion System (cubic-bezier, prefers-reduced-motion) dans san-coder-front et san-designer-worker"
```
