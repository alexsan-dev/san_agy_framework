# GRILLE QUANTITATIVE D'ÉVALUATION SUR 40 POINTS — `san_brainstorming`

> **Module :** `san_brainstorming` (Framework Antigravity `san_*`)  
> **Fichier de Référence :** `references/ideation_scoring_matrix.md`  
> **Auteur :** Alexsan.pro  
> **Objectif :** Fournir une méthode mathématique impitoyable et déterministe d'arbitrage d'idées produit et d'options architecturales avant tout investissement en ingénierie.

---

## 1. PRINCIPES FONDAMENTAUX DE LA NOTATION

La grille de scoring repose sur un principe d'**anti-complaisance cognitive**. Elle sanctionne lourdement les mirages technologiques (idées séduisantes sur un pitch deck mais irréalisables ou inadaptées à l'économie réelle) et valorise l'efficacité de déploiement, l'ancrage local et la sobriété d'ingénierie.

L'évaluation s'effectue sur 4 piliers indépendants notés chacun de **1.0 à 10.0**. Chaque pilier applique un coefficient spécifique pour aboutir à une note globale exacte sur **40.0 points** ($100\,\%$).

$$\text{Score Global (/40)} = (\text{Impact} \times 1.0) + (\text{Faisabilité/Effort} \times 1.0) + (\text{Terrain} \times 1.2) + (\text{Risques} \times 0.8)$$

---

## 2. DÉTAIL DES 4 CRITÈRES D'ÉVALUATION

### Critère 1 : Impact Business & Valeur Utilisateur (Base 10 — Poids 1.0 — Max 10 pts)
Mesure la capacité du concept à résoudre un problème douloureux réel, à générer du chiffre d'affaires direct ou indirect, et à retenir l'utilisateur dans la durée.

| Note /10 | Niveau de Valeur | Description et Caractéristiques |
| :---: | :--- | :--- |
| **1 - 3** | **Marginal / Volatile** | *« Nice-to-have »*, problème non douloureux, absence de volonté de payer chez la cible, monétisation hypothétique par la publicité non volumétrique. |
| **4 - 6** | **Modeste / Fonctionnel** | Résout une friction réelle mais occasionnelle. Monétisation possible mais à faible marge unitaire ou volume d'acquisition incertain. |
| **7 - 8** | **Forte Différenciation** | Douleur client aiguë (gain de temps ou d'argent immédiat et prouvable). Modèle de monétisation éprouvé (commission par transaction, abonnement rentable). |
| **9 - 10** | **Essentiel / Incontournable** | Révolutionne l'économie du client ou débloque un marché verrouillé. Rétention naturelle quotidienne, effet de réseau ou dépendance opérationnelle vertueuse. |

**Questions de contrôle impitoyables :**
1. L'utilisateur est-il prêt à payer de sa poche dès le jour 1 pour ce service ?
2. En quoi cette solution est-elle 5 fois supérieure à une conversation WhatsApp informelle ?
3. Le modèle économique survit-il si les volumes initiaux sont 10 fois inférieurs aux prévisions ?

---

### Critère 2 : Faisabilité & Simplicité Technique (Base 10 — Poids 1.0 — Max 10 pts)
*Échelle inversée : Plus le projet est rapide, simple et éprouvé à construire, plus la note est élevée.* Sanctionne la dette technique prématurée, l'empilement de microservices inutiles et les dépendances R&D risquées.

| Note /10 | Niveau d'Effort | Horizon de Réalisation MVP |
| :---: | :--- | :--- |
| **1 - 2** | **R&D Complexe / Bloquant** | Projet nécessitant des mois de R&D, de l'IA complexe auto-hébergée, des flux matériels non éprouvés ou une équipe de 5 ingénieurs spécialisés. |
| **3 - 5** | **Chantier Moyen** | 2 à 4 semaines de développement full-stack, intégration de plusieurs services tiers fragiles, synchronisations d'états complexes. |
| **6 - 8** | **Intégration Agile** | Livrable en 3 à 7 jours ouvrés sur une base technique existante éprouvée (Laravel, AdonisJS, React, Tailwind). Composants standards. |
| **9 - 10** | **MVP Éclair (24h - 48h)** | Prototype fonctionnel démontrable en moins de 48 heures avec des briques logicielles déjà maîtrisées, zéro complexité superflue. |

**Questions de contrôle impitoyables :**
1. Peut-on livrer une version minimale qui tourne dès demain soir ?
2. Le système nécessite-t-il des technologies non maîtrisées par le développeur ?
3. Combien de points de défaillance unique (SPOF) cette architecture introduit-elle ?

---

### Critère 3 : Réalité Terrain & Résilience Opérationnelle (Base 10 — Poids 1.2 — Max 12 pts)
*Le cœur de l'arbitrage Antigravity.* Évalue l'adéquation au contexte réel d'usage selon le `PROJECT_PROFILE` sélectionné :
- **Profil `emerging_market` :** Connectivité 3G/EDGE instable, terminaux Android d'entrée de gamme (1-2 Go RAM), culture WhatsApp et monétisation par Mobile Money (MTN MoMo, Airtel).
- **Profils `global_saas` / `mobile_consumer` / `cli_devtools` / `api_platform` :** Friction d'adoption, résistance au changement des utilisateurs, compatibilité environnementale (OS, runtimes, quotas API) et robustesse aux coupures réseau ou timeouts.

| Note /10 | Adéquation Terrain | Profil et Contraintes Supportées |
| :---: | :--- | :--- |
| **1 - 3** | **Inadapté / Hors-Sol** | Exige une connexion 4G/Fibre ininterrompue, carte bancaire Visa/Mastercard obligatoire, téléchargement lourd (> 30 Mo), formulaires longs à remplir. |
| **4 - 6** | **Fragile sous Dégradation** | Fonctionne en conditions nominales mais plante dès que le réseau bascule en 2G/EDGE ou lors d'un timeout de webhook Mobile Money. |
| **7 - 8** | **Résilient & Pragmatique** | Optimisé pour smartphones Android d'entrée de gamme (2 Go RAM), payload client compact (< 300 Ko), tolérance aux coupures réseau, Mobile Money natif. |
| **9 - 10** | **Enraciné Culturellement** | Intégré aux réflexes naturels locaux (WhatsApp, vocal, repères géographiques sans numéro de rue, push USSD 1-clic, modèle data-light). |

**Points de contrôle Afrique / Marchés Émergents :**
- **Data & Connectivité :** L'application fonctionne-t-elle avec un forfait data prépayé épuisé ou sous 3G instable (perte de paquets > 15 %, ping > 300 ms) ?
- **Moyens de Paiement :** Intégration native des flux USSD / STK Push (Airtel Money, MTN MoMo, Orange Money) avec confirmation asynchrone sécurisée par webhook ?
- **Parc Matériel :** Consommation mémoire RAM < 150 Mo, bundle JS initial < 300 Ko, tolérance au tueur de processus Android Go (HiOS, XOS) ?
- **Ergonomie Locale :** Navigation assistée par repères visuels, support des notes vocales, zéro jargon abstrait ?

---

### Critère 4 : Maîtrise des Risques & Réglementation (Base 10 — Poids 0.8 — Max 8 pts)
*Échelle inversée : Plus le risque est maîtrisé et l'architecture souveraine, plus la note est élevée.* Évalue les dépendances critiques, la sécurité des transactions et la conformité légale/réglementaire.

| Note /10 | Niveau de Vulnérabilité | Profil de Risque |
| :---: | :--- | :--- |
| **1 - 2** | **Risque Critique / Bloquant** | Dépendance totale à une API non officielle, conservation de fonds sans agrément bancaire (BEAC/BCEAO/COBAC), risque pénal ou de bannissement store imminent. |
| **3 - 5** | **Vulnérabilité Élevée** | Dépendance à un agrégateur unique sans fallback, risque de suspension d'accès WhatsApp Meta Cloud, conformité RGPD/APDP floue. |
| **6 - 8** | **Risque Maîtrisé** | APIs documentées et pérennes, agrégateur déclaré, architecture à double passerelle de secours, données sensibles chiffrées. |
| **9 - 10** | **Souveraineté & Sécurité Totale** | Zéro dépendance opaque, conformité légale irréprochable, tolérance aux pannes externes, contrôle total du code source et des données. |

**Questions de contrôle impitoyables :**
1. Que se passe-t-il si l'agrégateur Mobile Money tombe en panne pendant 4 heures ?
2. Stockons-nous des fonds d'usagers en violation des directives bancaires de la BEAC ou de la BCEAO ?
3. Quelle est la probabilité d'une suspension de compte par Meta, Google Play ou Apple ?

---

## 3. PONDÉRATION ET FORMULE DE CALCUL DÉTERMINISTE

Le calcul applique rigoureusement les pondérations contractuelles :

```
Score Global = (Impact * 1.0) + (Effort * 1.0) + (Terrain * 1.2) + (Risques * 0.8)
Score Pourcentage = (Score Global / 40.0) * 100
```

### Exemple de Calcul Chiffré :
- Impact Business : **8.5 / 10** $\times 1.0 = 8.50$
- Faisabilité / Effort : **8.0 / 10** $\times 1.0 = 8.00$
- Réalité Terrain : **9.0 / 10** $\times 1.2 = 10.80$
- Risques & Dépendances : **8.0 / 10** $\times 0.8 = 6.40$
- **Total Global :** $8.50 + 8.00 + 10.80 + 6.40 = \mathbf{33.70 / 40.0}$ ($84.3\,\%$)

---

## 4. SEUILS D'ARBITRAGE ET CLAUSES D'ÉLIMINATION DIRECTE

### 4.1 Clauses d'Élimination Directe (Disqualification Immédiate)
Avant tout calcul de moyenne ou de score total, les deux clauses de veto suivantes sont testées. Si l'une d'elles est déclenchée, l'option est disqualifiée avec la mention **NO-GO ABSOLU** :

> [!CAUTION]
> **CLAUSE ÉLIMINATOIRE 1 (Veto Terrain) :**  
> Si la note **Terrain $< 4.0 / 10$**, l'idée est rejetée immédiatement.  
> *Motif : Un produit incapable de fonctionner dans la réalité physique et économique de sa cible est voué à l'échec, quelle que soit son élégance technique.*

> [!CAUTION]
> **CLAUSE ÉLIMINATOIRE 2 (Veto Risques & Légalité) :**  
> Si la note **Risques $< 3.0 / 10$**, l'idée est rejetée immédiatement.  
> *Motif : Un projet reposant sur une illégalité bancaire ou une dépendance technique incontrôlable expose l'entreprise à la fermeture.*

---

### 4.2 Barème d'Arbitrage Final

| Score Global (/40) | Pourcentage | Verdict Officiel | Décision Opérationnelle |
| :---: | :---: | :---: | :--- |
| **$\ge 32.0$** | **$\ge 80.0\,\%$** | **GO MVP PRIORITAIRE** | **Validation immédiate.** Passage direct à `san_planner` pour écriture de la roadmap. |
| **$28.0$ à $31.9$** | **$70.0\,\%$ à $79.9\,\%$** | **GO MVP CONDITIONNEL / ITÉRATION** | **Admissible sous réserve.** Doit subir une simplification de scope ou une réduction des risques avant engagement. |
| **$< 28.0$** | **$< 70.0\,\%$** | **REJET RATIONNEL (NO-GO)** | **Piste écartée.** L'effort d'ingénierie et les risques dépassent les retours attendus. |

---

## 5. ALGORITHME DE CALCUL DÉTERMINISTE (PSEUDO-CODE)

```python
def evaluer_option(impact: float, effort: float, terrain: float, risques: float) -> dict:
    assert 1.0 <= impact <= 10.0
    assert 1.0 <= effort <= 10.0
    assert 1.0 <= terrain <= 10.0
    assert 1.0 <= risques <= 10.0

    # 1. Vérification des clauses d'élimination directe
    exclusions = []
    if terrain < 4.0:
        exclusions.append("ÉCHEC CRITIQUE TERRAIN : Note < 4.0/10. Solution inadaptée au contexte physique/économique.")
    if risques < 3.0:
        exclusions.append("ÉCHEC CRITIQUE RISQUES : Note < 3.0/10. Vulnérabilité légale, financière ou dépendance toxique.")

    # 2. Calcul du score pondéré
    score = (impact * 1.0) + (effort * 1.0) + (terrain * 1.2) + (risques * 0.8)
    pourcentage = (score / 40.0) * 100.0

    # 3. Verdict
    if exclusions:
        verdict = "REJETÉ (NO-GO ABSOLU)"
        statut = "NO_GO"
    elif score >= 32.0:
        verdict = "GO MVP VALIDÉ (PRIORITÉ HAUTE)"
        statut = "GO_MVP_PRIORITAIRE"
    elif score >= 28.0:
        verdict = "GO MVP CONDITIONNEL (ITÉRATION TECHNIQUE)"
        statut = "GO_CONDITIONNEL"
    else:
        verdict = "REJETÉ (SCORE INSUFFISANT < 28/40)"
        statut = "REJET"

    return {
        "score_40": round(score, 2),
        "pourcentage": round(pourcentage, 1),
        "verdict": verdict,
        "statut": statut,
        "exclusions": exclusions
    }
```

---

## 6. UTILISATION DU SCRIPT CLI DÉTERMINISTE

Le script `scripts/score_idea.py` est fourni pour évaluer automatiquement n'importe quelle option en ligne de commande ou dans un pipeline CI :

```bash
# Exemple 1 : Évaluation en profil emerging_market
python3 src/skills/san_brainstorming/scripts/score_idea.py --profile emerging_market --impact 8.5 --effort 8.0 --terrain 9.0 --risques 8.0

# Exemple 2 : Évaluation d'une CLI devtools (sans veto 3G absurde)
python3 src/skills/san_brainstorming/scripts/score_idea.py --profile cli_devtools --impact 9.0 --effort 8.5 --terrain 8.0 --risques 8.5

# Exemple 3 : Sortie JSON pour transmission programmatique vers san_planner
python3 src/skills/san_brainstorming/scripts/score_idea.py --profile global_saas --impact 8.5 --effort 8.0 --terrain 8.0 --risques 8.0 --json
```
