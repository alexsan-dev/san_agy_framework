# [Nom du Projet]

> **Description concise :** [Une ou deux phrases percutantes résumant la proposition de valeur, la cible usager et le contexte opérationnel].

---

## 🚀 Démarrage Rapide

### Prérequis
- [Runtime & Version, ex: Node.js >= 20.x, PHP >= 8.2, Go >= 1.22]
- [Gestionnaire de paquets, ex: pnpm >= 9.x, bun, composer]
- [Base de données / Cache, ex: PostgreSQL 16, Redis 7, SQLite]

### Installation
```bash
# 1. Cloner le dépôt
git clone <URL_DU_DEPOT>
cd <NOM_DU_PROJET>

# 2. Installer les dépendances
npm install # ou pnpm install / composer install

# 3. Configurer l'environnement
cp .env.example .env
# Éditer .env avec les identifiants locaux

# 4. Exécuter les migrations et seeds
npm run db:migrate
npm run db:seed

# 5. Démarrer le serveur de développement
npm run dev
```

---

## ⚙️ Configuration & Variables d'Environnement

| Variable | Description | Exemple / Valeur par défaut | Obligatoire ? |
| :--- | :--- | :--- | :---: |
| `APP_ENV` | Environnement d'exécution (`local`, `staging`, `production`) | `local` | Oui |
| `APP_PORT` | Port d'écoute du serveur HTTP | `3000` | Oui |
| `DATABASE_URL` | Chaîne de connexion à la base de données principale | `postgres://user:pass@localhost:5432/db` | Oui |
| `REDIS_URL` | URL du cache et verrous atomiques | `redis://localhost:6379` | Non |

---

## 🧪 Assurance Qualité & Tests

Ce projet applique la souveraineté des tests et la règle de **Preuve par le Code** du framework Antigravity (`san_*`).

```bash
# Exécuter les tests unitaires et d'intégration
npm test

# Exécuter la suite avec couverture de code
npm run test:coverage

# Audit de sécurité et hygiène
npm run lint
bash .agents/skills/san_copywriter/scripts/check_lorem.sh
```

---

## 🤖 Gouvernance Antigravity (`san_*`)

Ce projet est piloté avec l'orchestration cognitive **Google Antigravity CLI** :
- **Règles d'ingénierie :** `.agents/rules/` (`PROJECT.md`, `API.md`, `BRAND.md`)
- **Feuilles de route :** `roadmaps/` (actives) et `roadmaps/archives/` (clôturées à 100%)
- **Journal des modifications :** Suivi strict sous [CHANGELOG.md](CHANGELOG.md) selon [Keep a Changelog 1.1.0](https://keepachangelog.com/fr/1.1.0/) et [SemVer 2.0.0](https://semver.org/lang/fr/).

---

## 📄 Licence

Ce projet est sous licence [MIT / Propriétaire / Autre]. Voir le fichier `LICENSE` pour plus de détails.
