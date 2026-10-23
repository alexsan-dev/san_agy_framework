#!/usr/bin/env bash
# ==============================================================================
# SCRIPT OFFICIEL ANTIGRAVITY : QA & SECURITY GATE (san_qa_security_expert)
# Quality Gate Déterministe d'Assurance Qualité & Sécurité (Étage 1 anti-gaspillage)
# Framework : Google Antigravity (san_*) — alexsan.pro
# ==============================================================================
set -euo pipefail

# Couleurs ANSI pour terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BOLD}${BLUE}   ANTIGRAVITY QA & SECURITY GATE — ÉTAGE 1 (DÉTERMINISTE)       ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# Fonction utilitaire de vérification d'exécutables
check_tool() {
  local tool="$1"
  if ! command -v "$tool" &> /dev/null; then
    echo -e "${YELLOW}⚠ Outil non trouvé dans le PATH : ${tool}${NC}"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
  return 0
}

# ------------------------------------------------------------------------------
# 1. AUDIT DE SÉCURITÉ DES PAQUETS NODE.JS (CVE SCAN)
# ------------------------------------------------------------------------------
if [ -f "package.json" ]; then
  echo -e "\n${BLUE}[1/5] Audit des dépendances Node.js (CVE Scan npm)...${NC}"
  if check_tool npm; then
    if npm audit --audit-level=high; then
      echo -e "${GREEN}✔ Aucune vulnérabilité critique ou haute détectée dans npm.${NC}"
    else
      echo -e "${RED}✖ Vulnérabilités critiques ou hautes détectées par npm audit !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
else
  echo -e "\n${CYAN}[1/5] Aucun fichier package.json détecté. Étape npm ignorée.${NC}"
fi

# ------------------------------------------------------------------------------
# 2. AUDIT DE SÉCURITÉ DES PAQUETS COMPOSER (PHP)
# ------------------------------------------------------------------------------
if [ -f "composer.json" ]; then
  echo -e "\n${BLUE}[2/5] Audit des dépendances PHP Composer (CVE Scan)...${NC}"
  if check_tool composer; then
    if composer audit; then
      echo -e "${GREEN}✔ Aucune vulnérabilité détectée par composer audit.${NC}"
    else
      echo -e "${RED}✖ Vulnérabilités détectées dans les dépendances Composer !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
else
  echo -e "\n${CYAN}[2/5] Aucun fichier composer.json détecté. Étape Composer ignorée.${NC}"
fi

# ------------------------------------------------------------------------------
# 3. COMPILATION TYPESCRIPT STRICTE (tsc --noEmit)
# ------------------------------------------------------------------------------
if [ -f "tsconfig.json" ]; then
  echo -e "\n${BLUE}[3/5] Vérification TypeScript stricte (tsc --noEmit)...${NC}"
  TSC_EXEC=""
  if [ -x "./node_modules/.bin/tsc" ]; then
    TSC_EXEC="./node_modules/.bin/tsc"
  elif check_tool tsc; then
    TSC_EXEC="tsc"
  elif check_tool npx; then
    TSC_EXEC="npx tsc"
  fi

  if [ -n "$TSC_EXEC" ]; then
    if $TSC_EXEC --noEmit; then
      echo -e "${GREEN}✔ Compilation TypeScript 100% propre (zéro erreur de typage).${NC}"
    else
      echo -e "${RED}✖ Erreurs de compilation TypeScript détectées !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "${YELLOW}⚠ Compilateur tsc introuvable. Étape sautée.${NC}"
  fi
else
  echo -e "\n${CYAN}[3/5] Aucun tsconfig.json détecté. Étape TypeScript ignorée.${NC}"
fi

# ------------------------------------------------------------------------------
# 4. SCAN DE DÉTECTION DE SECRETS EN CLAIR DANS LE CODE SOURCE
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[4/5] Scan de détection de secrets / clés privées en clair...${NC}"
SECRET_PATTERNS='(BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|AIza[0-9A-Za-z\-_]{35}|ghp_[0-9a-zA-Z]{36}|sk_live_[0-9a-zA-Z]{24}|AKIA[0-9A-Z]{16})'

MATCHED_SECRETS=0
if grep -rE --exclude-dir={.git,node_modules,vendor,storage,dist,build,.agents,.gemini} "$SECRET_PATTERNS" . > /dev/null 2>&1; then
  MATCHED_SECRETS=1
fi

if [ "$MATCHED_SECRETS" -eq 1 ]; then
  echo -e "${RED}✖ ALERTE SÉCURITÉ : Présence probable de secrets/clés privées en clair dans le code !${NC}"
  grep -rnE --exclude-dir={.git,node_modules,vendor,storage,dist,build,.agents,.gemini} "$SECRET_PATTERNS" . || true
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✔ Aucun secret critique fuité détecté dans l'arborescence.${NC}"
fi

# ------------------------------------------------------------------------------
# 5. EXÉCUTION DES SUITES DE TESTS UNITAIRES / D'INTÉGRATION
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/5] Exécution des suites de tests automatisés...${NC}"
TESTS_FOUND=0

# Tests Laravel / PHP
if [ -f "artisan" ]; then
  if check_tool php; then
    TESTS_FOUND=1
    echo -e "▶ Exécution de la suite de tests Laravel (artisan test)..."
    if php artisan test --parallel; then
      echo -e "${GREEN}✔ Tests Laravel validés à 100%.${NC}"
    else
      echo -e "${RED}✖ Échec des tests Laravel !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# Tests Node.js / JavaScript / TypeScript
if [ -f "package.json" ]; then
  if grep -q '"test"' package.json 2>/dev/null; then
    if check_tool npm; then
      TESTS_FOUND=1
      echo -e "▶ Exécution de la suite de tests npm..."
      if npm test -- --passWithNoTests; then
        echo -e "${GREEN}✔ Tests JS/TS validés à 100%.${NC}"
      else
        echo -e "${RED}✖ Échec des tests npm !${NC}"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  fi
fi

if [ "$TESTS_FOUND" -eq 0 ]; then
  echo -e "${YELLOW}ℹ Aucun lanceur de test standard (artisan test, npm test) détecté.${NC}"
fi

# ------------------------------------------------------------------------------
# SYNTHÈSE DU QUALITY GATE ÉTAGE 1
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==================================================================${NC}"
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}${BOLD}VERDICT ÉTAGE 1 : ÉCHEC (${ERRORS} erreur(s) bloquante(s))${NC}"
  echo -e "${RED}Arrêt du Quality Gate. Corrigez les erreurs avant l'Étage 2 cognitif.${NC}"
  echo -e "${BLUE}==================================================================${NC}"
  exit 1
else
  echo -e "${GREEN}${BOLD}VERDICT ÉTAGE 1 : SUCCÈS TOTAL (0 anomalie bloquante)${NC}"
  echo -e "${GREEN}Feu vert accordé pour le lancement des auditeurs cognitifs (Étage 2).${NC}"
  echo -e "${BLUE}==================================================================${NC}"
  exit 0
fi
