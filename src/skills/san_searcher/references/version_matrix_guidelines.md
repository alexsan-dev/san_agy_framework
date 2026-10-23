# DIRECTIVES DE PINNING DE VERSIONS & CORRÉLATION DE COMPATIBILITÉ
# Framework Antigravity (`san_*`) — Moteur `san_searcher`

L'exactitude des patterns d'ingénierie dépend de la synchronisation parfaite entre les versions installées dans les manifestes locaux et la documentation consultée.

---

## 1. RÈGLE INTANGIBLE DU PINNING PRÉALABLE

Aucune recherche web ne doit être initiée sans avoir au préalable exécuté :
`bash scripts/detect_stack_versions.sh [PROJECT_ROOT]`

Cette inspection extrait les versions exactes depuis :
- `package.json` (`dependencies` et `devDependencies`)
- `composer.json` (`require` et `require-dev`)
- `Dockerfile` / `docker-compose.yml` (images de base et tags de services)
- `go.mod` (directive `go` et modules requis)
- `Cargo.toml` (`edition` et `dependencies`)
- `pyproject.toml` (dépendances Python)

---

## 2. MATRICE DE COMPATIBILITÉ MAJEURE PAR ÉCOSYSTÈME

### React & React Native
- **React 19 :**
  - Fin de `useMemo` / `useCallback` obligatoires avec le compilateur React.
  - Remplacement de `useFormState` par `useActionState`.
  - Support natif des promesses via `use()`.
  - Directives `"use client"` et `"use server"`.
- **Expo SDK 52 :**
  - Basé sur React Native 0.76+ et le Nouveau Moteur (New Architecture / Fabric / TurboModules) activé par défaut.
  - Dépréciation des modules historiques non compatibles New Arch.

### Laravel
- **Laravel 11 :**
  - Structure allégée : suppression des `Kernel.php` (remplacés par `bootstrap/app.php`).
  - Configuration fluide via `bootstrap/providers.php`.
  - Migrations simplifiées avec clés étrangères par convention.
  - Cache atomique Redis via `Cache::lock($name, $seconds)->get()`.

### Tailwind CSS
- **Tailwind CSS v4 :**
  - Moteur Oxide haute performance en Rust.
  - Suppression de `tailwind.config.js` au profit des directives CSS natives `@theme`.
  - Pas de configuration manuelle de purge : détection automatique de tous les fichiers du projet.

---

## 3. PROTOCOLE D'ARBITRAGE DE VERSION DIVERGENTE

Si un snippet ou tutoriel en ligne utilise une syntaxe différente du projet local :
1. **Identifier la version du snippet :** Date de publication, imports obsolètes (`tailwind.config.js`, `useFormState`).
2. **Rejeter l'ancien pattern :** Si le projet utilise la version moderne, interdire l'application de l'ancienne solution.
3. **Rejeter le futur non installé :** Si le projet est sous Laravel 10 ou React 18, ne pas utiliser d'APIs réservées à Laravel 11 ou React 19 tant qu'un bump de version n'a pas été validé dans la roadmap.
