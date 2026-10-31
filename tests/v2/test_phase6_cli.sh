#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 6 — PACKAGING DU PLUGIN & CLI UNIVERSEL (init, update, doctor)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLI_INDEX="${ROOT_DIR}/src/cli/index.js"

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
echo "  TEST PHASE 6 : CLI UNIVERSEL (init, update, doctor) & PLUGIN GLOBAL"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 0. Vérification de la version dans package.json
# ------------------------------------------------------------------------------
info "0. Vérification de la version 2.0.0 dans package.json"
PKG_VERSION=$(node -e "const pkg = JSON.parse(fs.readFileSync('${ROOT_DIR}/package.json', 'utf8')); console.log(pkg.version);")
assert_true "package.json a pour version '2.0.0' (actuel: ${PKG_VERSION})" \
  '[ "${PKG_VERSION}" = "2.0.0" ]'

CLI_VERSION_OUTPUT=$(node "${CLI_INDEX}" --version)
assert_true "CLI index.js --version retourne '2.0.0'" \
  'echo "${CLI_VERSION_OUTPUT}" | grep -q "2.0.0"'

# ------------------------------------------------------------------------------
# 1. Scénario 1 : init --local (Les 4 couches + gouvernance souveraine + hygiène réversible)
# ------------------------------------------------------------------------------
info "1. Scénario init --local sur dépôt temporaire avec résidus tiers"
TMP_LOCAL=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}"' EXIT

git -C "${TMP_LOCAL}" init -q
mkdir -p "${TMP_LOCAL}/.cursor"
echo "legacy cursor rules" > "${TMP_LOCAL}/.cursorrules"
echo "legacy claude md" > "${TMP_LOCAL}/CLAUDE.md"
echo '{"key":"value"}' > "${TMP_LOCAL}/.cursor/settings.json"
mkdir -p "${TMP_LOCAL}/.agents"
echo '{"rules": ["BRAND"]}' > "${TMP_LOCAL}/.agents/rules.json"

INIT_OUTPUT=$(node "${CLI_INDEX}" init --local --all --dir="${TMP_LOCAL}")
assert_true "init --local s'exécute avec succès" \
  'echo "${INIT_OUTPUT}" | grep -q "INSTALLATION DU FRAMEWORK ANTIGRAVITY"'

# Couche 1 : Skills
SKILLS_COUNT=$(find "${TMP_LOCAL}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
assert_true "Couche 1 : Les 17 skills sont installés dans .agents/skills/ (détectés: ${SKILLS_COUNT})" \
  '[ "${SKILLS_COUNT}" -eq 17 ]'

EXECUTABLE_SCRIPTS_COUNT=$(find "${TMP_LOCAL}/.agents/skills" -type f -name "*.sh" -perm -111 | wc -l)
assert_true "Couche 1 : Les scripts de skills possèdent le bit exécutable (chmod +x, count: ${EXECUTABLE_SCRIPTS_COUNT})" \
  '[ "${EXECUTABLE_SCRIPTS_COUNT}" -gt 5 ]'

# Couche 2 : Agents
AGENTS_COUNT=$(find "${TMP_LOCAL}/.agents/agents" -type f -name "san-*.md" | wc -l)
assert_true "Couche 2 : Les 8 sous-agents natifs sont déployés dans .agents/agents/ (count: ${AGENTS_COUNT})" \
  '[ "${AGENTS_COUNT}" -eq 8 ]'

assert_true "Couche 2 : san-researcher.md est présent et valide" \
  '[ -f "${TMP_LOCAL}/.agents/agents/san-researcher.md" ] && grep -q "name: san-researcher" "${TMP_LOCAL}/.agents/agents/san-researcher.md"'

assert_true "Couche 2 : san-architect.md est présent et valide" \
  '[ -f "${TMP_LOCAL}/.agents/agents/san-architect.md" ] && grep -q "name: san-architect" "${TMP_LOCAL}/.agents/agents/san-architect.md"'

assert_true "Couche 2 : san-qa-auditor.md est présent et valide" \
  '[ -f "${TMP_LOCAL}/.agents/agents/san-qa-auditor.md" ] && grep -q "name: san-qa-auditor" "${TMP_LOCAL}/.agents/agents/san-qa-auditor.md"'

# Couche 3 : Rules
RULES_COUNT=$(find "${TMP_LOCAL}/.agents/rules" -type f -name "*.md" | wc -l)
assert_true "Couche 3 : Les 5 règles normatives sont déployées dans .agents/rules/ (count: ${RULES_COUNT})" \
  '[ "${RULES_COUNT}" -eq 5 ]'

for r in BRAND.md PRODUCT.md PROJECT.md API.md LOGO.md; do
  assert_true "Couche 3 : Règle ${r} possède un frontmatter YAML valide avec trigger:" \
    '[ -f "${TMP_LOCAL}/.agents/rules/${r}" ] && grep -q "trigger:" "${TMP_LOCAL}/.agents/rules/${r}"'
done

assert_true "Couche 3 : L'ancien rules.json est supprimé" \
  '[ ! -f "${TMP_LOCAL}/.agents/rules.json" ]'

# Couche 4 : Hooks
assert_true "Couche 4 : .agents/hooks.json est présent et syntaxiquement valide" \
  '[ -f "${TMP_LOCAL}/.agents/hooks.json" ] && node -e "JSON.parse(fs.readFileSync(\"${TMP_LOCAL}/.agents/hooks.json\"))"'

assert_true "Couche 4 : session_start.mjs est présent et exécutable" \
  '[ -x "${TMP_LOCAL}/.agents/hooks/scripts/session_start.mjs" ]'

assert_true "Couche 4 : pre_invocation.mjs est présent et exécutable" \
  '[ -x "${TMP_LOCAL}/.agents/hooks/scripts/pre_invocation.mjs" ]'

assert_true "Couche 4 : pre_tool_guard.mjs est présent et exécutable" \
  '[ -x "${TMP_LOCAL}/.agents/hooks/scripts/pre_tool_guard.mjs" ]'

# Gouvernance racine
assert_true "Gouvernance : <root>/AGENTS.md est déployé à la racine" \
  '[ -f "${TMP_LOCAL}/AGENTS.md" ]'

AGENTS_FIRST_CHAR=$(head -n 1 "${TMP_LOCAL}/AGENTS.md")
assert_true "Gouvernance : <root>/AGENTS.md ne commence PAS par un frontmatter YAML" \
  '[ "${AGENTS_FIRST_CHAR}" != "---" ]'

AGENTS_SIZE=$(wc -c < "${TMP_LOCAL}/AGENTS.md" | tr -d ' ')
assert_true "Gouvernance : <root>/AGENTS.md taille < 4096 octets (${AGENTS_SIZE} octets)" \
  '[ "${AGENTS_SIZE}" -lt 4096 ]'

assert_true "Gouvernance : Index maître .agents/GEMINI.md est présent" \
  '[ -f "${TMP_LOCAL}/.agents/GEMINI.md" ]'

# Hygiène Git réversible
assert_true "Hygiène réversible : CLAUDE.md a disparu de la racine" \
  '[ ! -f "${TMP_LOCAL}/CLAUDE.md" ]'

assert_true "Hygiène réversible : .cursorrules a disparu de la racine" \
  '[ ! -f "${TMP_LOCAL}/.cursorrules" ]'

assert_true "Hygiène réversible : .cursor a disparu de la racine" \
  '[ ! -d "${TMP_LOCAL}/.cursor" ]'

assert_true "Hygiène réversible : Les résidus tiers sont sauvegardés dans .agents/backups/legacy-ai-configs/" \
  'ls -d "${TMP_LOCAL}"/.agents/backups/legacy-ai-configs/* >/dev/null 2>&1'

assert_true "Hygiène réversible : CLAUDE.md est préservé dans le dossier de backup" \
  'find "${TMP_LOCAL}/.agents/backups/legacy-ai-configs" -name "CLAUDE.md" | grep -q "CLAUDE.md"'

assert_true "Hygiène réversible : AGENTS.md n a JAMAIS été déplacé dans backups" \
  '! find "${TMP_LOCAL}/.agents/backups" -name "AGENTS.md" | grep -q "AGENTS.md"'

assert_true "Isolation Git : .gitignore contient /.agents/" \
  'grep -q "/\.agents/" "${TMP_LOCAL}/.gitignore"'

assert_true "Isolation Git : .gitignore contient /GEMINI.md" \
  'grep -q "/GEMINI.md" "${TMP_LOCAL}/.gitignore"'

# ------------------------------------------------------------------------------
# 2. Scénario 2 : Commande doctor sur le repo conforme
# ------------------------------------------------------------------------------
info "2. Commande doctor sur le repo conforme (doit retourner code 0)"
set +e
DOCTOR_OUTPUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_LOCAL}")
DOCTOR_CODE=$?
set -e

assert_true "doctor retourne un code de sortie 0 sur un repo conforme" \
  '[ "${DOCTOR_CODE}" -eq 0 ]'

assert_true "doctor affiche 'CONFORME (6/6 PILIERS AU VERT)'" \
  'echo "${DOCTOR_OUTPUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

for p in "Gouvernance souveraine" "Règles normatives" "Sous-agents natifs" "Garde-fous mécaniques" "Catalogue des 17 skills" "Étanchéité Git"; do
  assert_true "doctor valide le pilier : ${p}" \
    'echo "${DOCTOR_OUTPUT}" | grep -E "✔.*${p}"'
done

# ------------------------------------------------------------------------------
# 3. Scénario 3 : Commande doctor sur un repo cassé (doit échouer code 1)
# ------------------------------------------------------------------------------
info "3. Commande doctor sur repo cassé (doit retourner code 1)"
TMP_BROKEN=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_BROKEN}"' EXIT
cp -r "${TMP_LOCAL}/." "${TMP_BROKEN}/"

# Cas A : Sous-agents absents
rm -rf "${TMP_BROKEN}/.agents/agents"
set +e
DOC_BROKEN_A=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_A=$?
set -e
assert_true "doctor échoue (code 1) lorsque .agents/agents est absent" \
  '[ "${DOC_CODE_A}" -eq 1 ] && echo "${DOC_BROKEN_A}" | grep -q "NON CONFORME"'

# Cas B : Hooks absents
cp -r "${TMP_LOCAL}/.agents/agents" "${TMP_BROKEN}/.agents/"
rm -f "${TMP_BROKEN}/.agents/hooks.json"
set +e
DOC_BROKEN_B=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_B=$?
set -e
assert_true "doctor échoue (code 1) lorsque hooks.json est absent" \
  '[ "${DOC_CODE_B}" -eq 1 ] && echo "${DOC_BROKEN_B}" | grep -q "NON CONFORME"'

# Cas C : AGENTS.md avec frontmatter YAML invalide
cp "${TMP_LOCAL}/.agents/hooks.json" "${TMP_BROKEN}/.agents/"
echo -e "---\ntrigger: always_on\n---\n# Corrupted AGENTS.md" > "${TMP_BROKEN}/AGENTS.md"
set +e
DOC_BROKEN_C=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_C=$?
set -e
assert_true "doctor échoue (code 1) lorsque AGENTS.md possède un frontmatter YAML interdit" \
  '[ "${DOC_CODE_C}" -eq 1 ] && echo "${DOC_BROKEN_C}" | grep -q "NON CONFORME"'

rm -rf "${TMP_BROKEN}"

# ------------------------------------------------------------------------------
# 4. Scénario 4 : Commande update (migration v1.0 -> v2.0 non destructive)
# ------------------------------------------------------------------------------
info "4. Scénario update sur un projet v1.0 avec textes personnalisés"
TMP_V1=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_V1}"' EXIT

git -C "${TMP_V1}" init -q
mkdir -p "${TMP_V1}/.agents/rules"
cat << 'EOF' > "${TMP_V1}/.agents/rules/BRAND.md"
# CHARTE GRAPHIQUE V1 DU CLIENT
* Palette principale : #123456 et #ABCDEF
* Typographie sur-mesure : Cabinet Grotesk
* Directive critique : Zéro couleur violette sur les dashboards.
EOF

cat << 'EOF' > "${TMP_V1}/.agents/rules/PRODUCT.md"
# SPEC PRODUIT PROPRIÉTAIRE V1
* Invariant légal : KYC obligatoire avant retrait
* Support multi-devises Afrique de l'Ouest
EOF

mkdir -p "${TMP_V1}/.agents/skills/san_init"
echo "skill v1 obsolète" > "${TMP_V1}/.agents/skills/san_init/SKILL.md"
echo '{"rules": ["BRAND", "PRODUCT"]}' > "${TMP_V1}/.agents/rules.json"

UPDATE_OUTPUT=$(node "${CLI_INDEX}" update --dir="${TMP_V1}")
assert_true "update s'exécute avec succès" \
  'echo "${UPDATE_OUTPUT}" | grep -q "MIGRATION & MISE À JOUR v2.0"'

# Vérification Smart Merge Frontmatter
BRAND_POST=$(cat "${TMP_V1}/.agents/rules/BRAND.md")
assert_true "update : BRAND.md contient le frontmatter officiel 'trigger: glob'" \
  'echo "${BRAND_POST}" | grep -q "trigger: glob"'

assert_true "update : BRAND.md conserve 100% du texte métier personnalisé (#123456)" \
  'echo "${BRAND_POST}" | grep -q "#123456"'

assert_true "update : BRAND.md conserve la directive métier (Zéro couleur violette)" \
  'echo "${BRAND_POST}" | grep -q "Zéro couleur violette"'

PRODUCT_POST=$(cat "${TMP_V1}/.agents/rules/PRODUCT.md")
assert_true "update : PRODUCT.md contient le frontmatter officiel 'trigger: model_decision'" \
  'echo "${PRODUCT_POST}" | grep -q "trigger: model_decision"'

assert_true "update : PRODUCT.md conserve le texte métier (KYC obligatoire)" \
  'echo "${PRODUCT_POST}" | grep -q "KYC obligatoire avant retrait"'

assert_true "update : L'ancien rules.json v1 a été purgé" \
  '[ ! -f "${TMP_V1}/.agents/rules.json" ]'

assert_true "update : Les 8 sous-agents ont été installés dans .agents/agents/" \
  '[ "$(find "${TMP_V1}/.agents/agents" -name "san-*.md" | wc -l)" -eq 8 ]'

assert_true "update : .agents/hooks.json a été installé" \
  '[ -f "${TMP_V1}/.agents/hooks.json" ]'

assert_true "update : Les 17 skills sont resynchronisés" \
  '[ "$(find "${TMP_V1}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 17 ]'

assert_true "update : AGENTS.md souverain est créé à la racine" \
  '[ -f "${TMP_V1}/AGENTS.md" ]'

# doctor sur le repo migré
set +e
DOC_V1_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_V1}")
DOC_V1_CODE=$?
set -e
assert_true "doctor valide le repo migré par update avec code 0" \
  '[ "${DOC_V1_CODE}" -eq 0 ] && echo "${DOC_V1_OUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

rm -rf "${TMP_V1}"

# ------------------------------------------------------------------------------
# 5. Scénario 5 : init --global & agy plugin validate --strict --json
# ------------------------------------------------------------------------------
info "5. Scénario init --global et validation officielle agy plugin validate"
TMP_GLOBAL=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_GLOBAL}"' EXIT

GLOBAL_OUTPUT=$(node "${CLI_INDEX}" init --global --all --dir="${TMP_GLOBAL}")
assert_true "init --global s'exécute avec succès" \
  'echo "${GLOBAL_OUTPUT}" | grep -q "PACKAGING PLUGIN GLOBAL"'

assert_true "Plugin global : plugin.json est présent" \
  '[ -f "${TMP_GLOBAL}/plugin.json" ]'

assert_true "Plugin global : assets/logo.svg est présent" \
  '[ -f "${TMP_GLOBAL}/assets/logo.svg" ]'

assert_true "Plugin global : hooks.json est placé à la racine du plugin" \
  '[ -f "${TMP_GLOBAL}/hooks.json" ]'

assert_true "Plugin global : Les 3 scripts sont dans hooks/scripts/ et exécutables" \
  '[ -x "${TMP_GLOBAL}/hooks/scripts/session_start.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_invocation.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_tool_guard.mjs" ]'

assert_true "Plugin global : Les 8 agents sont dans agents/" \
  '[ "$(find "${TMP_GLOBAL}/agents" -name "san-*.md" | wc -l)" -eq 8 ]'

assert_true "Plugin global : Les 5 règles avec frontmatter sont dans rules/" \
  '[ "$(find "${TMP_GLOBAL}/rules" -name "*.md" | wc -l)" -eq 5 ]'

assert_true "Plugin global : Les 17 skills sont dans skills/" \
  '[ "$(find "${TMP_GLOBAL}/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 17 ]'

# Validation officielle Google Antigravity
if command -v agy >/dev/null 2>&1; then
  set +e
  AGY_VAL_JSON=$(agy plugin validate "${TMP_GLOBAL}" --strict --json 2>/dev/null)
  AGY_VAL_CODE=$?
  set -e

  assert_true "agy plugin validate --strict --json retourne code 0" \
    '[ "${AGY_VAL_CODE}" -eq 0 ]'

  AGY_AGENTS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.agents ?? 0)")
  assert_true "agy plugin validate détecte 8 agents (détectés: ${AGY_AGENTS})" \
    '[ "${AGY_AGENTS}" -eq 8 ]'

  AGY_SKILLS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.skills ?? 0)")
  assert_true "agy plugin validate détecte 17 skills (détectés: ${AGY_SKILLS})" \
    '[ "${AGY_SKILLS}" -eq 17 ]'

  AGY_HOOKS=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.hooks ?? 0)")
  assert_true "agy plugin validate détecte 1 hook (détectés: ${AGY_HOOKS})" \
    '[ "${AGY_HOOKS}" -eq 1 ]'

  AGY_RULES=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log(d.components?.rules ?? 0)")
  assert_true "agy plugin validate détecte 5 rules (détectées: ${AGY_RULES})" \
    '[ "${AGY_RULES}" -eq 5 ]'

  AGY_FINDINGS_COUNT=$(echo "${AGY_VAL_JSON}" | node -e "const d=JSON.parse(fs.readFileSync(0,'utf8')); console.log((d.findings ?? []).length)")
  assert_true "agy plugin validate ne rapporte 0 finding (0 warning, 0 error) en mode strict" \
    '[ "${AGY_FINDINGS_COUNT}" -eq 0 ]'
else
  info "agy non présent dans le PATH, test de validation agy ignoré"
fi

rm -rf "${TMP_GLOBAL}"

# ------------------------------------------------------------------------------
# Bilan Récapitulatif
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  RÉSULTATS DE LA PHASE 6 : ${PASSED_TESTS} passés, ${FAILED_TESTS} échecs"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "TOUTES LES ASSERTIONS DU LOT 6B (PHASE 6) SONT VALIDÉES À 100% !"
  exit 0
else
  red "ÉCHEC : ${FAILED_TESTS} assertion(s) n'ont pas été validées."
  exit 1
fi
