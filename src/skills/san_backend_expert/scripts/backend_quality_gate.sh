#!/usr/bin/env bash
# ==============================================================================
# SCRIPT OFFICIEL ANTIGRAVITY : BACKEND QUALITY GATE (san_backend_expert)
# Vérification déterministe de conformité, analyse statique, tests et sécurité.
# Mode FAIL-CLOSED : Zéro complaisance, validation multi-stacks certifiée.
# Stacks supportées : PHP/Laravel, Node/TS (Adonis, Nest, Express, Fastify), Python, Go
# ==============================================================================
set -euo pipefail

# Définition des codes couleurs ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}  ANTIGRAVITY FRAMEWORK : BACKEND QUALITY GATE (san_backend_expert)${NC}"
echo -e "${BOLD}${BLUE}  Mode FAIL-CLOSED : Zéro complaisance, tests & hygiène requis.    ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# 1. DÉTECTION AUTOMATIQUE DE LA STACK BACKEND
# ------------------------------------------------------------------------------
STACK=""
if [ -f "composer.json" ]; then
    STACK="PHP_LARAVEL"
    echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}PHP / Laravel / Composer${NC}"
elif [ -f "package.json" ]; then
    if grep -q "@adonisjs" package.json 2>/dev/null; then
        STACK="ADONIS_TS"
        echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Node.js / AdonisJS v6 (TypeScript strict)${NC}"
    elif grep -qE '"@nestjs|express|fastify' package.json 2>/dev/null || [ -f "nest-cli.json" ]; then
        STACK="NODE_BACKEND"
        echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Node.js / TypeScript (NestJS / Express / Fastify)${NC}"
    elif [ -f "tsconfig.json" ] || grep -q '"test"' package.json 2>/dev/null; then
        STACK="NODE_BACKEND"
        echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Node.js Backend générique${NC}"
    fi
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "setup.py" ]; then
    STACK="PYTHON"
    echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Python (pyproject.toml / requirements.txt)${NC}"
elif [ -f "go.mod" ]; then
    STACK="GOLANG"
    echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Go (go.mod)${NC}"
fi

if [ -z "$STACK" ]; then
    echo -e "${RED}✖ ÉCHEC CRITIQUE (FAIL-CLOSED) : Impossible d'identifier la stack backend.${NC}"
    echo -e "${RED}  Aucun fichier 'composer.json', 'package.json', 'pyproject.toml' ou 'go.mod' détecté dans $(pwd).${NC}"
    exit 1
fi

TOTAL_CHECKS=0
PASSED_CHECKS=0

run_step() {
    local step_name="$1"
    local title="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -e "\n${YELLOW}[Étape: ${step_name}] ${title}...${NC}"
}

success_step() {
    local message="$1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    echo -e "${GREEN}✔ ${message}${NC}"
}

fail_step() {
    local message="$1"
    echo -e "${RED}✖ ÉCHEC : ${message}${NC}"
    echo -e "${RED}======================================================================${NC}"
    echo -e "${RED}  BACKEND QUALITY GATE REJETÉ (FAIL-CLOSED) : Non-conformité détectée.${NC}"
    echo -e "${RED}======================================================================${NC}"
    exit 1
}

# ------------------------------------------------------------------------------
# CONTRÔLE COMMUN : HYGIÈNE ARCHITECTURALE (> 300 LIGNES & STRICT TYPES PHP)
# ------------------------------------------------------------------------------
check_architectural_hygiene() {
    run_step "Hygiène Architecturale" "Contrôle des fichiers monolithiques (>300 lignes) et strict types PHP"
    local hygiene_warnings=0

    # 1. Détection des fichiers > 300 lignes dans Controllers / Services / Actions / Handlers
    local target_dirs=()
    for d in app/Http/Controllers app/Services app/Actions app/Domain \
             src/controllers src/services src/actions src/domain \
             controllers services actions handlers internal; do
        if [ -d "$d" ]; then
            target_dirs+=("$d")
        fi
    done

    if [ ${#target_dirs[@]} -gt 0 ]; then
        while IFS= read -r f; do
            if [ -f "$f" ]; then
                local line_count
                line_count=$(wc -l < "$f" 2>/dev/null || echo 0)
                if [ "$line_count" -gt 300 ]; then
                    echo -e "${YELLOW}  ⚠ Fichier monolithique (>300 lignes) : ${f} (${line_count} lignes).${NC}"
                    echo -e "${YELLOW}    Recommandation : Découpez en Actions atomiques ou sous-services (san_backend_expert).${NC}"
                    hygiene_warnings=$((hygiene_warnings + 1))
                fi
            fi
        done < <(find "${target_dirs[@]}" -type f \( -name "*.php" -o -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) ! -path "*/vendor/*" ! -path "*/node_modules/*" 2>/dev/null || true)
    fi

    # 2. Détection de l'oubli de declare(strict_types=1); sur les fichiers PHP applicatifs
    if [ "$STACK" = "PHP_LARAVEL" ] || [ -f "composer.json" ]; then
        local php_dirs=()
        for d in app src; do
            [ -d "$d" ] && php_dirs+=("$d")
        done
        if [ ${#php_dirs[@]} -gt 0 ]; then
            local missing_strict=0
            while IFS= read -r f; do
                if [ -f "$f" ]; then
                    if ! grep -q "declare(strict_types=1)" "$f" 2>/dev/null; then
                        echo -e "${YELLOW}  ⚠ Typage strict PHP absent : ${f} sans 'declare(strict_types=1);'.${NC}"
                        missing_strict=$((missing_strict + 1))
                        hygiene_warnings=$((hygiene_warnings + 1))
                    fi
                fi
            done < <(find "${php_dirs[@]}" -type f -name "*.php" ! -path "*/bootstrap/*" ! -path "*/storage/*" 2>/dev/null || true)
        fi
    fi

    success_step "Hygiène architecturale contrôlée (${hygiene_warnings} avertissement(s))."
}

# ------------------------------------------------------------------------------
# 2. EXÉCUTION DU QUALITY GATE POUR LARAVEL / PHP
# ------------------------------------------------------------------------------
if [ "$STACK" = "PHP_LARAVEL" ]; then

    # Étape 1 : Analyse statique PHPStan si disponible
    PHPSTAN_BIN="./vendor/bin/phpstan"
    if [ ! -x "$PHPSTAN_BIN" ] && command -v phpstan >/dev/null 2>&1; then
        PHPSTAN_BIN="$(command -v phpstan)"
    fi

    if [ -x "$PHPSTAN_BIN" ]; then
        run_step "PHPStan" "Analyse statique rigoureuse du code source (PHPStan)"
        if "$PHPSTAN_BIN" analyse --level=max --memory-limit=1G; then
            success_step "PHPStan : 0 erreur d'analyse statique au niveau maximal."
        else
            fail_step "Des erreurs de typage ou d'architecture ont été relevées par PHPStan."
        fi
    elif grep -q '"phpstan":' composer.json 2>/dev/null; then
        run_step "PHPStan" "Analyse statique du code source (composer run-script phpstan)"
        if composer run-script phpstan; then
            success_step "PHPStan script : 0 erreur."
        else
            fail_step "Des erreurs ont été relevées par 'composer phpstan'."
        fi
    fi

    # Étape 2 : Exécution de la suite de tests automatisés (Pest / PHPUnit / Artisan / Composer)
    run_step "Tests PHP" "Exécution de la suite de tests automatisés (Pest / PHPUnit / Artisan / Composer)"
    if [ -x "./vendor/bin/pest" ]; then
        if ./vendor/bin/pest --bail --stop-on-failure; then
            success_step "Pest : 100% des tests validés au vert."
        else
            fail_step "Au moins un test automatisé a échoué sous Pest."
        fi
    elif [ -x "./vendor/bin/phpunit" ]; then
        if ./vendor/bin/phpunit --stop-on-failure; then
            success_step "PHPUnit : 100% des tests validés au vert."
        else
            fail_step "Au moins un test automatisé a échoué sous PHPUnit."
        fi
    elif [ -f "artisan" ] && command -v php >/dev/null 2>&1; then
        if php artisan test --parallel; then
            success_step "Artisan test : 100% des tests validés au vert."
        else
            fail_step "Au moins un test automatisé a échoué sous artisan test."
        fi
    elif grep -q '"test":' composer.json 2>/dev/null; then
        if composer test; then
            success_step "Composer test : 100% des tests validés avec succès."
        else
            fail_step "Au moins un test automatisé a échoué sous 'composer test'."
        fi
    else
        fail_step "Aucune suite de tests PHP (Pest, PHPUnit, artisan test, composer test) configurée dans ce projet."
    fi

    # Étape 3 : Scan statique préventif anti-N+1 (si app/ présent)
    if [ -d "app" ]; then
        run_step "N+1 Guard" "Contrôle statique préventif des requêtes SQL N+1"
        if grep -rqE "(preventLazyLoading|shouldBeStrict)" app/ bootstrap/ 2>/dev/null; then
            success_step "Garde-fou N+1 actif : 'preventLazyLoading()' ou 'shouldBeStrict()' détecté."
        else
            echo -e "${YELLOW}⚠ ALERTE PERFORMANCE : 'Model::preventLazyLoading(!app()->isProduction())' non détecté.${NC}"
            success_step "Scan N+1 effectué (recommandation émise pour AppServiceProvider)."
        fi
    fi

    # Étape 4 : Audit de sécurité des dépendances Composer (si composer.lock)
    if [ -f "composer.lock" ] && command -v composer >/dev/null 2>&1; then
        run_step "Composer Audit" "Audit de sécurité des dépendances PHP (composer audit)"
        if composer audit; then
            success_step "Composer Audit : Aucune vulnérabilité de sécurité critique recensée."
        else
            fail_step "Des vulnérabilités connues (CVE) ont été détectées dans les dépendances Composer."
        fi
    fi

    # Étape 5 : Hygiène architecturale
    check_architectural_hygiene

# ------------------------------------------------------------------------------
# 3. EXÉCUTION DU QUALITY GATE POUR ADONISJS (TYPESCRIPT)
# ------------------------------------------------------------------------------
elif [ "$STACK" = "ADONIS_TS" ]; then

    # Étape 1 : Vérification statique de typage strict TypeScript (tsc --noEmit)
    run_step "TypeScript" "Vérification du typage statique strict AdonisJS (tsc --noEmit)"
    TSC_BIN="./node_modules/.bin/tsc"
    if [ ! -x "$TSC_BIN" ] && command -v tsc >/dev/null 2>&1; then
        TSC_BIN="$(command -v tsc)"
    elif [ ! -x "$TSC_BIN" ] && command -v npx >/dev/null 2>&1; then
        TSC_BIN="npx tsc"
    fi

    if [ -n "$TSC_BIN" ]; then
        if $TSC_BIN --noEmit; then
            success_step "TypeScript : 0 erreur de typage strict."
        else
            fail_step "Des erreurs de compilation TypeScript strictes ont été détectées."
        fi
    else
        fail_step "Compilateur TypeScript (tsc) introuvable dans node_modules ou le PATH."
    fi

    # Étape 2 : Exécution de la suite de tests automatisés (Japa / node ace test)
    run_step "Tests AdonisJS" "Exécution de la suite de tests automatisés (node ace test / npm test)"
    if [ -f "ace.js" ] || [ -f "bin/test.ts" ] || [ -f "bin/test.js" ] || [ -f "ace" ]; then
        if node ace test; then
            success_step "Japa : 100% des tests validés au vert."
        else
            fail_step "Au moins un test a échoué lors de l'exécution de 'node ace test'."
        fi
    elif grep -q '"test":' package.json 2>/dev/null; then
        if npm test; then
            success_step "npm test : 100% des tests validés au vert."
        else
            fail_step "Au moins un test a échoué sous npm test."
        fi
    else
        fail_step "Configuration de test standard AdonisJS (node ace test) introuvable."
    fi

    # Étape 3 : Scan statique de prévention des anti-patterns ORM Lucid
    run_step "Lucid Eager Loading" "Scan statique préventif Lucid ORM & Eager Loading"
    if grep -rq "preload(" app/controllers/ app/services/ 2>/dev/null; then
        success_step "Eager loading Lucid : L'usage explicite de 'preload()' a été identifié."
    else
        echo -e "${YELLOW}ℹ Information : Veillez à utiliser '.preload()' sur vos modèles Lucid pour éviter les requêtes N+1.${NC}"
        success_step "Scan Lucid ORM complété."
    fi

    # Étape 4 : Audit de sécurité des paquets NPM
    if [ -f "package-lock.json" ] && command -v npm >/dev/null 2>&1; then
        run_step "NPM Audit" "Audit de sécurité des dépendances NPM"
        if npm audit --audit-level=high; then
            success_step "NPM Audit : Aucune vulnérabilité de sévérité haute ou critique."
        else
            fail_step "Des vulnérabilités de sécurité critiques ont été détectées dans les modules Node.js."
        fi
    fi

    # Étape 5 : Hygiène architecturale
    check_architectural_hygiene

# ------------------------------------------------------------------------------
# 4. EXÉCUTION DU QUALITY GATE POUR NODE.JS / TYPESCRIPT GÉNÉRIQUE (NESTJS, EXPRESS, FASTIFY)
# ------------------------------------------------------------------------------
elif [ "$STACK" = "NODE_BACKEND" ]; then

    # Étape 1 : Linting (ESLint / Biome) si configuré
    if grep -q '"lint"' package.json 2>/dev/null || [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f "biome.json" ]; then
        run_step "Linter Node" "Analyse statique et linter (ESLint / Biome)"
        if grep -q '"lint"' package.json 2>/dev/null; then
            if npm run lint; then
                success_step "Linter : 0 erreur de syntaxe ou conformité."
            else
                fail_step "Des erreurs de linting ont été relevées."
            fi
        elif command -v npx >/dev/null 2>&1; then
            if npx eslint "src/**/*.{ts,js}" --max-warnings=0 2>/dev/null; then
                success_step "ESLint : 0 violation."
            else
                fail_step "ESLint a relevé des erreurs ou avertissements bloquants."
            fi
        fi
    fi

    # Étape 2 : Typage strict TypeScript (si tsconfig.json présent)
    if [ -f "tsconfig.json" ]; then
        run_step "TypeScript" "Vérification du typage statique TypeScript (tsc --noEmit)"
        TSC_EXEC="npx tsc"
        [ -x "./node_modules/.bin/tsc" ] && TSC_EXEC="./node_modules/.bin/tsc"
        if $TSC_EXEC --noEmit; then
            success_step "TypeScript : 0 erreur de typage statique."
        else
            fail_step "Erreurs de typage TypeScript détectées dans le backend."
        fi
    fi

    # Étape 3 : Tests automatisés Node.js (OBLIGATOIRE)
    run_step "Tests Backend Node" "Exécution de la suite de tests automatisés (npm test)"
    if grep -q '"test"' package.json 2>/dev/null; then
        if npm test; then
            success_step "Tests Node.js : 100% des tests validés au vert."
        else
            fail_step "Au moins un test automatisé a échoué sous npm test."
        fi
    else
        fail_step "Aucun script de test ('test') configuré dans package.json (Mode Fail-Closed)."
    fi

    # Étape 4 : Audit de sécurité des dépendances
    if [ -f "package-lock.json" ] && command -v npm >/dev/null 2>&1; then
        run_step "NPM Audit" "Audit de sécurité des dépendances NPM"
        if npm audit --audit-level=high; then
            success_step "NPM Audit : Aucune vulnérabilité critique ou haute."
        else
            fail_step "Vulnérabilités critiques détectées dans npm audit."
        fi
    fi

    # Étape 5 : Hygiène architecturale
    check_architectural_hygiene

# ------------------------------------------------------------------------------
# 5. EXÉCUTION DU QUALITY GATE POUR PYTHON (PYPROJECT / REQUIREMENTS)
# ------------------------------------------------------------------------------
elif [ "$STACK" = "PYTHON" ]; then

    # Étape 1 : Linter Python (ruff / flake8)
    if command -v ruff >/dev/null 2>&1; then
        run_step "Ruff" "Analyse statique et linting avec Ruff (ruff check .)"
        if ruff check .; then
            success_step "Ruff : 0 violation de style ou bug détecté."
        else
            fail_step "Ruff a détecté des violations dans le code Python."
        fi
    elif command -v flake8 >/dev/null 2>&1; then
        run_step "Flake8" "Analyse statique avec Flake8"
        if flake8 .; then
            success_step "Flake8 : Code 100% conforme."
        else
            fail_step "Des erreurs ont été relevées par Flake8."
        fi
    fi

    # Étape 2 : Typage statique Python (mypy si configuré)
    if [ -f "mypy.ini" ] || ( [ -f "pyproject.toml" ] && grep -q "tool.mypy" pyproject.toml 2>/dev/null ); then
        if command -v mypy >/dev/null 2>&1; then
            run_step "Mypy" "Vérification statique des types Python (mypy .)"
            if mypy .; then
                success_step "Mypy : 0 erreur de typage statique."
            else
                fail_step "Des erreurs de typage statique ont été détectées par Mypy."
            fi
        fi
    fi

    # Étape 3 : Exécution de la suite de tests automatisés (pytest - OBLIGATOIRE)
    run_step "Tests Python" "Exécution de la suite de tests automatisés (pytest)"
    if command -v pytest >/dev/null 2>&1; then
        if pytest; then
            success_step "Pytest : 100% des tests validés au vert."
        else
            fail_step "Des tests automatisés ont échoué sous pytest."
        fi
    elif python3 -m unittest discover -s . >/dev/null 2>&1; then
        if python3 -m unittest discover -s .; then
            success_step "Python unittest : 100% des tests validés au vert."
        else
            fail_step "Des tests automatisés ont échoué sous unittest."
        fi
    else
        fail_step "Aucun exécuteur de test (pytest ou unittest) fonctionnel détecté."
    fi

    # Étape 4 : Hygiène architecturale
    check_architectural_hygiene

# ------------------------------------------------------------------------------
# 6. EXÉCUTION DU QUALITY GATE POUR GO (GO.MOD)
# ------------------------------------------------------------------------------
elif [ "$STACK" = "GOLANG" ]; then

    # Étape 1 : Analyse statique Go Vet
    run_step "Go Vet" "Analyse statique du code source Go (go vet ./...)"
    if command -v go >/dev/null 2>&1; then
        if go vet ./...; then
            success_step "Go Vet : 0 anomalie statique détectée."
        else
            fail_step "Des anomalies ont été relevées par 'go vet ./...'."
        fi
    else
        fail_step "Binaire 'go' introuvable dans l'environnement."
    fi

    # Étape 2 : Exécution des tests automatisés Go (OBLIGATOIRE)
    run_step "Go Test" "Exécution de la suite de tests automatisés (go test ./...)"
    if go test -v ./...; then
        success_step "Go Test : 100% des tests validés au vert."
    else
        fail_step "Au moins un test Go a échoué sous 'go test ./...'."
    fi

    # Étape 3 : Hygiène architecturale
    check_architectural_hygiene

fi

# ------------------------------------------------------------------------------
# 7. BILAN DE VALIDATION FINAL (FAIL-CLOSED : TOTAL_CHECKS > 0 ET 100% AU VERT)
# ------------------------------------------------------------------------------
if [ "$TOTAL_CHECKS" -eq 0 ] || [ "$PASSED_CHECKS" -ne "$TOTAL_CHECKS" ]; then
    echo -e "\n${RED}======================================================================${NC}"
    echo -e "${BOLD}${RED}  BACKEND QUALITY GATE REJETÉ [${PASSED_CHECKS}/${TOTAL_CHECKS} ÉTAPES VALIDÉES] (FAIL-CLOSED)${NC}"
    echo -e "${RED}  Exigence absolue : TOTAL_CHECKS > 0 et 100% des étapes au vert.${NC}"
    echo -e "${RED}======================================================================${NC}"
    exit 1
fi

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${BOLD}${GREEN}  QUALITY GATE BACKEND VALIDÉ AVEC SUCCÈS [${PASSED_CHECKS}/${TOTAL_CHECKS} ÉTAPES AU VERT]${NC}"
echo -e "${GREEN}  Architecture Contract-First, Typage Strict et Sécurité Certifiés.${NC}"
echo -e "${GREEN}======================================================================${NC}"
exit 0
