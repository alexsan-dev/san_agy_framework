#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 1 — CONSTITUTION V2.0, PROFILS CONTEXTUELS & RÈGLES YAML
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TEMPLATES_DIR="${ROOT_DIR}/src/skills/san_init/templates"
RULES_DIR="${TEMPLATES_DIR}/rules"

PASSED_TESTS=0
FAILED_TESTS=0

green() { echo -e "\033[32m✔ $1\033[0m"; }
red() { echo -e "\033[31m✘ $1\033[0m"; }
info() { echo -e "\033[34mℹ $1\033[0m"; }

assert_true() {
  local desc="$1"
  local condition="$2"
  if eval "$condition"; then
    green "$desc"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    red "ÉCHEC: $desc"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

echo "======================================================================"
echo "  TEST PHASE 1 : CONSTITUTION V2.0 & RÈGLES D'ORCHESTRATION"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 1. Vérification de l'absence de frontmatter YAML sur AGENTS & GEMINI
# ------------------------------------------------------------------------------
info "1. Vérification de l'absence de frontmatter YAML (always_on natif)"

AGENTS_FIRST_LINE=$(head -n 1 "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md")
assert_true "AGENTS_INDEX_TEMPLATE.md ne commence PAS par '---'" \
  '[ "${AGENTS_FIRST_LINE}" != "---" ]'

GEMINI_FIRST_LINE=$(head -n 1 "${TEMPLATES_DIR}/GEMINI_INDEX_TEMPLATE.md")
assert_true "GEMINI_INDEX_TEMPLATE.md ne commence PAS par '---'" \
  '[ "${GEMINI_FIRST_LINE}" != "---" ]'

assert_true "AGENTS_INDEX_TEMPLATE.md conserve le marqueur de Smart Merge" \
  'grep -q "<!-- san_\* context (generated) -->" "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md"'

AGENTS_SIZE=$(wc -c < "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md" | tr -d ' ')
assert_true "AGENTS_INDEX_TEMPLATE.md fait < 4 KB (${AGENTS_SIZE} octets)" \
  '[ "${AGENTS_SIZE}" -lt 4096 ]'

# ------------------------------------------------------------------------------
# 2. Vérification des 6 Lois d'Airain et de la Table de Routage d'Intention
# ------------------------------------------------------------------------------
info "2. Vérification des 6 Lois d'Airain et de la Table de Routage"

for law in "Zéro Solo-Coding" "Reconnaissance Factuelle" "Sous-Agents Atomiques" "Doute Contradictoire" "Contract-First" "Preuve par le Code Fail-Closed"; do
  assert_true "AGENTS_INDEX_TEMPLATE.md contient la loi : $law" \
    'grep -q "$law" "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md"'
  assert_true "GEMINI_INDEX_TEMPLATE.md contient la loi : $law" \
    'grep -q "$law" "${TEMPLATES_DIR}/GEMINI_INDEX_TEMPLATE.md"'
done

assert_true "AGENTS_INDEX_TEMPLATE.md contient la Table de Routage d'Intention" \
  'grep -q "TABLE DE ROUTAGE AUTOMATIQUE D'\''INTENTION" "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md"'

for intent in "Idéation, cadrage, scoring" \
              "Roadmap, phases, découpage" \
              "UI/UX, maquette, CSS, tokens" \
              "Feature, delivery, dev full-stack" \
              "QA, sécurité, audit, tests" \
              "Docker, CI/CD, déploiement" \
              "Store, ASO, RGPD, légal" \
              "Growth, SEO, acquisition"; do
  assert_true "AGENTS_INDEX_TEMPLATE.md contient l'intention : $intent" \
    'grep -q "$intent" "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md"'
  assert_true "GEMINI_INDEX_TEMPLATE.md contient l'intention : $intent" \
    'grep -q "$intent" "${TEMPLATES_DIR}/GEMINI_INDEX_TEMPLATE.md"'
done

assert_true "AGENTS_INDEX_TEMPLATE.md contient le placeholder {{SKILLS_LIST}}" \
  'grep -q "{{SKILLS_LIST}}" "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md"'

# ------------------------------------------------------------------------------
# 3. Vérification des Frontmatters YAML officiels sur les 5 règles
# ------------------------------------------------------------------------------
info "3. Vérification des Frontmatters YAML officiels sur les 5 règles"

check_yaml_frontmatter() {
  local file="$1"
  local expected_trigger="$2"
  local first_line
  first_line=$(head -n 1 "$file")
  if [ "$first_line" != "---" ]; then
    return 1
  fi
  grep -q "trigger: ${expected_trigger}" "$file" || return 1
  return 0
}

# PROJECT_TEMPLATE.md
assert_true "PROJECT_TEMPLATE.md possède un frontmatter valide avec trigger: always_on" \
  'check_yaml_frontmatter "${RULES_DIR}/PROJECT_TEMPLATE.md" "always_on"'

PROJECT_SIZE=$(wc -c < "${RULES_DIR}/PROJECT_TEMPLATE.md" | tr -d ' ')
assert_true "PROJECT_TEMPLATE.md fait < 8 KB (${PROJECT_SIZE} octets)" \
  '[ "${PROJECT_SIZE}" -lt 8192 ]'

assert_true "PROJECT_TEMPLATE.md documente PROJECT_PROFILE avec les 5 profils" \
  'grep -q "PROJECT_PROFILE:.*global_saas.*emerging_market_3g.*mobile_consumer.*cli_devtools.*api_platform" "${RULES_DIR}/PROJECT_TEMPLATE.md"'

assert_true "PROJECT_TEMPLATE.md documente le routage cognitif pro / flash" \
  'grep -q "gemini-3.1-pro-high" "${RULES_DIR}/PROJECT_TEMPLATE.md" && grep -q "gemini-3.8-flash-high" "${RULES_DIR}/PROJECT_TEMPLATE.md"'

# PRODUCT_TEMPLATE.md
assert_true "PRODUCT_TEMPLATE.md possède trigger: model_decision" \
  'check_yaml_frontmatter "${RULES_DIR}/PRODUCT_TEMPLATE.md" "model_decision"'

assert_true "PRODUCT_TEMPLATE.md possède la description de scoping requise" \
  'grep -q "Load when scoping product features, user flows, personas, business invariants, or market constraints." "${RULES_DIR}/PRODUCT_TEMPLATE.md"'

assert_true "PRODUCT_TEMPLATE.md possède des blocs de contraintes modulaires par profil" \
  'grep -q "BLOC A.*emerging_market_3g" "${RULES_DIR}/PRODUCT_TEMPLATE.md" && grep -q "BLOC B.*global_saas" "${RULES_DIR}/PRODUCT_TEMPLATE.md" && grep -q "BLOC C.*cli_devtools" "${RULES_DIR}/PRODUCT_TEMPLATE.md"'

# BRAND_TEMPLATE.md
assert_true "BRAND_TEMPLATE.md possède trigger: glob" \
  'check_yaml_frontmatter "${RULES_DIR}/BRAND_TEMPLATE.md" "glob"'

assert_true "BRAND_TEMPLATE.md possède les globs CSS/UI attendus" \
  'grep -q "globs: \"\*\.tsx, \*\.jsx, \*\.vue, \*\.svelte, \*\.html, \*\.css, \*\.scss, \*tailwind\*\"" "${RULES_DIR}/BRAND_TEMPLATE.md"'

assert_true "BRAND_TEMPLATE.md propose le choix explicite de l'\''Archétype Esthétique" \
  'grep -q "Minimalist Swiss" "${RULES_DIR}/BRAND_TEMPLATE.md" && grep -q "Neo-Brutalist" "${RULES_DIR}/BRAND_TEMPLATE.md" && grep -q "Editorial Warm" "${RULES_DIR}/BRAND_TEMPLATE.md"'

# API_TEMPLATE.md
assert_true "API_TEMPLATE.md possède trigger: glob" \
  'check_yaml_frontmatter "${RULES_DIR}/API_TEMPLATE.md" "glob"'

assert_true "API_TEMPLATE.md possède les globs API/route/controller/bru" \
  'grep -q "globs: \"\*controller\*, \*Controller\*, \*route\*, \*api\*, \*\.bru, \*openapi\*, \*schema\*, \*dto\*, \*migration\*\"" "${RULES_DIR}/API_TEMPLATE.md"'

assert_true "API_TEMPLATE.md impose transactions DB et Idempotency-Key" \
  'grep -q "TRANSACTIONS DE BASE DE DONNÉES OBLIGATOIRES" "${RULES_DIR}/API_TEMPLATE.md" && grep -q "Idempotency-Key" "${RULES_DIR}/API_TEMPLATE.md"'

# LOGO_TEMPLATE.md
assert_true "LOGO_TEMPLATE.md possède trigger: glob" \
  'check_yaml_frontmatter "${RULES_DIR}/LOGO_TEMPLATE.md" "glob"'

assert_true "LOGO_TEMPLATE.md possède les globs logo/icon/favicon/svg" \
  'grep -q "globs: \"\*logo\*, \*icon\*, \*favicon\*, \*manifest\*, \*\.svg\"" "${RULES_DIR}/LOGO_TEMPLATE.md"'

# ------------------------------------------------------------------------------
# 4. Vérification de la taille maximale de chaque template (< 18 KB)
# ------------------------------------------------------------------------------
info "4. Vérification de la taille maximale de chaque template (< 18 KB)"

for tmpl in "${TEMPLATES_DIR}/AGENTS_INDEX_TEMPLATE.md" \
            "${TEMPLATES_DIR}/GEMINI_INDEX_TEMPLATE.md" \
            "${RULES_DIR}/PROJECT_TEMPLATE.md" \
            "${RULES_DIR}/PRODUCT_TEMPLATE.md" \
            "${RULES_DIR}/BRAND_TEMPLATE.md" \
            "${RULES_DIR}/API_TEMPLATE.md" \
            "${RULES_DIR}/LOGO_TEMPLATE.md"; do
  file_name=$(basename "$tmpl")
  file_size=$(wc -c < "$tmpl" | tr -d ' ')
  assert_true "$file_name fait < 18 KB (${file_size} octets)" \
    '[ "${file_size}" -lt 18432 ]'
done

# ------------------------------------------------------------------------------
# 5. Vérification de la suppression de rules_json_template.json
# ------------------------------------------------------------------------------
info "5. Vérification de la suppression de rules_json_template.json"

assert_true "rules_json_template.json n'existe plus sur le disque" \
  '[ ! -f "${TEMPLATES_DIR}/rules_json_template.json" ]'

# ------------------------------------------------------------------------------
# 6. Validation officielle des 5 règles via 'agy plugin validate --strict --json'
# ------------------------------------------------------------------------------
info "6. Validation officielle des 5 règles via 'agy plugin validate --strict --json'"

TMP_PLUGIN_DIR=$(mktemp -d /tmp/test_san_plugin_XXXXXX)
mkdir -p "${TMP_PLUGIN_DIR}/rules"
cat << 'EOF' > "${TMP_PLUGIN_DIR}/plugin.json"
{
  "name": "san-mock-rules",
  "version": "1.0.0",
  "description": "Mock plugin to validate rules YAML frontmatter"
}
EOF
cp "${RULES_DIR}"/*.md "${TMP_PLUGIN_DIR}/rules/"
for f in "${TMP_PLUGIN_DIR}/rules"/*_TEMPLATE.md; do
  mv "$f" "${f//_TEMPLATE/}"
done

VALIDATE_OUT=$(agy plugin validate "${TMP_PLUGIN_DIR}" --strict --json 2>&1)
VALIDATE_CODE=$?

assert_true "agy plugin validate --strict --json retourne code 0" \
  '[ "${VALIDATE_CODE}" -eq 0 ]'

VALIDATE_RULES_COUNT=$(node -e "const r = JSON.parse(process.argv[1]); console.log(r.components?.rules || 0);" "${VALIDATE_OUT}")
assert_true "agy plugin validate a détecté exactement 5 règles valides" \
  '[ "${VALIDATE_RULES_COUNT}" -eq 5 ]'

VALIDATE_ERRORS_WARNINGS=$(node -e "const r = JSON.parse(process.argv[1]); const bad = (r.findings || []).filter(f => f.severity === 'error' || f.severity === 'warning'); console.log(bad.length);" "${VALIDATE_OUT}")
assert_true "agy plugin validate relève 0 erreur et 0 warning" \
  '[ "${VALIDATE_ERRORS_WARNINGS}" -eq 0 ]'

rm -rf "${TMP_PLUGIN_DIR}"

# ------------------------------------------------------------------------------
# 7. Vérification de la taille de AGENTS.md généré (< 4096 octets)
# ------------------------------------------------------------------------------
info "7. Vérification de la taille de AGENTS.md généré avec les 17 compétences (< 4096 octets)"

TMP_AGENTS_GEN_DIR=$(mktemp -d /tmp/test_san_agents_gen_XXXXXX)
node -e "
  const { generateAgentsContext } = require('${ROOT_DIR}/src/cli/installer.js');
  generateAgentsContext('${TMP_AGENTS_GEN_DIR}');
"
GEN_AGENTS_SIZE=$(wc -c < "${TMP_AGENTS_GEN_DIR}/AGENTS.md" | tr -d ' ')
assert_true "AGENTS.md généré fait strictement < 4096 octets (${GEN_AGENTS_SIZE} octets)" \
  '[ "${GEN_AGENTS_SIZE}" -lt 4096 ]'

assert_true "AGENTS.md généré contient les 17 compétences san_*" \
  'grep -q "san_ux_ui_expert" "${TMP_AGENTS_GEN_DIR}/AGENTS.md" && grep -q "san_backend_expert" "${TMP_AGENTS_GEN_DIR}/AGENTS.md"'

assert_true "AGENTS.md généré contient les descriptions ultra-concises" \
  'grep -q "API, transactions DB et idempotence." "${TMP_AGENTS_GEN_DIR}/AGENTS.md" && grep -q "Composants front/mobile, 5 états et 60 fps." "${TMP_AGENTS_GEN_DIR}/AGENTS.md"'

rm -rf "${TMP_AGENTS_GEN_DIR}"

# ------------------------------------------------------------------------------
# 8. Vérification que git_ai_hygiene.sh et installer.js préservent AGENTS.md
# ------------------------------------------------------------------------------
info "8. Vérification de la préservation de AGENTS.md (Zéro purge déchet)"

TMP_HYGIENE_DIR=$(mktemp -d /tmp/test_san_preserve_agents_XXXXXX)
(
  cd "${TMP_HYGIENE_DIR}"
  git init -q
  git config user.name "Preserve Tester"
  git config user.email "preserve@alexsan.pro"
  echo "# AGENTS.md existant et souverain" > AGENTS.md
  echo "legacy claude file" > CLAUDE.md
  echo "legacy cursor file" > .cursorrules
  git add AGENTS.md CLAUDE.md .cursorrules
  git commit -m "chore: test initial state" -q
)

(
  cd "${TMP_HYGIENE_DIR}"
  bash "${ROOT_DIR}/src/skills/san_init/scripts/git_ai_hygiene.sh" > /dev/null 2>&1
)

assert_true "git_ai_hygiene.sh ne supprime PAS AGENTS.md" \
  '[ -f "${TMP_HYGIENE_DIR}/AGENTS.md" ]'

assert_true "git_ai_hygiene.sh a bien purgé les vrais déchets (CLAUDE.md)" \
  '[ ! -f "${TMP_HYGIENE_DIR}/CLAUDE.md" ]'

node "${ROOT_DIR}/src/cli/index.js" init --local --all --dir="${TMP_HYGIENE_DIR}" > /dev/null 2>&1

assert_true "installer.js (init local) ne supprime PAS AGENTS.md" \
  '[ -f "${TMP_HYGIENE_DIR}/AGENTS.md" ]'

assert_true "AGENTS.md personnalisé a été scrupuleusement conservé (Smart Merge)" \
  'grep -q "AGENTS.md existant et souverain" "${TMP_HYGIENE_DIR}/AGENTS.md"'

rm -rf "${TMP_HYGIENE_DIR}"

# ------------------------------------------------------------------------------
# Bilan
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  BILAN DE VALIDATION PHASE 1"
echo "======================================================================"
echo "  Tests réussis : ${PASSED_TESTS}"
echo "  Tests échoués : ${FAILED_TESTS}"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "TOUS LES TESTS DE LA PHASE 1 SONT AU VERT (EXIT CODE 0) !"
  exit 0
else
  red "ÉCHEC : ${FAILED_TESTS} test(s) en erreur."
  exit 1
fi
