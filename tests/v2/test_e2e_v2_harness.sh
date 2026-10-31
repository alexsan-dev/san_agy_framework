#!/usr/bin/env bash
# ==============================================================================
# SUITE OFFICIELLE D'INTÉGRATION E2E & HARNESS v2.0 (Google Antigravity)
# Framework : @alexsan/agy-framework (san_*)
# Auteur    : Alexsan.pro · Cartesian Engineering & Cognitive Harness
# ==============================================================================
# Valide de bout en bout les 4 assertions clés de la Section 7.2 :
# 1. agy plugin validate --strict --json sur bundle global (0 finding, components conformes)
# 2. Déploiement local vierge Next.js/TS + doctor 6/6 au vert + git hermétique
# 3. Migration update non destructive v1.0 -> v2.0 (frontmatter injecté + texte intact + doctor vert)
# 4. Exécution bout-en-bout des 3 hooks et des 4 Quality Gates Fail-Closed
# ==============================================================================

set -euo pipefail

# Assurer que agy est accessible dans le PATH
export PATH="${HOME}/.local/bin:${PATH}"

# Définition des couleurs ANSI
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLI_INDEX="${FRAMEWORK_ROOT}/src/cli/index.js"

HOOKS_DIR="${FRAMEWORK_ROOT}/src/hooks"
HOOK_SCRIPTS_DIR="${HOOKS_DIR}/scripts"

QA_SECURITY_GATE="${FRAMEWORK_ROOT}/src/skills/san_qa_security_expert/scripts/qa_security_gate.sh"
BACKEND_GATE="${FRAMEWORK_ROOT}/src/skills/san_backend_expert/scripts/backend_quality_gate.sh"
FRONT_GATE="${FRAMEWORK_ROOT}/src/skills/san_ux_ui_expert/scripts/front_quality_gate.sh"
E2E_GATE="${FRAMEWORK_ROOT}/src/skills/san_executer/scripts/e2e_verification_gate.sh"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

pass() {
  local msg="$1"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  PASSED_TESTS=$((PASSED_TESTS + 1))
  echo -e "  ${GREEN}✔${NC} ${msg}"
}

fail() {
  local msg="$1"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  FAILED_TESTS=$((FAILED_TESTS + 1))
  echo -e "  ${RED}✖ ÉCHEC :${NC} ${msg}" >&2
}

assert_true() {
  local desc="$1"
  local cmd="$2"
  if eval "${cmd}"; then
    pass "${desc}"
  else
    fail "${desc}"
  fi
}

echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${CYAN}${BOLD}  SUITE E2E V2.0 : HARNESS ENFORCEMENT & CERTIFICATION OFFICIELLE    ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${GRAY}Framework Root : ${FRAMEWORK_ROOT}${NC}"
echo -e "${GRAY}CLI Binary     : ${CLI_INDEX}${NC}\n"

# Répertoire temporaire racine pour tous les tests isolés
TMP_ROOT="$(mktemp -d /tmp/test_san_v2_harness_XXXXXX)"

cleanup() {
  local exit_code=$?
  rm -rf "${TMP_ROOT}"
  if [[ ${exit_code} -eq 0 && ${FAILED_TESTS} -eq 0 ]]; then
    echo -e "\n${GREEN}${BOLD}Environnement temporaire nettoyé. Statut : SUCCÈS TOTAL.${NC}"
  else
    echo -e "\n${YELLOW}Environnement temporaire nettoyé. Statut : ÉCHECS DÉTECTÉS (${FAILED_TESTS}).${NC}"
  fi
}
trap cleanup EXIT

# ==============================================================================
# SECTION 1 : ASSERTION 1 — PACKAGING PLUGIN GLOBAL & agy plugin validate
# ==============================================================================
echo -e "${BOLD}${MAGENTA}--- [ASSERTION 1/4] Packaging Plugin Global & agy plugin validate --strict ---${NC}"

TMP_GLOBAL="${TMP_ROOT}/global_plugin"
mkdir -p "${TMP_GLOBAL}"

# 1.1 Exécution de init --global
GLOBAL_INIT_OUT=$(node "${CLI_INDEX}" init --global --all --dir="${TMP_GLOBAL}")
assert_true "init --global --all s'exécute avec succès" \
  'echo "${GLOBAL_INIT_OUT}" | grep -q "PACKAGING PLUGIN GLOBAL"'

# 1.2 Vérification physique des composants du plugin
assert_true "Plugin global : manifeste plugin.json présent" \
  '[ -f "${TMP_GLOBAL}/plugin.json" ]'

assert_true "Plugin global : logo assets/logo.svg présent" \
  '[ -f "${TMP_GLOBAL}/assets/logo.svg" ]'

assert_true "Plugin global : hooks.json présent à la racine du plugin" \
  '[ -f "${TMP_GLOBAL}/hooks.json" ]'

assert_true "Plugin global : 3 scripts de hooks exécutables dans hooks/scripts/" \
  '[ -x "${TMP_GLOBAL}/hooks/scripts/session_start.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_invocation.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_tool_guard.mjs" ]'

GLOBAL_AGENTS_COUNT=$(find "${TMP_GLOBAL}/agents" -type f -name "san-*.md" | wc -l)
assert_true "Plugin global : exactement 8 sous-agents dans agents/ (${GLOBAL_AGENTS_COUNT}/8)" \
  '[ "${GLOBAL_AGENTS_COUNT}" -eq 8 ]'

GLOBAL_RULES_COUNT=$(find "${TMP_GLOBAL}/rules" -type f -name "*.md" | wc -l)
assert_true "Plugin global : 5 règles avec frontmatter dans rules/ (${GLOBAL_RULES_COUNT}/5)" \
  '[ "${GLOBAL_RULES_COUNT}" -ge 1 ] && [ "${GLOBAL_RULES_COUNT}" -eq 5 ]'

GLOBAL_SKILLS_COUNT=$(find "${TMP_GLOBAL}/skills" -mindepth 1 -maxdepth 1 -type d -name "san_*" | wc -l)
assert_true "Plugin global : exactement 17 skills dans skills/ (${GLOBAL_SKILLS_COUNT}/17)" \
  '[ "${GLOBAL_SKILLS_COUNT}" -eq 17 ]'

# 1.3 Validation officielle Google Antigravity Plugin Engine
if command -v agy >/dev/null 2>&1; then
  set +e
  AGY_VAL_JSON=$(agy plugin validate "${TMP_GLOBAL}" --strict --json 2>/dev/null)
  AGY_VAL_CODE=$?
  set -e

  assert_true "agy plugin validate --strict --json retourne exit code 0" \
    '[ "${AGY_VAL_CODE}" -eq 0 ]'

  AGY_AGENTS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.agents ?? 0)")
  assert_true "agy plugin validate détecte exactement 8 agents (détectés: ${AGY_AGENTS})" \
    '[ "${AGY_AGENTS}" -eq 8 ]'

  AGY_HOOKS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.hooks ?? 0)")
  assert_true "agy plugin validate détecte exactement 1 hook (détectés: ${AGY_HOOKS})" \
    '[ "${AGY_HOOKS}" -eq 1 ]'

  AGY_RULES=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.rules ?? 0)")
  assert_true "agy plugin validate détecte >= 1 règles (détectées: ${AGY_RULES})" \
    '[ "${AGY_RULES}" -ge 1 ]'

  AGY_SKILLS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.skills ?? 0)")
  assert_true "agy plugin validate détecte exactement 17 skills (détectés: ${AGY_SKILLS})" \
    '[ "${AGY_SKILLS}" -eq 17 ]'

  AGY_FINDINGS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log((d.findings ?? []).length)")
  assert_true "agy plugin validate relève 0 finding (0 warning, 0 note, findings: [])" \
    '[ "${AGY_FINDINGS}" -eq 0 ]'
else
  fail "Binaire 'agy' introuvable dans PATH (${PATH})"
fi

# ==============================================================================
# SECTION 2 : ASSERTION 2 — DÉPLOIEMENT LOCAL NEXT.JS + DOCTOR 6/6 + GIT HERMÉTIQUE
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [ASSERTION 2/4] Déploiement Local Next.js, Doctor 6/6 & Herméticité Git ---${NC}"

TMP_CLIENT="${TMP_ROOT}/client_nextjs_app"
mkdir -p "${TMP_CLIENT}/src/app"

cat << 'EOF' > "${TMP_CLIENT}/package.json"
{
  "name": "client-nextjs-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "node -e 'process.exit(0)'"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/node": "^20.0.0",
    "@types/react": "^18.3.0"
  }
}
EOF

cat << 'EOF' > "${TMP_CLIENT}/tsconfig.json"
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "module": "esnext"
  }
}
EOF

cat << 'EOF' > "${TMP_CLIENT}/src/app/page.tsx"
import React from 'react';
export default function Page() {
  return <main><h1>Banque & MoMo v2.0</h1></main>;
}
EOF

cat << 'EOF' > "${TMP_CLIENT}/.gitignore"
node_modules/
.next/
out/
dist/

# --- ANTIGRAVITY AI ISOLATION (san_*) ---
# Espace souverain local Antigravity (Zéro fuite Git)
/.agents/
/AGENTS.md
/GEMINI.md
EOF

# Initialisation du dépôt Git du client
(
  cd "${TMP_CLIENT}"
  git init -q
  git config user.name "E2E Harness Engineer"
  git config user.email "qa-harness@alexsan.pro"
  git add .
  git commit -m "feat: initial client application commit" -q
)

# 2.1 Déploiement local complet via init --local --all
INIT_LOCAL_OUT=$(node "${CLI_INDEX}" init --local --all --dir="${TMP_CLIENT}")
assert_true "init --local --all s'exécute avec succès sur le projet client" \
  'echo "${INIT_LOCAL_OUT}" | grep -q "INSTALLATION DU FRAMEWORK ANTIGRAVITY"'

# 2.2 Exécution de doctor et validation des 6/6 piliers
set +e
DOCTOR_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_CLIENT}")
DOCTOR_EXIT=$?
set -e

assert_true "node src/cli/index.js doctor retourne exit code 0" \
  '[ "${DOCTOR_EXIT}" -eq 0 ]'

assert_true "doctor certifie 'CONFORME (6/6 PILIERS AU VERT)'" \
  'echo "${DOCTOR_OUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

assert_true "doctor valide le Pilier 1 (Gouvernance souveraine <root>/AGENTS.md)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Gouvernance souveraine"'

assert_true "doctor valide le Pilier 2 (Règles normatives .agents/rules/*.md)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Règles normatives"'

assert_true "doctor valide le Pilier 3 (Sous-agents natifs .agents/agents/*.md)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Sous-agents natifs"'

assert_true "doctor valide le Pilier 4 (Garde-fous mécaniques hooks.json & scripts)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Garde-fous mécaniques"'

assert_true "doctor valide le Pilier 5 (Catalogue des 17 skills <= 130 lignes)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Catalogue des 17 skills"'

assert_true "doctor valide le Pilier 6 (Étanchéité Git)" \
  'echo "${DOCTOR_OUT}" | grep -E "✔.*Étanchéité Git"'

# 2.3 Herméticité Git absolue (git status --porcelain 100% vide)
CLIENT_GIT_STATUS=$(git -C "${TMP_CLIENT}" status --porcelain)
assert_true "git status --porcelain est 100% vide (aucun fichier non suivi ni accidentellement commitable)" \
  '[ -z "${CLIENT_GIT_STATUS}" ]'

AGENTS_LEAK=$(git -C "${TMP_CLIENT}" status --porcelain | grep "\.agents" || true)
assert_true "Zéro artefact .agents/ détectable par Git" \
  '[ -z "${AGENTS_LEAK}" ]'

# ==============================================================================
# SECTION 3 : ASSERTION 3 — MIGRATION NON-DESTRUCTIVE v1.0 -> v2.0 VIA UPDATE
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [ASSERTION 3/4] Migration non-destructive v1.0 -> v2.0 via update ---${NC}"

TMP_V1="${TMP_ROOT}/legacy_v1_app"
mkdir -p "${TMP_V1}/.agents/rules"
mkdir -p "${TMP_V1}/.agents/skills/san_init"

(
  cd "${TMP_V1}"
  git init -q
  git config user.name "Legacy Maintainer"
  git config user.email "legacy@alexsan.pro"
)

# BRAND.md personnalisé métier v1 SANS frontmatter YAML
CUSTOM_BRAND_COLOR="#E11D48"
CUSTOM_BRAND_TYPO="Plus Jakarta Sans"
CUSTOM_BRAND_DIRECTIVE="Directive critique : Aucun bouton cyan sur fond blanc."

cat << EOF > "${TMP_V1}/.agents/rules/BRAND.md"
# CHARTE GRAPHIQUE V1 CLIENT PERSONNALISÉE
* Palette principale : ${CUSTOM_BRAND_COLOR} et #0284C7
* Typographie sur-mesure : ${CUSTOM_BRAND_TYPO}
* ${CUSTOM_BRAND_DIRECTIVE}
EOF

# PRODUCT.md personnalisé v1 SANS frontmatter YAML
CUSTOM_PRODUCT_DIRECTIVE="Invariant légal : KYC bancaire obligatoire niveau 2 avant tout transfert MoMo."
cat << EOF > "${TMP_V1}/.agents/rules/PRODUCT.md"
# SPÉCIFICATION PRODUIT CLIENT V1
* ${CUSTOM_PRODUCT_DIRECTIVE}
EOF

# Ancien fichier rules.json v1 obsolète
cat << 'EOF' > "${TMP_V1}/.agents/rules.json"
{
  "rules": ["BRAND", "PRODUCT"]
}
EOF

echo "v1 obsolete skill" > "${TMP_V1}/.agents/skills/san_init/SKILL.md"

# 3.1 Exécution de update
UPDATE_OUT=$(node "${CLI_INDEX}" update --dir="${TMP_V1}")
assert_true "update s'exécute avec succès sur le repo legacy v1.0" \
  'echo "${UPDATE_OUT}" | grep -q "MIGRATION & MISE À JOUR v2.0"'

# 3.2 Vérifications Smart Merge sur BRAND.md
BRAND_MIGRATED=$(cat "${TMP_V1}/.agents/rules/BRAND.md")
assert_true "BRAND.md : Frontmatter officiel 'trigger: glob' injecté" \
  'echo "${BRAND_MIGRATED}" | grep -q "trigger: glob"'

assert_true "BRAND.md : Couleur personnalisée '${CUSTOM_BRAND_COLOR}' 100% préservée" \
  'echo "${BRAND_MIGRATED}" | grep -q "${CUSTOM_BRAND_COLOR}"'

assert_true "BRAND.md : Typographie personnalisée '${CUSTOM_BRAND_TYPO}' 100% préservée" \
  'echo "${BRAND_MIGRATED}" | grep -q "${CUSTOM_BRAND_TYPO}"'

assert_true "BRAND.md : Directive métier critique 100% préservée" \
  'echo "${BRAND_MIGRATED}" | grep -q "${CUSTOM_BRAND_DIRECTIVE}"'

# 3.3 Vérifications Smart Merge sur PRODUCT.md
PRODUCT_MIGRATED=$(cat "${TMP_V1}/.agents/rules/PRODUCT.md")
assert_true "PRODUCT.md : Frontmatter officiel 'trigger: model_decision' injecté" \
  'echo "${PRODUCT_MIGRATED}" | grep -q "trigger: model_decision"'

assert_true "PRODUCT.md : Directive métier KYC 100% préservée" \
  'echo "${PRODUCT_MIGRATED}" | grep -q "${CUSTOM_PRODUCT_DIRECTIVE}"'

# 3.4 Vérification nettoyage et installation v2
assert_true "Ancien rules.json v1 formellement supprimé" \
  '[ ! -f "${TMP_V1}/.agents/rules.json" ]'

V1_AGENTS_COUNT=$(find "${TMP_V1}/.agents/agents" -type f -name "san-*.md" 2>/dev/null | wc -l)
assert_true "8 sous-agents natifs installés dans .agents/agents/ (${V1_AGENTS_COUNT}/8)" \
  '[ "${V1_AGENTS_COUNT}" -eq 8 ]'

assert_true "Fichier .agents/hooks.json installé et valide" \
  '[ -f "${TMP_V1}/.agents/hooks.json" ]'

V1_SKILLS_COUNT=$(find "${TMP_V1}/.agents/skills" -mindepth 1 -maxdepth 1 -type d -name "san_*" 2>/dev/null | wc -l)
assert_true "17 compétences resynchronisées dans .agents/skills/ (${V1_SKILLS_COUNT}/17)" \
  '[ "${V1_SKILLS_COUNT}" -eq 17 ]'

assert_true "Constitution souveraine <root>/AGENTS.md créée à la racine" \
  '[ -f "${TMP_V1}/AGENTS.md" ]'

# 3.5 Validation doctor sur le repo migré
set +e
DOC_V1_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_V1}")
DOC_V1_EXIT=$?
set -e

assert_true "doctor valide le repo migré avec exit code 0" \
  '[ "${DOC_V1_EXIT}" -eq 0 ]'

assert_true "doctor certifie le repo migré 'CONFORME (6/6 PILIERS AU VERT)'" \
  'echo "${DOC_V1_OUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

# ==============================================================================
# SECTION 4 : ASSERTION 4 — EXÉCUTION BOUT-EN-BOUT DES HOOKS & QUALITY GATES
# ==============================================================================
echo ""
echo -e "${BOLD}${MAGENTA}--- [ASSERTION 4/4] Exécution des 3 Hooks & des 4 Quality Gates Fail-Closed ---${NC}"

# 4.1 Test SessionStart (session_start.mjs)
SESSION_INPUT='{"workspacePaths": ["'"${FRAMEWORK_ROOT}"'"], "conversationId": "e2e-test-session"}'
SESSION_OUTPUT=$(echo "${SESSION_INPUT}" | node "${HOOK_SCRIPTS_DIR}/session_start.mjs")

assert_true "session_start.mjs produit un JSON valide" \
  'echo "${SESSION_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

SESSION_HAS_CONSTITUTION=$(echo "${SESSION_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data.get('injectSteps', [{}])[0].get('systemMessage', {}).get('systemMessage', '')
print('true' if '[SAN.AGY CONSTITUTION v2.0]' in msg and '8 native subagents' in msg else 'false')
")
assert_true "session_start.mjs injecte la Constitution souveraine v2.0" \
  '[ "${SESSION_HAS_CONSTITUTION}" = "true" ]'

# 4.2 Test PreInvocation (pre_invocation.mjs)
PRE_INV_INPUT='{"lastUserInput": "Développe le module de paiement MoMo", "conversationId": "e2e-test-preinv"}'
PRE_INV_OUTPUT=$(echo "${PRE_INV_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_invocation.mjs")

assert_true "pre_invocation.mjs produit un JSON valide sur prompt de développement" \
  'echo "${PRE_INV_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

PRE_INV_ENFORCES=$(echo "${PRE_INV_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
steps = data.get('injectSteps', [])
msg = steps[0].get('ephemeralMessage', '') if steps and isinstance(steps[0], dict) else ''
ok = ('Never solo-code features inline' in msg and 'san-qa-auditor' in msg)
print('true' if ok else 'false')
")
assert_true "pre_invocation.mjs injecte le rappel d'orchestration atomique et QA" \
  '[ "${PRE_INV_ENFORCES}" = "true" ]'

PRE_INV_NEUTRAL_INPUT='{"lastUserInput": "Bonjour quel temps fait-il ?", "conversationId": "e2e-test-neutral"}'
PRE_INV_NEUTRAL_OUTPUT=$(echo "${PRE_INV_NEUTRAL_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_invocation.mjs")
PRE_INV_NEUTRAL_EMPTY=$(echo "${PRE_INV_NEUTRAL_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
steps = data.get('injectSteps', None)
print('true' if isinstance(steps, list) and len(steps) == 0 else 'false')
")
assert_true "pre_invocation.mjs renvoie injectSteps: [] pour une question neutre" \
  '[ "${PRE_INV_NEUTRAL_EMPTY}" = "true" ]'

# 4.3 Test PreToolUse Guard (pre_tool_guard.mjs)
# A. Blocage archivage incomplet -> deny
INCOMPLETE_ARCHIVE_INPUT='{"toolCall": {"name": "write_file", "args": {"Path": "roadmaps/archives/2026-10-unfinished.md", "Content": "# Roadmap\n- [x] Tâche 1\n- [ ] Tâche non terminée restante\n"}}}'
DECISION_INCOMPLETE=$(echo "${INCOMPLETE_ARCHIVE_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys, json; print(json.load(sys.stdin).get('decision', ''))")
assert_true "pre_tool_guard.mjs bloque (decision: deny) l'archivage d'une roadmap incomplète" \
  '[ "${DECISION_INCOMPLETE}" = "deny" ]'

# B. Autorisation archivage complet -> ask
COMPLETE_ARCHIVE_INPUT='{"toolCall": {"name": "write_file", "args": {"Path": "roadmaps/archives/2026-10-finished.md", "Content": "# Archive\n- [x] Task 1\n- [x] Task 2"}}}'
DECISION_COMPLETE=$(echo "${COMPLETE_ARCHIVE_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys, json; print(json.load(sys.stdin).get('decision', ''))")
assert_true "pre_tool_guard.mjs émet 'ask' pour une roadmap 100% achevée" \
  '[ "${DECISION_COMPLETE}" = "ask" ]'

# C. Blocage lorem ipsum dans code source -> deny
LOREM_INPUT='{"toolCall": {"name": "write_file", "args": {"Path": "src/components/Dashboard.tsx", "Content": "<div>Lorem ipsum dolor sit amet</div>"}}}'
DECISION_LOREM=$(echo "${LOREM_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys, json; print(json.load(sys.stdin).get('decision', ''))")
assert_true "pre_tool_guard.mjs bloque (decision: deny) l'injection de lorem ipsum dans src/" \
  '[ "${DECISION_LOREM}" = "deny" ]'

# D. Code propre nominal -> ask
CLEAN_CODE_INPUT='{"toolCall": {"name": "write_file", "args": {"Path": "src/components/Dashboard.tsx", "Content": "export function Dashboard() { return <h1>Dashboard Pro</h1>; }"}}}'
DECISION_CLEAN=$(echo "${CLEAN_CODE_INPUT}" | node "${HOOK_SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys, json; print(json.load(sys.stdin).get('decision', ''))")
assert_true "pre_tool_guard.mjs émet 'ask' pour du code propre" \
  '[ "${DECISION_CLEAN}" = "ask" ]'

# 4.4 Les 4 Quality Gates Fail-Closed
TMP_GATES="${TMP_ROOT}/gates_validation"
mkdir -p "${TMP_GATES}"

# Gate 1 : qa_security_gate.sh
TMP_QA="${TMP_GATES}/qa"
mkdir -p "${TMP_QA}"
set +e
(cd "${TMP_QA}" && bash "${QA_SECURITY_GATE}") > /dev/null 2>&1
QA_EMPTY_EXIT=$?
set -e
assert_true "qa_security_gate.sh échoue (exit 1) en Fail-Closed sur un répertoire vide" \
  '[ "${QA_EMPTY_EXIT}" -eq 1 ]'

cat << 'EOF' > "${TMP_QA}/package.json"
{
  "name": "clean-qa-test",
  "scripts": { "test": "node -e 'process.exit(0)'" }
}
EOF
set +e
(cd "${TMP_QA}" && bash "${QA_SECURITY_GATE}") > /dev/null 2>&1
QA_PASS_EXIT=$?
set -e
assert_true "qa_security_gate.sh passe (exit 0) avec une suite de tests réelle conforme" \
  '[ "${QA_PASS_EXIT}" -eq 0 ]'

# Gate 2 : backend_quality_gate.sh
TMP_BACK="${TMP_GATES}/back"
mkdir -p "${TMP_BACK}"
set +e
(cd "${TMP_BACK}" && bash "${BACKEND_GATE}") > /dev/null 2>&1
BACK_EMPTY_EXIT=$?
set -e
assert_true "backend_quality_gate.sh échoue (exit 1) en Fail-Closed si aucune stack n'est détectée" \
  '[ "${BACK_EMPTY_EXIT}" -eq 1 ]'

mkdir -p "${TMP_BACK}/src"
cat << 'EOF' > "${TMP_BACK}/package.json"
{
  "name": "clean-backend",
  "scripts": { "test": "node -e 'process.exit(0)'" }
}
EOF
cat << 'EOF' > "${TMP_BACK}/src/server.js"
const express = require('express');
const app = express();
app.get('/health', (req, res) => res.json({ status: 'ok' }));
module.exports = app;
EOF
set +e
(cd "${TMP_BACK}" && bash "${BACKEND_GATE}") > /dev/null 2>&1
BACK_PASS_EXIT=$?
set -e
assert_true "backend_quality_gate.sh valide (exit 0) une stack backend avec suite de tests" \
  '[ "${BACK_PASS_EXIT}" -eq 0 ]'

# Gate 3 : front_quality_gate.sh
TMP_FRONT="${TMP_GATES}/front"
mkdir -p "${TMP_FRONT}"
set +e
(cd "${TMP_FRONT}" && bash "${FRONT_GATE}") > /dev/null 2>&1
FRONT_EMPTY_EXIT=$?
set -e
assert_true "front_quality_gate.sh échoue (exit 1) en Fail-Closed sur répertoire vide" \
  '[ "${FRONT_EMPTY_EXIT}" -eq 1 ]'

mkdir -p "${TMP_FRONT}/src"
cat << 'EOF' > "${TMP_FRONT}/package.json"
{
  "name": "clean-front",
  "scripts": { "test": "node -e 'process.exit(0)'" }
}
EOF
cat << 'EOF' > "${TMP_FRONT}/src/CleanComp.tsx"
import React, { useEffect } from 'react';
export const CleanComp = () => {
  useEffect(() => {
    const handler = () => {};
    window.addEventListener('resize', handler);
    return () => { window.removeEventListener('resize', handler); };
  }, []);
  return <div>Clean</div>;
};
EOF
set +e
(cd "${TMP_FRONT}" && bash "${FRONT_GATE}") > /dev/null 2>&1
FRONT_PASS_EXIT=$?
set -e
assert_true "front_quality_gate.sh valide (exit 0) un composant React avec cleanup conforme" \
  '[ "${FRONT_PASS_EXIT}" -eq 0 ]'

# Gate 4 : e2e_verification_gate.sh
TMP_E2E="${TMP_GATES}/e2e"
mkdir -p "${TMP_E2E}"
set +e
(cd "${TMP_E2E}" && bash "${E2E_GATE}") > /dev/null 2>&1
E2E_EMPTY_EXIT=$?
set -e
assert_true "e2e_verification_gate.sh échoue (exit 1) en Fail-Closed si CHECKS_RUN == 0" \
  '[ "${E2E_EMPTY_EXIT}" -eq 1 ]'

mkdir -p "${TMP_E2E}/bruno"
cat << 'EOF' > "${TMP_E2E}/bruno/test.bru"
meta {
  name: Test Endpoint
  type: http
  seq: 1
}
get {
  url: https://api.local/health
}
EOF
cat << 'EOF' > "${TMP_E2E}/composer.json"
{
  "name": "api/integration",
  "scripts": { "test": "exit 0" }
}
EOF
set +e
(cd "${TMP_E2E}" && bash "${E2E_GATE}") > /dev/null 2>&1
E2E_PASS_EXIT=$?
set -e
assert_true "e2e_verification_gate.sh certifie (exit 0) les contrats d'API avec suite d'intégration" \
  '[ "${E2E_PASS_EXIT}" -eq 0 ]'

# ==============================================================================
# SYNTHÈSE GLOBALE & RAPPORT FINAL
# ==============================================================================
echo ""
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "${BOLD}               BILAN FINAL DE LA SUITE OFFICIELLE E2E v2.0            ${NC}"
echo -e "${CYAN}${BOLD}======================================================================${NC}"
echo -e "  Total des assertions vérifiées : ${TOTAL_TESTS}"
echo -e "  Assertions réussies            : ${GREEN}${PASSED_TESTS}${NC}"
echo -e "  Assertions échouées            : ${RED}${FAILED_TESTS}${NC}"

if [[ "${FAILED_TESTS}" -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✔ SUCCÈS TOTAL : 100% DES 4 ASSERTIONS V2.0 SONT AU VERT !${NC}"
  echo -e "${CYAN}${BOLD}======================================================================${NC}\n"
  exit 0
else
  echo -e "${RED}${BOLD}✖ ÉCHEC : ${FAILED_TESTS} assertion(s) n'ont pas été validées.${NC}"
  echo -e "${CYAN}${BOLD}======================================================================${NC}\n"
  exit 1
fi
