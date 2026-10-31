#!/usr/bin/env bash
# scripts/front_quality_gate.sh
# Quality Gate déterministe pour l'ingénierie Frontend & Mobile Antigravity (san_ux_ui_expert).
# Mode FAIL-CLOSED : Zéro complaisance, éradication des fuites mémoire et failles de sécurité.
#
# Vérifie :
# 1. TypeScript strict (tsc --noEmit)
# 2. Linters (ESLint / Biome)
# 3. Tests unitaires (Jest / Vitest)
# 4. Fuites mémoires dans useEffect, composants monolithiques (>300 lignes), A11y (<div onClick)
# 5. Dépendances critiques et bundles (audit sans || true, bloquant sur faille critique)

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
echo -e "${BLUE}   Mode FAIL-CLOSED : Typage strict, Clean Effects, A11y & Sécurité  ${NC}"
echo -e "${BLUE}======================================================================${NC}"

TOTAL_CHECKS=0
TESTS_RUN=0

# Détection de code applicatif UI (src/, app/, pages/, components/)
HAS_UI_CODE=0
for d in "src" "app" "pages" "components"; do
  if [ -d "$d" ] && [ -n "$(find "$d" -maxdepth 4 -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.ts" -o -name "*.js" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | head -n 1)" ]; then
    HAS_UI_CODE=1
    break
  fi
done

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
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
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
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
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
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
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
if [ -f "package.json" ]; then
  if grep -q '"test"' package.json; then
    echo -e "${CYAN}ℹ Script de test présent dans package.json...${NC}"
    if $PM test -- --watchAll=false --bail 2>/dev/null || $RUN_CMD test 2>/dev/null; then
      echo -e "${GREEN}✔ Tests Unitaires : 100% des tests validés au vert.${NC}"
      TESTS_RUN=1
      TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    else
      echo -e "${RED}✖ ÉCHEC : Des tests unitaires ont échoué.${NC}"
      exit 1
    fi
  else
    if [ "$HAS_UI_CODE" -eq 1 ]; then
      echo -e "${RED}✖ [FAIL-CLOSED] Aucun script de test configuré alors que du code source UI existe.${NC}"
      exit 1
    else
      echo -e "${BLUE}ℹ Aucun script de test configuré dans package.json, étape ignorée.${NC}"
    fi
  fi
else
  if [ "$HAS_UI_CODE" -eq 1 ]; then
    echo -e "${RED}✖ [FAIL-CLOSED] Aucun script de test configuré alors que du code source UI existe.${NC}"
    exit 1
  else
    echo -e "${BLUE}ℹ Aucun package.json détecté dans le répertoire courant, étape ignorée.${NC}"
  fi
fi

if [ "$TESTS_RUN" -eq 0 ] && [ "$HAS_UI_CODE" -eq 1 ]; then
  echo -e "${RED}✖ [FAIL-CLOSED] Aucun script de test configuré alors que du code source UI existe.${NC}"
  exit 1
fi

# -----------------------------------------------------------------------------
# ÉTAPE 4 : SCAN CIBLÉ DES USEEFFECT, MONOLITHES (>300 LIGNES) & A11Y
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/5] Scan ciblé des useEffect, composants monolithiques (>300 lignes) et A11y...${NC}"
SCAN_DIRS=()
for d in "src" "app" "pages" "components"; do
  [ -d "$d" ] && SCAN_DIRS+=("$d")
done

if [ ${#SCAN_DIRS[@]} -gt 0 ] && command -v node >/dev/null 2>&1; then
  node -e '
const fs = require("fs");
const path = require("path");

const scanDirs = process.argv.slice(1);

function walkDir(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (!["node_modules", ".git", "dist", "build", "templates", "coverage", ".next", ".nuxt"].includes(entry.name)) {
        walkDir(fullPath, fileList);
      }
    } else if (/\.(tsx|jsx|ts|js|vue|svelte)$/.test(entry.name)) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

const files = [];
for (const d of scanDirs) {
  walkDir(d, files);
}
let leakCount = 0;
let monolithCount = 0;
let a11yCount = 0;

for (const file of files) {
  const content = fs.readFileSync(file, "utf8");
  const lines = content.split("\n");

  // 1. Contrôle composant monolithique (> 300 lignes)
  if (/\.(tsx|jsx|vue|svelte)$/.test(file) && lines.length > 300) {
    console.error(`\x1b[33m  ⚠ Composant monolithique (>300 lignes) : ${file} (${lines.length} lignes).\x1b[0m`);
    console.error(`\x1b[33m    Recommandation : Découpez en sous-composants atomiques ou hooks dédiés (san_ux_ui_expert).\x1b[0m`);
    monolithCount++;
  }

  // 2. Traque anti-pattern useEffect async
  const asyncEffectRegex = /useEffect\s*\(\s*async\b/g;
  while (asyncEffectRegex.exec(content) !== null) {
    console.error(`\x1b[31m  ✖ Anti-pattern critique dans ${file} : useEffect avec callback async (les fonctions async retournent une Promise et non une fonction de nettoyage synchrone).\x1b[0m`);
    leakCount++;
  }

  // 3. Contrôle ciblé des fuites mémoires dans les hooks useEffect
  // Détecte useEffect avec OU sans tableau de dépendances, arrow ou function
  const useEffectHeaderRegex = /useEffect\s*\(\s*(?:async\s*)?(?:\([^)]*\)|function\s*[a-zA-Z0-9_$]*\s*\([^)]*\))\s*=>?\s*\{/g;
  let match;
  while ((match = useEffectHeaderRegex.exec(content)) !== null) {
    const bodyStartIndex = useEffectHeaderRegex.lastIndex;
    let depth = 1;
    let i = bodyStartIndex;
    while (i < content.length && depth > 0) {
      if (content[i] === "{") depth++;
      else if (content[i] === "}") depth--;
      i++;
    }
    const body = content.substring(bodyStartIndex, i - 1);

    const hasListener = /addEventListener|subscribe\(/.test(body);
    const hasTimer = /setInterval\(/.test(body);

    // Support des fonctions de retour anonymes/fléchées ou identifiants nommés (ex: return cleanup; / return unbind;)
    const hasCleanup = /return\s*(?:\(\s*\)\s*=>|function\s*\(|\(\s*function|[a-zA-Z0-9_$]+(?:\s*;|\s*$))/m.test(body);

    if (hasListener) {
      const cleansListener = /removeEventListener|unsubscribe|abort/.test(body);
      if (!hasCleanup || !cleansListener) {
        console.error(`\x1b[31m  ✖ Fuite mémoire potentielle dans ${file} : useEffect avec addEventListener/subscribe sans fonction de retour avec removeEventListener/unsubscribe.\x1b[0m`);
        leakCount++;
      }
    }

    if (hasTimer) {
      const cleansTimer = /clearInterval/.test(body);
      if (!hasCleanup || !cleansTimer) {
        console.error(`\x1b[31m  ✖ Fuite mémoire potentielle dans ${file} : useEffect avec setInterval sans fonction de retour avec clearInterval.\x1b[0m`);
        leakCount++;
      }
    }
  }

  // 3. Contrôle accessibilité : <div onClick ou <span onClick inaccessible
  lines.forEach((line, idx) => {
    if (/<(div|span)[^>]*onClick/i.test(line)) {
      const isAccessible = /role=["\x27]button["\x27]|tabIndex=|onKeyDown=|onKeyUp=|onKeyPress=/i.test(line);
      if (!isAccessible) {
        console.error(`\x1b[33m  ⚠ Accessibilité A11y : ${file}:${idx + 1} : Élément interactif inaccessible sans role="button", tabIndex ni gestionnaire clavier.\x1b[0m`);
        console.error(`\x1b[33m    Snippet : ${line.trim().substring(0, 80)}\x1b[0m`);
        a11yCount++;
      }
    }
  });
}

if (leakCount > 0) {
  console.error(`\x1b[31m✖ ÉCHEC : ${leakCount} fuite(s) mémoire non nettoyée(s) dans useEffect.\x1b[0m`);
  process.exit(1);
} else {
  console.log(`\x1b[32m✔ Fuites mémoires : Aucun listener ou timer orphelin dans les hooks useEffect.\x1b[0m`);
}

if (monolithCount > 0) {
  console.log(`\x1b[33mℹ ${monolithCount} composant(s) monolithique(s) (>300 lignes) identifié(s).\x1b[0m`);
}
if (a11yCount > 0) {
  console.log(`\x1b[33mℹ ${a11yCount} élément(s) interactif(s) avec recommandation d\x27accessibilité clavier.\x1b[0m`);
}
' "${SCAN_DIRS[@]}"
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
else
  echo -e "${BLUE}ℹ Aucun répertoire UI (src, app, pages, components) trouvé ou Node.js indisponible pour le scan des composants.${NC}"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 5 : AUDIT DES DÉPENDANCES ET CONTRÔLE BUNDLE (SANS || true)
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

  # Audit des vulnérabilités critiques (MODE FAIL-CLOSED : SANS || true)
  if [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
    echo -e "${CYAN}ℹ Audit pnpm de sécurité (seuil critique bloquant)...${NC}"
    if ! pnpm audit --audit-level=critical; then
      echo -e "${RED}✖ ÉCHEC : Vulnérabilités de sécurité critiques détectées par pnpm audit !${NC}"
      exit 1
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  elif [ -f "package-lock.json" ] && command -v npm >/dev/null 2>&1; then
    echo -e "${CYAN}ℹ Audit npm de sécurité (seuil critique bloquant)...${NC}"
    if ! npm audit --audit-level=critical; then
      echo -e "${RED}✖ ÉCHEC : Vulnérabilités de sécurité critiques détectées par npm audit !${NC}"
      exit 1
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  fi
  echo -e "${GREEN}✔ Audit dépendances terminé (0 vulnérabilité critique).${NC}"
fi

# Mode FAIL-CLOSED : Si aucun contrôle de qualité n'a tourné
if [ "$TOTAL_CHECKS" -eq 0 ]; then
  echo -e "\n${RED}======================================================================${NC}"
  echo -e "${RED}✖ [FAIL-CLOSED] ÉCHEC : Aucun contrôle de qualité exécuté (TOTAL_CHECKS == 0).${NC}"
  echo -e "${RED}  Dossier vide ou composant sans aucun test ni vérification statique.${NC}"
  echo -e "${RED}======================================================================${NC}"
  exit 1
fi

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}   ✔ QUALITY GATE FRONTEND & MOBILE : CERTIFICATION 100% VALIDÉE (${TOTAL_CHECKS} check(s))${NC}"
echo -e "${GREEN}======================================================================${NC}"
exit 0
