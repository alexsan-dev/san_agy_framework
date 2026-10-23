# WHITELIST DES DOMAINES OFFICIELS DE CONFIANCE (OFFICIAL AUTHORITIES)
# Framework Antigravity (`san_*`) — Moteur `san_searcher`

Pour garantir l'étanchéité contextuelle et éradiquer les hallucinations d'APIs tierces, `san_searcher` restreint strictement ses recherches aux domaines éditeurs officiels. Tout blog non officiel, tutoriel obsolète ou fil de discussion non corroboré est disqualifié par défaut.

---

## 1. TABLEAU OFFICIEL DES DOMAINES DE RÉFÉRENCE

| Domaine Autorisé | Écosystème Cible | Type d'Informations Faisant Autorité | Paramètre Recommandé `search_web` |
| :--- | :--- | :--- | :--- |
| `react.dev` | Frontend React / RSC | React 19, Server Components, Hooks natifs, Concurrency | `domain: "react.dev"` |
| `laravel.com` | Backend PHP | Laravel 11+, Eloquent, Queues, Cache Locks, Sanctum | `domain: "laravel.com"` |
| `docs.expo.dev` | Mobile Cross-Platform | Expo SDK 52+, File-based Routing (Expo Router), Plugins natifs | `domain: "docs.expo.dev"` |
| `tailwindcss.com` | Design System & CSS | Tailwind CSS v4+, Directives `@theme`, Container Queries | `domain: "tailwindcss.com"` |
| `owasp.org` | Sécurité Applicative | OWASP Top 10 API Security, BOLA, IDOR, Injection mitigations | `domain: "owasp.org"` |
| `developer.mozilla.org` | Web Standards (MDN) | ECMAScript standard, Web APIs, HTTP Headers, Fetch | `domain: "developer.mozilla.org"` |
| `php.net` | Runtime Serveur | PHP 8.3+, Types stricts, Fibers, Fonctions natives | `domain: "php.net"` |
| `nodejs.org` | Runtime JavaScript | Node.js 22 LTS, Test Runner natif, AsyncLocalStorage | `domain: "nodejs.org"` |
| `nextjs.org` | Framework Fullstack | App Router, Server Actions, Caching, Middleware | `domain: "nextjs.org"` |
| `typescriptlang.org` | Typage Statique | TypeScript 5.x, Satisfies, Const Type Parameters | `domain: "typescriptlang.org"` |
| `stripe.com` | Passerelle de Paiement | Webhooks HMAC, Idempotency-Key, SetupIntents | `domain: "stripe.com"` |
| `go.dev` | Backend Concurrence | Go 1.23+, Generics, Slices package, Concurrency primitives | `domain: "go.dev"` |

---

## 2. RÈGLES DE RECHERCHE AVEC `search_web`

1. **Priorisation du paramètre `domain` :** Renseigner systématiquement le paramètre `domain` de l'outil `search_web` avec l'un des domaines ci-dessus.
2. **Précision lexicale et de version :** Associer systématiquement le nom exact du framework, la version majeure active sur le projet (issue de `detect_stack_versions.sh`) et l'API ciblée.
   - *Exemple non conforme :* `"comment utiliser les formulaires en react"`
   - *Exemple conforme :* `domain: "react.dev"` avec query `"react 19 useActionState form action official documentation"`
3. **Double vérification des Breaking Changes :** Toujours vérifier les sections *Upgrade Guide* ou *Release Notes* de la documentation officielle pour s'assurer que le pattern n'a pas été déprécié ou modifié dans la sous-version mineure installée.
