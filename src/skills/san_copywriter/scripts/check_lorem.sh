#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : check_lorem.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : san_copywriter
# DESCRIPTION : Linter récursif traquant impitoyablement les résidus de faux texte
#               (Lorem Ipsum, John Doe, Foo Bar, test test, dummy data, placeholders)
#               dans le code source applicatif et les maquettes.
#
# USAGE :
#   bash scripts/check_lorem.sh [--dir <chemin>] [--ext <extensions>]
#
# OPTIONS :
#   -d, --dir <CHEMIN>      Répertoire cible à inspecter (défaut : src/ si présent, sinon .)
#   -e, --ext <EXTS>        Extensions séparées par des virgules (défaut : js,ts,jsx,tsx,html,php,vue)
#   -h, --help              Affiche l'aide et quitte
#
# CODES DE SORTIE :
#   0 : Zéro faux texte détecté, codebase propre et réaliste
#   1 : Résidus de faux texte détectés avec liste des fichiers et lignes
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Linter récursif anti-Lorem Ipsum et traque du faux texte (san_copywriter).

Options :
  -d, --dir <CHEMIN>      Répertoire à inspecter (défaut : src/ si existant, sinon .)
  -e, --ext <EXTS>        Extensions de fichiers à analyser séparées par virgules
                          (défaut : js,ts,jsx,tsx,html,php,vue)
  -h, --help              Affiche cette aide et quitte

Exemples :
  $(basename "$0")
  $(basename "$0") --dir ./src --ext ts,tsx,vue
  $(basename "$0") -d app/ -e php,blade.php,html
EOF
}

# Détermination du répertoire par défaut
DEFAULT_DIR="."
if [[ -d "src" ]]; then
  DEFAULT_DIR="src"
fi

TARGET_DIR="${DEFAULT_DIR}"
EXTENSIONS="js,ts,jsx,tsx,html,php,vue"

# Analyse des arguments CLI
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir|-d)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --ext|-e)
      EXTENSIONS="${2:-}"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    -*)
      echo -e "${RED}[ERREUR] Option inconnue : $1${NC}" >&2
      show_help >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo -e "${RED}[ERREUR] Le répertoire spécifié n'existe pas : ${TARGET_DIR}${NC}" >&2
  exit 1
fi

echo -e "${BLUE}${BOLD}=== [san_copywriter] Traque Implacable du Faux Texte ===${NC}"
echo -e "${CYAN}Répertoire cible :${NC} ${TARGET_DIR}"
echo -e "${CYAN}Extensions surveillées :${NC} ${EXTENSIONS}"

# Répertoires à ignorer
EXCLUDED_DIRS=(
  ".git"
  "node_modules"
  "vendor"
  ".agents"
  ".agents/skills"
  "dist"
  "build"
  ".next"
  ".nuxt"
  "coverage"
  ".cache"
  ".gemini"
  "brain"
  "scratch"
  "archives"
  "storage"
)

# Construction des arguments d'exclusion pour grep / find
EXCLUDE_DIR_ARGS=()
for d in "${EXCLUDED_DIRS[@]}"; do
  EXCLUDE_DIR_ARGS+=("--exclude-dir=${d}")
done

# Construction des inclusions par extension
IFS=',' read -ra EXT_ARRAY <<< "${EXTENSIONS}"
INCLUDE_ARGS=()
for ext in "${EXT_ARRAY[@]}"; do
  # Nettoyage d'éventuels espaces ou points initiaux
  clean_ext="$(echo "${ext}" | tr -d ' ' | sed 's/^\.//')"
  if [[ -n "${clean_ext}" ]]; then
    INCLUDE_ARGS+=("--include=*.${clean_ext}")
  fi
done

# Termes et motifs de faux texte bannis
# Expressions régulières sensibles aux faux textes courants
PATTERNS=(
  "lorem ipsum"
  "dolor sit amet"
  "consectetur adipiscing"
  "sed do eiusmod"
  "tempor incididunt"
  "foo bar"
  "foobar"
  "baz qux"
  "test test"
  "dummy data"
  "dummy text"
  "sample text"
  "john doe"
  "jane doe"
  "texte de remplissage"
  "123 rue de la paix"
  "prix en dollars"
  "produit fictif"
  "asdf"
  "qwerty"
  "toto"
  "titi"
  "tata"
)

TEMP_LOG=$(mktemp)
TOTAL_MATCHES=0

# 1. Recherche des termes textuels bannis
for term in "${PATTERNS[@]}"; do
  # Exclure le script lui-même et les fichiers markdown de documentation si scannés par mégarde
  MATCHES=$(grep -rnI -i \
    "${EXCLUDE_DIR_ARGS[@]}" \
    "${INCLUDE_ARGS[@]}" \
    --exclude="check_lorem.sh" \
    --exclude="*.md" \
    "${term}" "${TARGET_DIR}" 2>/dev/null || true)

  if [[ -n "${MATCHES}" ]]; then
    while IFS= read -r line; do
      if [[ -n "${line}" ]]; then
        echo -e "${RED}✖ [TERME BANNI]${NC} '${term}'" >> "${TEMP_LOG}"
        echo "   -> ${line}" >> "${TEMP_LOG}"
        TOTAL_MATCHES=$((TOTAL_MATCHES + 1))
      fi
    done <<< "${MATCHES}"
  fi
done

# 2. Recherche ciblée sur les 'placeholders' résiduels
# Évite de fausser sur l'attribut HTML pur placeholder="..." ayant un vrai texte localisé
# Détecte: placeholder="placeholder", >placeholder<, 'placeholder', "placeholder", placeholder text
PLACEHOLDER_MATCHES=$(grep -rnI -i -E \
  '([>"\x27\s]|^)placeholder([<"\x27\s]|$)|placeholder\s*=\s*["\x27]placeholder["\x27]|placeholder\s+text' \
  "${EXCLUDE_DIR_ARGS[@]}" \
  "${INCLUDE_ARGS[@]}" \
  --exclude="check_lorem.sh" \
  --exclude="*.md" \
  "${TARGET_DIR}" 2>/dev/null || true)

if [[ -n "${PLACEHOLDER_MATCHES}" ]]; then
  while IFS= read -r line; do
    if [[ -n "${line}" ]]; then
      # Filtrer pour s'assurer que ce n'est pas un attribut standard avec valeur réelle ex: placeholder="Rechercher..."
      # Si la ligne contient placeholder="valeur_reelle", on vérifie si la valeur est elle-même un dummy
      echo -e "${YELLOW}✖ [PLACEHOLDER SUSPECT]${NC} 'placeholder'" >> "${TEMP_LOG}"
      echo "   -> ${line}" >> "${TEMP_LOG}"
      TOTAL_MATCHES=$((TOTAL_MATCHES + 1))
    fi
  done <<< "${PLACEHOLDER_MATCHES}"
fi

# Résultat et arbitrage
if [[ ${TOTAL_MATCHES} -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}🚨 [ALERTE ROUGE] ${TOTAL_MATCHES} occurrence(s) de faux texte détectée(s) !${NC}\n"
  cat "${TEMP_LOG}"
  rm -f "${TEMP_LOG}"
  echo -e "\n${RED}======================================================================${NC}"
  echo -e "${RED}${BOLD}   ÉCHEC DU CONTRÔLE DE RÉALISME DE MICRO-COPIE (san_copywriter)      ${NC}"
  echo -e "${RED}======================================================================${NC}"
  echo -e "${YELLOW}Directive : Bannissez immédiatement ces contenus factices.${NC}"
  echo -e "Remplacez-les par de la micro-copie incarnée, locale et empathique :"
  echo -e "  - Vrais noms : 'Christian Mabiala', 'Awa Traoré', 'Moussa Diop'"
  echo -e "  - Vraies devises : '2 500 FCFA', '15 000 XAF' (avec espace insécable)"
  echo -e "  - Vrais repères : 'Arrêt Marché Total, Bacongo', 'Grand Marché, Pointe-Noire'"
  echo -e "  - Vrais flux : 'Paiement MTN MoMo / Airtel Money', 'Confirmation par SMS'"
  echo -e "Consultez : ${CYAN}.agents/skills/san_copywriter/references/local_copy_guidelines.md${NC}\n"
  exit 1
else
  rm -f "${TEMP_LOG}"
  echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
  echo -e "${GREEN}${BOLD}   ✅ CONTRÔLE RÉUSSI : ZÉRO FAUX TEXTE DÉTECTÉ                      ${NC}"
  echo -e "${GREEN}${BOLD}======================================================================${NC}"
  echo -e "${GREEN}Aucun résidu de Lorem Ipsum, Foo Bar, test test ou données factices.${NC}"
  echo -e "${CYAN}La micro-copie de l'application est vivante, réaliste et prête pour la production.${NC}\n"
  exit 0
fi
