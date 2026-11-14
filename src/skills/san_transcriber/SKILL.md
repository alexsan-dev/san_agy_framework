---
name: san_transcriber
description: Déclenché via /san_transcriber à l'approche d'une limite de quota (Antigravity ou OpenCode) ou avant un changement de modèle/harnais pour générer un transcript de relais sceptique dans roadmaps/transcripts/.
---

# `san_transcriber` — Relais Sceptique de Fin de Quota (*Doubt & Verify*)

Ce runbook impératif régit la passation de relais entre deux sessions d'agents (changement de modèle, bascule Antigravity $\leftrightarrow$ OpenCode V2, ou approche d'épuisement de quota). Son but n'est **jamais** de dicter aveuglément la suite à l'agent entrant, mais de lui transmettre le contexte **et** de le forcer à douter et vérifier le terrain par lui-même.

---

## Quand déclencher `/san_transcriber`

1. Lorsque le quota du modèle courant (`Argon`, `Carbon`, `HY4`, etc.) approche de sa limite.
2. Avant un changement de modèle ou de harnais (`san-framework models`, bascule `agy` $\leftrightarrow$ `opencode`).
3. Lors d'une mise en pause d'un chantier multi-phases sur `roadmaps/*.md`.

---

## Protocole de Génération du Transcript (Agent Sortant)

### Étape 1 : Auto-Critique Lucide & Collecte des Faits
1. Consulter les roadmaps actives (`roadmaps/*.md`) et l'état réel (`git status --short`, tests exécutés ou non).
2. Identifier honnêtement :
   - **Ce qui a été accompli, comment et pourquoi** (décisions techniques, compromis).
   - **Zones de doute & hypothèses fragiles** : tests non relancés, raccourcis pris, cas limites non couverts, fichiers non inspectés.
   - **Ce qui reste à accomplir** sans prétendre que ce qui n'est pas prouvé fonctionne.

### Étape 2 : Génération Déterministe via `transcript_helper.mjs`
Exécuter le script [transcript_helper.mjs](scripts/transcript_helper.mjs) basé sur le gabarit [TRANSCRIPT_TEMPLATE.md](templates/TRANSCRIPT_TEMPLATE.md) :

```bash
node .agents/skills/san_transcriber/scripts/transcript_helper.mjs \
  --summary="Modules implémentés et tests exécutés" \
  --why="Choix d'architecture et compromis retenus" \
  --doubts="Hypothèses fragiles, tests manquants ou zones non vérifiées" \
  --next="Tâches critiques restantes sur la roadmap"
```

*(Dans le dépôt source du framework, le chemin équivalent est `src/skills/san_transcriber/scripts/transcript_helper.mjs`.)*

- Le script inspecte automatiquement les roadmaps actives dans `roadmaps/*.md` (comptage `- [x]` / `- [ ]`), `git status --short` et les 5 derniers commits (`git log -n 5 --oneline`).
- Il génère le fichier `roadmaps/transcripts/TRANSCRIPT_<ROADMAP_SLUG>_<JJMMAAAA>.md` et affiche son chemin exact.
- Au démarrage de la session suivante, `session_start.mjs` détecte automatiquement le transcript récent dans `roadmaps/transcripts/` et injecte l'alerte de relais sceptique.

---

## Protocole de Relais Sceptique (*Doubt & Verify* — Agent Entrant)

> [!CAUTION]
> **RÈGLE D'OR DU RELAIS SCEPTIQUE :**  
> Le transcript de l'agent sortant est une **hypothèse de départ non fiable**, jamais un ordre aveugle. L'agent entrant doit **douter** de chaque affirmation du premier agent et tracer sa propre voie pour achever la roadmap.

Dès qu'un `Active Relay Transcript` est annoncé par `session_start.mjs` :
1. **Lire le transcript comme un suspect, pas comme un patron :** Repérer les zones de doute (Section 2) et les affirmations non prouvées.
2. **Inspecter `.agents/cache/REPO_MAP.md` & la roadmap réelle :** Relire directement la roadmap active (`roadmaps/*.md`) pour constater l'état exact des `- [x]` et `- [ ]`.
3. **Auditer le code réel (`git diff` & `git status`) :** Vérifier que les fichiers prétendument livrés existent, sont propres et conformes aux contrats.
4. **Exécuter les tests réels :** Relancer les suites de tests et Quality Gates pour confirmer qu'il n'y a ni régression ni *testing theater*.
5. **Rechallenger le chemin restant :** Si l'approche de l'agent sortant est sous-optimale ou fragile, l'améliorer ou pivoter avant de reprendre l'exécution Dual-Harness (`swarm` sous Antigravity | `subagent` sous OpenCode V2).

---

## Invariants Non Négociables
1. **Zéro Complaisance :** Ne jamais cocher `- [x]` ou reprendre un plan sans preuve directe dans le code et les tests.
2. **Traçabilité Roadmap :** Tout transcript reste relié aux roadmaps actives dans `roadmaps/transcripts/`.
3. **Zéro Faux Positif `stop_guard` :** Les fichiers `roadmaps/transcripts/*.md` sont exemptés de blocage par `stop_guard.mjs`.
