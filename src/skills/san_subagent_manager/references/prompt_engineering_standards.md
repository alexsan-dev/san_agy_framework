# STANDARDS DE RÉDACTION HERMÉTIQUE DE PROMPTS SYSTÈME
# Framework Antigravity (`san_*`) — Moteur `san_subagent_manager`

Un sous-agent Antigravity est une unité de calcul isolée. La qualité de son exécution dépend directement de la rigueur mathématique du prompt système injecté. Tout flou d'instruction engendre des hallucinations, des modifications de fichiers parasites et une surconsommation de tokens.

---

## 1. LA STRUCTURE EN 6 SECTIONS DIRECTIVES OBLIGATOIRES

Tout prompt système calibré pour un sous-agent doit impérativement comporter les 6 sections normatives suivantes :

1. **`ROLE` :** Identité précise (2 à 5 mots), spécialité technologique et rattachement au framework Antigravity (`san_*`). Mention formelle du `conversationId` parent pour le retour.
2. **`MISSION` :** But unique, délimité et non ambigu. Énonciation de la condition d'arrêt immédiate.
3. **`INPUTS` :** Chemins absolus ou URIs `file:///` des fichiers d'entrée et règles autorisées. Interdiction formelle de scanner d'autres répertoires.
4. **`OUTPUTS` :** Liste fermée et exhaustive des fichiers cibles créés ou modifiés.
5. **`CONSTRAINTS` :** Garde-fous inviolables : interdiction de toucher hors périmètre, interdiction d'inventer des dépendances, interdiction formelle d'appeler des outils récursifs (`invoke_subagent`, `define_subagent`), interdiction de polling.
6. **`VALIDATION_COMMAND & REDDITION` :** Commande de test binaire exécutable (`run_command`), suivie de l'obligation absolue d'appeler `send_message(Recipient: parent_id, Message: schema)` avec statuts normés (`SUCCÈS_TOTAL`, `ÉCHEC_PARTIEL`, `BLOCAGE`).

---

## 2. LES 5 RÈGLES ANTI-HALLUCINATION DU FRAMEWORK

### Règle 1 : Chemins Fichiers Absolus Déterministes
- **À Proscrire :** *"Regarde dans le dossier components et modifie le bouton."*
- **Obligatoire :** `file:////home/alexsan-dev/PROJECTS/app/src/components/ui/PrimaryButton.tsx`

### Règle 2 : Dépendances Fixées sur Manifestes Locaux
- Le prompt doit formellement interdire l'importation de packages qui ne figurent pas dans `package.json` ou `composer.json`. L'agent ne doit jamais inventer une fonction utilitaire issue d'une librairie tierce non installée.

### Règle 3 : Preuve par le Code (Proof-Backed Delivery)
- L'agent ne peut prétendre avoir achevé sa tâche sans fournir le résultat textuel exact d'une commande de validation (`npm test`, `php artisan test`, etc.) montrant 0 échec.

### Règle 4 : Interdiction de Récursion Sauvage
- Tout sous-agent a pour interdiction d'invoquer un autre sous-agent. Seul le niveau d'orchestration maître possède la vision globale et la capacité de déléguer.

### Règle 5 : Communication Unilatérale par `send_message`
- Le sous-agent ne doit pas échanger de bavardages inutiles. Sa conclusion de mission se matérialise par un unique appel à `send_message` contenant la fiche de statut normée.
