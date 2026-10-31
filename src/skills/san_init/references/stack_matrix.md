# Matrice Officielle des Stacks Logicielles & Détection Déterministe

Ce référentiel documente les indicateurs techniques analysés par `san-researcher` et le script `detect_stack_versions.sh` pour calibrer automatiquement l'environnement Antigravity sans question superflue.

---

## 1. Matrice des 10 Stacks Standards

| Stack Identifiée | Fichiers Indicateurs Clés | Fichiers de Configuration | Gestionnaire Recommandé | Ports Usuels | Profil par Défaut |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. React (Vite / CRA)** | `vite.config.ts`, `vite.config.js`, `index.html` racine | `package.json` (`dependencies.react`) | `pnpm` > `bun` > `npm` | `5173`, `3000` | `global_saas` |
| **2. Vite (Vanilla / Vue / Svelte)** | `vite.config.*`, absence de React | `package.json`, `vite.config.ts` | `pnpm` > `bun` > `npm` | `5173` | `global_saas` |
| **3. Next.js (App / Pages Router)** | `next.config.*`, dossier `app/` ou `pages/` | `tsconfig.json`, `next-env.d.ts` | `pnpm` > `bun` > `npm` | `3000` | `global_saas` |
| **4. Expo (Managed / Bare)** | `app.json`, `app.config.*`, `"expo"` dans `package.json` | `metro.config.js`, `tsconfig.json` | `npx expo`, `pnpm` | `8081` | `mobile_consumer` |
| **5. React Native CLI (Bare)** | `android/` + `ios/`, `react-native.config.js` | `Podfile`, `metro.config.js` | `yarn`, `npm` | `8081` | `mobile_consumer` |
| **6. Laravel** | `artisan`, `composer.json` (`laravel/framework`) | `config/app.php`, `phpunit.xml` | `composer` + `pnpm`/`npm` | `8000`, `5173` | `api_platform` / `emerging_market` |
| **7. AdonisJS** | `ace`, `adonisrc.ts` ou `adonisrc.json` | `tsconfig.json`, `@adonisjs/core` | `pnpm` > `npm` | `3333` | `api_platform` |
| **8. NestJS** | `nest-cli.json`, `src/main.ts` (`@nestjs/core`) | `tsconfig.build.json` | `pnpm` > `npm` | `3000` | `api_platform` |
| **9. Go (Golang)** | `go.mod`, `go.sum`, `main.go` | `Makefile`, `Dockerfile` | `go mod` | `8080`, `3000` | `cli_devtools` / `api_platform` |
| **10. Python (FastAPI / Django)** | `pyproject.toml`, `requirements.txt`, `manage.py` | `poetry.lock`, `Pipfile` | `uv` > `poetry` > `pip` | `8000` | `api_platform` |

---

## 2. Détection par Script Déterministe

Le sous-agent `san-researcher` exécute la reconnaissance via l'outil dédié :

```bash
bash .agents/skills/san_searcher/scripts/detect_stack_versions.sh --json
```

Ce script extrait les versions réelles épinglées (`node`, `react`, `next`, `laravel`, `python`, `go`, etc.) et émet un payload JSON normalisé garantissant le pinning strict de version sans hallucination.
