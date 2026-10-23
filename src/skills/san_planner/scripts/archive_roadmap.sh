#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : archive_roadmap.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : Alexsan.pro
# DESCRIPTION : Contrôle déterministe d'exhaustivité et archivage d'une roadmap.
#               Exige 100% de tâches validées (- [x]) avec preuve par le code.
#               Bloque et échoue avec exit code 1 dès la moindre tâche orpheline (- [ ]).
# USAGE : bash scripts/archive_roadmap.sh <chemin_vers_la_roadmap.md>
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs de terminal
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}=== [san_planner] Contrôle d'Archivage Déterministe de Roadmap ===${NC}"

# 1. Vérification de l'argument d'entrée
if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo -e "${RED}[ERREUR] Argument manquant.${NC}"
    echo -e "${YELLOW}Usage : $0 <chemin_vers_la_roadmap.md>${NC}"
    echo -e "Exemple : $0 roadmaps/PHASE_1_AUTHENTIFICATION_MOMO_23102026.md"
    exit 1
fi

ROADMAP_FILE="$1"

# 2. Vérification de l'existence physique du fichier
if [ ! -f "$ROADMAP_FILE" ]; then
    echo -e "${RED}[ERREUR] Fichier introuvable sur le disque : ${ROADMAP_FILE}${NC}"
    exit 1
fi

BASENAME=$(basename "$ROADMAP_FILE")
DIRNAME=$(dirname "$ROADMAP_FILE")

# 3. Vérification si déjà archivé
if [[ "$DIRNAME" == *"archives"* ]] || [[ "$ROADMAP_FILE" == *"/archives/"* ]]; then
    echo -e "${YELLOW}[AVERTISSEMENT] Le fichier est déjà situé dans le répertoire d'archives : ${ROADMAP_FILE}${NC}"
    exit 0
fi

# 4. Analyse et comptage des cases à cocher
UNCHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]*\]" "$ROADMAP_FILE" || true)
CHECKED_MATCHES=$(grep -n -E "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "$ROADMAP_FILE" || true)

UNCHECKED_COUNT=0
if [ -n "$UNCHECKED_MATCHES" ]; then
    UNCHECKED_COUNT=$(echo "$UNCHECKED_MATCHES" | wc -l)
fi

CHECKED_COUNT=0
if [ -n "$CHECKED_MATCHES" ]; then
    CHECKED_COUNT=$(echo "$CHECKED_MATCHES" | wc -l)
fi

TOTAL_TASKS=$((CHECKED_COUNT + UNCHECKED_COUNT))

echo -e "${CYAN}Analyse du document :${NC} ${BOLD}${BASENAME}${NC}"
echo -e "  - Total de tâches identifiées : ${BOLD}${TOTAL_TASKS}${NC}"
echo -e "  - Tâches complétées & prouvées (- [x]) : ${GREEN}${CHECKED_COUNT}${NC}"
echo -e "  - Tâches en attente / orphelines (- [ ]) : ${YELLOW}${UNCHECKED_COUNT}${NC}"

# 5. Blocage strict : tâches orphelines restantes -> exit 1
if [ "$UNCHECKED_COUNT" -gt 0 ]; then
    echo -e "\n${RED}${BOLD}[BLOCAGE STRICT] Impossible d'archiver la roadmap !${NC}"
    echo -e "${RED}Il reste ${UNCHECKED_COUNT} tâche(s) non cochée(s) ou non prouvée(s).${NC}"
    echo -e "\n${YELLOW}${BOLD}Numéros de ligne et contenu des tâches orphelines :${NC}"
    echo "$UNCHECKED_MATCHES"
    echo -e "\n${RED}[ACTION REQUISE] Règle de Preuve par le Code : développez, testez et prouvez chaque tâche avant d'archiver.${NC}"
    exit 1
fi

# 6. Blocage strict : aucune tâche cochée -> exit 1
if [ "$CHECKED_COUNT" -eq 0 ]; then
    echo -e "\n${RED}${BOLD}[BLOCAGE] La roadmap ne contient aucune tâche validée (- [x]). Archivage refusé.${NC}"
    exit 1
fi

# 7. Toutes les tâches sont validées (100%) : déplacement vers archives
ARCHIVES_DIR="${DIRNAME}/archives"
mkdir -p "$ARCHIVES_DIR"

DESTINATION="${ARCHIVES_DIR}/${BASENAME}"

mv "$ROADMAP_FILE" "$DESTINATION"

CURRENT_DATE=$(date "+%d/%m/%Y à %H:%M:%S")

# 8. Rapport de succès éclatant
echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}      ARCHIVAGE RÉUSSI AVEC SUCCÈS — PREUVE PAR LE CODE 100%          ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}Date & Heure :${NC}               ${CURRENT_DATE}"
echo -e "${CYAN}Fichier archivé :${NC}            ${BASENAME}"
echo -e "${CYAN}Emplacement d'archive :${NC}      ${GREEN}${DESTINATION}${NC}"
echo -e "${CYAN}Tâches validées (- [x]) :${NC}    ${GREEN}${CHECKED_COUNT} / ${CHECKED_COUNT} (100%)${NC}"
echo -e "${CYAN}Tâches orphelines (- [ ]) :${NC}  ${GREEN}0 (Zéro)${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${BLUE}${BOLD}[FAST-TRACK HYGIÈNE] Rappel obligatoire :${NC}"
echo -e "  1. Consignez les livrables dans ${BOLD}CHANGELOG.md${NC} sous la version cible."
echo -e "  2. Référencez l'archive : ${CYAN}${DESTINATION}${NC}"
echo -e "${GREEN}[OK] Statut final : Roadmap archivée de manière déterministe.${NC}\n"

exit 0
