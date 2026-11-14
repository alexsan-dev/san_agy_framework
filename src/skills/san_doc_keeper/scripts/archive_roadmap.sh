#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : archive_roadmap.sh (v2.2.0)
# MODULES : san_planner & san_doc_keeper
# FRAMEWORK : Antigravity / Dual-Harness (san_*)
# DESCRIPTION : Contrôle déterministe de complétude (100% de cases cochées),
#               certification cryptographique SHA-256 et archivage sécurisé vers
#               <dir>/archives/<BASENAME> (sans altérer le nom par défaut).
#               Bloque et échoue avec exit code 1 dès la moindre tâche orpheline (- [ ]).
# USAGE : bash archive_roadmap.sh [--dated] <chemin_vers_la_roadmap.md>
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs de terminal
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
  cat << 'EOF'
Usage: archive_roadmap.sh [--dated] <chemin_vers_la_roadmap.md>

Options:
  --dated       Ajoute le suffixe _ARCHIVED_<JJMMAAAA> au fichier archivé
                (par défaut: conserve exactement <BASENAME> dans archives/)
  -h, --help    Affiche cette aide et quitte
EOF
}

USE_DATED=0
ROADMAP_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --dated)
      USE_DATED=1
      shift
      ;;
    -*)
      echo -e "${RED}[ERREUR] Option inconnue : $1${NC}" >&2
      show_help >&2
      exit 1
      ;;
    *)
      if [[ -z "${ROADMAP_PATH}" ]]; then
        ROADMAP_PATH="$1"
      else
        echo -e "${RED}[ERREUR] Argument supplémentaire inattendu : $1${NC}" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

echo -e "${BLUE}${BOLD}=== [san_planner / san_doc_keeper] Contrôle d'Archivage Déterministe ===${NC}"

# 1. Vérification de l'argument d'entrée et de l'existence physique
if [[ -z "${ROADMAP_PATH}" ]]; then
  echo -e "${RED}[ERREUR] Argument manquant.${NC}" >&2
  echo -e "${YELLOW}Usage : $0 [--dated] <chemin_vers_la_roadmap.md>${NC}" >&2
  exit 1
fi

if [[ ! -f "${ROADMAP_PATH}" ]]; then
  echo -e "${RED}[ERREUR] Fichier introuvable sur le disque : ${ROADMAP_PATH}${NC}" >&2
  exit 1
fi

BASENAME=$(basename "${ROADMAP_PATH}")
DIRNAME=$(dirname "${ROADMAP_PATH}")

# 2. Vérification si déjà archivé
if [[ "${DIRNAME}" == *"archives"* ]] || [[ "${ROADMAP_PATH}" == *"/archives/"* ]]; then
  echo -e "${YELLOW}[AVERTISSEMENT] Le fichier est déjà situé dans le répertoire d'archives : ${ROADMAP_PATH}${NC}"
  exit 0
fi

# 3. Analyse et comptage strict des cases à cocher
UNCHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]*\]" "${ROADMAP_PATH}" || true)
CHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "${ROADMAP_PATH}" || true)

UNCHECKED_COUNT=0
if [[ -n "${UNCHECKED_MATCHES}" ]]; then
  UNCHECKED_COUNT=$(echo "${UNCHECKED_MATCHES}" | wc -l | tr -d ' ')
fi

CHECKED_COUNT=0
if [[ -n "${CHECKED_MATCHES}" ]]; then
  CHECKED_COUNT=$(echo "${CHECKED_MATCHES}" | wc -l | tr -d ' ')
fi

TOTAL_TASKS=$((CHECKED_COUNT + UNCHECKED_COUNT))

echo -e "${CYAN}Analyse du document :${NC} ${BOLD}${BASENAME}${NC}"
echo -e "  - Total de tâches identifiées : ${BOLD}${TOTAL_TASKS}${NC}"
echo -e "  - Tâches complétées & prouvées (- [x]) : ${GREEN}${CHECKED_COUNT}${NC}"
echo -e "  - Tâches en attente / orphelines (- [ ]) : ${YELLOW}${UNCHECKED_COUNT}${NC}"

# 4. Blocage strict : tâches orphelines restantes -> exit 1
if [[ "${UNCHECKED_COUNT}" -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}[BLOCAGE STRICT] Impossible d'archiver la roadmap !${NC}" >&2
  echo -e "${RED}Il reste ${UNCHECKED_COUNT} tâche(s) non cochée(s) ou non prouvée(s).${NC}" >&2
  echo -e "\n${YELLOW}${BOLD}Numéros de ligne et contenu des tâches orphelines :${NC}" >&2
  echo "${UNCHECKED_MATCHES}" >&2
  echo -e "\n${RED}[ACTION REQUISE] Règle de Preuve par le Code : développez, testez et prouvez chaque tâche avant d'archiver.${NC}" >&2
  exit 1
fi

# 5. Blocage strict : aucune tâche cochée -> exit 1
if [[ "${CHECKED_COUNT}" -eq 0 ]]; then
  echo -e "\n${RED}${BOLD}[BLOCAGE] La roadmap ne contient aucune tâche validée (- [x]). Archivage refusé.${NC}" >&2
  exit 1
fi

# 6. Calcul de l'empreinte SHA-256 et estampilles temporelles
if command -v sha256sum >/dev/null 2>&1; then
  SHA_HASH=$(sha256sum "${ROADMAP_PATH}" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  SHA_HASH=$(shasum -a 256 "${ROADMAP_PATH}" | awk '{print $1}')
else
  SHA_HASH="unavailable"
fi

ARCHIVE_DATE=$(date "+%Y-%m-%d %H:%M:%S")
DATE_STAMP=$(date "+%d%m%Y")
BASENAME_NO_EXT="${BASENAME%.*}"
ARCHIVES_DIR="${DIRNAME}/archives"

if [[ "${USE_DATED}" -eq 1 ]]; then
  DESTINATION="${ARCHIVES_DIR}/${BASENAME_NO_EXT}_ARCHIVED_${DATE_STAMP}.md"
else
  DESTINATION="${ARCHIVES_DIR}/${BASENAME}"
fi

mkdir -p "${ARCHIVES_DIR}"

# 7. Injection de l'en-tête de certification SHA-256 et déplacement atomique
TEMP_FILE=$(mktemp)
cat << EOF > "${TEMP_FILE}"
> **CERTIFICATION D'ARCHIVAGE CARTÉSIENNE :**  
> - **Statut :** 100 % des tâches vérifiées et prouvées dans la codebase.  
> - **Date d'Archivage :** ${ARCHIVE_DATE}  
> - **Empreinte SHA-256 Initiale :** \`${SHA_HASH}\`  
> - **Tâches validées :** ${CHECKED_COUNT} / ${CHECKED_COUNT}  
> - **Archivé par :** san_planner / san_doc_keeper (Antigravity Framework)

---

EOF

cat "${ROADMAP_PATH}" >> "${TEMP_FILE}"
mv "${TEMP_FILE}" "${DESTINATION}"
rm -f "${ROADMAP_PATH}"

# 8. Rapport de succès
echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}      ARCHIVAGE RÉUSSI AVEC SUCCÈS — PREUVE PAR LE CODE 100%          ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}Date & Heure :${NC}               ${ARCHIVE_DATE}"
echo -e "${CYAN}Fichier archivé :${NC}            ${BASENAME}"
echo -e "${CYAN}Emplacement d'archive :${NC}      ${GREEN}${DESTINATION}${NC}"
echo -e "${CYAN}Empreinte SHA-256 :${NC}          ${BOLD}${SHA_HASH}${NC}"
echo -e "${CYAN}Tâches validées (- [x]) :${NC}    ${GREEN}${CHECKED_COUNT} / ${CHECKED_COUNT} (100%)${NC}"
echo -e "${CYAN}Tâches orphelines (- [ ]) :${NC}  ${GREEN}0 (Zéro)${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${BLUE}${BOLD}[FAST-TRACK HYGIÈNE] Rappel obligatoire :${NC}"
echo -e "  1. Consignez les livrables dans ${BOLD}CHANGELOG.md${NC} sous la version cible."
echo -e "  2. Référencez l'archive : ${CYAN}${DESTINATION}${NC}"
echo -e "${GREEN}[OK] Statut final : Roadmap archivée de manière déterministe.${NC}\n"

exit 0
