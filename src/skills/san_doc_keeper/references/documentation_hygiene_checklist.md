# Grille de Contrôle d'Hygiène Documentaire (Documentation Hygiene Checklist)

Cette grille d'audit est exécutée par `san_doc_keeper` lors de la clôture de toute phase de développement ou avant toute mise en production.

---

## 1. Audit du `CHANGELOG.md`

- [ ] **Présence du fichier :** `CHANGELOG.md` existe à la racine du projet.
- [ ] **Section [Unreleased] :** Les modifications récentes y sont consignées.
- [ ] **Catégorisation stricte :** Toutes les entrées relèvent exclusivement des 7 catégories :
  - `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`, `Performance`.
- [ ] **Preuve par le Code :** Chaque entrée correspond à un code réel, testé et commitable. Zéro hallucination.
- [ ] **Pas de commits git bruts :** Les messages sont formulés pour des humains (métier/technique clair).

---

## 2. Audit du `README.md`

- [ ] **Commandes fonctionnelles :** Les commandes de démarrage (`npm run dev`, etc.) et de test (`npm test`) reflètent fidèlement le `package.json` ou l'outillage en place.
- [ ] **Variables d'environnement :** Toutes les variables présentes dans `.env.example` sont documentées avec leur rôle et statut (obligatoire/optionnel).
- [ ] **Versions de runtimes :** Les versions minimales requises (Node, PHP, Python, Docker) sont à jour.

---

## 3. Audit des Règles `.agents/rules/`

- [ ] **`.agents/rules/PROJECT.md` :** Les nouvelles commandes de build, linters ou conventions d'architecture y sont répercutées.
- [ ] **`.agents/rules/API.md` :** Les nouveaux endpoints, headers requis (ex: `Idempotency-Key`, `Authorization`) ou contrats JSON y sont décrits.

---

## 4. Audit des Feuilles de Route (`roadmaps/`)

- [ ] **Complétude 100% :** Aucune case `- [ ]` ne subsiste dans la roadmap ciblée pour archivage.
- [ ] **Archivage atomique :** Utilisation de `scripts/archive_roadmap.sh` déplaçant le fichier vers `roadmaps/archives/` avec certification SHA-256.
- [ ] **Zéro suppression :** Les roadmaps terminées ne sont jamais effacées via `rm`.
