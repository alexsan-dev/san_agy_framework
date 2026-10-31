---
name: san_store_legal_expert
description: Déclenché quand l'utilisateur souhaite vérifier la conformité App Store / Google Play Store, éliminer les motifs de rejet (directive Apple 5.1.1, compte test reviewer), auditer les permissions ou générer les chartes légales dérivées du code (RGPD/Data Safety).
---

# `san_store_legal_expert` — Runbook de Conformité Stores & Ingénierie Légale

Protocole d'audit et de préparation à la publication mobile (Apple App Store, Google Play Store). Fonde chaque document réglementaire et justification technique sur la **vérité objective du code source** (permissions, SDKs réels, tables BDD).

---

## 1. LES TROIS PILIERS ANTI-REJET NON NÉGOCIABLES

1. **Compte Test Reviewer Pré-configuré :**
   - Identifiants de test pré-configurés sans dépendance à un SMS réel payant ou géolocalisé (`reviewer@alexsan.pro`, OTP fixe `123456`, solde de démonstration crédité).
2. **Directive Apple 5.1.1 (Suppression de Compte in-app) :**
   - Bouton présent in-app accessible en $\le 3$ taps (*Profil > Sécurité & Compte > Supprimer mon compte*).
   - Déclenchement d'un appel API réel (`DELETE /api/v1/account/me`) avec purge ou anonymisation sous 30 jours, doublé d'une URL web publique de secours.
3. **Justification des Permissions Sensibles :**
   - Chaque permission (`CAMERA`, `LOCATION`, `NOTIFICATIONS`) doit être justifiée avec un bénéfice utilisateur direct et concret.

---

## 2. PROTOCOLE D'EXÉCUTION PAS À PAS

### Étape 1 : Audit Statique Automatisé des Permissions et SDKs
- Lancer le scan statique sur les répertoires de l'application mobile :
  ```bash
  bash .agents/skills/san_store_legal_expert/scripts/scan_app_permissions.sh apps/mobile
  ```
- Extraire l'inventaire des permissions (`AndroidManifest.xml`, `Info.plist`, `app.json`), des SDKs tiers (`package.json`) et des données collectées en BDD.

### Étape 2 : Revue Anti-Rejet Spécifique Stores
- Confronter l'inventaire extrait aux [Motifs de Rejet Fréquents](references/store_rejection_patterns.md).
- Rédiger les justifications de permissions en consultant le [Guide des Permissions Sensibles](references/permissions_guide.md).

### Étape 3 : Rédaction Technique Dérivée du Code Source
- Générer les documents réglementaires dans `docs/` à partir des gabarits officiels :
  - [STORE_CHECKLIST_TEMPLATE.md](templates/STORE_CHECKLIST_TEMPLATE.md) $\rightarrow$ `docs/STORE_CHECKLIST.md`
  - [PRIVACY_POLICY_TEMPLATE.md](templates/PRIVACY_POLICY_TEMPLATE.md) $\rightarrow$ `docs/PRIVACY_POLICY.md`
  - [TERMS_TEMPLATE.md](templates/TERMS_TEMPLATE.md) $\rightarrow$ `docs/TERMS.md`
  - [DATA_MAP_TEMPLATE.md](templates/DATA_MAP_TEMPLATE.md) $\rightarrow$ `docs/DATA_MAP.md`
- Apposer systématiquement la mention légale de conformité :
  > *« Ce document est une synthèse technique documentée issue du code source du projet. Il ne constitue pas un conseil juridique formel et doit être validé par un professionnel habilité. »*

### Étape 4 : Entonnoir de Contrôle en 2 Étages
- **Étage 1 (Vérification Technique Déterministe) :**
  - Vérifier la disponibilité (HTTP 200) des URLs publiques hébergeant la politique de confidentialité.
  - Valider l'accès immédiat du compte reviewer en environnement de staging.
- **Étage 2 (Revue Critique) :**
  - Valider la présence d'une checklist affichant **0 BLOQUANT**.
  - Si un manquement est détecté, émettre un ticket prescriptif à [san_ux_ui_expert](../san_ux_ui_expert/SKILL.md) (bouton in-app) ou [san_backend_expert](../san_backend_expert/SKILL.md) (endpoint de purge).

---

## 3. RESSOURCES DU SKILL

- **Scripts Déterministes :**
  - [scripts/scan_app_permissions.sh](scripts/scan_app_permissions.sh) : Analyse statique des manifests et dépendances mobiles.
- **Guides de Référence :**
  - [references/store_rejection_patterns.md](references/store_rejection_patterns.md) : Catalogue des motifs de rejet Apple / Google et remédiations.
  - [references/permissions_guide.md](references/permissions_guide.md) : Justifications types homologuées par permission.
- **Templates Documentaires :**
  - [templates/STORE_CHECKLIST_TEMPLATE.md](templates/STORE_CHECKLIST_TEMPLATE.md) : Checklist anti-rejet et identifiants reviewer (`docs/STORE_CHECKLIST.md`).
  - [templates/PRIVACY_POLICY_TEMPLATE.md](templates/PRIVACY_POLICY_TEMPLATE.md) : Politique de confidentialité issue du code (`docs/PRIVACY_POLICY.md`).
  - [templates/TERMS_TEMPLATE.md](templates/TERMS_TEMPLATE.md) : Conditions Générales d'Utilisation (`docs/TERMS.md`).
  - [templates/DATA_MAP_TEMPLATE.md](templates/DATA_MAP_TEMPLATE.md) : Cartographie des données et sous-traitants (`docs/DATA_MAP.md`).
