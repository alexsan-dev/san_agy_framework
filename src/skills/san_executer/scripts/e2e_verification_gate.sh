#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : e2e_verification_gate.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : Alexsan.pro
# DESCRIPTION : Contrôle de qualité automatisé Étage 1 Full-Stack (Zéro-Token LLM).
#               Coordonne le gate frontend, le gate backend et les contrats Bruno.
# USAGE : ./e2e_verification_gate.sh [--skip-bruno] [--help]
# ==============================================================================

set -euo pipefail

# Couleurs ANSI pour affichage terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_DIR="$(pwd)"

show_help() {
  cat << 'EOF'
Usage: e2e_verification_gate.sh [OPTIONS]

Coordonne le Quality Gate Étage 1 (Déterministe) du framework Antigravity :
1. Frontend Quality Gate (tsc, linters, tests unitaires Jest/Vitest, fuites mémoires)
2. Backend Quality Gate (PHPStan, Pest/Japa/Go/Pytest, scan N+1, audit dépendances)
3. Contrats d'API & Assertions Bruno (.bru)

Options:
  --skip-bruno   Ignore l'exécution des tests de contrats Bruno
  -v, --verbose  Mode verbeux avec logs détaillés
  -h, --help     Affiche ce message d'aide et quitte

Codes de retour :
  0  Succès total : tous les gates applicables sont au vert
  1  Échec d'au moins un composant du Quality Gate
EOF
}

SKIP_BRUNO=0
VERBOSE=0

for arg in "$@"; do
  case $arg in
    --skip-bruno)
      SKIP_BRUNO=1
      shift
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      # Argument inconnu ignoré ou pris en compte
      ;;
  esac
done

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}${BOLD}   ANTIGRAVITY : CONTRÔLE DE QUALITÉ ÉTAGE 1 (E2E VERIFICATION GATE)   ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${CYAN}Contexte d'exécution : ${CURRENT_DIR}${NC}\n"

FRONT_STATUS="SKIPPED"
BACKEND_STATUS="SKIPPED"
BRUNO_STATUS="SKIPPED"

GLOBAL_FAILURE=0

# ==============================================================================
# SECTION 1 : FRONTEND QUALITY GATE
# ==============================================================================
echo -e "${BLUE}${BOLD}--- [1/3] EXÉCUTION DU QUALITY GATE FRONTEND ---${NC}"

HAS_FRONTEND=0
if [[ -f "tsconfig.json" ]] || \
   ([[ -f "package.json" ]] && (grep -qE '"react"|"vue"|"svelte"|"expo"|"next"|"nuxt"|"vite"' package.json 2>/dev/null || [[ ! -f "composer.json" && ! -f "artisan" && ! -f "go.mod" && ! -f "pyproject.toml" ]])) || \
   [ -n "$(find . -maxdepth 3 -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | head -n 1)" ]; then
  HAS_FRONTEND=1
fi

if [[ $HAS_FRONTEND -eq 1 ]]; then
  # Recherche d'un script dédié front_quality_gate.sh
  FRONT_SCRIPT=""
  POSSIBLE_FRONT_PATHS=(
    "${CURRENT_DIR}/scripts/front_quality_gate.sh"
    "${CURRENT_DIR}/.agents/skills/san_ux_ui_expert/scripts/front_quality_gate.sh"
    "${SCRIPT_DIR}/../../san_ux_ui_expert/scripts/front_quality_gate.sh"
  )

  for p in "${POSSIBLE_FRONT_PATHS[@]}"; do
    if [[ -f "$p" ]]; then
      FRONT_SCRIPT="$p"
      break
    fi
  done

  if [[ -n "$FRONT_SCRIPT" ]]; then
    echo -e "${CYAN}ℹ Script Frontend dédié détecté : ${FRONT_SCRIPT}${NC}"
    set +e
    bash "$FRONT_SCRIPT"
    FRONT_CODE=$?
    set -e
    if [[ $FRONT_CODE -eq 0 ]]; then
      echo -e "${GREEN}✔ Gate Frontend (scripté) validé avec succès.${NC}"
      FRONT_STATUS="PASS"
    else
      echo -e "${RED}✖ ÉCHEC : Le Quality Gate Frontend a échoué (code: ${FRONT_CODE}).${NC}"
      FRONT_STATUS="FAIL"
      GLOBAL_FAILURE=1
    fi
  else
    echo -e "${CYAN}ℹ Stack Frontend détectée. Exécution des contrôles intégrés...${NC}"
    FRONT_LOCAL_FAIL=0

    # 1. Typage strict TypeScript si tsconfig.json présent
    if [[ -f "tsconfig.json" ]]; then
      echo -e "${YELLOW}  -> Contrôle de typage TypeScript (tsc --noEmit)...${NC}"
      if command -v pnpm >/dev/null 2>&1 && [[ -f "pnpm-lock.yaml" ]]; then
        pnpm exec tsc --noEmit || FRONT_LOCAL_FAIL=1
      elif command -v npm >/dev/null 2>&1; then
        npx tsc --noEmit || FRONT_LOCAL_FAIL=1
      fi
      if [[ $FRONT_LOCAL_FAIL -ne 0 ]]; then
        echo -e "${RED}  ✖ Erreur de compilation TypeScript.${NC}"
      else
        echo -e "${GREEN}  ✔ Typage TypeScript 100% valide.${NC}"
      fi
    fi

    # 2. Linter si script lint configuré
    if [[ $FRONT_LOCAL_FAIL -eq 0 && -f "package.json" ]] && grep -q '"lint"' package.json; then
      echo -e "${YELLOW}  -> Exécution du linter...${NC}"
      (npm run lint --silent || pnpm run lint --silent) || FRONT_LOCAL_FAIL=1
      if [[ $FRONT_LOCAL_FAIL -ne 0 ]]; then
        echo -e "${RED}  ✖ Erreurs de linting détectées.${NC}"
      else
        echo -e "${GREEN}  ✔ Linters au vert.${NC}"
      fi
    fi

    # 3. Tests unitaires / composants si configurés
    if [[ $FRONT_LOCAL_FAIL -eq 0 && -f "package.json" ]] && grep -q '"test"' package.json; then
      echo -e "${YELLOW}  -> Exécution de la suite de tests (Jest/Vitest/Test Runner)...${NC}"
      set +e
      npm test -- --watchAll=false 2>/dev/null || npm test 2>/dev/null || pnpm test 2>/dev/null
      TEST_RES=$?
      set -e
      if [[ $TEST_RES -ne 0 ]]; then
        echo -e "${RED}  ✖ Échec des tests frontend.${NC}"
        FRONT_LOCAL_FAIL=1
      else
        echo -e "${GREEN}  ✔ Tests frontend validés.${NC}"
      fi
    fi

    # 4. Détection préventive de fuite mémoire dans les useEffect
    if [[ $FRONT_LOCAL_FAIL -eq 0 && -d "src" ]]; then
      LEAK_COUNT=0
      for f in $(grep -rl "addEventListener" src/ 2>/dev/null || true); do
        if ! grep -q "removeEventListener" "$f"; then
          echo -e "${RED}  ⚠ Fuite mémoire potentielle dans $f : addEventListener sans removeEventListener.${NC}"
          LEAK_COUNT=$((LEAK_COUNT + 1))
        fi
      done
      if [[ $LEAK_COUNT -gt 0 ]]; then
        echo -e "${RED}  ✖ Détection de fuite(s) mémoire dans les hooks d'écoute.${NC}"
        FRONT_LOCAL_FAIL=1
      fi
    fi

    if [[ $FRONT_LOCAL_FAIL -eq 0 ]]; then
      echo -e "${GREEN}✔ Gate Frontend intégré validé avec succès.${NC}"
      FRONT_STATUS="PASS"
    else
      echo -e "${RED}✖ ÉCHEC : Le Gate Frontend intégré a échoué.${NC}"
      FRONT_STATUS="FAIL"
      GLOBAL_FAILURE=1
    fi
  fi
else
  echo -e "${YELLOW}ℹ Aucun composant Frontend détecté dans cet environnement.${NC}"
  FRONT_STATUS="SKIPPED"
fi

echo ""

# ==============================================================================
# SECTION 2 : BACKEND QUALITY GATE
# ==============================================================================
echo -e "${BLUE}${BOLD}--- [2/3] EXÉCUTION DU QUALITY GATE BACKEND ---${NC}"

HAS_BACKEND=0
if [[ -f "composer.json" || -f "artisan" ]] || \
   ([[ -f "package.json" ]] && grep -qE '"@adonisjs|"@nestjs|express|fastify' package.json 2>/dev/null) || \
   [[ -f "go.mod" || -f "pyproject.toml" || -f "pytest.ini" ]] || \
   ([[ -f "requirements.txt" ]] && grep -qi "pytest" requirements.txt 2>/dev/null); then
  HAS_BACKEND=1
fi

if [[ $HAS_BACKEND -eq 1 ]]; then
  # Recherche d'un script dédié backend_quality_gate.sh
  BACKEND_SCRIPT=""
  POSSIBLE_BACKEND_PATHS=(
    "${CURRENT_DIR}/scripts/backend_quality_gate.sh"
    "${CURRENT_DIR}/.agents/skills/san_backend_expert/scripts/backend_quality_gate.sh"
    "${SCRIPT_DIR}/../../san_backend_expert/scripts/backend_quality_gate.sh"
  )

  for p in "${POSSIBLE_BACKEND_PATHS[@]}"; do
    if [[ -f "$p" ]]; then
      BACKEND_SCRIPT="$p"
      break
    fi
  done

  if [[ -n "$BACKEND_SCRIPT" ]]; then
    echo -e "${CYAN}ℹ Script Backend dédié détecté : ${BACKEND_SCRIPT}${NC}"
    set +e
    bash "$BACKEND_SCRIPT"
    BACKEND_CODE=$?
    set -e
    if [[ $BACKEND_CODE -eq 0 ]]; then
      echo -e "${GREEN}✔ Gate Backend (scripté) validé avec succès.${NC}"
      BACKEND_STATUS="PASS"
    else
      echo -e "${RED}✖ ÉCHEC : Le Quality Gate Backend a échoué (code: ${BACKEND_CODE}).${NC}"
      BACKEND_STATUS="FAIL"
      GLOBAL_FAILURE=1
    fi
  else
    # Pas de script dédié, détection de la stack backend et exécution des contrôles
    BACK_LOCAL_FAIL=0

    if [[ -f "composer.json" || -f "artisan" ]]; then
      echo -e "${CYAN}ℹ Stack PHP / Laravel détectée.${NC}"
      
      # PHPStan analyse si présent
      if [[ -f "vendor/bin/phpstan" ]]; then
        echo -e "${YELLOW}  -> Analyse statique PHPStan...${NC}"
        ./vendor/bin/phpstan analyse --level=max --memory-limit=1G || BACK_LOCAL_FAIL=1
      fi

      # Tests Pest / PHPUnit / Artisan test / composer test
      if [[ $BACK_LOCAL_FAIL -eq 0 ]]; then
        echo -e "${YELLOW}  -> Exécution des tests Backend...${NC}"
        if [[ -f "vendor/bin/pest" ]]; then
          ./vendor/bin/pest --bail || BACK_LOCAL_FAIL=1
        elif [[ -f "vendor/bin/phpunit" ]]; then
          ./vendor/bin/phpunit --stop-on-failure || BACK_LOCAL_FAIL=1
        elif [[ -f "artisan" ]]; then
          php artisan test --parallel || BACK_LOCAL_FAIL=1
        elif grep -q '"test"' composer.json 2>/dev/null; then
          composer test || BACK_LOCAL_FAIL=1
        fi
      fi

      # Contrôle N+1 si Laravel
      if [[ $BACK_LOCAL_FAIL -eq 0 && -d "app" ]]; then
        if grep -rq "preventLazyLoading" app/ 2>/dev/null; then
          echo -e "${GREEN}  ✔ Détection N+1 active (Model::preventLazyLoading).${NC}"
        fi
      fi

    elif [[ -f "adonisrc.ts" || -f "adonisrc.json" ]] || ([[ -f "package.json" ]] && grep -q "@adonisjs" package.json 2>/dev/null); then
      echo -e "${CYAN}ℹ Stack AdonisJS détectée.${NC}"
      if command -v node >/dev/null 2>&1 && [[ -f "ace" ]]; then
        node ace test || BACK_LOCAL_FAIL=1
      fi

    elif [[ -f "nest-cli.json" ]] || ([[ -f "package.json" ]] && grep -q "@nestjs" package.json 2>/dev/null); then
      echo -e "${CYAN}ℹ Stack NestJS détectée.${NC}"
      (npm test || pnpm test) || BACK_LOCAL_FAIL=1

    elif [[ -f "go.mod" ]]; then
      echo -e "${CYAN}ℹ Stack Golang détectée.${NC}"
      go test -v -race ./... || BACK_LOCAL_FAIL=1

    elif [[ -f "pyproject.toml" || -f "pytest.ini" ]] || ([[ -f "requirements.txt" ]] && grep -qi "pytest" requirements.txt 2>/dev/null); then
      echo -e "${CYAN}ℹ Stack Python détectée.${NC}"
      pytest -v || BACK_LOCAL_FAIL=1
    fi

    if [[ $BACK_LOCAL_FAIL -eq 0 ]]; then
      echo -e "${GREEN}✔ Gate Backend intégré validé avec succès.${NC}"
      BACKEND_STATUS="PASS"
    else
      echo -e "${RED}✖ ÉCHEC : Le Gate Backend intégré a échoué.${NC}"
      BACKEND_STATUS="FAIL"
      GLOBAL_FAILURE=1
    fi
  fi
else
  echo -e "${YELLOW}ℹ Aucun composant Backend détecté dans cet environnement.${NC}"
  BACKEND_STATUS="SKIPPED"
fi

echo ""

# ==============================================================================
# SECTION 3 : CONTRATS D'API & ASSERTIONS BRUNO
# ==============================================================================
echo -e "${BLUE}${BOLD}--- [3/3] VÉRIFICATION DES CONTRATS D'API & BRUNO ---${NC}"

API_VERIFICATION_NOTE=""

if [[ $SKIP_BRUNO -eq 1 ]]; then
  echo -e "${YELLOW}ℹ Tests Bruno ignorés via flag --skip-bruno.${NC}"
  BRUNO_STATUS="SKIPPED"
elif [[ -d "bruno" ]]; then
  echo -e "${CYAN}ℹ Dossier de collections Bruno 'bruno/' détecté.${NC}"
  if command -v bru >/dev/null 2>&1; then
    echo -e "${YELLOW}  -> Lancement des assertions de collection Bruno via CLI (bru run)...${NC}"
    set +e
    bru run bruno/ --bail
    BRUNO_CODE=$?
    set -e
    if [[ $BRUNO_CODE -eq 0 ]]; then
      echo -e "${GREEN}✔ Assertions Bruno 100% validées dynamiquement.${NC}"
      BRUNO_STATUS="PASS"
    else
      echo -e "${RED}✖ ÉCHEC : Des assertions de requêtes Bruno ont échoué.${NC}"
      BRUNO_STATUS="FAIL"
      GLOBAL_FAILURE=1
    fi
  else
    echo -e "${YELLOW}  -> CLI Bruno ('bru') non installé dans l'environnement.${NC}"
    echo -e "${YELLOW}  -> Analyse statique de conformité des fichiers .bru...${NC}"
    BRU_FILES=$(find bruno/ -type f -name "*.bru" 2>/dev/null || true)
    BRU_ERRORS=0
    if [[ -n "$BRU_FILES" ]]; then
      for bf in $BRU_FILES; do
        if ! grep -q "meta" "$bf" || ! grep -qE "(get|post|put|patch|delete)" "$bf"; then
          echo -e "${RED}  ✖ Fichier Bruno mal formé : $bf${NC}"
          BRU_ERRORS=$((BRU_ERRORS + 1))
        fi
      done
      if [[ $BRU_ERRORS -gt 0 ]]; then
        echo -e "${RED}✖ ÉCHEC : $BRU_ERRORS fichier(s) Bruno non conforme(s).${NC}"
        BRUNO_STATUS="FAIL"
        GLOBAL_FAILURE=1
      else
        echo -e "${YELLOW}  ⚠ Syntaxe et métadonnées des collections Bruno conformes (analyse statique).${NC}"
        echo -e "${YELLOW}  ⚠ Attention : Aucun test HTTP dynamique exécuté par 'bru' CLI.${NC}"
        BRUNO_STATUS="STATIC_ONLY_UNVERIFIED"

        # Mode Fail-Closed : Exiger qu'au moins une suite réelle de tests d'intégration API
        # (Bruno dynamique, Supertest, Pest HTTP, Pytest ou Go httptest) ait été exécutée avec exit 0
        if [[ "$BACKEND_STATUS" == "PASS" ]]; then
          echo -e "${GREEN}✔ Contrats d'API certifiés via la suite d'intégration backend (Pest/Supertest/Pytest/Go) validée au vert.${NC}"
          API_VERIFICATION_NOTE="Validé via la suite de tests d'intégration Backend"
        else
          echo -e "${RED}✖ ÉCHEC (FAIL-CLOSED) : 'bru' CLI n'a rien exécuté et aucune suite d'intégration API alternative n'a tourné avec succès.${NC}"
          echo -e "${RED}  Fin du Testing Theater : Au moins une suite réelle de tests d'intégration API (exit 0) est requise.${NC}"
          GLOBAL_FAILURE=1
        fi
      fi
    else
      echo -e "${YELLOW}ℹ Aucune requête .bru trouvée dans 'bruno/'.${NC}"
      BRUNO_STATUS="SKIPPED"
    fi
  fi
else
  # Vérification si des endpoints sont documentés mais orphelins de Bruno
  if [[ -d ".agents/rules/technicals/endpoints" ]]; then
    EP_COUNT=$(find .agents/rules/technicals/endpoints -type f -name "*.md" 2>/dev/null | wc -l)
    if [[ $EP_COUNT -gt 0 ]]; then
      echo -e "${YELLOW}⚠ $EP_COUNT endpoint(s) spécifié(s) dans .agents/rules/technicals/endpoints/ sans dossier 'bruno/' associé.${NC}"
    fi
  fi
  echo -e "${YELLOW}ℹ Aucun dossier de tests Bruno 'bruno/' présent.${NC}"
  BRUNO_STATUS="SKIPPED"
fi

echo ""

# ==============================================================================
# SYNTHÈSE CONSOLIDÉE ET VERDICT FINAL
# ==============================================================================
echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}${BOLD}             RÉSUMÉ CONSOLIDÉ DU QUALITY GATE ÉTAGE 1                 ${NC}"
echo -e "${BLUE}======================================================================${NC}"

format_status() {
  local status="$1"
  case $status in
    PASS*)
      echo -e "${GREEN}${BOLD}[ PASS ]${NC}"
      ;;
    FAIL)
      echo -e "${RED}${BOLD}[ FAIL ]${NC}"
      ;;
    STATIC_ONLY_UNVERIFIED)
      echo -e "${YELLOW}${BOLD}[ STATIC_ONLY_UNVERIFIED ]${NC}"
      ;;
    NOT_RUN)
      echo -e "${YELLOW}[ NOT_RUN ]${NC}"
      ;;
    SKIPPED)
      echo -e "${YELLOW}[ SKIPPED ]${NC}"
      ;;
    *)
      echo -e "${status}"
      ;;
  esac
}

echo -e "  1. Quality Gate Frontend (UI, typage, tests)  : $(format_status "$FRONT_STATUS")"
echo -e "  2. Quality Gate Backend (Logique, tests, N+1) : $(format_status "$BACKEND_STATUS")"
echo -e "  3. Contrats d'API Bruno (Assertions HTTP)     : $(format_status "$BRUNO_STATUS")"
if [[ -n "$API_VERIFICATION_NOTE" ]]; then
  echo -e "     ↳ ${CYAN}Note : ${API_VERIFICATION_NOTE}${NC}"
fi
echo -e "${BLUE}======================================================================${NC}"

CHECKS_RUN=0
if [[ "$FRONT_STATUS" == "PASS" ]]; then
  CHECKS_RUN=$((CHECKS_RUN + 1))
fi
if [[ "$BACKEND_STATUS" == "PASS" ]]; then
  CHECKS_RUN=$((CHECKS_RUN + 1))
fi
if [[ "$BRUNO_STATUS" == "PASS" ]]; then
  CHECKS_RUN=$((CHECKS_RUN + 1))
fi

if [[ $GLOBAL_FAILURE -ne 0 ]]; then
  echo -e "${RED}${BOLD}[VERDICT : ÉCHEC] L'Étage 1 du Quality Gate n'est pas validé.${NC}"
  echo -e "${RED}Arrêt immédiat de la chaîne : le code doit être corrigé avant tout audit LLM Étage 2.${NC}"
  exit 1
fi

if [[ $CHECKS_RUN -eq 0 ]] || [[ "$FRONT_STATUS" == "SKIPPED" && "$BACKEND_STATUS" == "SKIPPED" && ( "$BRUNO_STATUS" == "SKIPPED" || "$BRUNO_STATUS" == "STATIC_ONLY_UNVERIFIED" ) ]]; then
  echo -e "${RED}${BOLD}[VERDICT : ÉCHEC (FAIL-CLOSED)] Aucun contrôle réel n'a été exécuté (CHECKS_RUN == 0).${NC}"
  echo -e "${RED}Tous les composants sont SKIPPED ou non exécutés. Fin du Testing Theater : au moins un gate réel doit être exécuté et validé.${NC}"
  exit 1
fi

echo -e "${GREEN}${BOLD}[VERDICT : SUCCÈS TOTAL] L'Étage 1 est 100% vert (${CHECKS_RUN} composant(s) validé(s)).${NC}"
echo -e "${GREEN}Autorisation formelle accordée pour le passage à l'Étage 2 (Audit LLM & Pentest).${NC}"
exit 0
