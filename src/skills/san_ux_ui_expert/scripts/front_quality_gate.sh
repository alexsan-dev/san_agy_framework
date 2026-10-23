#!/usr/bin/env bash
# scripts/front_quality_gate.sh
# Quality Gate déterministe pour l'ingénierie Frontend & Mobile Antigravity (san_ux_ui_expert).
#
# Vérifie :
# 1. TypeScript strict (tsc --noEmit)
# 2. Linters (ESLint / Biome)
# 3. Tests unitaires (Jest / Vitest)
# 4. Fuites mémoires dans les hooks useEffect
# 5. Dépendances critiques et bundles

set -euo pipefail

# Couleurs ANSI pour terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}   ANTIGRAVITY : QUALITY GATE FRONTEND & MOBILE (san_ux_ui_expert)   ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# -----------------------------------------------------------------------------
# AUTO-DÉTECTION INTELLIGENTE DU PACKAGE MANAGER (pnpm > bun > npm > yarn)
# -----------------------------------------------------------------------------
PM="npm"
RUN_CMD="npm run"
EXEC_CMD="npx"

if [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
  PM="pnpm"
  RUN_CMD="pnpm run"
  EXEC_CMD="pnpm exec"
elif [ -f "bun.lockb" ] || [ -f "bun.lock" ] && command -v bun >/dev/null 2>&1; then
  PM="bun"
  RUN_CMD="bun run"
  EXEC_CMD="bunx"
elif [ -f "yarn.lock" ] && command -v yarn >/dev/null 2>&1; then
  PM="yarn"
  RUN_CMD="yarn run"
  EXEC_CMD="yarn"
elif command -v pnpm >/dev/null 2>&1 && [ -f "pnpm-lock.yaml" ]; then
  PM="pnpm"
  RUN_CMD="pnpm run"
  EXEC_CMD="pnpm exec"
fi

echo -e "${CYAN}ℹ Package Manager détecté : ${BOLD}${PM}${NC} (runner: ${EXEC_CMD})"

# -----------------------------------------------------------------------------
# ÉTAPE 1 : VÉRIFICATION DU TYPAGE TYPESCRIPT STRICT
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/5] Vérification stricte du typage TypeScript (tsc --noEmit)...${NC}"
if [ -f "tsconfig.json" ]; then
  if $EXEC_CMD tsc --noEmit; then
    echo -e "${GREEN}✔ TypeScript : 0 erreur de typage détectée.${NC}"
  else
    echo -e "${RED}✖ ÉCHEC : Erreurs de compilation TypeScript. Corrigez le typage avant de livrer.${NC}"
    exit 1
  fi
else
  echo -e "${BLUE}ℹ Aucun tsconfig.json détecté dans le répertoire courant, étape ignorée.${NC}"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 2 : LINTERS ET RÈGLES DE SYNTAXE (ESLint / Biome)
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/5] Analyse statique et linters de code...${NC}"
LINTER_EXECUTED=0

if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
  echo -e "${CYAN}ℹ Linter Biome détecté...${NC}"
  if $EXEC_CMD biome check --diagnostic-level=error .; then
    echo -e "${GREEN}✔ Biome : Analyse réussie, 0 violation bloquante.${NC}"
    LINTER_EXECUTED=1
  else
    echo -e "${RED}✖ ÉCHEC : Des violations de syntaxe Biome ont été détectées.${NC}"
    exit 1
  fi
elif [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.cjs" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
  echo -e "${CYAN}ℹ ESLint détecté...${NC}"
  TARGET_PATHS="src/**/*.{ts,tsx}"
  [ ! -d "src" ] && [ -d "app" ] && TARGET_PATHS="app/**/*.{ts,tsx}"
  
  if $EXEC_CMD eslint "$TARGET_PATHS" --max-warnings=0 2>/dev/null; then
    echo -e "${GREEN}✔ ESLint : Code 100% conforme aux standards.${NC}"
    LINTER_EXECUTED=1
  else
    echo -e "${RED}✖ ÉCHEC : ESLint a retourné des erreurs ou des warnings.${NC}"
    exit 1
  fi
fi

if [ "$LINTER_EXECUTED" -eq 0 ]; then
  echo -e "${BLUE}ℹ Aucun linter configuré (ni Biome, ni ESLint), passage à l'étape suivante.${NC}"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 3 : SUITE DE TESTS UNITAIRES (Jest / Vitest)
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/5] Exécution de la suite de tests unitaires et composants...${NC}"
if [ -f "package.json" ] && grep -q '"test"' package.json; then
  echo -e "${CYAN}ℹ Script de test présent dans package.json...${NC}"
  if $PM test -- --watchAll=false --bail 2>/dev/null || $RUN_CMD test 2>/dev/null; then
    echo -e "${GREEN}✔ Tests Unitaires : 100% des tests validés au vert.${NC}"
  else
    echo -e "${RED}✖ ÉCHEC : Des tests unitaires ont échoué.${NC}"
    exit 1
  fi
else
  echo -e "${BLUE}ℹ Aucun script de test configuré dans package.json, étape ignorée.${NC}"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 4 : SCAN STATIQUE DE FUITES MÉMOIRES DANS LES USEEFFECT
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/5] Scan statique des fuites mémoires dans les composants (useEffect)...${NC}"
LEAK_COUNT=0
SCAN_DIR="src"
[ ! -d "src" ] && [ -d "app" ] && SCAN_DIR="app"

if [ -d "$SCAN_DIR" ]; then
  # Recherche dans les fichiers sources TypeScript / JavaScript (hors .md et templates)
  while IFS= read -r file; do
    if [ -n "$file" ]; then
      # Si addEventListener est présent, vérifier la présence d'un nettoyage (removeEventListener ou unsubscribe)
      if grep -q "addEventListener" "$file"; then
        if ! grep -qE "removeEventListener|unsubscribe" "$file"; then
          echo -e "${RED}⚠ Fuite potentielle dans $file : addEventListener sans nettoyage (removeEventListener ou unsubscribe).${NC}"
          LEAK_COUNT=$((LEAK_COUNT + 1))
        fi
      fi

      # Si setInterval est présent, vérifier la présence de clearInterval
      if grep -q "setInterval" "$file"; then
        if ! grep -q "clearInterval" "$file"; then
          echo -e "${RED}⚠ Fuite potentielle dans $file : setInterval sans nettoyage clearInterval.${NC}"
          LEAK_COUNT=$((LEAK_COUNT + 1))
        fi
      fi
    fi
  done < <(find "$SCAN_DIR" -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.ts" -o -name "*.js" \) ! -path "*/templates/*" 2>/dev/null || true)

  if [ "$LEAK_COUNT" -gt 0 ]; then
    echo -e "${RED}✖ ÉCHEC : $LEAK_COUNT composant(s) présentent un risque de fuite de mémoire non nettoyée.${NC}"
    exit 1
  else
    echo -e "${GREEN}✔ Fuites mémoires : Aucun gestionnaire d'événement ou timer orphelin détecté.${NC}"
  fi
else
  echo -e "${BLUE}ℹ Aucun répertoire $SCAN_DIR trouvé pour le scan des composants.${NC}"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 5 : AUDIT DES DÉPENDANCES ET CONTRÔLE BUNDLE
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/5] Audit des dépendances et contrôle de poids de bundle...${NC}"
if [ -f "package.json" ]; then
  # Détection de lodash complet
  if grep -q '"lodash"' package.json; then
    echo -e "${YELLOW}⚠ AVERTISSEMENT : 'lodash' monolithique est déclaré. Préférez des imports ciblés ('lodash-es/get') ou des alternatives natives ES2022+.${NC}"
  fi

  # Détection de moment.js obsolète
  if grep -q '"moment"' package.json; then
    echo -e "${YELLOW}⚠ AVERTISSEMENT : 'moment' alourdit inutilement le bundle. Préférez 'date-fns' ou les API Intl standard.${NC}"
  fi

  # Audit rapide de vulnérabilités si le PM le supporte
  if [ "$PM" = "pnpm" ] && command -v pnpm >/dev/null 2>&1; then
    pnpm audit --audit-level=high 2>/dev/null || true
  elif [ "$PM" = "npm" ] && command -v npm >/dev/null 2>&1; then
    npm audit --audit-level=high 2>/dev/null || true
  fi
  echo -e "${GREEN}✔ Audit dépendances terminé.${NC}"
fi

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}   ✔ QUALITY GATE FRONTEND & MOBILE : CERTIFICATION 100% VALIDÉE     ${NC}"
echo -e "${GREEN}======================================================================${NC}"
exit 0
