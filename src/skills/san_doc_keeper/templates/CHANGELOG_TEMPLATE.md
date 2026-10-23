# Changelog

Toutes les modifications notables apportées à ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère à la [Gestion sémantique de version (SemVer 2.0.0)](https://semver.org/lang/fr/).

---

## [Unreleased]

### Added
- [Nouvelle fonctionnalité métier, nouvel écran, nouveau service ou endpoint]

### Changed
- [Modification de comportement d'une fonctionnalité existante ou refactorisation]

### Deprecated
- [Fonctionnalité marquée comme obsolète en prévision d'une suppression future]

### Removed
- [Fonctionnalité, dépendance obsolète ou fichier définitivement retiré]

### Fixed
- [Correction d'anomalie, de condition de course ou de régression identifiée]

### Security
- [Correctif de vulnérabilité, durcissement cryptographique, protection CSRF/XSS/BOLA]

### Performance
- [Optimisation de requêtes SQL (suppression N+1), mise en cache, réduction du bundle]

---

## [1.0.0] - YYYY-MM-DD

### Added
- Initialisation officielle de la structure de projet avec le framework Antigravity (`san_*`).
- Configuration de l'hygiène Git hermétique et de l'espace souverain `.agents/`.
- Première feuille de route de production validée et archivée.

---

<!--
Directives d'utilisation de san_doc_keeper :
1. Chaque clôture de phase via le Fast-Track orchestrateur doit alimenter la section [Unreleased] via changelog_helper.sh :
   bash scripts/changelog_helper.sh --type Added --desc "Description du livrable"
2. Les 7 catégories Keep a Changelog v1.1.0 sont strictes et exclusives :
   Added, Changed, Deprecated, Removed, Fixed, Security, Performance.
3. Ne jamais consigner d'entrée non prouvée dans la codebase réelle.
-->
