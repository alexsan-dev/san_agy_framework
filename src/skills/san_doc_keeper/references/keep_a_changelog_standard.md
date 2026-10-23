# Standard Keep a Changelog v1.1.0 & Semantic Versioning (SemVer 2.0.0)

Ce document constitue la référence canonique utilisée par `san_doc_keeper` pour garantir l'uniformité, la lisibilité et l'intégrité du fichier `CHANGELOG.md`.

---

## 1. Principes Fondamentaux de Keep a Changelog

1. **Un changelog est écrit pour des humains, pas pour des machines :**
   - Éviter les dumps bruts de messages de commit git (`fix: typo in line 42`).
   - Décrire l'impact métier et fonctionnel pour l'utilisateur ou le développeur qui consomme le logiciel.
2. **Une seule entrée par changement distinct :**
   - Regrouper les modifications atomiques logiques sous un même libellé clair.
3. **La version la plus récente est toujours en haut :**
   - L'ordre chronologique inverse est rigoureusement respecté.
4. **La section `[Unreleased]` précède toutes les versions publiées :**
   - Tout travail en cours sur une roadmap active s'insère dans `[Unreleased]`.
5. **Les dates de publication respectent la norme ISO 8601 :** `YYYY-MM-DD`.

---

## 2. Les 7 Catégories Normatives Exclusives

Toute ligne d'action insérée dans le changelog doit être classée sous l'une des 7 catégories ci-dessous :

### 1. `### Added` (Ajouts)
- Nouvelles fonctionnalités, nouveaux écrans, nouveaux endpoints d'API, nouvelles bibliothèques ou composants réutilisables.
- *Exemple :* `Support des paiements échelonnés via Airtel Money.`

### 2. `### Changed` (Modifications)
- Changements apportés à des fonctionnalités ou flux existants, refactorisations d'architecture, réorganisations de routes.
- *Exemple :* `Migration du moteur d'authentification vers des tokens JWT asymétriques RS256.`

### 3. `### Deprecated` (Dépréciations)
- Fonctionnalités stables aujourd'hui mais vouées à être supprimées dans une version ultérieure. Prévient les consommateurs en amont.
- *Exemple :* `Dépréciation du paramètre 'phone_number' au profit de 'msisdn_e164'.`

### 4. `### Removed` (Suppressions)
- Retrait définitif de fonctionnalités obsolètes, endpoints désactivés, colonnes de base de données supprimées ou dépendances éliminées.
- *Exemple :* `Suppression du fallback HTTP non chiffré sur l'endpoint de vérification de solde.`

### 5. `### Fixed` (Corrections)
- Résolution d'anomalies, bugs d'interface, conditions de course, erreurs de typage ou calculs erronés.
- *Exemple :* `Correction d'un blocage de l'interface lors de la perte de signal 3G durant le checkout.`

### 6. `### Security` (Sécurité)
- Durcissement de l'authentification, correctifs de vulnérabilités (OWASP Top 10), protection anti-CSRF, assainissement XSS, cryptographie.
- *Exemple :* `Validation stricte des signatures de webhooks via HMAC-SHA256 à temps constant.`

### 7. `### Performance` (Performance)
- Optimisations de requêtes SQL (éradication du problème N+1), indexation d'index composites, mise en cache Redis, réduction de la taille des bundles.
- *Exemple :* `Indexation composite B-Tree sur transactions(user_id, created_at) réduisant le p95 de 420ms à 35ms.`

---

## 3. Protocole Semantic Versioning 2.0.0 (SemVer)

La numérotation respecte le format strict : `MAJEUR.MINEUR.CORRECTIF` (`MAJOR.MINOR.PATCH`).

### MAJEUR (X.0.0) : Changements Non Rétrocompatibles (Breaking Changes)
- Rupture de contrat d'API publique (suppression de champs ou modification de types de retours).
- Changement de configuration système obligatoire rendant l'ancienne incompatible.
- Réinitialisation ou migration destructrice de base de données.

### MINEUR (0.X.0) : Nouvelles Fonctionnalités Rétrocompatibles
- Ajout de nouveaux endpoints ou paramètres optionnels.
- Nouvelles fonctionnalités métier utilisables sans altérer l'existant.
- Dépréciation d'anciennes méthodes qui continuent à fonctionner.

### CORRECTIF / PATCH (0.0.X) : Corrections Rétrocompatibles
- Résolution de bugs (`Fixed`).
- Patches de vulnérabilité sans changement de contrat (`Security`).
- Optimisations internes de performance (`Performance`).

---

## 4. Procédure de Publication d'une Version (Release)

Lors du passage de `[Unreleased]` vers une version figée :
1. Remplacer `## [Unreleased]` par la nouvelle version et la date du jour :
   ```markdown
   ## [1.2.0] - 2026-10-23
   ```
2. Recréer une section `## [Unreleased]` vide au-dessus de la nouvelle version.
3. Créer le tag git annoté correspondant :
   ```bash
   git tag -a v1.2.0 -m "Release v1.2.0: Intégration Mobile Money et durcissement HMAC"
   ```
