---
id: IDEA-{{THEME}}-{{DATE}}
theme: "{{THEME}}"
date: "{{DATE_FR}}" # Format : JJ/MM/AAAA
author: "Alexsan.pro via Antigravity san_brainstorming"
status: "PROPOSÉ" # Valeurs : PROPOSÉ | VALIDÉ_POUR_ROADMAP | EN_SUSPENS | REJETÉ
selected_option: "Option A"
global_score_40: 00.0 # Score calculé sur 40 points
go_no_go_verdict: "GO_MVP_VALIDÉ" # Valeurs : GO_MVP_VALIDÉ | EN_SUSPENS | REJETÉ
target_handover_skill: "san_planner"
---

# DOSSIER D'IDÉATION & CADRAGE STRATÉGIQUE — {{THEME}}

> **Fichier :** `/roadmaps/ideas/{{THEME}}_{{DATE_COMPACT}}.md`  
> **Date d'arbitrage :** {{DATE_FR}}  
> **Statut :** PROPOSÉ AU DÉVELOPPEUR  
> **Arbitre :** Tech Lead / Décideur Produit  
> **Module Source :** `san_brainstorming` (Framework Antigravity `san_*`)

---

## 1. PROBLÉMATIQUE RACINE & OPPORTUNITÉ MARCHÉ

### 1.1 Le Point de Friction Douloureux
<!-- 
Exposé cartésien et sans complaisance du problème :
- Qu'est-ce qui coûte du temps, de l'argent ou des clients aujourd'hui ?
- Quelle est la perte financière ou opérationnelle directe subie par la cible ?
-->
- **Constat Terrain :** [Décrire ici la douleur concrète vécue par l'utilisateur final].
- **Impact Économique :** [Perte de conversion, perte de temps, abandon de commande ou surcoût mesurable].

### 1.2 Pourquoi les Solutions Existantes Échouent
<!--
Expliquer pourquoi les solutions classiques ou occidentales ne fonctionnent pas dans ce contexte :
- Ex: Les formulaires longs avec carte bancaire excluent 90 % des usagers locaux.
- Ex: Les applications stores de 45 Mo sont rejetées pour cause de data prépayée coûteuse.
-->
- **Verrou 1 (Paiement/Monétisation) :** [Pourquoi les passerelles habituelles échouent].
- **Verrou 2 (Infrastructure/Réseau) :** [Pourquoi les applications lourdes ou synchrones plantent].
- **Verrou 3 (Adoption/Culture) :** [Pourquoi les habitudes locales rejettent le modèle standard].

### 1.3 L'Opportunité Produit Immédiate
- **Proposition de Valeur Unique :** [Ce que notre solution permet d'accomplir en 3 clics ou 1 message].
- **Avantage Concurrentiel Déterminant :** [Pourquoi notre approche est impossible à concurrencer facilement sur le terrain local].

---

## 2. PERSONAS CIBLES & RÉALITÉ TERRAIN

### 2.1 Persona Utilisateur Principal
* **Profil Cible :** [Ex: Commerçante de marché de détail à Pointe-Noire / Artisan livreur à Brazzaville / Cadre PME à Kinshasa].
* **Équipement Matériel :** Smartphone Android d'entrée de gamme (ex: Tecno Pop 7 / Infinix Smart 7, 2 Go RAM, stockage quasi-saturé).
* **Connectivité Réseau :** Forfait data journalier prépayé (3G instable / EDGE, coupures d'électricité fréquentes).
* **Canaux de Prédilection :** WhatsApp (messages et notes vocales), appels directs, SMS de notification opérateur.

### 2.2 Vecteurs de Confiance & Points de Rupture
* **Facteurs d'Adoption Rapide :**
  - Validation de transaction par SMS Mobile Money officiel (Airtel Money / MTN MoMo).
  - Navigation par repères visuels urbains connus (pas de numérotation de rue abstraite).
  - Possibilité de joindre un humain en 1 clic sur WhatsApp en cas de doute.
* **Facteurs d'Abandon Immédiat :**
  - Téléchargement lourd (> 15 Mo sur le store).
  - Formulaire de plus de 3 champs obligatoires.
  - Débit Mobile Money sans preuve immédiate ou écran bloqué sans retour visuel.

---

## 3. COMPARATIF DES 3 OPTIONS D'ARCHITECTURE ET DE MISE SUR LE MARCHÉ

### Option A (Piste Recommandée) : [Nom de l'Option A, ex: Micro-Application Web PWA + Push USSD MoMo]
* **Description & Parcours Utilisateur :**
  - [Parcours épuré en 3 étapes : Arrivée instantanée sans installation, sélection produit, paiement push USSD 1-clic].
* **Architecture Technique & Stack Préconisée :**
  - Frontend : Web Mobile ultra-léger (React / Vanilla JS + Tailwind, bundle initial < 250 Ko).
  - Backend : API REST (Laravel ou AdonisJS) avec persistance Redis et cache agressif.
  - Données : SQLite ou PostgreSQL + Outbox locale pour résilience offline.
* **Forces :**
  - Zéro friction d'installation (accessible via lien WhatsApp ou QR Code).
  - Démarrage instantané même sous réseau 3G dégradé.
  - Coût d'infrastructure minimal et déploiement sous 48h.
* **Faiblesses & Mitigations :**
  - Pas de push notifications natives iOS (sans impact sur cible Android 95 %+).
* **Évaluation Matricielle sur 40 Points :**
  - Impact Business & Valeur : `0.0/10` (Poids 1.0 -> `0.00`)
  - Faisabilité & Simplicité (Inversé) : `0.0/10` (Poids 1.0 -> `0.00`)
  - Réalité Terrain Afrique : `0.0/10` (Poids 1.2 -> `0.00`)
  - Risques & Dépendances (Inversé) : `0.0/10` (Poids 0.8 -> `0.00`)
* **Score Global :** `00.00 / 40.00` (`00.0 %`)
* **Verdict Formel :** **GO MVP PRIORITAIRE**

---

### Option B (Alternative) : [Nom de l'Option B, ex: Bot Conversationnel WhatsApp Cloud API]
* **Description & Parcours Utilisateur :**
  - [Tout le flux s'exécute dans une conversation WhatsApp : catalogue texte/images, commande, lien de paiement MoMo].
* **Architecture Technique :**
  - Backend : Webhook Node.js / Laravel branché sur l'API Meta WhatsApp Business Cloud.
  - Paiement : Envoi d'un lien sécurisé ou déclenchement direct du Push USSD opérateur.
* **Forces :**
  - Adoption immédiate à 100 %, aucune courbe d'apprentissage, utilise l'application déjà ouverte par l'usager.
* **Faiblesses & Risques :**
  - Coûts variables par conversation facturés par Meta (modèle payant).
  - Ergonomie rigide pour la consultation d'un catalogue riche (> 20 produits).
  - Risque de suspension arbitraire du compte par Meta en cas de signalements.
* **Évaluation Matricielle sur 40 Points :**
  - Impact Business & Valeur : `0.0/10` (Poids 1.0 -> `0.00`)
  - Faisabilité & Simplicité (Inversé) : `0.0/10` (Poids 1.0 -> `0.00`)
  - Réalité Terrain Afrique : `0.0/10` (Poids 1.2 -> `0.00`)
  - Risques & Dépendances (Inversé) : `0.0/10` (Poids 0.8 -> `0.00`)
* **Score Global :** `00.00 / 40.00` (`00.0 %`)
* **Verdict Formel :** **GO MVP CONDITIONNEL / ITÉRATION (Phase 2)**

---

### Option C (Piste Écartée) : [Nom de l'Option C, ex: Application Mobile Native Store avec Carte Bancaire]
* **Description :**
  - [Application mobile native publiée sur Google Play Store et Apple App Store, parcours standard occidental].
* **Architecture Technique :**
  - Application React Native / Flutter, passerelle de paiement Stripe / In-App Purchases.
* **Faiblesses Critiques & Raisons du Rejet :**
  - Poids de téléchargement de 35 à 60 Mo rédhibitoire pour les forfaits data prépayés.
  - Dépendance à la carte bancaire excluant plus de 85 % de la cible locale.
  - Commissions stores de 15 à 30 % destructrices de marge sur des micro-paniers.
  - Cycle de review Play Store / App Store freinant les corrections d'urgence.
* **Évaluation Matricielle sur 40 Points :**
  - Impact Business & Valeur : `0.0/10` (Poids 1.0 -> `0.00`)
  - Faisabilité & Simplicité (Inversé) : `0.0/10` (Poids 1.0 -> `0.00`)
  - Réalité Terrain Afrique : `0.0/10` (Poids 1.2 -> `0.00`)
  - Risques & Dépendances (Inversé) : `0.0/10` (Poids 0.8 -> `0.00`)
* **Score Global :** `00.00 / 40.00` (`00.0 %`)
* **Verdict Formel :** **REJETÉ (NO-GO ABSOLU TERRAIN & RISQUES)**

---

## 4. MATRICE SYNTHÉTIQUE COMPARATIVE SUR 40 POINTS

| Critère d'Évaluation | Poids | Option A (Web PWA MoMo) | Option B (Bot WhatsApp) | Option C (App Store Native) |
| :--- | :---: | :---: | :---: | :---: |
| **1. Impact Business & Valeur** | Coef 1.0 (max 10) | **0.0** | 0.0 | 0.0 |
| **2. Faisabilité & Simplicité (Inversé)** | Coef 1.0 (max 10) | **0.0** | 0.0 | 0.0 |
| **3. Réalité Terrain Afrique** | Coef 1.2 (max 12) | **0.0** | 0.0 | 0.0 |
| **4. Risques & Réglementation (Inversé)** | Coef 0.8 (max 8) | **0.0** | 0.0 | 0.0 |
| **SCORE GLOBAL TOTAL / 40.0** | **100 %** | **00.00 / 40** | **00.00 / 40** | **00.00 / 40** |
| **Pourcentage Normalisé** | — | **00.0 %** | **00.0 %** | **00.0 %** |
| **Alerte Clause Éliminatoire** | — | **Aucune** | Aucune | Veto Terrain / Risque |
| **Verdict Arbitrage** | — | **GO MVP PRIORITAIRE** | **EN SUSPENS** | **REJETÉ** |

---

## 5. RECOMMANDATION FORMELLE & QUESTION D'ARBITRAGE

### 5.1 Recommandation Antigravity
> Nous préconisons le déploiement immédiat de l'**Option A** :
> 1. Elle élimine la barrière du téléchargement en restant sous le seuil critique des 300 Ko.
> 2. Elle s'intègre directement aux habitudes de paiement locales via Mobile Money USSD Push.
> 3. Elle est livrable en version MVP testable sous 48 heures.
> L'Option B pourra être envisagée en Phase 2 comme canal de réengagement conversationnel.

### 5.2 Question d'Arbitrage Fermée pour le Développeur
> **Question au Développeur :**  
> *« Validez-vous la sélection de l'Option A (Score : {{SCORE_A}}/40) pour transmission immédiate à [san_planner](../skills/san_planner.md) afin de générer la roadmap `/roadmaps/MVP_{{THEME}}_{{DATE_COMPACT}}.md` ? »*  
> - `[OUI]` -> Déclenche le passage du statut à `VALIDÉ_POUR_ROADMAP` et le transfert vers `san_planner`.  
> - `[NON / AJUSTEMENT]` -> Spécifier les paramètres à recalculer.

---

## 6. BORDEREAU DE TRANSMISSION VERS `san_planner`
*(Section consommée automatiquement par `san_planner` dès validation de l'arbitrage)*

```yaml
handover_payload:
  theme: "{{THEME}}"
  validated_option: "Option A"
  target_architecture: "Web PWA Mobile-First + API REST + Webhooks MoMo"
  target_stack:
    frontend: "React / Vite / Tailwind CSS"
    backend: "Laravel API ou AdonisJS"
    cache_and_queue: "Redis"
    database: "PostgreSQL ou SQLite"
  scope_mvp:
    - "Initialisation de paiement Push USSD Mobile Money (Airtel / MTN) avec Idempotency-Key"
    - "Écran client réactif gérant les 5 états UI obligatoires (Idéal, Vide, Chargement, Erreur, Succès)"
    - "Endpoint de réception de webhook asynchrone sécurisé par signature HMAC"
    - "Mécanisme de polling sécurisé avec timeout et fallback de vérification de statut"
    - "Collection de tests d'intégration d'API (fichiers Bruno .bru)"
  out_of_scope_mvp:
    - "Application mobile native iOS / Android sur les stores"
    - "Gestion multi-devises internationale (exclusivement devises locales XAF/CDF)"
    - "Moteur de recommandation complexe par IA"
  technical_constraints:
    - "Bundle initial JavaScript : < 250 Ko compressé"
    - "Temps de chargement p95 sous réseau 3G simulé : < 2.0 secondes"
    - "Consommation RAM client : < 120 Mo"
    - "Résilience offline : Persistance locale des données et réessai en arrière-plan"
```
