# Matrice des Suites de Tests par Stack Technologique

Dans le framework Antigravity, **la Preuve par le Code est souveraine**. Aucune tâche d'ingénierie ne peut être marquée `- [x]` sans vérification physique d'un fichier et exécution concluante de la suite de tests officielle correspondant à la technologie hôte.

---

## 1. Matrice des Tests & Commandes Validantes

| Stack Technique | Tests Unitaires & Composants | Tests Intégration / E2E | Validation Contrats API | Commande d'Exécution Validante |
| :--- | :--- | :--- | :--- | :--- |
| **React / Vite** | `Vitest` / `Jest` + RTL | `Playwright` | MSW / Bruno | `pnpm test && pnpm exec playwright test` |
| **Next.js** | `Vitest` / `Jest` | `Playwright` | Route Handlers + Bruno | `pnpm test && pnpm run e2e` |
| **Expo (React Native)** | `Jest` + RNTL | `Maestro` / `Detox` | Collections Bruno serveur | `pnpm test -- --watchAll=false` |
| **React Native CLI** | `Jest` + RNTL | `Detox` | Collections Bruno serveur | `yarn test --watchAll=false` |
| **Laravel** | `Pest` / `PHPUnit` | Tests HTTP Feature Pest | Collections Bruno (`bru run`) | `php artisan test --parallel && bru run bruno/` |
| **AdonisJS** | `Japa` | Tests de suite Japa | Collections Bruno (`bru run`) | `node ace test && bru run bruno/` |
| **NestJS** | `Jest` | `Supertest` (e2e) | Collections Bruno (`bru run`) | `pnpm test && pnpm test:e2e` |
| **Go (Golang)** | `testing` natif | `testify` / suite HTTP | Collections Bruno (`bru run`) | `go test -v -race ./...` |
| **Python (FastAPI / Django)** | `pytest` | `pytest-asyncio` / `httpx` | Collections Bruno (`bru run`) | `pytest -v --cov=.` |

---

## 2. Principes Fondamentaux de la Preuve par le Code

1. **Interdiction du Mocking Theater :** Tout test unitaire mockant la totalité de la couche métier ou de la base de données sans tester l'intégration réelle est considéré comme non recevable.
2. **Couverture des Cas aux Limites :** Chaque endpoint ou service critique doit comporter au moins 1 test du cas nominal et 2 tests de cas limites (données invalides, erreurs d'authentification/autorisation, collision de concurrence).
3. **Zéro Coche d'Anticipation :** L'orchestrateur vérifie systématiquement la présence physique du fichier sur le disque (`read_file` ou `test -f`) et le code de sortie 0 de la commande de test avant d'apposer `- [x]`.
