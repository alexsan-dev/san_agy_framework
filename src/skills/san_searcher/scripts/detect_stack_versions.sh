#!/usr/bin/env bash
# scripts/detect_stack_versions.sh
# Extraction déterministe et cartésienne des versions de frameworks, runtimes et dépendances clés d'un projet.
# Usage: ./detect_stack_versions.sh [PROJECT_ROOT] [--json]
# Options:
#   -h, --help    Affiche l'aide
#   --json        Affiche le résumé au format JSON structuré

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

JSON_OUTPUT=false

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      cat << 'EOF'
Usage: detect_stack_versions.sh [PROJECT_ROOT] [--json]

Inspecte les manifestes locaux (package.json, composer.json, Dockerfile, docker-compose.yml, go.mod, Cargo.toml, pyproject.toml)
pour figer les versions exactes des technologies du projet (Pinning de versions).

Options:
  --json    Retourne un objet JSON valide contenant { languages, frameworks, packageManagers, databases }
  -h, --help Affiche cette aide

Exemples:
  ./detect_stack_versions.sh
  ./detect_stack_versions.sh /chemin/vers/projet
  ./detect_stack_versions.sh . --json
EOF
      exit 0
      ;;
    --json)
      JSON_OUTPUT=true
      ;;
  esac
done

# Déterminer la racine du projet (premier argument non-optionnel ou '.')
ROOT_DIR="."
for arg in "$@"; do
  if [[ "$arg" != "--json" && "$arg" != "-h" && "$arg" != "--help" ]]; then
    ROOT_DIR="$arg"
    break
  fi
done

if [[ ! -d "${ROOT_DIR}" ]]; then
  if [[ "${JSON_OUTPUT}" == "true" ]]; then
    echo "{\"error\": \"Repertoire introuvable: ${ROOT_DIR}\"}" >&2
  else
    echo -e "${RED}❌ Erreur : Le répertoire '${ROOT_DIR}' est introuvable.${NC}" >&2
  fi
  exit 1
fi

ROOT_DIR="$(cd "${ROOT_DIR}" && pwd)"

# ==============================================================================
# MODE 1 : SORTIE JSON BIEN FORMÉE (--json)
# ==============================================================================
if [[ "${JSON_OUTPUT}" == "true" ]]; then
  if command -v node >/dev/null 2>&1; then
    node -e "
      const fs = require('fs');
      const path = require('path');
      const root = process.argv[1] || '.';

      const result = {
        languages: [],
        frameworks: [],
        packageManagers: [],
        databases: []
      };

      // 1. Package Managers via lockfiles
      if (fs.existsSync(path.join(root, 'pnpm-lock.yaml'))) result.packageManagers.push({ name: 'pnpm' });
      if (fs.existsSync(path.join(root, 'package-lock.json'))) result.packageManagers.push({ name: 'npm' });
      if (fs.existsSync(path.join(root, 'yarn.lock'))) result.packageManagers.push({ name: 'yarn' });
      if (fs.existsSync(path.join(root, 'bun.lockb')) || fs.existsSync(path.join(root, 'bun.lock'))) result.packageManagers.push({ name: 'bun' });
      if (fs.existsSync(path.join(root, 'composer.lock')) || fs.existsSync(path.join(root, 'composer.json'))) result.packageManagers.push({ name: 'composer' });
      if (fs.existsSync(path.join(root, 'Cargo.lock')) || fs.existsSync(path.join(root, 'Cargo.toml'))) result.packageManagers.push({ name: 'cargo' });
      if (fs.existsSync(path.join(root, 'poetry.lock'))) result.packageManagers.push({ name: 'poetry' });

      // 2. Node / JS / TS ecosystem (package.json)
      const pkgPath = path.join(root, 'package.json');
      if (fs.existsSync(pkgPath)) {
        try {
          const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
          const deps = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});

          result.languages.push({ name: 'JavaScript' });
          if (deps.typescript || fs.existsSync(path.join(root, 'tsconfig.json'))) {
            result.languages.push({ name: 'TypeScript', version: deps.typescript || 'detected' });
          }

          const fwList = [
            'react', 'react-dom', 'react-native', 'expo', 'next', 'vue', 'nuxt', 'vite',
            'tailwindcss', '@nestjs/core', 'express', 'fastify', 'adonisjs', '@adonisjs/core',
            'svelte', 'astro', 'zod'
          ];
          fwList.forEach(fw => {
            if (deps[fw]) result.frameworks.push({ name: fw, version: deps[fw] });
          });

          const dbDeps = {
            'pg': 'PostgreSQL',
            '@prisma/client': 'Prisma ORM',
            'prisma': 'Prisma ORM',
            'mysql2': 'MySQL',
            'mysql': 'MySQL',
            'ioredis': 'Redis',
            'redis': 'Redis',
            'mongoose': 'MongoDB',
            'mongodb': 'MongoDB',
            'better-sqlite3': 'SQLite',
            'sqlite3': 'SQLite'
          };
          Object.keys(dbDeps).forEach(d => {
            if (deps[d] && !result.databases.some(item => item.name === dbDeps[d])) {
              result.databases.push({ name: dbDeps[d], package: d, version: deps[d] });
            }
          });
        } catch (e) {}
      }

      // 3. PHP / Laravel ecosystem (composer.json)
      const compPath = path.join(root, 'composer.json');
      if (fs.existsSync(compPath)) {
        try {
          const comp = JSON.parse(fs.readFileSync(compPath, 'utf8'));
          const req = Object.assign({}, comp.require || {}, comp['require-dev'] || {});
          result.languages.push({ name: 'PHP', version: req.php || 'detected' });

          const phpFws = ['laravel/framework', 'pestphp/pest', 'phpunit/phpunit', 'symfony/framework-bundle', 'livewire/livewire', 'filament/filament'];
          phpFws.forEach(pfw => {
            if (req[pfw]) result.frameworks.push({ name: pfw, version: req[pfw] });
          });
        } catch (e) {}
      }

      // 4. Go ecosystem (go.mod)
      const goModPath = path.join(root, 'go.mod');
      if (fs.existsSync(goModPath)) {
        try {
          const content = fs.readFileSync(goModPath, 'utf8');
          const goVerMatch = content.match(/^go\s+([0-9.]+)/m);
          result.languages.push({ name: 'Go', version: goVerMatch ? goVerMatch[1] : 'detected' });
          if (content.includes('gin-gonic/gin')) result.frameworks.push({ name: 'gin' });
          if (content.includes('labstack/echo')) result.frameworks.push({ name: 'echo' });
          if (content.includes('gofiber/fiber')) result.frameworks.push({ name: 'fiber' });
        } catch (e) {}
      }

      // 5. Rust ecosystem (Cargo.toml)
      const cargoPath = path.join(root, 'Cargo.toml');
      if (fs.existsSync(cargoPath)) {
        try {
          const content = fs.readFileSync(cargoPath, 'utf8');
          const edMatch = content.match(/edition\s*=\s*[\"']([^\"']+)[\"']/);
          result.languages.push({ name: 'Rust', edition: edMatch ? edMatch[1] : 'detected' });
          if (content.includes('actix-web')) result.frameworks.push({ name: 'actix-web' });
          if (content.includes('axum')) result.frameworks.push({ name: 'axum' });
          if (content.includes('tokio')) result.frameworks.push({ name: 'tokio' });
        } catch (e) {}
      }

      // 6. Python ecosystem (pyproject.toml / requirements.txt)
      const pyProjPath = path.join(root, 'pyproject.toml');
      const reqTxtPath = path.join(root, 'requirements.txt');
      if (fs.existsSync(pyProjPath) || fs.existsSync(reqTxtPath)) {
        result.languages.push({ name: 'Python' });
        const pyContent = (fs.existsSync(pyProjPath) ? fs.readFileSync(pyProjPath, 'utf8') : '') +
                          (fs.existsSync(reqTxtPath) ? fs.readFileSync(reqTxtPath, 'utf8') : '');
        ['fastapi', 'django', 'flask', 'torch', 'pydantic'].forEach(pfw => {
          if (new RegExp('\\b' + pfw + '\\b', 'i').test(pyContent)) {
            result.frameworks.push({ name: pfw });
          }
        });
      }

      // 7. Databases via Docker Compose
      const composeFiles = ['docker-compose.yml', 'docker-compose.yaml'];
      composeFiles.forEach(cf => {
        const cPath = path.join(root, cf);
        if (fs.existsSync(cPath)) {
          try {
            const composeContent = fs.readFileSync(cPath, 'utf8');
            const dbImages = {
              'postgres': 'PostgreSQL',
              'mysql': 'MySQL',
              'mariadb': 'MariaDB',
              'mongo': 'MongoDB',
              'redis': 'Redis'
            };
            Object.keys(dbImages).forEach(dbi => {
              const regex = new RegExp('image:\\s*(?:.*\\/)?' + dbi + '(?::([a-zA-Z0-9_.-]+))?', 'i');
              const match = composeContent.match(regex);
              if (match && !result.databases.some(item => item.name === dbImages[dbi])) {
                result.databases.push({ name: dbImages[dbi], version: match[1] || 'latest' });
              }
            });
          } catch (e) {}
        }
      });

      console.log(JSON.stringify(result, null, 2));
    " "${ROOT_DIR}"
  else
    # Fallback minimal JSON si node n'est pas disponible
    echo "{\"languages\": [], \"frameworks\": [], \"packageManagers\": [], \"databases\": []}"
  fi
  exit 0
fi

# ==============================================================================
# MODE 2 : SORTIE TEXTE FORMATÉE PAR DÉFAUT
# ==============================================================================
echo -e "${BLUE}🔍 [san_searcher] Analyse des manifestes locaux dans : ${CYAN}${ROOT_DIR}${NC}"
echo -e "${BOLD}=== PINNING DES VERSIONS DE LA STACK LOCALE ===${NC}"

VERSIONS_FOUND=0

# 1. Écosystème Node.js / JavaScript / TypeScript (package.json)
if [[ -f "${ROOT_DIR}/package.json" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${GREEN}📦 Manifeste détecté : package.json${NC}"

  if command -v node >/dev/null 2>&1; then
    node -e "
      const fs = require('fs');
      try {
        const pkg = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
        const deps = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});
        const targets = [
          'react', 'react-dom', 'react-native', 'expo', 'next', 'vue', 'vite',
          'tailwindcss', 'typescript', '@nestjs/core', 'express', 'fastify',
          'adonisjs', '@adonisjs/core', 'zod', 'prisma', '@prisma/client'
        ];
        if (pkg.name) console.log('  - Nom du package : ' + pkg.name + (pkg.version ? ' (' + pkg.version + ')' : ''));
        targets.forEach(t => {
          if (deps[t]) console.log('  - ' + t + ' : ' + deps[t]);
        });
      } catch (e) {
        console.error('Erreur lecture package.json:', e.message);
      }
    " "${ROOT_DIR}/package.json" || true
  else
    grep -E '"(react|expo|next|vue|tailwindcss|typescript)"' "${ROOT_DIR}/package.json" | sed 's/^[ \t]*/  - /' || true
  fi
fi

# 2. Écosystème PHP / Laravel (composer.json)
if [[ -f "${ROOT_DIR}/composer.json" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${CYAN}🐘 Manifeste détecté : composer.json${NC}"

  if command -v php >/dev/null 2>&1; then
    php -r "
      \$content = @file_get_contents('${ROOT_DIR}/composer.json');
      if (\$content) {
        \$json = json_decode(\$content, true);
        \$req = array_merge(\$json['require'] ?? [], \$json['require-dev'] ?? []);
        \$targets = [
          'php', 'laravel/framework', 'pestphp/pest', 'phpunit/phpunit',
          'laravel/sanctum', 'livewire/livewire', 'inertiajs/inertia-laravel',
          'symfony/framework-bundle', 'filament/filament'
        ];
        foreach (\$targets as \$t) {
          if (isset(\$req[\$t])) {
            echo '  - ' . \$t . ' : ' . \$req[\$t] . PHP_EOL;
          }
        }
      }
    " || true
  elif command -v node >/dev/null 2>&1; then
    node -e "
      const fs = require('fs');
      try {
        const comp = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
        const deps = Object.assign({}, comp.require || {}, comp['require-dev'] || {});
        const targets = ['php', 'laravel/framework', 'pestphp/pest', 'laravel/sanctum', 'livewire/livewire', 'symfony/framework-bundle'];
        targets.forEach(t => {
          if (deps[t]) console.log('  - ' + t + ' : ' + deps[t]);
        });
      } catch (e) {}
    " "${ROOT_DIR}/composer.json" || true
  else
    grep -E '"(php|laravel/framework|pestphp/pest)"' "${ROOT_DIR}/composer.json" | sed 's/^[ \t]*/  - /' || true
  fi
fi

# 3. Écosystème Go (go.mod)
if [[ -f "${ROOT_DIR}/go.mod" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${CYAN}🐹 Manifeste détecté : go.mod${NC}"
  grep -E "^go [0-9]" "${ROOT_DIR}/go.mod" | sed 's/^/  - Version Go : /' || true
  grep -E "github\.com/(gin-gonic/gin|labstack/echo|gofiber/fiber|go-chi/chi)" "${ROOT_DIR}/go.mod" | sed 's/^[ \t]*/  - /' || true
fi

# 4. Écosystème Rust (Cargo.toml)
if [[ -f "${ROOT_DIR}/Cargo.toml" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${YELLOW}🦀 Manifeste détecté : Cargo.toml${NC}"
  grep -E "^edition[ ]*=" "${ROOT_DIR}/Cargo.toml" | sed 's/^[ \t]*/  - /' || true
  grep -E "^(tokio|actix-web|axum|serde)[ ]*=" "${ROOT_DIR}/Cargo.toml" | sed 's/^[ \t]*/  - /' || true
fi

# 5. Écosystème Python (pyproject.toml / requirements.txt)
if [[ -f "${ROOT_DIR}/pyproject.toml" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${CYAN}🐍 Manifeste détecté : pyproject.toml${NC}"
  grep -E "(fastapi|django|flask|torch|pydantic)" "${ROOT_DIR}/pyproject.toml" | sed 's/^[ \t]*/  - /' || true
elif [[ -f "${ROOT_DIR}/requirements.txt" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${CYAN}🐍 Manifeste détecté : requirements.txt${NC}"
  grep -E "^(fastapi|django|flask|torch|pydantic)" "${ROOT_DIR}/requirements.txt" | head -n 10 | sed 's/^/  - /' || true
fi

# 6. Écosystème Conteneurs & Infrastructure (Dockerfile / docker-compose.yml)
if [[ -f "${ROOT_DIR}/Dockerfile" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${BLUE}🐳 Fichier conteneur : Dockerfile${NC}"
  grep -E "^FROM " "${ROOT_DIR}/Dockerfile" | sed 's/^/  - Image de base : /' || true
fi

if [[ -f "${ROOT_DIR}/docker-compose.yml" || -f "${ROOT_DIR}/docker-compose.yaml" ]]; then
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml"
  [[ ! -f "${COMPOSE_FILE}" ]] && COMPOSE_FILE="${ROOT_DIR}/docker-compose.yaml"
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  echo -e "${BLUE}🐙 Fichier orchestration : $(basename "${COMPOSE_FILE}")${NC}"
  grep -E "[ ]*image:[ ]*" "${COMPOSE_FILE}" | sed 's/^[ \t]*image:[ ]*/  - Service image : /' || true
fi

echo -e "${BOLD}===============================================${NC}"
if [[ ${VERSIONS_FOUND} -eq 0 ]]; then
  echo -e "${YELLOW}⚠️ Aucun manifeste standard (package.json, composer.json, Dockerfile, go.mod) détecté dans ce répertoire.${NC}"
  echo -e "${YELLOW}Vérifiez le chemin spécifié ou définissez manuellement les versions lors de vos recherches.${NC}"
  exit 1
else
  echo -e "${GREEN}✅ [san_searcher] Pinning de versions achevé avec succès (${VERSIONS_FOUND} manifestes analysés).${NC}"
  echo -e "${GREEN}💡 Consigne : Utilisez impérativement ces numéros de version dans vos requêtes search_web.${NC}"
  exit 0
fi
