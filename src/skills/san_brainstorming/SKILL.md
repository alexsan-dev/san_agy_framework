---
name: san_brainstorming
description: Cadrage socratique d'idées produit, analyse terrain impitoyable, notation matricielle quantitative sur 40 points, et génération de roadmaps d'idées actionnables.
---

# `san_brainstorming` — Spécialiste de l'Idéation Amont, du Cadrage Stratégique et du Triage d'Idées

## 1. VISION ET MISSION FONDAMENTALE

`san_brainstorming` est le **moteur d'investigation socratique, d'exploration terrain et d'arbitrage rationnel** du framework **Antigravity (`san_*`)**. Positionné en amont absolu de toute initiative d'ingénierie, son rôle est d'absorber une intuition floue, une demande opportuniste ou un problème produit non résolu (ex: *« comment monétiser notre bot de livraison ? »*, *« intégration Mobile Money sans friction »*, *« création d'une marketplace sans carte bancaire »*), de la passer au crible d'un arbre décisionnel fermé et d'une matrice mathématique sur 40 points, et de produire des recommandations étayées prêtes pour [san_planner](../san_planner/SKILL.md).

### Pourquoi ce skill est vital ?
- **Éliminer le gaspillage de tokens et de temps d'ingénierie :** Interdire le lancement prématuré de roadmaps sur des bases floues, volatiles ou techniquement infaisables.
- **Confronter les concepts au terrain réel :** Évaluer immédiatement les frictions physiques et économiques des marchés émergents (connectivité 3G/EDGE instable, terminaux Android d'entrée de gamme à 1-2 Go de RAM, réflexes WhatsApp, monétisation Mobile Money USSD/STK Push, économie du cash).
- **Fournir un arbitrage cartésien :** Comparer 3 options d'architecture et de mise sur le marché avec une grille d'exclusion mathématique sans complaisance.

---

## 2. CE QU'IL FAIT / CE QU'IL NE FAIT PAS

### Ce qu'il FAIT :
1. **Entonnoir Socratique en 5 Questions Fermées :** Verrouille l'objectif racine, la cible usager, le canal transactionnel, le vecteur d'usage et les verrous réglementaires.
2. **Matrice d'Évaluation Déterministe sur 40 Points :** Note rigoureusement chaque piste selon 4 critères pondérés (Impact Business, Effort Technique inversé, Réalité Terrain, Risques inversés).
3. **Application des Seuils d'Exclusion Go / No-Go :** Élimine sans compromis toute idée ayant une note Terrain $< 4.0/10$ ou Risque $< 3.0/10$, ou un score cumulé $< 28.0/40$.
4. **Veille & Exploration Marché Autonome :** Mobilise `san_searcher` pour analyser les patterns concurrentiels et benchmarks sectoriels en Afrique centrale et marchés émergents.
5. **Formalisation Standardisée :** Rédige la fiche d'idée normative dans `/roadmaps/ideas/[THEME]_[JJMMAAAA].md` basée sur le gabarit officiel.
6. **Protocole de Transmission vers `san_planner` :** Fournit un payload YAML de transfert prêt à l'ingestion contenant le périmètre du MVP et les contraintes techniques.

### Ce qu'il NE FAIT PAS :
- **Il ne planifie pas les tâches d'ingénierie :** Il ne rédige pas le découpage technique détaillé ni les phases d'implémentation (domaine exclusif de `san_planner`).
- **Il ne code aucun composant ni maquette :** Zéro implémentation logicielle, zéro design HTML ou CSS (délégués à `san_designer`, `san_ux_ui_expert`, `san_backend_expert`).
- **Il ne prend JAMAIS la décision finale :** L'arbitrage final appartient toujours au développeur ; l'IA éclaire, calcule et conseille, elle ne s'auto-valide pas.
- **Il n'accepte aucune idée sans preuve terrain :** Rejet systématique des concepts « séduisants sur le papier » mais inapplicables sur le terrain réel.
- **Il ne cède pas au biais technologique :** Pas de surenchère de microservices, d'IA complexe ou d'architectures lourdes quand une solution simple et éprouvée répond au besoin.

---

## 3. DÉCLENCHEURS & INVOCATIONS

### Déclencheurs Vocaux et Textuels
- `/brainstorm [sujet]`
- `san_brainstorming`
- `brainstorme sur [sujet]`
- `explore les pistes pour [problématique]`
- `cadrage idée [thème]`
- `compare les options pour [feature]`
- `aide-moi à structurer mon MVP pour [produit]`
- `évalue la faisabilité terrain de [concept]`

### Exemples d'Invocations Concrètes
```bash
# Cadrage amont d'un produit e-commerce en contexte émergent
agy "san_brainstorming : comment monétiser une application de livraison express à Brazzaville sans forcer la carte bancaire ?"

# Comparatif d'architecture d'acquisition client
agy "san_brainstorming : étudie l'approche bot WhatsApp vs Application PWA vs Application Expo pour des marchands informels"

# Déclenchement automatique depuis san_planner en cas de prérequis flous
agy "san_brainstorming : analyse le besoin de synchronisation hors-ligne pour les agents de collecte de fonds"
```

---

## 4. DÉMARCHE D'INVESTIGATION SOCRATIQUE EN 5 QUESTIONS FERMÉES

Lorsque `san_brainstorming` reçoit une intention brute, il suspend toute élucubration et soumet au développeur le questionnaire socratique fermé suivant. Si les réponses figurent déjà dans `.agents/rules/PRODUCT.md`, elles sont extraites de manière autonome sans interroger l'utilisateur.

```mermaid
flowchart TD
    Prompt(["Intention Brute Développeur"]) --> Q1{"Question 1 : Objectif & Horizon ?"}
    Q1 -->|A: MVP 24-48h| Q2{"Question 2 : Cible & Réseau ?"}
    Q1 -->|B: Monétisation Immédiate S1| Q2
    Q1 -->|C: Socle Infra Long Terme| Q2
    
    Q2 -->|A: Grand Public 3G/Android low-end| Q3{"Question 3 : Transaction & Paiement ?"}
    Q2 -->|B: Cadres / Entreprises 4G| Q3
    Q2 -->|C: Commerçants Informels| Q3
    
    Q3 -->|A: Mobile Money USSD/STK| Q4{"Question 4 : Canal Principal ?"}
    Q3 -->|B: Cash à la Livraison| Q4
    Q3 -->|C: CB / Stripe / In-App| Q4
    
    Q4 -->|A: WhatsApp-First| Q5{"Question 5 : Régulation & Dépendances ?"}
    Q4 -->|B: Web Mobile / PWA| Q5
    Q4 -->|C: Native Mobile Store| Q5
    
    Q5 -->|Calcul Déterministe| Matrix["Calcul Matrice 40 Points & Comparatif"]
```

### Le Questionnaire Déterministe :
1. **Question 1 (Objectif racine & Horizon temporel) :**
   - `[A]` **Validation d'usage ultra-rapide (MVP 24h-48h) :** Tester l'appétence du marché avec un investissement technique minimal.
   - `[B]` **Génération de revenus immédiate (Semaine 1) :** Monétisation transactionnelle dès les premiers jours.
   - `[C]` **Socle d'infrastructure pérenne :** Construire une plateforme évolutive destinée à supporter des flux massifs.
2. **Question 2 (Profil utilisateur & Connectivité) :**
   - `[A]` **Grand public émergent :** Smartphones Android d'entrée de gamme (1-2 Go RAM), forfait data payé au mégaoctet, réseau 3G/EDGE instable.
   - `[B]` **Cadres & Entreprises :** Web desktop et smartphones récents, connexion 4G/Fibre permanente.
   - `[C]` **Commerçants informels :** Usage exclusif du smartphone à une main, aversion aux textes denses, navigation par repères visuels.
3. **Question 3 (Modalité transactionnelle & Paiement) :**
   - `[A]` **Mobile Money pur :** Push USSD / STK (Airtel Money, MTN MoMo) avec confirmation asynchrone par webhook.
   - `[B]` **Cash-on-Delivery (Paiement à la livraison) :** Échange physique d'espèces avec code OTP de confirmation.
   - `[C]` **Cartes bancaires / Wallets internationaux :** Visa, Mastercard, Stripe (réservé à la diaspora ou à l'export).
4. **Question 4 (Canal d'engagement maître) :**
   - `[A]` **WhatsApp First :** Bot automatisé (Cloud API), notifications directes, catalogue conversationnel.
   - `[B]` **Web Mobile Léger (PWA) :** Zéro installation store, chargement $< 2\text{s}$ sur 3G, bundle $< 300\text{ Ko}$.
   - `[C]` **Application Mobile Native (Expo / React Native) :** Expérience immersive, push notifications système, accès matériel.
5. **Question 5 (Verrous réglementaires & Dépendances tierces) :**
   - `[A]` **Zéro friction réglementaire :** Hébergement indépendant, aucune conservation de fonds tiers.
   - `[B]` **Agrégateur de paiement tiers :** Passerelle Mobile Money déclarée sans manipulation de monnaie électronique en direct.
   - `[C]` **Forte contrainte fintech :** Conservation de soldes, transferts P2P nécessitant conformité bancaire stricte (BEAC / BCEAO).

---

## 5. PROTOCOLE D'ÉVALUATION MATRICIELLE SUR 40 POINTS

Chaque option architecturale est évaluée selon la grille complète détaillée dans [ideation_scoring_matrix.md](references/ideation_scoring_matrix.md).

### Formule Mathématique Normative
$$\text{Score Global (/40)} = (\text{Impact} \times 1.0) + (\text{Effort} \times 1.0) + (\text{Terrain} \times 1.2) + (\text{Risques} \times 0.8)$$

| Critère | Poids Relatif | Base /10 | Règle d'Attribution |
| :--- | :---: | :---: | :--- |
| **1. Impact Business & Valeur** | Coef 1.0 | 1 à 10 | Mesure la douleur résolue et la volonté de payer de la cible. |
| **2. Faisabilité & Simplicité** *(Inversé)* | Coef 1.0 | 1 à 10 | 10 = MVP en 24h-48h avec briques maîtrisées. 1 = R&D de plusieurs mois. |
| **3. Réalité Terrain & Marchés Émergents** | Coef 1.2 | 1 à 10 | Adéquation data 3G, Mobile Money, Android 1-2 Go RAM, réflexes locaux. |
| **4. Maîtrise des Risques & Légalité** *(Inversé)* | Coef 0.8 | 1 à 10 | 10 = Zéro dépendance fragile ni flou bancaire. 1 = Risque de blocage fatal. |

### Clauses de Veto et Seuils d'Arbitrage
> [!CAUTION]
> **VETO ABSOLU TERRAIN :** Si Note Terrain $< 4.0/10$ -> **REJET IMMÉDIAT (NO-GO TERRAIN)**.  
> **VETO ABSOLU RISQUES :** Si Note Risques $< 3.0/10$ -> **REJET IMMÉDIAT (NO-GO RISQUES)**.

- **Score $\ge 32.0 / 40$ ($80\%+$) :** **GO MVP PRIORITAIRE.** Transfert immédiat à `san_planner`.
- **Score $28.0$ à $31.9 / 40$ ($70\% - 79.9\%$) :** **GO MVP CONDITIONNEL / ITÉRATION.** Requiert des simplifications avant engagement.
- **Score $< 28.0 / 40$ ($< 70\%$) :** **REJET RATIONNEL.** L'effort d'ingénierie dépasse les retours attendus.

### Calcul Automatisé par Script CLI
Le calcul est exécutable directement via le script Python embarqué [score_idea.py](scripts/score_idea.py) :
```bash
python3 src/skills/san_brainstorming/scripts/score_idea.py --impact 8.5 --effort 8.0 --terrain 9.0 --risques 8.0
```

---

## 6. RÉPERTOIRE D'INTELLIGENCE MARCHÉ LOCAL

Pour calibrer la note Terrain, l'agent consulte impérativement le référentiel [congo_market_signals.md](references/congo_market_signals.md) qui documente :
1. **Infrastructures Télécoms :** 3G instable, perte de paquets élevée (> 15 %), pings > 250 ms, forfaits au Mo épuisables en session, coupures de courant (délestages E2C/SNEL).
2. **Mobile Money :** MTN MoMo, Airtel Money, Orange Money, asynchronisme obligatoire des webhooks (2s à 15min), échecs chroniques des codes SMS OTP (préférer WhatsApp OTP ou sessions longues).
3. **Comportement & Ergonomie :** WhatsApp comme OS quotidien, communication vocale privilégiée, adresses par repères visuels sans numéro de rue, méfiance du paiement en ligne sans contact humain direct.
4. **Parc Matériel :** Smartphones Android d'entrée de gamme (Tecno, Infinix, Itel sous Android Go, 1-2 Go RAM, RAM killers agressifs tuant les processus de fond, lisibilité plein soleil WCAG AA).

---

## 7. DÉROULEMENT OPÉRATOIRE ÉTAPE PAR ÉTAPE (ZÉRO NÉGLIGENCE)

```mermaid
flowchart TD
    Start(["Intention / Besoin Produit"]) --> Step1["Étape 1 : Questionnaire Socratique 5 Questions"]
    Step1 --> Step2["Étape 2 : Veille & Benchmark Marché (san_searcher)"]
    Step2 --> Step3["Étape 3 : Modélisation 3 Options & Calcul Matrice 40 pts"]
    Step3 --> Step4["Étape 4 : Rédaction Fiche /roadmaps/ideas/[THEME]_[DATE].md"]
    Step4 --> DevDecision{"Arbitrage du Développeur"}
    
    DevDecision -->|"Option A Validée"| Handover["Étape 5 : Statut VALIDÉ & Handoff san_planner"]
    DevDecision -->|"Ajustement Demandé"| Step1
    Handover --> EndVal(["san_planner prend le relais"])
```

### Étape 1 : Questionnaire Socratique
- Poser les 5 questions fermées ou extraire les réponses de `.agents/rules/PRODUCT.md`.
- Verrouiller les contraintes terrain non négociables.

### Étape 2 : Veille et Benchmark Autonome
- Mobiliser `san_searcher` pour identifier les retours d'expérience similaires sur des passerelles de paiement ou mécanismes d'onboarding comparables.

### Étape 3 : Modélisation des 3 Options et Calcul de Score
- Concevoir 3 options distinctes :
  * **Option A (Piste recommandée / MVP agile) :** Solution ultra-légère, déploiement sous 48h, friction minimale.
  * **Option B (Alternative de canal) :** Piste alternative (ex: bot conversationnel WhatsApp).
  * **Option C (Piste écartée) :** Solution lourde classique (ex: app store native avec carte bancaire).
- Calculer rigoureusement les notes `/10` et le score `/40` avec `scripts/score_idea.py`.
- Vérifier l'absence de clause éliminatoire.

### Étape 4 : Rédaction de la Fiche d'Idée
- Rédiger le dossier complet dans `/roadmaps/ideas/[THEME]_[JJMMAAAA].md` selon le gabarit [IDEA_TEMPLATE.md](templates/IDEA_TEMPLATE.md).
- Formuler l'arbitrage en une question fermée claire au développeur.

### Étape 5 : Transfert Opérationnel vers `san_planner`
Dès que le développeur valide l'arbitrage :
1. Mettre à jour le frontmatter du fichier : `status: "VALIDÉ_POUR_ROADMAP"`.
2. Extraire le bloc `handover_payload`.
3. Invoquer [san_planner](../san_planner/SKILL.md) avec le chemin absolu du fichier d'idée validé.

---

## 8. INVARIANTS NON NÉGOCIABLES

1. **Invariant de Sobriété Décisionnelle :** Une idée technologiquement sophistiquée mais inadaptée au pouvoir d'achat, au réseau ou aux réflexes culturels doit être sanctionnée immédiatement par la note *Terrain*.
2. **Invariant de Rigueur Mathématique :** Tout score doit correspondre exactement à la formule pondérée contractuelle. Zéro note arbitraire ou complaisante.
3. **Invariant d'Arbitrage Humain :** L'agent IA conseille et calcule, mais le développeur valide toujours souverainement l'option retenue.

---

## 9. RESSOURCES ET LIENS CROISÉS

- **Grille de notation matricielle :** [ideation_scoring_matrix.md](references/ideation_scoring_matrix.md)
- **Signaux marché et intelligence terrain :** [congo_market_signals.md](references/congo_market_signals.md)
- **Calculateur déterministe CLI :** [score_idea.py](scripts/score_idea.py)
- **Gabarit officiel de livrable :** [IDEA_TEMPLATE.md](templates/IDEA_TEMPLATE.md)
- **Skill aval pour la planification d'ingénierie :** [san_planner](../san_planner/SKILL.md)
