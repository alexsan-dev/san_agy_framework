---
name: san_transcriber
title: Sous-Skill de Relais Sceptique Inter-Modèles & Cross-Harness (Doubt & Verify)
version: "2.2.0"
type: sub_skill
role: Skeptical Relay & Session Handover Specialist (v2.2 Dual-Harness)
harness: dual_harness
models_config: ".agents/models.json"
routing:
  antigravity:
    orchestrator: "gemini-4-argon-high"
    executor: "gemini-4-hydrogen-xhigh"
    primitive: "swarm"
  opencode_v2:
    orchestrator: "opencode-go/hy4"
    executor: "opencode-go/deepseek-v4-pro"
    primitive: "subagent"
triggers:
  - "/san_transcriber"
  - "san_transcriber"
  - "transcript de relais"
  - "passation de relais"
  - "doubt and verify"
description: "Sous-skill transversal de relais sceptique multi-modèles et cross-harnais (Doubt & Verify). Compilé dans skills/san_transcriber.md pour invocation /san_transcriber et mobilisé par san_executer / san_planner avant épuisement de quota ou changement de modèle via san-framework models. Génère roadmaps/transcripts/TRANSCRIPT_<ROADMAP_SLUG>_<JJMMAAAA>.md via transcript_helper.mjs et impose à la session suivante d'auditer le terrain avant reprise."
---

# `san_transcriber` — Sous-Skill de Relais Sceptique (*Doubt & Verify*)

> **Note d'implantation architecturale :**  
> `san_transcriber` dispose d'un point d'entrée slash `/san_transcriber` ([../skills/san_transcriber.md](../skills/san_transcriber.md)) et d'un déploiement natif unifié sous `src/skills/san_transcriber/` $\rightarrow$ `.agents/skills/san_transcriber/` pour Antigravity CLI et OpenCode V2.

---

## 1. RÔLE & SYNERGIE DANS LE CYCLE DUAL-HARNESS

`san_transcriber` intervient comme **sas de transmission critique** dès qu'un orchestrateur (`Argon`, `Carbon`, `HY4`) approche sa limite de quota, bascule de modèle via `san-framework models` (`.agents/models.json`), ou passe la main entre **Antigravity (`swarm`)** et **OpenCode V2 (`subagent`)**.

Contrairement à une simple note de handoff optimiste :
1. **L'agent sortant** consigne les faits, le pourquoi, **ses doutes explicites** et l'état réel de la codebase (`git status`, `- [x]`/`- [ ]` dans `roadmaps/*.md`) via `scripts/transcript_helper.mjs`.
2. **`session_start.mjs`** détecte automatiquement le transcript récent dans `roadmaps/transcripts/` à la session suivante.
3. **L'agent entrant** applique strictement le protocole ***Doubt & Verify*** : considérer chaque affirmation du transcript comme non prouvée tant que `.agents/cache/REPO_MAP.md`, `git diff`, la roadmap réelle et les tests exécutables n'ont pas confirmé les faits.

---

## 2. PIPELINE DÉTERMINISTE (`transcript_helper.mjs` & `TRANSCRIPT_TEMPLATE.md`)

```bash
node .agents/skills/san_transcriber/scripts/transcript_helper.mjs \
  --summary="<livrables concrets>" \
  --why="<décisions et compromis techniques>" \
  --doubts="<angles morts, tests non relancés, risques>" \
  --next="<prochaines actions vérifiables>"
```

- **Sortie générée :** `roadmaps/transcripts/TRANSCRIPT_<ROADMAP_SLUG>_<JJMMAAAA>.md` (basé sur `templates/TRANSCRIPT_TEMPLATE.md`).
- **Protection Hook :** Exempté des blocages faux positifs de `stop_guard.mjs` ; les roadmaps elles-mêmes restent gérées par `archive_roadmap.sh` ([san_doc_keeper](san_doc_keeper.md)).

---

## 3. RÈGLES NON NÉGOCIABLES DU RELAIS SCEPTIQUE

1. **Doute Méthodique Systématique :** Ne jamais relancer aveuglément le plan d'un agent précédent ; vérifier d'abord la vérité du code (`read_file(StartLine, EndLine)`) et la réalité des tests (`exit 0`).
2. **Transparence des Manques :** Tout test sauté ou non ré-exécuté doit être déclaré dans la section *Zones de Doute* du transcript sortant.
3. **Continuité Dual-Harness :** Après contre-audit, l'agent entrant reprend la délégation via `swarm` (`gemini-4-hydrogen-xhigh`) ou `subagent` (`.agents/models.json`) sans jamais recourir à `invoke_subagent(Model: 'inherit')` sur `Argon`/`Carbon`.

---

## 4. RÉFÉRENCES CROISÉES

- [`../skills/san_transcriber.md`](../skills/san_transcriber.md) : Documentation maître de l'invocation `/san_transcriber`.
- [`../skills/san_executer.md`](../skills/san_executer.md) & [`../skills/san_planner.md`](../skills/san_planner.md) : Orchestrateurs consommant et émettant les transcripts de relais.
- [`san_doc_keeper.md`](san_doc_keeper.md) & [`san_subagent_manager.md`](san_subagent_manager.md) : Archivage et supervision des workers après reprise.
