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
# 0. Vérification de la version 2.2.0, whats-new, models et --help
# ------------------------------------------------------------------------------
info "0. Vérification de la version 2.2.0 dans package.json & CLI"
PKG_VERSION=$(node -e "const pkg = JSON.parse(fs.readFileSync('${ROOT_DIR}/package.json', 'utf8')); console.log(pkg.version);")
assert_true "package.json a pour version '2.2.0' (actuel: ${PKG_VERSION})" \
  '[ "${PKG_VERSION}" = "2.2.0" ]'

CLI_VERSION_OUTPUT=$(node "${CLI_INDEX}" --version)
assert_true "CLI index.js --version retourne '2.2.0'" \
  'echo "${CLI_VERSION_OUTPUT}" | grep -q "2.2.0"'

WHATS_NEW_OUTPUT=$(node "${CLI_INDEX}" whats-new)
assert_true "CLI index.js whats-new affiche 'What'\''s New on san-agy v2.2.0'" \
  'echo "${WHATS_NEW_OUTPUT}" | grep -q "What'\''s New on san-agy v2.2.0"'

HELP_OUTPUT=$(node "${CLI_INDEX}" --help)
assert_true "CLI index.js --help documente whats-new, models et --light" \
  'echo "${HELP_OUTPUT}" | grep -q "whats-new" && echo "${HELP_OUTPUT}" | grep -q "models" && echo "${HELP_OUTPUT}" | grep -q "\-\-light"'

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
assert_true "Couche 1 : Les 19 skills sont installés dans .agents/skills/ (détectés: ${SKILLS_COUNT})" \
  '[ "${SKILLS_COUNT}" -eq 19 ]'

assert_true "Dual-Harness : .agents/models.json créé en version 2.2.0" \
  'python3 -c "import json; d=json.load(open(\"${TMP_LOCAL}/.agents/models.json\")); assert d[\"version\"]==\"2.2.0\" and d[\"agy\"][\"executor\"]==\"gemini-4-hydrogen-xhigh\" and d[\"opencode\"][\"executor\"]==\"opencode-go/deepseek-v4-pro\""'

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

assert_true "Couche 4 : post_tool_indexer.mjs est présent et exécutable" \
  '[ -x "${TMP_LOCAL}/.agents/hooks/scripts/post_tool_indexer.mjs" ]'

assert_true "Couche 4 : stop_guard.mjs est présent et exécutable" \
  '[ -x "${TMP_LOCAL}/.agents/hooks/scripts/stop_guard.mjs" ]'

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

for p in "Gouvernance souveraine" "Règles normatives" "Sous-agents natifs" "Garde-fous mécaniques" "Catalogue des 19 skills" "Étanchéité Git"; do
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

# Cas D : stop_guard.mjs absent
cp "${TMP_LOCAL}/AGENTS.md" "${TMP_BROKEN}/AGENTS.md"
rm -f "${TMP_BROKEN}/.agents/hooks/scripts/stop_guard.mjs"
set +e
DOC_BROKEN_D=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_D=$?
set -e
assert_true "doctor échoue (code 1) lorsque stop_guard.mjs est absent" \
  '[ "${DOC_CODE_D}" -eq 1 ] && echo "${DOC_BROKEN_D}" | grep -q "NON CONFORME"'

rm -rf "${TMP_BROKEN}"

# ------------------------------------------------------------------------------
# 4. Scénario 4 : Commande update (migration v1.0 -> v2.2 non destructive & What's New)
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
  'echo "${UPDATE_OUTPUT}" | grep -q "MIGRATION & MISE À JOUR v2.2"'

assert_true "update affiche l'encart What'\''s New on san-agy v2.2.0 dans le terminal" \
  'echo "${UPDATE_OUTPUT}" | grep -q "What'\''s New on san-agy v2.2.0"'

assert_true "update génère .agents/cache/whats_new_pending.json avec version=2.2.0 et seen=false" \
  'python3 -c "import json; d=json.load(open(\"${TMP_V1}/.agents/cache/whats_new_pending.json\")); assert d[\"version\"]==\"2.2.0\" and d[\"seen\"] is False and len(d.get(\"highlights\", [])) >= 5"'

# Vérification injection unique au 1er SessionStart post-update
SESSION_V1_OUT1=$(echo '{"workspacePaths":["'"${TMP_V1}"'"]}' | node "${TMP_V1}/.agents/hooks/scripts/session_start.mjs")
assert_true "1er SessionStart post-update injecte [WHAT'\''S NEW ON SAN.AGY v2.2.0] et bascule seen=true" \
  'python3 -c "import sys,json; out=json.loads(sys.argv[1]); msg=out[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"[WHAT'\''S NEW ON SAN.AGY v2.2.0]\" in msg; cache=json.load(open(\"${TMP_V1}/.agents/cache/whats_new_pending.json\")); assert cache[\"seen\"] is True" "${SESSION_V1_OUT1}"'

SESSION_V1_OUT2=$(echo '{"workspacePaths":["'"${TMP_V1}"'"]}' | node "${TMP_V1}/.agents/hooks/scripts/session_start.mjs")
assert_true "2ème SessionStart post-update n'\''injecte plus [WHAT'\''S NEW ON SAN.AGY v2.2.0]" \
  'python3 -c "import sys,json; out=json.loads(sys.argv[1]); msg=out[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"[WHAT'\''S NEW ON SAN.AGY v2.2.0]\" not in msg" "${SESSION_V1_OUT2}"'

assert_true "update installe stop_guard.mjs exécutable" \
  '[ -x "${TMP_V1}/.agents/hooks/scripts/stop_guard.mjs" ]'

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

assert_true "update : Les 19 skills sont resynchronisés" \
  '[ "$(find "${TMP_V1}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 19 ]'

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

assert_true "Plugin global : Les 5 scripts de hooks sont dans hooks/scripts/ et exécutables" \
  '[ -x "${TMP_GLOBAL}/hooks/scripts/session_start.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_invocation.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_tool_guard.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/post_tool_indexer.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/stop_guard.mjs" ]'

assert_true "Plugin global : Les 8 agents sont dans agents/" \
  '[ "$(find "${TMP_GLOBAL}/agents" -name "san-*.md" | wc -l)" -eq 8 ]'

assert_true "Plugin global : Les 5 règles avec frontmatter sont dans rules/" \
  '[ "$(find "${TMP_GLOBAL}/rules" -name "*.md" | wc -l)" -eq 5 ]'

assert_true "Plugin global : Les 19 skills sont dans skills/" \
  '[ "$(find "${TMP_GLOBAL}/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 19 ]'

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
  assert_true "agy plugin validate détecte 19 skills (détectés: ${AGY_SKILLS})" \
    '[ "${AGY_SKILLS}" -eq 19 ]'

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
# 6. Scénario 6 : Mode Héritage Léger (init --light / update --light / doctor)
# ------------------------------------------------------------------------------
info "6. Scénario Mode Héritage Léger (--light : .agents/skills.json inherits & doctor)"
TMP_LIGHT=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_LIGHT}"' EXIT

git -C "${TMP_LIGHT}" init -q
LIGHT_INIT_OUT=$(node "${CLI_INDEX}" init --local --light --dir="${TMP_LIGHT}")
assert_true "init --local --light s'exécute avec succès" \
  'echo "${LIGHT_INIT_OUT}" | grep -q "INSTALLATION DU FRAMEWORK ANTIGRAVITY"'

assert_true "Mode --light : .agents/skills.json créé avec version=1 et inherits vers src/skills" \
  'python3 -c "import json,os; d=json.load(open(\"${TMP_LIGHT}/.agents/skills.json\")); expected=os.path.realpath(\"${ROOT_DIR}/src/skills\"); assert d.get(\"version\")==1 and len(d.get(\"inherits\", []))>=1 and os.path.realpath(d[\"inherits\"][0])==expected"'

assert_true "Mode --light : les 19 dossiers lourds ne sont PAS copiés dans .agents/skills/" \
  '[ ! -d "${TMP_LIGHT}/.agents/skills" ]'

assert_true "Mode --light : rules, agents, hooks (dont stop_guard.mjs) et cache REPO_MAP.md sont locaux" \
  '[ -f "${TMP_LIGHT}/.agents/rules/PROJECT.md" ] && [ -f "${TMP_LIGHT}/.agents/agents/san-architect.md" ] && [ -x "${TMP_LIGHT}/.agents/hooks/scripts/stop_guard.mjs" ] && [ -f "${TMP_LIGHT}/.agents/cache/REPO_MAP.md" ] && [ -f "${TMP_LIGHT}/AGENTS.md" ]'

set +e
DOC_LIGHT_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_LIGHT}")
DOC_LIGHT_CODE=$?
set -e
assert_true "doctor valide le projet en mode --light (code 0, 6/6 PILIERS AU VERT)" \
  '[ "${DOC_LIGHT_CODE}" -eq 0 ] && echo "${DOC_LIGHT_OUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

# Test update --light
LIGHT_UPDATE_OUT=$(node "${CLI_INDEX}" update --light --dir="${TMP_LIGHT}")
assert_true "update --light met à jour sans copier .agents/skills/ et génère whats_new_pending.json" \
  '[ ! -d "${TMP_LIGHT}/.agents/skills" ] && [ -f "${TMP_LIGHT}/.agents/skills.json" ] && [ -f "${TMP_LIGHT}/.agents/cache/whats_new_pending.json" ] && echo "${LIGHT_UPDATE_OUT}" | grep -q "What'\''s New on san-agy v2.2.0"'

# Test chemin fantôme dans .agents/skills.json -> doctor doit échouer (code 1)
echo '{"version": 1, "inherits": ["/tmp/chemin_fantome_san_skills_inexistant"]}' > "${TMP_LIGHT}/.agents/skills.json"
set +e
DOC_PHANTOM_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_LIGHT}")
DOC_PHANTOM_CODE=$?
set -e
assert_true "doctor échoue (code 1) si .agents/skills.json pointe vers un chemin fantôme" \
  '[ "${DOC_PHANTOM_CODE}" -eq 1 ] && echo "${DOC_PHANTOM_OUT}" | grep -q "NON CONFORME"'

rm -rf "${TMP_LIGHT}"

# ------------------------------------------------------------------------------
# 7. Scénario 7 : Commande models & OpenCode V2 (opencode.json + opencode debug agents)
# ------------------------------------------------------------------------------
info "7. Scénario san-framework models (.agents/models.json, opencode.json V2 & opencode debug agents)"
TMP_MODELS=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_MODELS}"' EXIT

git -C "${TMP_MODELS}" init -q
node "${CLI_INDEX}" init --local --all --opencode --dir="${TMP_MODELS}" > /dev/null

MODELS_OUT=$(node "${CLI_INDEX}" models --opencode=opencode-go/qwen3.8-flash --agy=gemini-4-hydrogen-xhigh --dir="${TMP_MODELS}")
assert_true "san-framework models met à jour .agents/models.json (opencode-go/qwen3.8-flash & gemini-4-hydrogen-xhigh)" \
  'python3 -c "import json; d=json.load(open(\"${TMP_MODELS}/.agents/models.json\")); assert d[\"version\"]==\"2.2.0\" and d[\"opencode\"][\"executor\"]==\"opencode-go/qwen3.8-flash\" and d[\"agy\"][\"executor\"]==\"gemini-4-hydrogen-xhigh\""'

assert_true "san-framework models met à jour les 8 agents dans opencode.json (mode: subagent, model: opencode-go/qwen3.8-flash)" \
  'python3 -c "
import json
expected = [
  \"san-researcher\", \"san-architect\", \"san-designer-worker\", \"san-coder-back\",
  \"san-coder-front\", \"san-qa-auditor\", \"san-ops-devops\", \"san-growth-legal\"
]
c = json.load(open(\"${TMP_MODELS}/opencode.json\"))
agents = c.get(\"agents\", {})
assert all(a in agents for a in expected), f\"Missing agents: {set(expected)-set(agents)}\"
for a in expected:
    assert agents[a].get(\"model\") == \"opencode-go/qwen3.8-flash\", a
    assert agents[a].get(\"mode\") == \"subagent\", a
for ro in (\"san-researcher\", \"san-architect\", \"san-qa-auditor\"):
    perms = agents[ro].get(\"permissions\", [])
    assert any(p.get(\"action\") == \"edit\" and p.get(\"effect\") == \"deny\" for p in perms), ro
"'

MODELS_VIEW_OUT=$(node "${CLI_INDEX}" models --dir="${TMP_MODELS}")
assert_true "san-framework models (lecture) affiche les modèles actifs" \
  'echo "${MODELS_VIEW_OUT}" | grep -q "opencode-go/qwen3.8-flash" && echo "${MODELS_VIEW_OUT}" | grep -q "gemini-4-hydrogen-xhigh"'

OPENCODE_BIN=""
if command -v opencode >/dev/null 2>&1; then
  OPENCODE_BIN="$(command -v opencode)"
elif [ -x "/home/alexsan-dev/.opencode/bin/opencode" ]; then
  OPENCODE_BIN="/home/alexsan-dev/.opencode/bin/opencode"
fi

if [ -n "${OPENCODE_BIN}" ]; then
  set +e
  OC_DEBUG_OUT=$(cd "${TMP_MODELS}" && "${OPENCODE_BIN}" debug agents 2>&1)
  OC_DEBUG_CODE=$?
  set -e
  assert_true "opencode debug agents s'exécute sans erreur (exit code 0)" \
    '[ "${OC_DEBUG_CODE}" -eq 0 ]'

  assert_true "opencode debug agents découvre les 8 sous-agents san-* avec mode subagent et modèle opencode-go/qwen3.8-flash" \
    'python3 -c "
import sys, json
data = json.loads(sys.argv[1])
by_id = {a.get(\"id\"): a for a in data if isinstance(a, dict)}
expected = [
  \"san-researcher\", \"san-architect\", \"san-designer-worker\", \"san-coder-back\",
  \"san-coder-front\", \"san-qa-auditor\", \"san-ops-devops\", \"san-growth-legal\"
]
for a in expected:
    assert a in by_id, a
    assert by_id[a].get(\"mode\") == \"subagent\", a
    m = by_id[a].get(\"model\", {})
    assert m.get(\"providerID\") == \"opencode-go\" and m.get(\"id\") == \"qwen3.8-flash\", m
" "${OC_DEBUG_OUT}"'
else
  info "opencode non présent, validation opencode debug agents ignorée"
fi

rm -rf "${TMP_MODELS}"

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
