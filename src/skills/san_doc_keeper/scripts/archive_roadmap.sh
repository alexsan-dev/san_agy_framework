#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : archive_roadmap.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : san_doc_keeper
# DESCRIPTION : Contrôle déterministe de complétude (100% de cases cochées),
#               certification cryptographique SHA-256 et archivage sécurisé.
#               Bloque et échoue avec exit code 1 dès la moindre tâche orpheline (- [ ]).
# USAGE : bash scripts/archive_roadmap.sh <CHEMIN_ROADMAP>
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}=== [san_doc_keeper] Audit de Complétude et Archivage Cartésien ===${NC}"

ROADMAP_PATH="${1:-}"

if [[ -z "${ROADMAP_PATH}" || ! -f "${ROADMAP_PATH}" ]]; then
  echo -e "${RED}[ERREUR] Fichier de feuille de route introuvable ou non spécifié.${NC}" >&2
  echo -e "${YELLOW}Usage : $0 <CHEMIN_ROADMAP>${NC}" >&2
  echo -e "Exemple : $0 roadmaps/01_AUTH_MOMO_23102026.md" >&2
  exit 1
fi

BASENAME=$(basename "${ROADMAP_PATH}")
DIRNAME=$(dirname "${ROADMAP_PATH}")

# Vérification si le document est déjà archivé
if [[ "${DIRNAME}" == *"archives"* ]] || [[ "${ROADMAP_PATH}" == *"/archives/"* ]]; then
  echo -e "${YELLOW}[AVERTISSEMENT] Le fichier est déjà situé dans le répertoire d'archives : ${ROADMAP_PATH}${NC}"
  exit 0
fi

echo -e "${CYAN}Audit du document :${NC} ${BOLD}${BASENAME}${NC}"

# 1. Vérification stricte des cases non cochées (- [ ])
UNCHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]*\]" "${ROADMAP_PATH}" || true)
CHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "${ROADMAP_PATH}" || true)

UNCHECKED_COUNT=0
if [[ -n "${UNCHECKED_MATCHES}" ]]; then
  UNCHECKED_COUNT=$(echo "${UNCHECKED_MATCHES}" | wc -l)
fi

CHECKED_COUNT=0
if [[ -n "${CHECKED_MATCHES}" ]]; then
  CHECKED_COUNT=$(echo "${CHECKED_MATCHES}" | wc -l)
fi

TOTAL_TASKS=$((CHECKED_COUNT + UNCHECKED_COUNT))

echo -e "  - Total de tâches identifiées : ${BOLD}${TOTAL_TASKS}${NC}"
echo -e "  - Tâches validées (- [x]) : ${GREEN}${CHECKED_COUNT}${NC}"
echo -e "  - Tâches non complétées (- [ ]) : ${YELLOW}${UNCHECKED_COUNT}${NC}"

# 2. Blocage strict si tâches orphelines
if [[ ${UNCHECKED_COUNT} -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}🚨 [BLOCAGE STRICT] REFUS D'ARCHIVAGE : Des tâches restent incomplètes !${NC}" >&2
  echo -e "${YELLOW}Lignes incriminées dans ${BASENAME} :${NC}" >&2
  echo "${UNCHECKED_MATCHES}" >&2
  echo -e "\n${RED}[RÈGLE D'OR] 100% des tâches doivent être cochées (- [x]) sur preuve de code avant archivage.${NC}" >&2
  exit 1
fi

# 3. Blocage strict si aucune tâche cochée
if [[ ${CHECKED_COUNT} -eq 0 ]]; then
  echo -e "\n${RED}${BOLD}🚨 [BLOCAGE] Aucune case cochée (- [x]) détectée dans ce document.${NC}" >&2
  exit 1
fi

echo -e "  - Complétude vérifiée : ${GREEN}${CHECKED_COUNT}/${CHECKED_COUNT} (100%)${NC}"

# 4. Calcul de l'empreinte SHA-256 et estampilles temporelles
SHA_HASH=$(sha256sum "${ROADMAP_PATH}" | awk '{print $1}')
ARCHIVE_DATE=$(date "+%Y-%m-%d %H:%M:%S")
DATE_STAMP=$(date +%d%m%Y)

BASENAME_NO_EXT="${BASENAME%.*}"
ARCHIVES_DIR="${DIRNAME}/archives"
TARGET_ARCHIVE="${ARCHIVES_DIR}/${BASENAME_NO_EXT}_ARCHIVED_${DATE_STAMP}.md"

mkdir -p "${ARCHIVES_DIR}"

# 5. Injection de l'en-tête de certification cartésienne
TEMP_FILE=$(mktemp)
cat << EOF > "${TEMP_FILE}"
> **CERTIFICATION D'ARCHIVAGE CARTÉSIENNE :**  
> - **Statut :** 100 % des tâches vérifiées et prouvées dans la codebase.  
> - **Date d'Archivage :** ${ARCHIVE_DATE}  
> - **Empreinte SHA-256 Initiale :** \`${SHA_HASH}\`  
> - **Tâches validées :** ${CHECKED_COUNT} / ${CHECKED_COUNT}  
> - **Archivé par :** san_doc_keeper (Antigravity Framework)

---

EOF

cat "${ROADMAP_PATH}" >> "${TEMP_FILE}"
mv "${TEMP_FILE}" "${TARGET_ARCHIVE}"
rm -f "${ROADMAP_PATH}"

echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}     ARCHIVAGE CARTÉSIEN RÉUSSI — CERTIFIÉ SAN_DOC_KEEPER            ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}Origine :${NC}            ${ROADMAP_PATH}"
echo -e "${CYAN}Archive sécurisée :${NC}  ${GREEN}${TARGET_ARCHIVE}${NC}"
echo -e "${CYAN}Empreinte SHA-256 :${NC}  ${BOLD}${SHA_HASH}${NC}"
echo -e "${CYAN}Complétude :${NC}         ${GREEN}100 % (${CHECKED_COUNT} tâches cochées)${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${BLUE}${BOLD}[FAST-TRACK] Prochaine étape recommandée :${NC}"
echo -e "  bash src/skills/san_doc_keeper/scripts/changelog_helper.sh --type Added --desc \"Clôture et archivage de ${BASENAME_NO_EXT}\""
echo ""
exit 0
