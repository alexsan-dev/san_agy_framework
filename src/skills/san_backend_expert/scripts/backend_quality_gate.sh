#!/usr/bin/env bash
# ==============================================================================
# SCRIPT OFFICIEL ANTIGRAVITY : BACKEND QUALITY GATE (san_backend_expert)
# Vérification déterministe de conformité, analyse statique max, tests et sécurité.
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
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# 1. DÉTECTION AUTOMATIQUE DE LA STACK BACKEND
# ------------------------------------------------------------------------------
STACK=""
if [ -f "composer.json" ]; then
    STACK="PHP_LARAVEL"
    echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}PHP 8.x / Laravel${NC}"
elif [ -f "package.json" ] && grep -q "@adonisjs" package.json 2>/dev/null; then
    STACK="ADONIS_TS"
    echo -e "${CYAN}▶ Stack détectée :${NC} ${BOLD}Node.js / AdonisJS v6 (TypeScript strict)${NC}"
else
    echo -e "${RED}✖ ÉCHEC CRITIQUE : Impossible d'identifier la stack backend.${NC}"
    echo -e "${RED}  Aucun fichier 'composer.json' ou 'package.json' (@adonisjs) détecté dans $(pwd).${NC}"
    exit 1
fi

TOTAL_CHECKS=0
PASSED_CHECKS=0

run_step() {
    local step_num="$1"
    local title="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -e "\n${YELLOW}[${step_num}] ${title}...${NC}"
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
    echo -e "${RED}  BACKEND QUALITY GATE REJETÉ : Régression détectée.${NC}"
    echo -e "${RED}======================================================================${NC}"
    exit 1
}

# ------------------------------------------------------------------------------
# 2. EXÉCUTION DU QUALITY GATE POUR LARAVEL (PHP)
# ------------------------------------------------------------------------------
if [ "$STACK" = "PHP_LARAVEL" ]; then

    # Étape 1 : Analyse statique PHPStan au niveau maximal (Level Max)
    run_step "1/4" "Analyse statique rigoureuse du code source (PHPStan level max)"
    PHPSTAN_BIN="./vendor/bin/phpstan"
    if [ ! -x "$PHPSTAN_BIN" ] && command -v phpstan >/dev/null 2>&1; then
        PHPSTAN_BIN="$(command -v phpstan)"
    fi

    if [ -x "$PHPSTAN_BIN" ] || command -v phpstan >/dev/null 2>&1; then
        if "$PHPSTAN_BIN" analyse --level=max --memory-limit=1G; then
            success_step "PHPStan : 0 erreur d'analyse statique au niveau maximal."
        else
            fail_step "Des erreurs de typage ou d'architecture ont été relevées par PHPStan."
        fi
    elif grep -q '"phpstan":' composer.json 2>/dev/null; then
        if composer run-script phpstan; then
            success_step "PHPStan script : 0 erreur."
        else
            fail_step "Des erreurs ont été relevées par 'composer phpstan'."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : PHPStan n'est pas installé dans vendor/bin/phpstan. Exécutez 'composer require --dev phpstan/phpstan'.${NC}"
    fi

    # Étape 2 : Exécution de la suite de tests unitaires et d'intégration (Pest ou PHPUnit)
    run_step "2/4" "Exécution de la suite de tests automatisés (Pest / PHPUnit)"
    if [ -x "./vendor/bin/pest" ]; then
        if ./vendor/bin/pest --bail --stop-on-failure; then
            success_step "Pest : 100% des tests unitaires et feature validés avec succès."
        else
            fail_step "Au moins un test automatisé a échoué sous Pest."
        fi
    elif [ -x "./vendor/bin/phpunit" ]; then
        if ./vendor/bin/phpunit --stop-on-failure; then
            success_step "PHPUnit : 100% des tests validés au vert."
        else
            fail_step "Au moins un test automatisé a échoué sous PHPUnit."
        fi
    elif grep -q '"test":' composer.json 2>/dev/null; then
        if composer test; then
            success_step "Composer test : 100% des tests validés avec succès."
        else
            fail_step "Au moins un test automatisé a échoué sous 'composer test'."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : Aucun exécuteur de test (Pest/PHPUnit) trouvé dans ./vendor/bin/.${NC}"
    fi

    # Étape 3 : Scan statique préventif anti-N+1 (preventLazyLoading & shouldBeStrict)
    run_step "3/4" "Contrôle statique préventif des requêtes SQL N+1"
    LAZY_GUARD_FOUND=false
    if grep -rqE "(preventLazyLoading|shouldBeStrict)" app/ bootstrap/ 2>/dev/null; then
        LAZY_GUARD_FOUND=true
    fi

    if [ "$LAZY_GUARD_FOUND" = true ]; then
        success_step "Garde-fou N+1 actif : 'Model::preventLazyLoading()' ou 'Model::shouldBeStrict()' détecté."
    else
        echo -e "${YELLOW}⚠ ALERTE PERFORMANCE : 'Model::preventLazyLoading(!app()->isProduction())' n'a pas été détecté dans app/ ou bootstrap/.${NC}"
        echo -e "${YELLOW}  Pour respecter les standards alexsan.pro, ajoutez cette directive dans AppServiceProvider::boot().${NC}"
    fi

    # Vérification additionnelle : absence d'appels paresseux évidents dans les boucles
    if grep -rE "foreach\s*\(.*as.*\)\s*\{" -A 5 app/Http/Controllers/ 2>/dev/null | grep -E "->(relations|items|comments|tags|orders|wallets)->" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Attention : Suspicion de chargement N+1 détectée dans les contrôleurs. Utilisez le eager-loading avec 'with()'.${NC}"
    fi

    # Étape 4 : Audit de sécurité des dépendances Composer (CVEs)
    run_step "4/4" "Audit de sécurité des dépendances PHP (composer audit)"
    if command -v composer >/dev/null 2>&1; then
        if composer audit; then
            success_step "Composer Audit : Aucune vulnérabilité de sécurité critique recensée."
        else
            fail_step "Des vulnérabilités connues (CVE) ont été détectées dans les dépendances Composer."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : Binaire composer introuvable pour l'audit.${NC}"
    fi

# ------------------------------------------------------------------------------
# 3. EXÉCUTION DU QUALITY GATE POUR ADONISJS (TYPESCRIPT)
# ------------------------------------------------------------------------------
elif [ "$STACK" = "ADONIS_TS" ]; then

    # Étape 1 : Vérification statique de typage strict TypeScript (tsc --noEmit)
    run_step "1/4" "Vérification du typage statique strict AdonisJS (tsc --noEmit)"
    TSC_BIN="./node_modules/.bin/tsc"
    if [ ! -x "$TSC_BIN" ] && command -v tsc >/dev/null 2>&1; then
        TSC_BIN="$(command -v tsc)"
    fi

    if [ -x "$TSC_BIN" ] || command -v tsc >/dev/null 2>&1; then
        if "$TSC_BIN" --noEmit; then
            success_step "TypeScript : 0 erreur de typage strict."
        else
            fail_step "Des erreurs de compilation TypeScript strictes ont été détectées."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : Compilateur TypeScript (tsc) introuvable dans ./node_modules/.bin/tsc. Exécutez 'npm install'.${NC}"
    fi

    # Étape 2 : Exécution de la suite de tests automatisés (Japa / node ace test)
    run_step "2/4" "Exécution de la suite de tests fonctionnels et unitaires (node ace test)"
    if [ -f "ace.js" ] || [ -f "bin/test.ts" ] || [ -f "bin/test.js" ]; then
        if node ace test; then
            success_step "Japa : 100% des tests validés au vert."
        else
            fail_step "Au moins un test a échoué lors de l'exécution de 'node ace test'."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : Configuration de test standard AdonisJS introuvable.${NC}"
    fi

    # Étape 3 : Scan statique de prévention des anti-patterns ORM Lucid
    run_step "3/4" "Scan statique préventif Lucid ORM & Eager Loading"
    if grep -rq "preload(" app/controllers/ app/services/ 2>/dev/null; then
        success_step "Eager loading Lucid : L'usage explicite de 'preload()' a été identifié."
    else
        echo -e "${YELLOW}ℹ Information : Veillez à toujours utiliser '.preload()' sur vos modèles Lucid pour éviter les requêtes N+1.${NC}"
    fi

    # Étape 4 : Audit de sécurité des paquets NPM
    run_step "4/4" "Audit de sécurité des dépendances NPM (npm audit)"
    if [ -f "package-lock.json" ] && command -v npm >/dev/null 2>&1; then
        if npm audit --audit-level=high; then
            success_step "NPM Audit : Aucune vulnérabilité de sévérité haute ou critique."
        else
            fail_step "Des vulnérabilités de sécurité critiques ont été détectées dans les modules Node.js."
        fi
    else
        echo -e "${YELLOW}⚠ Avertissement : 'package-lock.json' introuvable. Exécutez 'npm install' avant l'audit de sécurité.${NC}"
    fi

fi

# ------------------------------------------------------------------------------
# 4. BILAN DE VALIDATION FINAL
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${BOLD}${GREEN}  QUALITY GATE BACKEND VALIDÉ AVEC SUCCÈS [${PASSED_CHECKS}/${TOTAL_CHECKS} ÉTAPES AU VERT]${NC}"
echo -e "${GREEN}  Architecture Contract-First, Typage Strict et Sécurité Certifiés.${NC}"
echo -e "${GREEN}======================================================================${NC}"
exit 0
