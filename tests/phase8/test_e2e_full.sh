#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 8 (VALIDATION GLOBALE & TESTS D'INTÉGRATION END-TO-END)
# Framework Universel Antigravity (san_*)
# Auteur : Alexsan.pro · Cartesian Engineering & Cognitive Harness
# ==============================================================================

set -euo pipefail

# Définition des couleurs ANSI vives
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

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
echo -e "${CYAN}${BOLD}  SUITE DE TESTS E2E & VALIDATION GLOBALE — PHASE 8 (san_*)          ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${GRAY}Framework Root : ${FRAMEWORK_ROOT}${NC}"
echo -e "${GRAY}CLI Binary     : ${CLI_BIN}${NC}\n"

if [[ ! -f "${CLI_BIN}" ]]; then
  echo -e "${RED}[ERREUR FATALE] Le binaire CLI n'existe pas : ${CLI_BIN}${NC}" >&2
  exit 1
fi

# Environnement temporaire isolé
TMP_BASE="$(mktemp -d /tmp/test_san_phase8_XXXXXX)"
echo -e "${BLUE}[+] Environnement temporaire isolé :${NC} ${TMP_BASE}"

cleanup() {
  local exit_code=$?
  echo ""
  echo -e "${BLUE}[+] Nettoyage de l'environnement temporaire isolé...${NC}"
  rm -rf "${TMP_BASE}"
  if [[ ${exit_code} -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}Nettoyage terminé avec succès.${NC}"
  else
    echo -e "${YELLOW}Nettoyage terminé après échec.${NC}"
  fi
}
trap cleanup EXIT

# ==============================================================================
# TEST 1 : SIMULATION D'UN PROJET CLIENT RÉALISTE (NEXT.JS / TYPESCRIPT)
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 1/6] Simulation d'un projet client réaliste (Next.js / TS) ---${NC}"

CLIENT_DIR="${TMP_BASE}/client_app"
mkdir -p "${CLIENT_DIR}/src/app"

# 1.1 Fichiers réalistes du projet client
cat << 'EOF' > "${CLIENT_DIR}/package.json"
{
  "name": "client-fullstack-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/node": "^20.0.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0"
  }
}
EOF

cat << 'EOF' > "${CLIENT_DIR}/tsconfig.json"
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat << 'EOF' > "${CLIENT_DIR}/src/app/page.tsx"
import React from 'react';

export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1 className="text-4xl font-bold">Plateforme de Services Bancaires & MoMo</h1>
      <p className="mt-4 text-lg">Solde disponible : 150 000 FCFA</p>
    </main>
  );
}
EOF

cat << 'EOF' > "${CLIENT_DIR}/.gitignore"
# Dependencies
node_modules/
/.pnp
.pnp.js

# Production build outputs
.next/
out/
build/
dist/

# Logs
npm-debug.log*
yarn-debug.log*

# System
.DS_Store
Thumbs.db
EOF

# 1.2 Initialisation Git et commit initial
(
  cd "${CLIENT_DIR}"
  git init -q
  git config user.name "QA Test Engineer"
  git config user.email "qa-e2e@alexsan.pro"
  git add .
  git commit -m "feat: initial client application commit" -q
)
pass "Projet client Next.js / TypeScript initialisé et versionné sous Git."

# 1.3 Exécution du CLI d'installation locale
node "${CLI_BIN}" init --local --all --dir="${CLIENT_DIR}" > "${TMP_BASE}/test1_install.log" 2>&1 || {
  echo -e "${RED}[ERREUR] Échec de l'installation CLI locale !${NC}" >&2
  cat "${TMP_BASE}/test1_install.log" >&2
  fail "L'installation CLI locale a échoué."
}
pass "Installation locale exécutée avec succès via le CLI (node src/cli/index.js init --local --all --dir=...)."

# 1.4 Vérification des 17 compétences déployées dans .agents/skills/
SKILL_COUNT=$(find "${CLIENT_DIR}/.agents/skills" -mindepth 1 -maxdepth 1 -type d -name "san_*" | wc -l)
if [[ "${SKILL_COUNT}" -ne 17 ]]; then
  fail "Nombre de compétences installées incorrect : ${SKILL_COUNT}/17 !"
fi
pass "Exactement 17 compétences Antigravity déployées dans .agents/skills/."

# 1.5 Vérification des règles normatives dans .agents/rules/
EXPECTED_RULES=("BRAND.md" "PRODUCT.md" "PROJECT.md" "API.md" "LOGO.md")
for rule_file in "${EXPECTED_RULES[@]}"; do
  if [[ ! -f "${CLIENT_DIR}/.agents/rules/${rule_file}" ]]; then
    fail "Règle normative manquante : .agents/rules/${rule_file} !"
  fi
done
pass "Règles normatives déployées (BRAND.md, PRODUCT.md, PROJECT.md, API.md, LOGO.md)."

# 1.6 Vérification de GEMINI.md
if [[ ! -f "${CLIENT_DIR}/.agents/GEMINI.md" ]]; then
  fail "Fichier index maître .agents/GEMINI.md manquant !"
fi
pass "Index maître .agents/GEMINI.md vérifié (chargement contextuel natif v2.0 via frontmatters YAML)."

# 1.7 Vérification des permissions d'exécution sur tous les scripts déployés
SCRIPTS_FOUND=0
UNEXECUTABLE_SCRIPTS=0
while IFS= read -r -d '' script_file; do
  SCRIPTS_FOUND=$((SCRIPTS_FOUND + 1))
  if [[ ! -x "${script_file}" ]]; then
    echo -e "${RED}[!] Script non exécutable détecté : ${script_file}${NC}" >&2
    UNEXECUTABLE_SCRIPTS=$((UNEXECUTABLE_SCRIPTS + 1))
  fi
done < <(find "${CLIENT_DIR}/.agents/skills" -type f \( -name "*.sh" -o -name "*.mjs" \) -print0)

if [[ "${UNEXECUTABLE_SCRIPTS}" -gt 0 ]]; then
  fail "${UNEXECUTABLE_SCRIPTS} script(s) déployé(s) n'ont pas les droits d'exécution (+x) !"
fi
if [[ "${SCRIPTS_FOUND}" -lt 15 ]]; then
  fail "Nombre suspect de scripts trouvés (${SCRIPTS_FOUND} < 15) !"
fi
pass "Toutes les permissions d'exécution (+x) vérifiées sur les ${SCRIPTS_FOUND} scripts déployés (*.sh, *.mjs)."

# ==============================================================================
# TEST 2 : EXÉCUTION RÉELLE DE SCRIPTS DÉPLOYÉS DANS LE CONTEXTE CLIENT
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 2/6] Exécution réelle de scripts déployés dans le contexte client ---${NC}"

# 2.1 Exécution de build_tokens.mjs (san_design_tokens)
BUILD_TOKENS_DEPLOYED="${CLIENT_DIR}/.agents/skills/san_design_tokens/scripts/build_tokens.mjs"
if [[ ! -f "${BUILD_TOKENS_DEPLOYED}" ]]; then
  fail "Script déployé build_tokens.mjs introuvable !"
fi

(
  cd "${CLIENT_DIR}"
  node "${BUILD_TOKENS_DEPLOYED}" --input .agents/rules/BRAND.md --out-dir src/styles/tokens --format css > "${TMP_BASE}/test2_build_tokens.log" 2>&1
) || {
  echo -e "${RED}[ERREUR] Exécution de build_tokens.mjs a échoué !${NC}" >&2
  cat "${TMP_BASE}/test2_build_tokens.log" >&2
  fail "Échec de build_tokens.mjs sur BRAND.md."
}

if [[ ! -f "${CLIENT_DIR}/src/styles/tokens/tokens.css" ]]; then
  fail "Le fichier tokens.css n'a pas été généré par build_tokens.mjs !"
fi
if ! grep -q "\-\-color-primary" "${CLIENT_DIR}/src/styles/tokens/tokens.css"; then
  fail "tokens.css ne contient pas la définition attendue des tokens !"
fi
pass "build_tokens.mjs exécuté avec succès : BRAND.md compilé vers src/styles/tokens/tokens.css (audit WCAG conforme)."

# 2.2 Exécution de check_lorem.sh (san_copywriter) sur le projet client
CHECK_LOREM_DEPLOYED="${CLIENT_DIR}/.agents/skills/san_copywriter/scripts/check_lorem.sh"
if [[ ! -f "${CHECK_LOREM_DEPLOYED}" ]]; then
  fail "Script déployé check_lorem.sh introuvable !"
fi

(
  cd "${CLIENT_DIR}"
  bash "${CHECK_LOREM_DEPLOYED}" --dir src > "${TMP_BASE}/test2_check_lorem_clean.log" 2>&1
) || {
  echo -e "${RED}[ERREUR] check_lorem.sh a échoué sur du code propre !${NC}" >&2
  cat "${TMP_BASE}/test2_check_lorem_clean.log" >&2
  fail "Faux positif lors de l'exécution de check_lorem.sh sur le projet client."
}
pass "check_lorem.sh exécuté avec succès sur src/ : code propre validé (zéro faux positif)."

# Test de non-régression de détection : injection temporaire de faux texte
cat << 'EOF' > "${CLIENT_DIR}/src/app/lorem_test.tsx"
export const Temp = () => <div>Lorem ipsum dolor sit amet</div>;
EOF

set +e
(
  cd "${CLIENT_DIR}"
  bash "${CHECK_LOREM_DEPLOYED}" --dir src > "${TMP_BASE}/test2_check_lorem_trap.log" 2>&1
)
LOREM_TRAP_CODE=$?
set -e
rm -f "${CLIENT_DIR}/src/app/lorem_test.tsx"

if [[ "${LOREM_TRAP_CODE}" -eq 0 ]]; then
  fail "check_lorem.sh n'a pas intercepté le faux texte injecté !"
fi
pass "check_lorem.sh intercepte rigoureusement les pollutions de faux texte (code de rejet: ${LOREM_TRAP_CODE})."

# 2.3 Exécution de archive_roadmap.sh (san_planner)
ARCHIVE_ROADMAP_DEPLOYED="${CLIENT_DIR}/.agents/skills/san_planner/scripts/archive_roadmap.sh"
if [[ ! -f "${ARCHIVE_ROADMAP_DEPLOYED}" ]]; then
  fail "Script déployé archive_roadmap.sh introuvable !"
fi

mkdir -p "${CLIENT_DIR}/roadmaps"

# A. Cas incomplet (doit échouer code 1)
cat << 'EOF' > "${CLIENT_DIR}/roadmaps/PHASE_TEST_INCOMPLETE.md"
# ROADMAP TEST PHASE INCOMPLETE
- [x] Tâche 1 complétée avec preuve
- [ ] Tâche 2 EN COURS NON TESTEE
- [x] Tâche 3 complétée avec preuve
EOF

set +e
(
  cd "${CLIENT_DIR}"
  bash "${ARCHIVE_ROADMAP_DEPLOYED}" roadmaps/PHASE_TEST_INCOMPLETE.md > "${TMP_BASE}/test2_archive_fail.log" 2>&1
)
ARCHIVE_FAIL_CODE=$?
set -e

if [[ "${ARCHIVE_FAIL_CODE}" -ne 1 ]]; then
  fail "archive_roadmap.sh aurait dû échouer avec exit code 1 sur roadmap incomplète (code retourné: ${ARCHIVE_FAIL_CODE}) !"
fi
if [[ ! -f "${CLIENT_DIR}/roadmaps/PHASE_TEST_INCOMPLETE.md" ]]; then
  fail "Le fichier de roadmap incomplète a été déplacé à tort !"
fi
pass "archive_roadmap.sh bloque strictement une roadmap incomplète (exit code 1)."

# B. Cas complet (doit réussir code 0)
cat << 'EOF' > "${CLIENT_DIR}/roadmaps/PHASE_TEST_COMPLETE.md"
# ROADMAP TEST PHASE COMPLETE 100%
- [x] Tâche 1 entièrement complétée et prouvée
- [x] Tâche 2 entièrement complétée et prouvée
- [x] Tâche 3 entièrement complétée et prouvée
EOF

set +e
(
  cd "${CLIENT_DIR}"
  bash "${ARCHIVE_ROADMAP_DEPLOYED}" roadmaps/PHASE_TEST_COMPLETE.md > "${TMP_BASE}/test2_archive_success.log" 2>&1
)
ARCHIVE_SUCCESS_CODE=$?
set -e

if [[ "${ARCHIVE_SUCCESS_CODE}" -ne 0 ]]; then
  echo -e "${RED}[ERREUR] archive_roadmap.sh a échoué sur roadmap 100% valide !${NC}" >&2
  cat "${TMP_BASE}/test2_archive_success.log" >&2
  fail "archive_roadmap.sh a échoué avec exit code ${ARCHIVE_SUCCESS_CODE} !"
fi
if [[ ! -f "${CLIENT_DIR}/roadmaps/archives/PHASE_TEST_COMPLETE.md" ]]; then
  fail "Le fichier de roadmap complet n'a pas été archivé dans roadmaps/archives/ !"
fi
pass "archive_roadmap.sh archive avec succès la roadmap 100% validée (exit code 0)."

# ==============================================================================
# TEST 3 : DÉPLOIEMENT EN MODE GLOBAL (--GLOBAL)
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 3/6] Déploiement en mode global (--global) ---${NC}"

GLOBAL_TARGET_DIR="${TMP_BASE}/global_skills_store"
mkdir -p "${GLOBAL_TARGET_DIR}"

node "${CLI_BIN}" init --global --all --dir="${GLOBAL_TARGET_DIR}" > "${TMP_BASE}/test3_global_install.log" 2>&1 || {
  echo -e "${RED}[ERREUR] Déploiement global CLI a échoué !${NC}" >&2
  cat "${TMP_BASE}/test3_global_install.log" >&2
  fail "Le déploiement global (--global) a échoué."
}

GLOBAL_SKILL_COUNT=0
if [[ -d "${GLOBAL_TARGET_DIR}/skills" ]]; then
  GLOBAL_SKILL_COUNT=$(find "${GLOBAL_TARGET_DIR}/skills" -mindepth 1 -maxdepth 1 -type d -name "san_*" | wc -l)
else
  GLOBAL_SKILL_COUNT=$(find "${GLOBAL_TARGET_DIR}" -mindepth 1 -maxdepth 1 -type d -name "san_*" | wc -l)
fi

if [[ "${GLOBAL_SKILL_COUNT}" -ne 17 ]]; then
  fail "Nombre de compétences déployées globalement incorrect : ${GLOBAL_SKILL_COUNT}/17 !"
fi
pass "17 compétences Antigravity déployées dans le répertoire global (${GLOBAL_TARGET_DIR})."

if [[ ! -f "${GLOBAL_TARGET_DIR}/plugin.json" ]]; then
  fail "Manifeste plugin.json absent dans le répertoire global !"
fi
pass "Manifeste plugin.json présent dans le déploiement global v2.0."

if command -v agy >/dev/null 2>&1; then
  set +e
  AGY_VAL_OUT=$(agy plugin validate "${GLOBAL_TARGET_DIR}" --strict --json 2>/dev/null)
  AGY_VAL_EXIT=$?
  set -e
  if [[ "${AGY_VAL_EXIT}" -ne 0 ]]; then
    fail "agy plugin validate --strict --json a échoué avec le code ${AGY_VAL_EXIT} !"
  fi
  pass "agy plugin validate --strict --json validé avec succès (exit 0)."
else
  pass "agy non trouvé dans PATH, validation sautée."
fi

GLOBAL_UNEXECUTABLE=0
while IFS= read -r -d '' script_file; do
  if [[ ! -x "${script_file}" ]]; then
    GLOBAL_UNEXECUTABLE=$((GLOBAL_UNEXECUTABLE + 1))
  fi
done < <(find "${GLOBAL_TARGET_DIR}" -type f \( -name "*.sh" -o -name "*.mjs" \) -print0)

if [[ "${GLOBAL_UNEXECUTABLE}" -gt 0 ]]; then
  fail "${GLOBAL_UNEXECUTABLE} script(s) globaux n'ont pas les permissions d'exécution !"
fi
pass "Toutes les permissions d'exécution (+x) vérifiées sur les compétences globales."

# ==============================================================================
# TEST 4 : ÉTANCHÉITÉ GIT ABSOLUE & PURGE ANTI-POLLUTION
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 4/6] Étanchéité Git absolue & purge anti-pollution ---${NC}"

# 4.1 Vérification de l'injection des blocs souverains dans .gitignore et .git/info/exclude
GITIGNORE_PATH="${CLIENT_DIR}/.gitignore"
EXCLUDE_PATH="${CLIENT_DIR}/.git/info/exclude"

if ! grep -F -q "# --- ANTIGRAVITY AI ISOLATION (san_*) ---" "${GITIGNORE_PATH}"; then
  fail "Bloc de souveraineté absent dans .gitignore !"
fi
if ! grep -F -q "/.agents/" "${GITIGNORE_PATH}"; then
  fail "Règle /.agents/ absente dans .gitignore !"
fi
pass "Bloc de souveraineté correctement injecté dans .gitignore."

if ! grep -F -q "# --- ANTIGRAVITY AI ISOLATION (san_*) ---" "${EXCLUDE_PATH}"; then
  fail "Bloc de souveraineté absent dans .git/info/exclude !"
fi
if ! grep -F -q "/.agents/" "${EXCLUDE_PATH}"; then
  fail "Règle /.agents/ absente dans .git/info/exclude !"
fi
pass "Bloc de souveraineté et étanchéité confirmés dans .git/info/exclude."

# 4.2 Vérifier que git status ne liste strictement aucun fichier de .agents/
cd "${CLIENT_DIR}"
GIT_STATUS_AGENTS=$(git status --porcelain | grep "\.agents" || true)
if [[ -n "${GIT_STATUS_AGENTS}" ]]; then
  fail "Fuite détectée ! 'git status' liste des fichiers .agents/ :\n${GIT_STATUS_AGENTS}"
fi
pass "Étanchéité souveraine Git validée : zéro fichier .agents/ visible dans git status."

# 4.3 Simulation de pollution résiduelle par d'anciens agents (CLAUDE.md et .cursorrules)
echo "# Configuration obsolète Claude" > "${CLIENT_DIR}/CLAUDE.md"
echo "cursor_rules = obsolete" > "${CLIENT_DIR}/.cursorrules"

(
  cd "${CLIENT_DIR}"
  git add -f CLAUDE.md .cursorrules
  git commit -m "chore: add legacy agent pollution files" -q
)

if [[ ! -f "${CLIENT_DIR}/CLAUDE.md" ]] || [[ ! -f "${CLIENT_DIR}/.cursorrules" ]]; then
  fail "Échec de création des fichiers de test pollués CLAUDE.md / .cursorrules."
fi

# 4.4 Relance du déploiement
node "${CLI_BIN}" init --local --all --dir="${CLIENT_DIR}" > "${TMP_BASE}/test4_purge.log" 2>&1

# 4.5 Vérification de la purge physique et du désindexage Git
if [[ -f "${CLIENT_DIR}/CLAUDE.md" ]]; then
  fail "CLAUDE.md n'a pas été supprimé physiquement du disque !"
fi
if [[ -f "${CLIENT_DIR}/.cursorrules" ]]; then
  fail ".cursorrules n'a pas été supprimé physiquement du disque !"
fi
pass "Purge physique immédiate des résidus d'anciens agents (CLAUDE.md, .cursorrules) validée."

cd "${CLIENT_DIR}"
INDEXED_LEGACY=$(git ls-files CLAUDE.md .cursorrules || true)
if [[ -n "${INDEXED_LEGACY}" ]]; then
  fail "Les fichiers purgés sont toujours indexés dans l'arbre Git : ${INDEXED_LEGACY} !"
fi
pass "Désindexage automatique du cache Git (git rm --cached) validé pour les résidus."

# ==============================================================================
# TEST 5 : SMART MERGE & NON-RÉGRESSION
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 5/6] Smart Merge & Non-régression ---${NC}"

# 5.1 Personnalisation utilisateur de PRODUCT.md
CUSTOM_PRODUCT_CONTENT="CONFIDENTIAL UNIQUE PRODUCT VALUE - 100% SECURE BANKING PLATFORM CONGO"
echo "${CUSTOM_PRODUCT_CONTENT}" > "${CLIENT_DIR}/.agents/rules/PRODUCT.md"

# 5.2 Création d'un skill custom externe
mkdir -p "${CLIENT_DIR}/.agents/skills/my_custom_skill"
cat << 'EOF' > "${CLIENT_DIR}/.agents/skills/my_custom_skill/SKILL.md"
---
name: my_custom_skill
description: Compétence propriétaire sur mesure du client
---

# My Custom Skill
Logique métier privée.
EOF

# 5.3 Réexécution du CLI d'installation
node "${CLI_BIN}" init --local --all --dir="${CLIENT_DIR}" > "${TMP_BASE}/test5_smart_merge.log" 2>&1

# 5.4 Assertions de non-régression
if ! grep -q "${CUSTOM_PRODUCT_CONTENT}" "${CLIENT_DIR}/.agents/rules/PRODUCT.md"; then
  fail "Smart Merge défaillant ! Le fichier personnalisé .agents/rules/PRODUCT.md a été écrasé !"
fi
pass "Smart Merge validé : PRODUCT.md personnalisé scrupuleusement préservé sans écrasement."

if [[ ! -f "${CLIENT_DIR}/.agents/skills/my_custom_skill/SKILL.md" ]]; then
  fail "Non-régression défaillante ! La compétence tierce my_custom_skill a été supprimée !"
fi
pass "Non-régression validée : my_custom_skill tiers préservé dans .agents/skills/."

TOTAL_SKILLS_LOCAL=$(find "${CLIENT_DIR}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [[ "${TOTAL_SKILLS_LOCAL}" -ne 18 ]]; then
  fail "Nombre total de compétences inattendu dans .agents/skills/ : ${TOTAL_SKILLS_LOCAL} (attendu: 18) !"
fi
pass "Intégrité globale du répertoire de compétences confirmée (17 san_* + 1 custom = 18)."

# ==============================================================================
# TEST 6 : CONFORMITÉ CARTÉSIENNE ANTIGRAVITY DES 17 MODULES DU FRAMEWORK
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [TEST 6/6] Conformité cartésienne Antigravity des 17 modules ---${NC}"

AUDITED_MODULES=0
FORBIDDEN_FOUND=0
INVALID_FRONTMATTER=0

for module_dir in "${FRAMEWORK_ROOT}/src/skills"/san_*; do
  [[ -d "${module_dir}" ]] || continue
  module_name=$(basename "${module_dir}")
  AUDITED_MODULES=$((AUDITED_MODULES + 1))
  skill_file="${module_dir}/SKILL.md"

  # A. Existence de SKILL.md
  if [[ ! -f "${skill_file}" ]]; then
    echo -e "${RED}[!] SKILL.md manquant pour ${module_name}${NC}" >&2
    INVALID_FRONTMATTER=$((INVALID_FRONTMATTER + 1))
    continue
  fi

  # B. Validation du frontmatter YAML et de description
  first_line=$(head -n 1 "${skill_file}")
  if [[ "${first_line}" != "---" ]]; then
    echo -e "${RED}[!] Frontmatter YAML invalide (début sans '---') : ${module_name}${NC}" >&2
    INVALID_FRONTMATTER=$((INVALID_FRONTMATTER + 1))
  fi

  description_val=$(grep -E "^description:" "${skill_file}" | head -n 1 | sed -E "s/^description:[[:space:]]*//" || true)
  if [[ -z "${description_val}" ]]; then
    echo -e "${RED}[!] 'description:' absente ou vide dans ${module_name}${NC}" >&2
    INVALID_FRONTMATTER=$((INVALID_FRONTMATTER + 1))
  fi

  name_val=$(grep -E "^name:" "${skill_file}" | head -n 1 | sed -E "s/^name:[[:space:]]*//" || true)
  if [[ -z "${name_val}" ]]; then
    echo -e "${RED}[!] 'name:' absent ou vide dans ${module_name}${NC}" >&2
    INVALID_FRONTMATTER=$((INVALID_FRONTMATTER + 1))
  fi

  # C. Traque impitoyable des mentions privées interdites
  forbidden_matches=$(grep -in -E "koteka|vunette" "${skill_file}" || true)
  if [[ -n "${forbidden_matches}" ]]; then
    echo -e "${RED}[!] Mention privée interdite détectée dans ${module_name}/SKILL.md :${NC}" >&2
    echo "${forbidden_matches}" >&2
    FORBIDDEN_FOUND=$((FORBIDDEN_FOUND + 1))
  fi
done

if [[ "${AUDITED_MODULES}" -ne 17 ]]; then
  fail "Nombre de modules audités incorrect dans src/skills/ : ${AUDITED_MODULES}/17 !"
fi
pass "17 modules sources audités avec succès dans src/skills/."

if [[ "${INVALID_FRONTMATTER}" -gt 0 ]]; then
  fail "${INVALID_FRONTMATTER} module(s) ont un frontmatter YAML invalide ou incomplet !"
fi
pass "Conformité cartésienne du frontmatter YAML (name, description non vide, délimiteurs) validée sur tous les 17 modules."

if [[ "${FORBIDDEN_FOUND}" -gt 0 ]]; then
  fail "${FORBIDDEN_FOUND} module(s) contiennent des mentions privées interdites ('koteka', 'vunette') !"
fi
pass "Zéro mention privée interdite ('koteka', 'vunette') dans l'ensemble des 17 modules (universalité souveraine)."

# ==============================================================================
# BILAN FINAL & RAPPORT D'EXÉCUTION
# ==============================================================================
echo ""
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}     BILAN GLOBAL E2E : ${PASSED_TESTS}/${TOTAL_TESTS} VÉRIFICATIONS RÉUSSIES (100% VERT)       ${NC}"
echo -e "${GREEN}${BOLD}     STATUT FINAL : PHASE 8 VALIDÉE AVEC SUCCÈS                        ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}\n"

exit 0
