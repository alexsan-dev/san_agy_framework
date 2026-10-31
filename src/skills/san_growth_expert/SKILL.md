---
name: san_growth_expert
description: Déclenché quand l'utilisateur souhaite concevoir un plan de tracking analytics unifié en snake_case, optimiser le référencement naturel local (SEO) ou maximiser la conversion sur les fiches de stores applicatifs (ASO).
---

# `san_growth_expert` — Runbook Growth, SEO Local & Plan de Tracking Analytics

Protocole d'acquisition organique, d'optimisation store (ASO) et de gouvernance de la donnée comportementale sous déontologie **100% White-Hat** (zéro faux avis, zéro clic manipulé). Conçu pour le respect de la bande passante mobile (payloads légers, zéro impact LCP sur 3G).

---

## 1. RÈGLES D'OR DE CROISSANCE & DE MESURE

1. **Taxonomie Déterministe en `snake_case` :**
   - Événements standardisés partagés entre Firebase, GA4 et Meta Pixel (`screen_view`, `view_item`, `add_to_cart`, `purchase_momo`).
   - Paramètre obligatoire de devise locale : `currency: "XAF"`.
2. **Sobriété Réseau & Zéro Script Bloquant :**
   - Batchs compressés (< 2 Ko), chargement asynchrone sans dégradation du Largest Contentful Paint (LCP).
3. **SEO Local Réaliste :**
   - Ciblage géographique précis (quartiers, repères urbains, moyens de paiement locaux) plutôt que requêtes génériques creuses.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Cartographie d'Intention et Mots-Clés Locaux
- Extraire la vision produit depuis `.agents/rules/PRODUCT.md`.
- Définir les intentions de recherche géolocalisées en consultant le guide [SEO Local Afrique & Congo](references/local_seo_congo.md).
- Rédiger les structures de balisage JSON-LD à partir des gabarits [Schema.org](references/schema_org_templates.md).

### Étape 2 : Plan de Taggage Analytique Unifié
- Établir la matrice d'événements dans `docs/TRACKING_PLAN.md` à partir du gabarit [TRACKING_PLAN_TEMPLATE.md](templates/TRACKING_PLAN_TEMPLATE.md).
- Suivre les conventions de nommage et typage du guide [Taxonomie de Tracking](references/tracking_taxonomy.md).
- Coordonner l'intégration des hooks de mesure avec [san_ux_ui_expert](../san_ux_ui_expert/SKILL.md).

### Étape 3 : Fiche Store ASO et Storyboard Visuel
- Définir la fiche de métadonnées selon le [Playbook ASO](references/aso_playbook.md) et [STORE_LISTING_TEMPLATE.md](templates/STORE_LISTING_TEMPLATE.md) :
  - Titre (max 30 car.), sous-titre (max 30/80 car.), description structurée en 4 volets.
  - Mots-clés cachés iOS sans espace séparés par des virgules.
- Fournir à [san_designer](../san_designer/SKILL.md) le storyboard des 5 captures de conversion levant les objections en moins de 3 secondes.
- Coordonner les textes percutants avec [san_copywriter](../san_copywriter/SKILL.md).

### Étape 4 : Entonnoir de Validation en 2 Étages
- **Étage 1 (Vérification Automatisée Scriptée) :**
  - Exécuter le script de validation locale :
    ```bash
    bash .agents/skills/san_growth_expert/scripts/verify_tracking_and_seo.sh https://alexsan.pro
    ```
  - Vérifier la conformité du sitemap, du balisage Schema.org JSON-LD et les limites strictes de caractères des stores.
- **Étage 2 (Audit DebugView & Zéro Événement Fantôme) :**
  - Vérifier dans la console réseau ou Firebase DebugView qu'une interaction utilisateur n'émet qu'un seul et unique événement réseau typé.

### Étape 5 : Clôture Documentaire & Alignement Légal
- Synchroniser l'inventaire des traceurs et SDKs avec [san_store_legal_expert](../san_store_legal_expert/SKILL.md) pour conformité dans `docs/PRIVACY_POLICY.md`.
- Consigner la livraison dans `CHANGELOG.md` sous la section `[Growth & Analytics]`.

---

## 3. RESSOURCES DU SKILL

- **Scripts de Contrôle :**
  - [scripts/verify_tracking_and_seo.sh](scripts/verify_tracking_and_seo.sh) : Audit automatisé du sitemap, des métas et du JSON-LD.
- **Guides de Référence :**
  - [references/local_seo_congo.md](references/local_seo_congo.md) : Stratégies de positionnement et intentions locales.
  - [references/aso_playbook.md](references/aso_playbook.md) : Règles strictes des stores, limitations et storyboards.
  - [references/tracking_taxonomy.md](references/tracking_taxonomy.md) : Taxonomie d'événements snake_case et sobriété réseau.
  - [references/schema_org_templates.md](references/schema_org_templates.md) : Modèles JSON-LD LocalBusiness et MobileApplication.
- **Templates Stratégiques :**
  - [templates/TRACKING_PLAN_TEMPLATE.md](templates/TRACKING_PLAN_TEMPLATE.md) : Matrice unifiée de tracking (`docs/TRACKING_PLAN.md`).
  - [templates/STORE_LISTING_TEMPLATE.md](templates/STORE_LISTING_TEMPLATE.md) : Fiche de métadonnées ASO (`docs/STORE_LISTING.md`).
