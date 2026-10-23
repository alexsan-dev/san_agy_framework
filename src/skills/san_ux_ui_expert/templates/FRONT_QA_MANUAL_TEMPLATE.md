# Fiche de Vérification Manuelle QA Frontend & Mobile

**Fonctionnalité :** [Nom de la Feature / Écran]  
**Testeur / Auditeur :** [Nom du Testeur]  
**Date :** [AAAA-MM-JJ]  
**Appareil Réel Utilisé :** [Ex: iPhone 15 Pro iOS 17.4 / Samsung Galaxy A54 Android 14]  
**Environnement Réseau Testé :** [WiFi Nominal / 3G Throttlée / Mode Avion]  
**Statut Global :** [PASS / FAIL]

---

## 1. VÉRIFICATION DES 5 ÉTATS UI

| N° | État Testé | Protocole de Test Manuel | Comportement Attendu | Résultat |
| :--- | :--- | :--- | :--- | :--- |
| **E1** | **État Idéal** | Charger l'écran avec un compte ayant des données actives. | Données affichées sans clignotement, défilement 60 fps, bouton actif scale 0.98. | [PASS / FAIL] |
| **E2** | **État Vide** | Charger l'écran avec un compte vierge (0 élément). | Empty state incitatif avec illustration et bouton CTA direct pour débloquer. | [PASS / FAIL] |
| **E3** | **État Chargement** | Simuler un réseau 3G lent (DevTools ou réseau réel bridé). | Skeleton géométrique exact affiché, aucun spinner aveugle, aucun CLS (> 0.05). | [PASS / FAIL] |
| **E4** | **État Erreur** | Couper la route API ou provoquer une erreur 500. | Message empathique sans blâme, bouton « Réessayer » fonctionnel avec backoff. | [PASS / FAIL] |
| **E5** | **État Hors-Ligne** | Activer le mode Avion après un premier chargement. | Données locales issues du cache affichées, bandeau discret hors-ligne visible. | [PASS / FAIL] |

---

## 2. ERGONOMIE PHYSIQUE DU POUCE & CONTEXTE TERRAIN

| N° | Point de Contrôle | Protocole de Vérification | Comportement Attendu | Résultat |
| :--- | :--- | :--- | :--- | :--- |
| **T1** | **Zone du Pouce** | Tenir le smartphone d'une seule main (droite ou gauche). | L'ensemble des boutons primaires (CTA) est actionnable sans changer de prise. | [PASS / FAIL] |
| **T2** | **Cibles Tactiles** | Tapoter rapidement sur chaque bouton et icône interactive. | Pas de raté tactile, surface perçue $\ge 44 \times 44\text{px}$, aucun chevauchement. | [PASS / FAIL] |
| **T3** | **Lisibilité Plein Soleil** | Consulter l'écran sous lumière extérieure vive ($> 10\,000\text{ lux}$). | Montants en FCFA et textes critiques parfaitement lisibles sans plisser les yeux. | [PASS / FAIL] |
| **T4** | **Retour Haptique** | Tapoter sur un bouton d'action ou sélectionner un opérateur MoMo. | Micro-vibration physique tactile nette ressentie sur le terminal physique. | [PASS / FAIL] |

---

## 3. RÉSILIENCE HORS-LIGNE & OUTBOX

| N° | Scénario de Coupure Brutale | Comportement Attendu | Résultat |
| :--- | :--- | :--- | :--- |
| **R1** | Saisir un virement / ajout au panier puis passer en mode Avion avant de cliquer. | Mutation appliquée immédiatement dans l'UI (Optimistic), message « mise en file locale ». | [PASS / FAIL] |
| **R2** | Désactiver le mode Avion (reconnexion au réseau). | La file Outbox se vide automatiquement et les données serveur sont réconciliées. | [PASS / FAIL] |
| **R3** | Sélectionner une image de 8 Mo pour téléversement. | Compression transparente locale effectuée, poids envoyé $< 300\text{ Ko}$. | [PASS / FAIL] |

---

## 4. CONCLUSION DU TEST

* **Nombre d'anomalies bloquantes :** [0]
* **Commentaires généraux :** [Observations complémentaires du testeur]
* **Verdict :** [VALIDÉ POUR LIVRAISON / RETOUR AU LEAD DEVELOPER]
