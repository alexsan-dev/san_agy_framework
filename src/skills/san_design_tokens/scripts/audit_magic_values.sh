#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : audit_magic_values.sh
# MODULE : san_design_tokens
# FRAMEWORK : Antigravity (san_*)
# DESCRIPTION : Scanner statique cartésien traquant impitoyablement les valeurs
#               magiques (couleurs hexadécimales, rgb/hsl et espacements arbitraires).
# EXIT CODE : 0 si codebase saine, 1 si violations détectées.
# ==============================================================================

set -euo pipefail

# Couleurs ANSI
ANSI_RESET="\033[0m"
ANSI_BOLD="\033[1m"
ANSI_RED="\033[31m"
ANSI_GREEN="\033[32m"
ANSI_YELLOW="\033[33m"
ANSI_BLUE="\033[34m"
ANSI_CYAN="\033[36m"
ANSI_GRAY="\033[90m"

function print_help() {
  echo -e "${ANSI_BOLD}${ANSI_BLUE}=== Scanner Anti-Valeurs Magiques Antigravity (audit_magic_values.sh) ===${ANSI_RESET}"
  echo ""
  echo -e "${ANSI_BOLD}USAGE :${ANSI_RESET}"
  echo "  bash audit_magic_values.sh [OPTIONS] [RÉPERTOIRE_CIBLE]"
  echo ""
  echo -e "${ANSI_BOLD}OPTIONS :${ANSI_RESET}"
  echo "  -t, --target <dossier>   Dossier à scanner (Défaut: src/ ou .)"
  echo "  -h, --help               Affiche cette aide et termine l'exécution"
  echo ""
  echo -e "${ANSI_BOLD}EXEMPLES :${ANSI_RESET}"
  echo "  bash audit_magic_values.sh src/"
  echo "  bash audit_magic_values.sh --target components/"
  echo ""
}

TARGET_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    -t|--target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --target=*)
      TARGET_DIR="${1#*=}"
      shift 1
      ;;
    -*)
      echo -e "${ANSI_RED}Option inconnue : $1${ANSI_RESET}"
      print_help
      exit 1
      ;;
    *)
      if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="$1"
      fi
      shift 1
      ;;
  esac
done

# Résolution cartésienne du répertoire cible
if [[ -z "${TARGET_DIR}" ]]; then
  if [[ -d "src" ]]; then
    TARGET_DIR="src"
  elif [[ -d "app" ]]; then
    TARGET_DIR="app"
  else
    TARGET_DIR="."
  fi
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo -e "${ANSI_RED}❌ Répertoire introuvable : ${TARGET_DIR}${ANSI_RESET}"
  exit 1
fi

echo -e "${ANSI_BOLD}${ANSI_BLUE}🔍 [san_design_tokens] Scan anti-valeurs magiques dans : ${ANSI_CYAN}${TARGET_DIR}${ANSI_RESET}"
echo -e "${ANSI_GRAY}Recherche de couleurs arbitraires, palettes non autorisées et espacements hors échelle...${ANSI_RESET}\n"

TOTAL_VIOLATIONS=0

# Fichiers et dossiers à exclure (préservant maquettes design et tests autorisés)
EXCLUDE_DIRS=(
  --exclude-dir="node_modules"
  --exclude-dir=".git"
  --exclude-dir="dist"
  --exclude-dir="build"
  --exclude-dir=".next"
  --exclude-dir=".nuxt"
  --exclude-dir=".expo"
  --exclude-dir="coverage"
  --exclude-dir="tokens"
  --exclude-dir="brain"
  --exclude-dir=".system_generated"
  --exclude-dir="sub-skills"
  --exclude-dir="design"
  --exclude-dir="tests"
  --exclude-dir="test"
  --exclude-dir="__tests__"
  --exclude-dir="fixtures"
  --exclude-dir="mockups"
  --exclude-dir="templates"
)

EXCLUDE_FILES=(
  --exclude="audit_magic_values.sh"
  --exclude="tokens.*"
  --exclude="tailwind.tokens.*"
  --exclude="tailwind.config.*"
  --exclude="*BRAND*.md"
  --exclude="*LOGO*.md"
  --exclude="*.svg"
  --exclude="*.json"
  --exclude="*.lock"
  --exclude="pnpm-lock.yaml"
  --exclude="package-lock.json"
  --exclude="*.test.*"
  --exclude="*.spec.*"
)

INCLUDE_EXTENSIONS=(
  --include="*.js"
  --include="*.jsx"
  --include="*.ts"
  --include="*.tsx"
  --include="*.vue"
  --include="*.svelte"
  --include="*.html"
  --include="*.css"
  --include="*.scss"
)

# 1. Traque des classes arbitraires Tailwind de couleurs (ex: bg-[#...], text-[#...])
ARBITRARY_TW_COLORS=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" "${INCLUDE_EXTENSIONS[@]}" \
  '(bg|text|border|ring|stroke|fill)-\[#[0-9a-fA-F]{3,8}\]' \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${ARBITRARY_TW_COLORS}" ]]; then
  COUNT=$(echo "${ARBITRARY_TW_COLORS}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} classe(s) arbitraire(s) Tailwind de couleur hexadécimale :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Utilisez les tokens canoniques (ex: bg-primary, text-on-surface)${ANSI_RESET}"
  echo "${ARBITRARY_TW_COLORS}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# 2. Traque des espacements arbitraires hors échelle (ex: p-[13px], mt-[7px], w-[23px])
# Note : Les dimensions structurelles légitimes d'accessibilité WCAG tactile (min-h-[44px], min-w-[44px], h-[44px], w-[44px]) sont expressément autorisées.
RAW_SPACING=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" "${INCLUDE_EXTENSIONS[@]}" \
  '(p|px|py|pt|pb|pl|pr|m|mx|my|mt|mb|ml|mr|gap|w|h|min-w|min-h)-\[[0-9]+px\]' \
  "${TARGET_DIR}" 2>/dev/null || true)

ARBITRARY_TW_SPACING=""
if [[ -n "${RAW_SPACING}" ]]; then
  # On exclut les dimensions structurelles d'accessibilité (44px)
  ARBITRARY_TW_SPACING=$(echo "${RAW_SPACING}" | grep -vE '(min-h|min-w|h|w)-\[44px\]' || true)
fi

if [[ -n "${ARBITRARY_TW_SPACING}" ]]; then
  COUNT=$(echo "${ARBITRARY_TW_SPACING}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} espacement(s) arbitraire(s) hors échelle de base 4px :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Utilisez l'échelle standard (ex: p-2 [8px], mt-4 [16px], gap-6 [24px]). Les cibles tactiles 44px d'accessibilité sont exemptées.${ANSI_RESET}"
  echo "${ARBITRARY_TW_SPACING}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# 3. Traque des codes hexadécimaux et formats rgb/hsl dans les styles inline (JSX style={{ ... }} ou style="...")
INLINE_RAW_COLORS=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" "${INCLUDE_EXTENSIONS[@]}" \
  '(style=.*(#[0-9a-fA-F]{3,8}|(rgb|hsl)a?\([0-9 ,.%]+\)))' \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${INLINE_RAW_COLORS}" ]]; then
  COUNT=$(echo "${INLINE_RAW_COLORS}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} couleur(s) brute(s) dans un style inline :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Interdiction des styles inline hardcodés. Liez aux variables CSS ou tokens TS.${ANSI_RESET}"
  echo "${INLINE_RAW_COLORS}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# 4. Traque des déclarations CSS brutes sans var(--...)
RAW_CSS_COLORS=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" --include="*.css" --include="*.scss" \
  '(color|background|background-color|border-color)\s*:\s*(#[0-9a-fA-F]{3,8}|(rgb|hsl)a?\([0-9 ,.%]+\))\s*;' \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${RAW_CSS_COLORS}" ]]; then
  COUNT=$(echo "${RAW_CSS_COLORS}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} propriété(s) CSS hardcodée(s) sans var() :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Utilisez var(--color-*) issues de tokens.css${ANSI_RESET}"
  echo "${RAW_CSS_COLORS}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# 5. Traque des classes Tailwind de couleurs génériques arbitraires hors tokens (anti-AI taste)
GENERIC_TW_COLORS=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" "${INCLUDE_EXTENSIONS[@]}" \
  '\b(bg|text|border|ring|stroke|fill|from|via|to)-(purple|indigo|fuchsia|violet)-[0-9]{2,3}\b' \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${GENERIC_TW_COLORS}" ]]; then
  COUNT=$(echo "${GENERIC_TW_COLORS}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} classe(s) Tailwind de palette générique arbitraire (violet/indigo) :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Proscription des dégradés et couleurs violets/indigo stéréotypés. Utilisez les tokens canoniques (ex: bg-primary, text-on-surface)${ANSI_RESET}"
  echo "${GENERIC_TW_COLORS}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# 6. Traque des z-index arbitraires démesurés (z-[999*])
ARBITRARY_Z_INDEX=$(grep -rnE \
  "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}" "${INCLUDE_EXTENSIONS[@]}" \
  '\bz-\[999[0-9]*\]' \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${ARBITRARY_Z_INDEX}" ]]; then
  COUNT=$(echo "${ARBITRARY_Z_INDEX}" | wc -l)
  TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + COUNT))
  echo -e "${ANSI_RED}${ANSI_BOLD}❌ [VIOLATION] ${COUNT} z-index arbitraire(s) démesuré(s) (z-[999*]) :${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Règle : Utilisez une échelle de plans ordonnée (z-10, z-20, z-50) au lieu de z-index sauvages.${ANSI_RESET}"
  echo "${ARBITRARY_Z_INDEX}" | while read -r line; do
    echo -e "  ${ANSI_GRAY}→${ANSI_RESET} ${line}"
  done
  echo ""
fi

# Synthèse et code de sortie
if [[ ${TOTAL_VIOLATIONS} -gt 0 ]]; then
  echo -e "${ANSI_BOLD}${ANSI_RED}🚨 [AUDIT ÉCHOUÉ] ${TOTAL_VIOLATIONS} valeur(s) magique(s) ou interdite(s) détectée(s) dans la codebase.${ANSI_RESET}"
  echo -e "${ANSI_YELLOW}Refactorisez ces valeurs vers la source de vérité BRAND.md via build_tokens.mjs.${ANSI_RESET}"
  exit 1
else
  echo -e "${ANSI_BOLD}${ANSI_GREEN}✨ [AUDIT VALIDÉ] Zéro valeur magique détectée dans ${TARGET_DIR}.${ANSI_RESET}"
  echo -e "${ANSI_GRAY}L'invariance esthétique et cinétique est respectée à 100%.${ANSI_RESET}"
  exit 0
fi
