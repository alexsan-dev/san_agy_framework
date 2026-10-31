---
trigger: model_decision
description: "Load when scoping product features, user flows, personas, business invariants, or market constraints."
---
# CADRAGE PRODUIT, STRATÉGIE & MARCHÉ (`PRODUCT.md`)

> **Source de vérité produit :** Ce document régit la vision d'affaires, les personas cibles, les métriques de succès et les contraintes opérationnelles indispensables à la prise de décision fonctionnelle.

---

## 1. VISION PRODUIT & PROPOSITION DE VALEUR UNIQUE (UVP)

* **Nom Officiel du Produit :** `[NOM_PRODUIT]`
* **Profil Projet Associé :** `PROJECT_PROFILE: [global_saas | emerging_market_3g | mobile_consumer | cli_devtools | api_platform]`
* **Le Problème Douloureux :** `[Description concise du problème critique et de la friction quotidienne subie par les utilisateurs cibles]`
* **La Solution Déterminante :** `[Comment notre produit pulvérise cette friction en un minimum d'interactions claires]`
* **Proposition de Valeur Unique (UVP) :** `"[Phrase d'impact mémorable en 12 mots maximum résumant l'avantage exclusif]"`
* **Modèle Économique (Business Model) :** `[Abonnement SaaS B2B / Commission par transaction / Freemium / Facturation à l'usage / Open Source Sponsorship]`

---

## 2. PERSONAS CIBLES & ENVIRONNEMENT D'USAGE

### Persona Primaire (Utilisateur Cœur de Cible)
* **Profil Type :** `[Ex: Responsable des opérations, commerçant de proximité, développeur backend, consommateur mobile]`
* **Contexte d'Utilisation :** `[Ex: Bureau multi-écrans, smartphone en mobilité sur réseau instable, terminal de commande CLI]`
* **Appareils & Systèmes :** `[Ex: Navigateurs modernes Chrome/Safari, smartphones Android d'entrée de gamme, terminaux Linux/macOS]`
* **Objectif Prioritaire :** `[Ex: Automatiser une tâche récurrente, finaliser un paiement sans friction, inspecter des métriques]`

### Persona Secondaire (Superviseur / Opérateur Back-Office)
* **Profil :** `[Ex: Administrateur de compte, superviseur financier, agent de support]`
* **Besoin Clé :** Vision synthétique, export de données, traçabilité des opérations, filtres multicritères instantanés.

---

## 3. CONTRAINTES OPÉRATIONNELLES MODULAIRES (SELON `PROJECT_PROFILE`)

L'équipe produit et technique applique les contraintes correspondant au `PROJECT_PROFILE` déclaré dans `PROJECT.md` :

### BLOC A — Si `PROJECT_PROFILE: emerging_market_3g` ou `mobile_consumer`
* **Connectivité Dégradée (3G / EDGE / Hors-Ligne) :**
  - Démarrage instantané offline-first en moins de 1.5s via cache local (SQLite, IndexedDB, WatermelonDB).
  - Mises à jour optimistes avec indicateur discret de synchronisation en cours.
  - File d'attente locale persistante (*Outbox Pattern*) rejouée séquentiellement à la reconnexion.
  - Sobriété de bande passante : payload moyen par session $< 1.5\text{ Mo}$, compression systématique.
* **Paiements Mobiles Locaux :**
  - Passerelles Mobile Money (Airtel, MTN, Orange, Wave, M-Pesa).
  - Gestion asynchrone des flux USSD / Push STK sans bloquer l'interface.
  - Clé d'idempotence UUIDv4 obligatoire sur toute transaction financière.
* **Localisation Réaliste :** Repères urbains, quartiers et carrefours connus (proscription des codes postaux obligatoires).
* **Canaux Favoris :** Partage natif via `whatsapp://send` et authentification par numéro de téléphone + OTP SMS/WhatsApp.

### BLOC B — Si `PROJECT_PROFILE: global_saas`
* **Multi-Tenancy & Isolation des Données :** Cloisonnement étanche des locataires au niveau schéma ou filtres de requêtes sécurisés.
* **Authentification d'Entreprise :** Prise en charge SSO (SAML 2.0, OAuth2/OIDC, Google Workspace, Azure AD).
* **Gouvernance & Conformité :** Piste d'audit immuable (*Audit Trail*) pour toute action administrative, conformité RGPD (droit à l'oubli, export JSON/CSV) et exigences SOC2.
* **Facturation & Quotas :** Intégration passerelle de souscription (Stripe, LemonSqueezy) et enforcement des limites par plan d'abonnement.
* **Haute Disponibilité :** SLA cible de $99.9\%$, tolérance aux pannes multizones et reprise après sinistre documentée.

### BLOC C — Si `PROJECT_PROFILE: cli_devtools` ou `api_platform`
* **Performance & Temps de Démarrage :** Démarrage de la commande CLI en moins de 100ms, temps de réponse API p99 $< 50\text{ms}$.
* **Ergonomie Terminal & Compatibilité POSIX :**
  - Sortie humaine colorée avec indicateur d'avancement si TTY interactif ; sortie neutre ou JSON brute si redirection / pipe (`--json`, `--no-color`).
  - Codes d'erreur de sortie normalisés (`0` succès, `1` erreur générique, `2` mauvaise utilisation d'arguments).
* **Versioning Sémantique & Évolution :** Respect strict de SemVer, politique d'obsolescence (*deprecation window*) avec alertes rétrocompatibles.
* **Rate Limiting & Quotas API :** Limitation distribuée basée sur IP / jeton API avec en-têtes `X-RateLimit-*`.

---

## 4. INDICATEURS CLÉS DE PERFORMANCE (KPIS) & OBJECTIFS D'AFFAIRES

| Indicateur (KPI) | Cible Minimale Exigée | Méthode de Mesure / Outil |
| :--- | :--- | :--- |
| **Taux de complétion de l'onboarding** | $> 85\%$ (web/mobile) / $> 95\%$ exécution `--help` (`cli_devtools`) | Funnel d'activation du premier usage |
| **Time-to-Value (Action clé accomplie)** | $< 45\text{ secondes}$ (web/mobile) / $< 5\text{s}$ premier succès CLI/API | Chronométrage de la séquence nominale |
| **Taux d'échec de l'action principale** | $< 1\%$ | Ratio des erreurs applicatives sur le total initié |
| **Taux de rétention J+7 (Day 7)** | $> 30\%$ | Utilisateurs récurrents après une semaine |
| **Temps de réponse / Démarrage** | $< 250\text{ms}$ (web/mobile) / Démarrage CLI $< 100\text{ms}$ / Latence API p99 $< 50\text{ms}$ | Métriques APM / RUM / Benchmarks CLI |
| **Poids total du livrable initial** | $< 15\text{ Mo}$ (mobile) / $< 400\text{ Ko}$ (web) / $< 20\text{ Mo}$ (binaire `cli_devtools`) | Analyse de bundle au build / taille du binaire compilé |

> **Note profils `cli_devtools` & `api_platform` :** Pour les livrables d'outillage ou d'API sans interface graphique web/mobile, les KPIs d'onboarding UI et de rétention visuelle sont adaptés :
> - **Temps de démarrage commande CLI :** $< 100\text{ms}$ (cold start).
> - **Poids du binaire compilé CLI :** $< 20\text{ Mo}$ (ou package npm sans dépendances natives volumineuses).
> - **Latence API p99 :** $< 50\text{ms}$ sur les endpoints nominaux (hors requêtes analytiques lourdes).
> - **Taux d'erreur 5xx API :** $< 0.1\%$ du volume total de requêtes.
