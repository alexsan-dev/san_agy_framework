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
assert_true "package.json a pour version '3.0.0' (actuel: ${PKG_VERSION})" \
  '[ "${PKG_VERSION}" = "3.0.0" ]'

CLI_VERSION_OUTPUT=$(node "${CLI_INDEX}" --version)
assert_true "CLI index.js --version retourne '3.0.0'" \
  'echo "${CLI_VERSION_OUTPUT}" | grep -q "3.0.0"'

WHATS_NEW_OUTPUT=$(node "${CLI_INDEX}" whats-new)
assert_true "CLI index.js whats-new affiche 'What'\''s New on san_ai_harness v3.0.0'" \
  'echo "${WHATS_NEW_OUTPUT}" | grep -q "What'\''s New on san_ai_harness v3.0.0"'

HELP_OUTPUT=$(node "${CLI_INDEX}" --help)
assert_true "CLI index.js --help documente whats-new, models, --compaction et --light" \
  'echo "${HELP_OUTPUT}" | grep -q "whats-new" && echo "${HELP_OUTPUT}" | grep -q "models" && echo "${HELP_OUTPUT}" | grep -q "\-\-compaction" && echo "${HELP_OUTPUT}" | grep -q "\-\-light"'

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
  'echo "${INIT_OUTPUT}" | grep -q "INSTALLATION DE SAN AI HARNESS"'

# Couche 1 : Skills
SKILLS_COUNT=$(find "${TMP_LOCAL}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
assert_true "Couche 1 : Les 17 skills sont installés dans .agents/skills/ (détectés: ${SKILLS_COUNT})" \
  '[ "${SKILLS_COUNT}" -eq 17 ]'

assert_true "Dual-Harness : .agents/models.json créé en version 3.0.0 (orchestrateurs inherit-user-model & compaction 120k)" \
  'python3 -c "import json; d=json.load(open(\"${TMP_LOCAL}/.agents/models.json\")); assert d[\"version\"]==\"3.0.0\" and d[\"agy\"][\"orchestrator\"]==\"inherit-user-model\" and d[\"agy\"][\"executor\"]==\"gemini-4-hydrogen-xhigh\" and d[\"opencode\"][\"orchestrator\"]==\"inherit-user-model\" and d[\"opencode\"][\"executor\"]==\"opencode-go/qwen3.8-flash\" and d[\"compaction\"][\"targetTokens\"]==120000"'

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

assert_true "Couche 4 : post_tool_indexer.mjs, stop_guard.mjs et .agents/cache/ sont absents" \
  '[ ! -e "${TMP_LOCAL}/.agents/hooks/scripts/post_tool_indexer.mjs" ] && [ ! -e "${TMP_LOCAL}/.agents/hooks/scripts/stop_guard.mjs" ] && [ ! -e "${TMP_LOCAL}/.agents/cache" ]'

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

# Cas D : pre_invocation.mjs absent
cp "${TMP_LOCAL}/AGENTS.md" "${TMP_BROKEN}/AGENTS.md"
rm -f "${TMP_BROKEN}/.agents/hooks/scripts/pre_invocation.mjs"
set +e
DOC_BROKEN_D=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_D=$?
set -e
assert_true "doctor échoue (code 1) lorsque pre_invocation.mjs est absent" \
  '[ "${DOC_CODE_D}" -eq 1 ] && echo "${DOC_BROKEN_D}" | grep -q "NON CONFORME"'

# Cas E : .agents/cache résiduel présent -> doctor doit échouer
cp "${TMP_LOCAL}/.agents/hooks/scripts/pre_invocation.mjs" "${TMP_BROKEN}/.agents/hooks/scripts/pre_invocation.mjs"
mkdir -p "${TMP_BROKEN}/.agents/cache"
echo "# old map" > "${TMP_BROKEN}/.agents/cache/REPO_MAP.md"
set +e
DOC_BROKEN_E=$(node "${CLI_INDEX}" doctor --dir="${TMP_BROKEN}")
DOC_CODE_E=$?
set -e
assert_true "doctor échoue (code 1) lorsque .agents/cache/ obsolète est présent" \
  '[ "${DOC_CODE_E}" -eq 1 ] && echo "${DOC_BROKEN_E}" | grep -q "NON CONFORME"'

rm -rf "${TMP_BROKEN}"

# ------------------------------------------------------------------------------
# 4. Scénario 4 : Commande update (migration v2.x -> v3.0, purge cache & What's New)
# ------------------------------------------------------------------------------
info "4. Scénario update sur un projet legacy avec textes personnalisés & résidus .agents/cache"
TMP_V1=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_V1}"' EXIT

git -C "${TMP_V1}" init -q
mkdir -p "${TMP_V1}/.agents/rules" "${TMP_V1}/.agents/cache" "${TMP_V1}/.agents/hooks/scripts" "${TMP_V1}/.agents/skills/san_init" "${TMP_V1}/.agents/skills/san_cartographer" "${TMP_V1}/.agents/skills/san_transcriber"
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

cat << 'EOF' > "${TMP_V1}/.agents/rules/PROJECT.md"
---
trigger: always_on
---
# Règles Projet Legacy
* Auth hashing : Argon2id + salage fort.
* Routing legacy : Argon -> swarm gemini-4-hydrogen-xhigh ; consulter .agents/cache/REPO_MAP.md.
* Relais : san_transcriber
EOF

echo "# legacy map" > "${TMP_V1}/.agents/cache/REPO_MAP.md"
echo '{"legacy":true}' > "${TMP_V1}/.agents/cache/repo-index.json"
echo "// old" > "${TMP_V1}/.agents/hooks/scripts/post_tool_indexer.mjs"
echo "// old" > "${TMP_V1}/.agents/hooks/scripts/stop_guard.mjs"
echo "# dup" > "${TMP_V1}/.agents/AGENTS.md"
echo "skill v1 obsolète" > "${TMP_V1}/.agents/skills/san_init/SKILL.md"
echo '{"rules": ["BRAND", "PRODUCT"]}' > "${TMP_V1}/.agents/rules.json"
cat << 'EOF' > "${TMP_V1}/.agents/models.json"
{
  "version": "2.2.0",
  "agy": { "orchestrator": "gemini-4-argon-high", "executor": "gemini-4-hydrogen-xhigh" },
  "opencode": { "orchestrator": "opencode-go/mimo-v2.6-pro", "executor": "opencode-go/deepseek-v4.1-flash" }
}
EOF

UPDATE_OUTPUT=$(node "${CLI_INDEX}" update --dir="${TMP_V1}")
assert_true "update s'exécute avec succès (bannière MIGRATION & MISE À JOUR v3.0.0)" \
  'echo "${UPDATE_OUTPUT}" | grep -q "MIGRATION & MISE À JOUR v3.0.0"'

assert_true "update force orchestrator: inherit-user-model dans .agents/models.json" \
  'python3 -c "import json; d=json.load(open(\"${TMP_V1}/.agents/models.json\")); assert d[\"agy\"][\"orchestrator\"]==\"inherit-user-model\" and d[\"opencode\"][\"orchestrator\"]==\"inherit-user-model\""'

assert_true "update affiche l'encart What'\''s New on san_ai_harness v3.0.0 dans le terminal" \
  'echo "${UPDATE_OUTPUT}" | grep -q "What'\''s New on san_ai_harness v3.0.0"'

assert_true "update purge .agents/cache, post_tool_indexer.mjs, stop_guard.mjs, san_cartographer, san_transcriber et .agents/AGENTS.md" \
  '[ ! -e "${TMP_V1}/.agents/cache" ] && [ ! -e "${TMP_V1}/.agents/hooks/scripts/post_tool_indexer.mjs" ] && [ ! -e "${TMP_V1}/.agents/hooks/scripts/stop_guard.mjs" ] && [ ! -e "${TMP_V1}/.agents/skills/san_cartographer" ] && [ ! -e "${TMP_V1}/.agents/skills/san_transcriber" ] && [ ! -e "${TMP_V1}/.agents/AGENTS.md" ]'

PROJECT_MIGRATED=$(cat "${TMP_V1}/.agents/rules/PROJECT.md")
assert_true "update migre PROJECT.md (supprime gemini-4-hydrogen-xhigh/REPO_MAP/san_transcriber) tout en préservant Argon2id" \
  'echo "${PROJECT_MIGRATED}" | grep -q "Argon2id" && ! echo "${PROJECT_MIGRATED}" | grep -q "gemini-4-hydrogen-xhigh" && ! echo "${PROJECT_MIGRATED}" | grep -q "REPO_MAP" && ! echo "${PROJECT_MIGRATED}" | grep -q "san_transcriber"'

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

assert_true "Plugin global : Les 3 scripts de hooks sobres sont dans hooks/scripts/ et exécutables (zéro post_tool_indexer / stop_guard)" \
  '[ -x "${TMP_GLOBAL}/hooks/scripts/session_start.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_invocation.mjs" ] && [ -x "${TMP_GLOBAL}/hooks/scripts/pre_tool_guard.mjs" ] && [ ! -e "${TMP_GLOBAL}/hooks/scripts/post_tool_indexer.mjs" ] && [ ! -e "${TMP_GLOBAL}/hooks/scripts/stop_guard.mjs" ]'

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
# 6. Scénario 6 : Mode Héritage Léger (init --light / update --light / doctor)
# ------------------------------------------------------------------------------
info "6. Scénario Mode Héritage Léger (--light : .agents/skills.json inherits & doctor)"
TMP_LIGHT=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_LIGHT}"' EXIT

git -C "${TMP_LIGHT}" init -q
LIGHT_INIT_OUT=$(node "${CLI_INDEX}" init --local --light --dir="${TMP_LIGHT}")
assert_true "init --local --light s'exécute avec succès" \
  'echo "${LIGHT_INIT_OUT}" | grep -q "INSTALLATION DE SAN AI HARNESS"'

assert_true "Mode --light : .agents/skills.json créé avec version=1 et inherits vers src/skills" \
  'python3 -c "import json,os; d=json.load(open(\"${TMP_LIGHT}/.agents/skills.json\")); expected=os.path.realpath(\"${ROOT_DIR}/src/skills\"); assert d.get(\"version\")==1 and len(d.get(\"inherits\", []))>=1 and os.path.realpath(d[\"inherits\"][0])==expected"'

assert_true "Mode --light : les 17 dossiers lourds ne sont PAS copiés dans .agents/skills/" \
  '[ ! -d "${TMP_LIGHT}/.agents/skills" ]'

assert_true "Mode --light : rules, agents, 3 hooks sobres locaux & zéro .agents/cache/" \
  '[ -f "${TMP_LIGHT}/.agents/rules/PROJECT.md" ] && [ -f "${TMP_LIGHT}/.agents/agents/san-architect.md" ] && [ -x "${TMP_LIGHT}/.agents/hooks/scripts/pre_invocation.mjs" ] && [ ! -e "${TMP_LIGHT}/.agents/cache" ] && [ -f "${TMP_LIGHT}/AGENTS.md" ]'

set +e
DOC_LIGHT_OUT=$(node "${CLI_INDEX}" doctor --dir="${TMP_LIGHT}")
DOC_LIGHT_CODE=$?
set -e
assert_true "doctor valide le projet en mode --light (code 0, 6/6 PILIERS AU VERT)" \
  '[ "${DOC_LIGHT_CODE}" -eq 0 ] && echo "${DOC_LIGHT_OUT}" | grep -q "CONFORME (6/6 PILIERS AU VERT)"'

# Test update --light
LIGHT_UPDATE_OUT=$(node "${CLI_INDEX}" update --light --dir="${TMP_LIGHT}")
assert_true "update --light met à jour sans copier .agents/skills/ et sans créer .agents/cache/" \
  '[ ! -d "${TMP_LIGHT}/.agents/skills" ] && [ -f "${TMP_LIGHT}/.agents/skills.json" ] && [ ! -e "${TMP_LIGHT}/.agents/cache" ] && echo "${LIGHT_UPDATE_OUT}" | grep -q "What'\''s New on san_ai_harness v3.0.0"'

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
# 7. Scénario 7 : Commande models & OpenCode V2.3 (plugin san_swarm + compaction 120k/150k + debug agents)
# ------------------------------------------------------------------------------
info "7. Scénario san-harness models (.agents/models.json, opencode.json V2.3 & opencode --standalone debug agents)"
TMP_MODELS=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_MODELS}"' EXIT

git -C "${TMP_MODELS}" init -q
node "${CLI_INDEX}" init --local --all --opencode --dir="${TMP_MODELS}" > /dev/null

MODELS_OUT=$(node "${CLI_INDEX}" models --opencode=opencode-go/qwen3.8-flash --agy=gemini-4-hydrogen-xhigh --compaction=150000 --dir="${TMP_MODELS}")
assert_true "san-harness models met à jour .agents/models.json (v3.0.0, qwen3.8-flash, agy & compaction 150000)" \
  'python3 -c "import json; d=json.load(open(\"${TMP_MODELS}/.agents/models.json\")); assert d[\"version\"]==\"3.0.0\" and d[\"agy\"][\"orchestrator\"]==\"inherit-user-model\" and d[\"opencode\"][\"orchestrator\"]==\"inherit-user-model\" and d[\"opencode\"][\"executor\"]==\"opencode-go/qwen3.8-flash\" and d[\"agy\"][\"executor\"]==\"gemini-4-hydrogen-xhigh\" and d[\"compaction\"][\"targetTokens\"]==150000"'

assert_true "san-harness models met à jour opencode.json V2.3 (san-orchestrator sans model, plugins, commands, 8 workers)" \
  'python3 -c "
import json
expected = [
  \"san-researcher\", \"san-architect\", \"san-designer-worker\", \"san-coder-back\",
  \"san-coder-front\", \"san-qa-auditor\", \"san-ops-devops\", \"san-growth-legal\"
]
c = json.load(open(\"${TMP_MODELS}/opencode.json\"))
assert c.get(\"default_agent\") == \"san-orchestrator\"
assert \"./.agents/opencode\" in c.get(\"plugins\", [])
assert c.get(\"compaction\", {}).get(\"auto\") is True
assert \"san-board\" in c.get(\"commands\", {}) and \"san-swarm\" in c.get(\"commands\", {})
agents = c.get(\"agents\", {})
orch = agents.get(\"san-orchestrator\", {})
assert orch.get(\"mode\") == \"primary\" and (\"model\" not in orch or not orch[\"model\"]), orch
assert all(a in agents for a in expected), f\"Missing agents: {set(expected)-set(agents)}\"
for a in expected:
    assert agents[a].get(\"model\") == \"opencode-go/qwen3.8-flash\", a
    assert agents[a].get(\"mode\") == \"subagent\", a
for ro in (\"san-researcher\", \"san-architect\", \"san-qa-auditor\"):
    perms = agents[ro].get(\"permissions\", [])
    assert any(p.get(\"action\") == \"edit\" and p.get(\"effect\") == \"deny\" for p in perms), ro
"'

assert_true "Plugin OpenCode Swarm Board déployé dans .agents/opencode/" \
  '[ -f "${TMP_MODELS}/.agents/opencode/san-harness-plugin.mjs" ] && [ -f "${TMP_MODELS}/.agents/opencode/package.json" ]'

MODELS_VIEW_OUT=$(node "${CLI_INDEX}" models --dir="${TMP_MODELS}")
assert_true "san-harness models (lecture) affiche les modèles actifs et compaction" \
  'echo "${MODELS_VIEW_OUT}" | grep -q "opencode-go/qwen3.8-flash" && echo "${MODELS_VIEW_OUT}" | grep -q "gemini-4-hydrogen-xhigh" && echo "${MODELS_VIEW_OUT}" | grep -q "150000"'

OPENCODE_BIN=""
if command -v opencode >/dev/null 2>&1; then
  OPENCODE_BIN="$(command -v opencode)"
elif [ -x "/home/alexsan-dev/.opencode/bin/opencode" ]; then
  OPENCODE_BIN="/home/alexsan-dev/.opencode/bin/opencode"
fi

if [ -n "${OPENCODE_BIN}" ]; then
  set +e
  OC_DEBUG_OUT=$(cd "${TMP_MODELS}" && "${OPENCODE_BIN}" --standalone debug agents 2>&1)
  OC_DEBUG_CODE=$?
  set -e
  assert_true "opencode --standalone debug agents s'exécute sans erreur (exit code 0)" \
    '[ "${OC_DEBUG_CODE}" -eq 0 ]'

  assert_true "opencode debug agents découvre san-orchestrator (primary) + les 8 san-* (subagent, qwen3.8-flash)" \
    'python3 -c "
import sys, json
raw = sys.argv[1]
data = json.loads(raw[raw.index(\"[\"):])
by_id = {a.get(\"id\"): a for a in data if isinstance(a, dict)}
assert \"san-orchestrator\" in by_id and by_id[\"san-orchestrator\"].get(\"mode\") == \"primary\"
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
# 8. Scénario 8 : Monorepo walk-up (ignore .agents/ tiers) & Menu TTY sur install existante
# ------------------------------------------------------------------------------
info "8. Scénario Monorepo walk-up (.agents/ tiers ignoré) & reconnaissance TTY"
TMP_MONO=$(mktemp -d)
trap 'rm -rf "${TMP_LOCAL}" "${TMP_MODELS}" "${TMP_MONO}"' EXIT

git -C "${TMP_MONO}" init -q
node "${CLI_INDEX}" init --local --all --dir="${TMP_MONO}" > /dev/null
mkdir -p "${TMP_MONO}/packages/api/.agents/skills/laravel-boost"
touch "${TMP_MONO}/packages/api/.agents/skills/laravel-boost/SKILL.md"

DOC_MONO_OUT=$(cd "${TMP_MONO}/packages/api" && node "${CLI_INDEX}" doctor)
assert_true "doctor depuis sous-dossier monorepo (avec .agents/ tiers) remonte à la racine (${TMP_MONO})" \
  'echo "${DOC_MONO_OUT}" | grep -q ": ${TMP_MONO}" && echo "${DOC_MONO_OUT}" | grep -q "CONFORME (6/6"'

UPD_MONO_OUT=$(cd "${TMP_MONO}/packages/api" && node "${CLI_INDEX}" update --dry-run)
assert_true "update depuis sous-dossier monorepo cible la racine du projet" \
  'echo "${UPD_MONO_OUT}" | grep -qE "Projet.*: ${TMP_MONO}"'

PTY_OUT=$(python3 -c '
import os, pty, select, subprocess, time
master, slave = pty.openpty()
env = os.environ.copy()
env["TERM"] = "xterm"
p = subprocess.Popen(
    ["node", "'"${CLI_INDEX}"'"],
    cwd="'"${TMP_MONO}/packages/api"'",
    stdin=slave, stdout=slave, stderr=slave, env=env, close_fds=True
)
os.close(slave)
buf = b""
sent = False
deadline = time.time() + 10
while time.time() < deadline:
    r, _, _ = select.select([master], [], [], 0.2)
    if master in r:
        try:
            chunk = os.read(master, 4096)
            if not chunk:
                break
            buf += chunk
            if not sent and b"Votre choix" in buf:
                os.write(master, b"5\n")
                sent = True
        except OSError:
            break
    elif p.poll() is not None:
        break
p.wait(timeout=5)
os.close(master)
print(buf.decode("utf-8", errors="replace"))
')
assert_true "san-harness sans argument en TTY détecte .agents/ existant et propose [1] Mettre à jour" \
  'echo "${PTY_OUT}" | grep -q "SAN AI Harness déjà installé dans ce projet" && echo "${PTY_OUT}" | grep -q "${TMP_MONO}" && echo "${PTY_OUT}" | grep -q "Mettre à jour vers"'

rm -rf "${TMP_MONO}"

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
