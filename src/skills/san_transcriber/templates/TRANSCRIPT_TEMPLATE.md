# TRANSCRIPT DE RELAIS SCEPTIQUE : {{ROADMAP_TITLE}}

> **Date de génération :** {{DATE_DISPLAY}} (`{{TIMESTAMP_ISO}}`)  
> **Harnais / Modèle sortant :** {{OUTGOING_HARNESS_MODEL}}  
> **Roadmaps actives associées :** {{ACTIVE_ROADMAPS_LIST}}  
> **Progression constatée (`- [x]` / `- [ ]`) :** {{PROGRESS_SUMMARY}}  
> **État Git courant :** {{GIT_BRANCH_INFO}}

---

## 1. CE QUI A ÉTÉ ACCOMPLI, COMMENT ET POURQUOI (DÉCISIONS & COMPROMIS)

### Travaux déclarés par l'agent sortant
{{SUMMARY_SECTION}}

### Décisions techniques, compromis & justifications (`--why`)
{{WHY_SECTION}}

### Preuves Git locales constatées automatiquement
**`git status --short` :**
```text
{{GIT_STATUS_SHORT}}
```

**5 derniers commits (`git log -n 5 --oneline`) :**
```text
{{GIT_LOG_ONELINE}}
```

---

## 2. ZONES DE DOUTE, HYPOTHÈSES FRAGILES & RACCOURCIS POTENTIELS (AUTO-CRITIQUE)

{{DOUBTS_SECTION}}

---

## 3. PROTOCOLE DE RELAIS SCEPTIQUE (*DOUBT & VERIFY* — POUR L'AGENT ENTRANT)

> [!CAUTION]
> **NE FAIS PAS CONFIANCE AVEUGLÉMENT AU PREMIER AGENT :**  
> Ce transcript n'est **pas** une vérité certifiée ni une feuille d'ordres à exécuter mécaniquement. L'agent sortant approchait sa limite de quota ou changeait de harnais ; ses résumés peuvent contenir des angles morts, du *testing theater*, des suppositions périmées ou des chemins sous-optimaux.

Avant d'écrire une seule ligne de code ou de cocher `- [x]`, l'agent entrant DOIT exécuter ces 5 contrôles sceptiques :
1. **Lire la carte réelle :** Consulter `.agents/cache/REPO_MAP.md` et relire directement les roadmaps actives listées en en-tête.
2. **Auditer le diff réel :** Exécuter `git status --short` et `git diff` pour vérifier ce qui a réellement été modifié par rapport à ce que l'agent sortant prétend avoir fait.
3. **Rejouer les tests réels :** Exécuter la suite de tests et Quality Gates sur le code présent (ne jamais supposer qu'un test passé plus tôt passe encore).
4. **Challenger les hypothèses fragiles :** Examiner la Section 2 ci-dessus ; si une décision ou un raccourci de l'agent sortant est bancal, le corriger ou choisir une meilleure architecture.
5. **Recalculer le chemin critique :** Vérifier l'ordre optimal des tâches `- [ ]` restantes et aligner avec l'utilisateur (`ask_question` / `question`) en cas d'ambiguïté produit/UI.

---

## 4. CE QUI RESTE À ACCOMPLIR

### Synthèse transmise (`--next`)
{{NEXT_SECTION}}

### Inventaire brut des roadmaps actives & cases restantes (`- [ ]`)
{{ROADMAPS_INVENTORY}}
