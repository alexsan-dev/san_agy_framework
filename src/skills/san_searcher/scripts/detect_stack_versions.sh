#!/usr/bin/env bash
# scripts/detect_stack_versions.sh
# Extraction déterministe et cartésienne des versions de frameworks, runtimes et dépendances clés d'un projet.
# Usage: ./detect_stack_versions.sh [PROJECT_ROOT]
# Options:
#   -h, --help    Affiche l'aide
#   --json        Affiche le résumé au format JSON

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
  echo -e "${RED}❌ Erreur : Le répertoire '${ROOT_DIR}' est introuvable.${NC}" >&2
  exit 1
fi

ROOT_DIR="$(cd "${ROOT_DIR}" && pwd)"

if [[ "${JSON_OUTPUT}" == "false" ]]; then
  echo -e "${BLUE}🔍 [san_searcher] Analyse des manifestes locaux dans : ${CYAN}${ROOT_DIR}${NC}"
  echo -e "${BOLD}=== PINNING DES VERSIONS DE LA STACK LOCALE ===${NC}"
fi

VERSIONS_FOUND=0

# 1. Écosystème Node.js / JavaScript / TypeScript (package.json)
if [[ -f "${ROOT_DIR}/package.json" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${GREEN}📦 Manifeste détecté : package.json${NC}"
  fi
  
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
    # Fallback grep/sed si node absent
    grep -E '"(react|expo|next|vue|tailwindcss|typescript)"' "${ROOT_DIR}/package.json" | sed 's/^[ \t]*/  - /' || true
  fi
fi

# 2. Écosystème PHP / Laravel (composer.json)
if [[ -f "${ROOT_DIR}/composer.json" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${CYAN}🐘 Manifeste détecté : composer.json${NC}"
  fi
  
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
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${CYAN}🐹 Manifeste détecté : go.mod${NC}"
    grep -E "^go [0-9]" "${ROOT_DIR}/go.mod" | sed 's/^/  - Version Go : /' || true
    grep -E "github\.com/(gin-gonic/gin|labstack/echo|gofiber/fiber|go-chi/chi)" "${ROOT_DIR}/go.mod" | sed 's/^[ \t]*/  - /' || true
  fi
fi

# 4. Écosystème Rust (Cargo.toml)
if [[ -f "${ROOT_DIR}/Cargo.toml" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${YELLOW}🦀 Manifeste détecté : Cargo.toml${NC}"
    grep -E "^edition[ ]*=" "${ROOT_DIR}/Cargo.toml" | sed 's/^[ \t]*/  - /' || true
    grep -E "^(tokio|actix-web|axum|serde)[ ]*=" "${ROOT_DIR}/Cargo.toml" | sed 's/^[ \t]*/  - /' || true
  fi
fi

# 5. Écosystème Python (pyproject.toml / requirements.txt)
if [[ -f "${ROOT_DIR}/pyproject.toml" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${CYAN}🐍 Manifeste détecté : pyproject.toml${NC}"
    grep -E "(fastapi|django|flask|torch|pydantic)" "${ROOT_DIR}/pyproject.toml" | sed 's/^[ \t]*/  - /' || true
  fi
elif [[ -f "${ROOT_DIR}/requirements.txt" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${CYAN}🐍 Manifeste détecté : requirements.txt${NC}"
    grep -E "^(fastapi|django|flask|torch|pydantic)" "${ROOT_DIR}/requirements.txt" | head -n 10 | sed 's/^/  - /' || true
  fi
fi

# 6. Écosystème Conteneurs & Infrastructure (Dockerfile / docker-compose.yml)
if [[ -f "${ROOT_DIR}/Dockerfile" ]]; then
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${BLUE}🐳 Fichier conteneur : Dockerfile${NC}"
    grep -E "^FROM " "${ROOT_DIR}/Dockerfile" | sed 's/^/  - Image de base : /' || true
  fi
fi

if [[ -f "${ROOT_DIR}/docker-compose.yml" || -f "${ROOT_DIR}/docker-compose.yaml" ]]; then
  COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml"
  [[ ! -f "${COMPOSE_FILE}" ]] && COMPOSE_FILE="${ROOT_DIR}/docker-compose.yaml"
  VERSIONS_FOUND=$((VERSIONS_FOUND + 1))
  if [[ "${JSON_OUTPUT}" == "false" ]]; then
    echo -e "${BLUE}🐙 Fichier orchestration : $(basename "${COMPOSE_FILE}")${NC}"
    grep -E "[ ]*image:[ ]*" "${COMPOSE_FILE}" | sed 's/^[ \t]*image:[ ]*/  - Service image : /' || true
  fi
fi

if [[ "${JSON_OUTPUT}" == "false" ]]; then
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
fi
