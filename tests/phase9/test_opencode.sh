#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 9 (COMPATIBILITÉ OP ENCODE — CONTEXTE & MISE À JOUR)
# Framework Universel Antigravity (san_*)
# Auteur : Alexsan.pro · Cartesian Engineering & Cognitive Harness
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLI_BIN="${FRAMEWORK_ROOT}/src/cli/index.js"

TOTAL_TESTS=0
PASSED_TESTS=0

pass() {
  local msg="$1"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  PASSED_TESTS=$((PASSED_TESTS + 1))
  echo -e "  ${GREEN}[OK]${NC} ${msg}"
}

fail() {
  local msg="$1"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  echo -e "  ${RED}[ÉCHEC]${NC} ${msg}" >&2
  exit 1
}

echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}${BOLD}  SUITE DE TESTS PHASE 9 — COMPATIBILITÉ OP ENCODE & MISE À JOUR      ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}"

if [[ ! -f "${CLI_BIN}" ]]; then
  echo -e "${RED}[ERREUR FATALE] Le binaire CLI n'existe pas : ${CLI_BIN}${NC}" >&2
  exit 1
fi

TMP_BASE="$(mktemp -d /tmp/test_san_phase9_XXXXXX)"
cleanup() {
  rm -rf "${TMP_BASE}"
}
trap cleanup EXIT

# ==============================================================================
# TEST 1 : INITIALISATION LOCALE AVEC CONTEXTE OP ENCODE (--opencode)
# ==============================================================================
echo ""
echo -e "${BOLD}--- [TEST 1/4] Initialisation locale avec contexte opencode (--opencode) ---${NC}"

PROJECT_DIR="${TMP_BASE}/opencode_project"
mkdir -p "${PROJECT_DIR}"
(
  cd "${PROJECT_DIR}"
  git init -q
  git config user.name "OpenCode Tester"
  git config user.email "oc@alexsan.pro"
)

node "${CLI_BIN}" init --local --all --opencode --dir="${PROJECT_DIR}" > "${TMP_BASE}/install_opencode.log" 2>&1 || {
  cat "${TMP_BASE}/install_opencode.log" >&2
  fail "L'installation --opencode a échoué."
}
pass "Installation --local --all --opencode exécutée avec succès."

# 1.1 AGENTS.md généré avec le marqueur et la liste des compétences
if [[ ! -f "${PROJECT_DIR}/AGENTS.md" ]]; then
  fail "AGENTS.md n'a pas été généré !"
fi
if ! grep -q "opencode context (generated)" "${PROJECT_DIR}/AGENTS.md"; then
  fail "AGENTS.md ne contient pas le marqueur de génération !"
fi
if ! grep -q "san_planner" "${PROJECT_DIR}/AGENTS.md"; then
  fail "AGENTS.md ne référence pas la compétence san_planner !"
fi
pass "AGENTS.md généré avec le marqueur et la liste des compétences."

# 1.2 opencode.json valide avec skills.paths et instructions
if [[ ! -f "${PROJECT_DIR}/opencode.json" ]]; then
  fail "opencode.json n'a pas été généré !"
fi
if ! python3 -c "import json,sys; c=json.load(open(sys.argv[1])); assert '.agents/skills' in c['skills']['paths']; assert '.agents/GEMINI.md' in c['instructions']" "${PROJECT_DIR}/opencode.json"; then
  fail "opencode.json invalide : skills.paths ou instructions manquants !"
fi
pass "opencode.json valide : skills.paths et instructions corrects."

# 1.3 AGENTS.md n'est PAS purgé en mode opencode
if [[ ! -f "${PROJECT_DIR}/AGENTS.md" ]]; then
  fail "AGENTS.md a été purgé en mode opencode !"
fi
pass "AGENTS.md préservé (non purgé) en mode opencode."

# 1.4 AGENTS.md committable, .agents/ toujours ignoré
if git -C "${PROJECT_DIR}" check-ignore AGENTS.md >/dev/null 2>&1; then
  fail "AGENTS.md est ignoré par Git (devrait être committable) !"
fi
if ! git -C "${PROJECT_DIR}" check-ignore .agents >/dev/null 2>&1; then
  fail ".agents/ n'est pas ignoré par Git !"
fi
pass "AGENTS.md committable et .agents/ hermétiquement ignoré."

# ==============================================================================
# TEST 2 : COMMANDE UPDATE (MISE À JOUR SUR REPO DÉJÀ DÉPLOYÉ)
# ==============================================================================
echo ""
echo -e "${BOLD}--- [TEST 2/4] Commande update sur repo déjà déployé ---${NC}"

node "${CLI_BIN}" update --dir="${PROJECT_DIR}" > "${TMP_BASE}/update.log" 2>&1 || {
  cat "${TMP_BASE}/update.log" >&2
  fail "La commande update a échoué."
}
if ! grep -q "Détecté" "${TMP_BASE}/update.log"; then
  fail "La commande update n'a pas détecté le déploiement .agents/."
fi
pass "Commande update exécutée et déploiement détecté."

# ==============================================================================
# TEST 3 : SMART MERGE DU CONTEXTE OP ENCODE (NON-RÉGRESSION)
# ==============================================================================
echo ""
echo -e "${BOLD}--- [TEST 3/4] Smart Merge du contexte opencode (non-régression) ---${NC}"

# 3.1 Personnalisation utilisateur d'AGENTS.md (sans marqueur)
echo "# MON AGENTS PERSONNALISÉ CLIENT (CONFIDENTIEL)" > "${PROJECT_DIR}/AGENTS.md"

# 3.2 Ajout d'un champ personnalisé dans opencode.json
python3 -c "import json,sys; p=sys.argv[1]; c=json.load(open(p)); c['model']='anthropic/claude-sonnet-4-6'; json.dump(c, open(p,'w'), indent=2)" "${PROJECT_DIR}/opencode.json"

# 3.3 Réexécution de update
node "${CLI_BIN}" update --dir="${PROJECT_DIR}" > "${TMP_BASE}/update_smart_merge.log" 2>&1

# 3.4 Assertions de non-régression
if ! grep -q "MON AGENTS PERSONNALISÉ CLIENT" "${PROJECT_DIR}/AGENTS.md"; then
  fail "Smart Merge défaillant : AGENTS.md personnalisé a été écrasé !"
fi
pass "AGENTS.md personnalisé scrupuleusement préservé (Smart Merge)."

if ! grep -q '"model"' "${PROJECT_DIR}/opencode.json"; then
  fail "Le champ personnalisé 'model' a été écrasé dans opencode.json !"
fi
if ! grep -q '.agents/skills' "${PROJECT_DIR}/opencode.json"; then
  fail "skills.paths a disparu de opencode.json après fusion !"
fi
pass "opencode.json fusionné sans écraser les champs utilisateur."

# ==============================================================================
# TEST 4 : MODE DRY-RUN DE LA COMMANDE UPDATE
# ==============================================================================
echo ""
echo -e "${BOLD}--- [TEST 4/4] Mode Dry-Run de la commande update ---${NC}"

DRY_PROJECT="${TMP_BASE}/dry_project"
mkdir -p "${DRY_PROJECT}"
node "${CLI_BIN}" update --dir="${DRY_PROJECT}" --dry-run > "${TMP_BASE}/update_dry.log" 2>&1

if [[ -f "${DRY_PROJECT}/AGENTS.md" ]] || [[ -f "${DRY_PROJECT}/opencode.json" ]]; then
  fail "Le mode --dry-run a écrit des fichiers sur le disque !"
fi
pass "Mode Dry-Run de update validé (zéro écriture)."

# ==============================================================================
# BILAN FINAL
# ==============================================================================
echo ""
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}     BILAN PHASE 9 : ${PASSED_TESTS}/${TOTAL_TESTS} VÉRIFICATIONS RÉUSSIES (100% VERT)   ${NC}"
echo -e "${GREEN}${BOLD}     STATUT FINAL : PHASE 9 VALIDÉE AVEC SUCCÈS                        ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}\n"

exit 0
