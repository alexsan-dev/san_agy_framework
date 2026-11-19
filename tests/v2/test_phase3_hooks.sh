#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 3 — GARDE-FOUS SOBRES (3 HOOKS) & COMPACTION 120K
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HOOKS_DIR="${ROOT_DIR}/src/hooks"
SCRIPTS_DIR="${HOOKS_DIR}/scripts"

PASSED_TESTS=0
FAILED_TESTS=0

green() { echo -e "\033[32m✔ $1\033[0m"; }
red() { echo -e "\033[31m✘ $1\033[0m"; }
info() { echo -e "\033[34mℹ $1\033[0m"; }

assert_true() {
  local desc="$1"
  local condition="$2"
  if eval "${condition}"; then
    green "$desc"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    red "ÉCHEC: $desc"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

run_hook_timed() {
  local __out_var="$1"
  local __lat_var="$2"
  local __script="$3"
  local __payload="$4"
  local __result
  __result=$(node -e '
    const { spawnSync } = require("child_process");
    const t0 = performance.now();
    const res = spawnSync(process.execPath, [process.argv[1]], {
      input: process.argv[2],
      encoding: "utf8",
      stdio: ["pipe", "pipe", "inherit"],
    });
    const dt = Math.round(performance.now() - t0);
    process.stdout.write(dt + "\n" + (res.stdout || "") + "\n__SAN_HOOK_END__");
    if (res.error || res.status !== 0) process.exit(res.status || 1);
  ' "${__script}" "${__payload}")
  __result="${__result%$'\n__SAN_HOOK_END__'}"
  local __lat="${__result%%$'\n'*}"
  local __out="${__result#*$'\n'}"
  printf -v "${__lat_var}" '%s' "${__lat}"
  printf -v "${__out_var}" '%s' "${__out}"
}

echo "======================================================================"
echo "  TEST PHASE 3 : GARDE-FOUS SOBRES (3 HOOKS) & COMPACTION 120K"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 1. Existence physique des 3 scripts sobres & suppression des anciens bloat hooks
# ------------------------------------------------------------------------------
info "1. Vérification physique des 3 hooks sobres (zéro post_tool_indexer / stop_guard)"

assert_true "hooks.json existe dans src/hooks/" \
  '[ -f "${HOOKS_DIR}/hooks.json" ]'

assert_true "session_start.mjs existe et est exécutable" \
  '[ -x "${SCRIPTS_DIR}/session_start.mjs" ]'

assert_true "pre_invocation.mjs existe et est exécutable" \
  '[ -x "${SCRIPTS_DIR}/pre_invocation.mjs" ]'

assert_true "pre_tool_guard.mjs existe et est exécutable" \
  '[ -x "${SCRIPTS_DIR}/pre_tool_guard.mjs" ]'

assert_true "post_tool_indexer.mjs et stop_guard.mjs sont formellement supprimés" \
  '[ ! -f "${SCRIPTS_DIR}/post_tool_indexer.mjs" ] && [ ! -f "${SCRIPTS_DIR}/stop_guard.mjs" ]'

# ------------------------------------------------------------------------------
# 2. Structure et syntaxe native de hooks.json (3 hooks uniquement)
# ------------------------------------------------------------------------------
info "2. Validation structurelle de hooks.json (syntaxe à clé nommée, zéro PostToolUse/Stop)"

HOOKS_JSON="${HOOKS_DIR}/hooks.json"

assert_true "hooks.json est un JSON valide" \
  'python3 -m json.tool "${HOOKS_JSON}" > /dev/null 2>&1'

assert_true "hooks.json contient SessionStart, PreInvocation et PreToolUse (matcher write_file|edit_file)" \
  'grep -q "\"SessionStart\"" "${HOOKS_JSON}" && grep -q "\"PreInvocation\"" "${HOOKS_JSON}" && grep -q "\"PreToolUse\"" "${HOOKS_JSON}" && grep -q "\"matcher\": \"write_file|edit_file\"" "${HOOKS_JSON}"'

assert_true "hooks.json ne contient plus PostToolUse ni Stop" \
  '! grep -q "\"PostToolUse\"" "${HOOKS_JSON}" && ! grep -q "\"Stop\"" "${HOOKS_JSON}"'

assert_true "Les timeouts sont configurés à 5s" \
  'grep -q "\"timeout\": 5" "${HOOKS_JSON}"'

# ------------------------------------------------------------------------------
# 3. Test du script SessionStart (session_start.mjs — sobre, zéro .agents/cache)
# ------------------------------------------------------------------------------
info "3. Test de session_start.mjs (roadmap active, PROJECT_PROFILE, zéro écriture cache & latence)"

SESSION_START_INPUT=$(cat << EOF
{
  "workspacePaths": ["${ROOT_DIR}"],
  "conversationId": "session-test-v3-001"
}
EOF
)

run_hook_timed SESSION_START_OUTPUT LATENCY "${SCRIPTS_DIR}/session_start.mjs" "${SESSION_START_INPUT}"

assert_true "session_start.mjs répond en moins de 150ms (${LATENCY}ms)" \
  '[ "${LATENCY}" -lt 150 ]'

assert_true "session_start.mjs émet le systemMessage [SAN AI HARNESS v3.0]" \
  'echo "${SESSION_START_OUTPUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); msg=d[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"[SAN AI HARNESS v3.0]\" in msg and \"8 workers\" in msg and \"120k auto-compaction\" in msg"'

# Détection roadmap active sans création de .agents/cache
TEMP_WS=$(mktemp -d /tmp/san-v3-session.XXXXXX)
mkdir -p "${TEMP_WS}/roadmaps" "${TEMP_WS}/.agents/rules"
echo "# Active Test Roadmap" > "${TEMP_WS}/roadmaps/ACTIVE_ROADMAP_TEST.md"
cat << 'EOF' > "${TEMP_WS}/.agents/rules/PROJECT.md"
# Project Rules
PROJECT_PROFILE: "cli_devtools"
EOF

SESSION_WS_OUT=$(echo '{"workspacePaths":["'"${TEMP_WS}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
assert_true "session_start.mjs détecte ACTIVE_ROADMAP_TEST.md et (Profile: cli_devtools) sans créer .agents/cache/" \
  'echo "${SESSION_WS_OUT}" | python3 -c "import sys,json; msg=json.load(sys.stdin)[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"ACTIVE_ROADMAP_TEST.md\" in msg and \"(Profile: cli_devtools)\" in msg" && [ ! -d "${TEMP_WS}/.agents/cache" ]'

rm -rf "${TEMP_WS}"

# Ignorer README.md et *_template.md dans roadmaps/
TEMP_WS_EMPTY=$(mktemp -d /tmp/san-v3-empty.XXXXXX)
mkdir -p "${TEMP_WS_EMPTY}/roadmaps"
echo "# Roadmaps Directory" > "${TEMP_WS_EMPTY}/roadmaps/README.md"
echo "# Template" > "${TEMP_WS_EMPTY}/roadmaps/template.md"
EMPTY_OUT=$(echo '{"workspacePaths":["'"${TEMP_WS_EMPTY}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
rm -rf "${TEMP_WS_EMPTY}"

assert_true "session_start.mjs ignore README.md/template.md et retourne Roadmap: none" \
  'echo "${EMPTY_OUT}" | python3 -c "import sys,json; msg=json.load(sys.stdin)[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"Roadmap: none\" in msg"'

# ------------------------------------------------------------------------------
# 4. Test du script PreInvocation (pre_invocation.mjs — Garde de Compaction 120k)
# ------------------------------------------------------------------------------
info "4. Test de pre_invocation.mjs (Garde Compaction 120k Tokens, CHECKPOINT & latence)"

# 4.1 Sous le seuil : silencieux (injectSteps: [])
PRE_INV_NORMAL='{"lastUserInput": "Développe le module auth", "conversationId": "pre-inv-normal"}'
run_hook_timed PRE_NORMAL_OUT LATENCY_PRE "${SCRIPTS_DIR}/pre_invocation.mjs" "${PRE_INV_NORMAL}"

assert_true "pre_invocation.mjs répond en moins de 150ms (${LATENCY_PRE}ms)" \
  '[ "${LATENCY_PRE}" -lt 150 ]'

assert_true "Sous 120k tokens : pre_invocation.mjs reste silencieux (injectSteps: [])" \
  'echo "${PRE_NORMAL_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get(\"injectSteps\") == []"'

# 4.2 Test explicite forceCompactionCheckForTest=true
PRE_FORCE_OUT=$(echo '{"forceCompactionCheckForTest": true}' | node "${SCRIPTS_DIR}/pre_invocation.mjs")
assert_true "forceCompactionCheckForTest=true émet l'alerte [SAN HARNESS — COMPACTION 120K] /compact" \
  'echo "${PRE_FORCE_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); msg=d[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"[SAN HARNESS — COMPACTION 120K]\" in msg and \"/compact\" in msg"'

# 4.3 Transcript JSONL dépassant 120k -> déclenche compaction ; puis CHECKPOINT -> réinitialise
TMP_COMPACT_WS=$(mktemp -d /tmp/san-compact-ws.XXXXXX)
mkdir -p "${TMP_COMPACT_WS}/.agents"
cat << 'EOF' > "${TMP_COMPACT_WS}/.agents/models.json"
{
  "version": "3.0.0",
  "compaction": { "targetTokens": 120000, "auto": true }
}
EOF
TRANSCRIPT_JSONL="${TMP_COMPACT_WS}/transcript.jsonl"
printf '{"type":"PLANNER_RESPONSE","input_tokens":85000,"cache_read_tokens":45000}\n' > "${TRANSCRIPT_JSONL}"

PRE_OVER_OUT=$(echo "{\"workspacePaths\":[\"${TMP_COMPACT_WS}\"],\"transcriptPath\":\"${TRANSCRIPT_JSONL}\"}" | node "${SCRIPTS_DIR}/pre_invocation.mjs")
assert_true "Transcript JSONL à 130k tokens (>= 120k) déclenche la recommandation /compact" \
  'echo "${PRE_OVER_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); msg=d[\"injectSteps\"][0][\"systemMessage\"][\"systemMessage\"]; assert \"130k\" in msg and \"120k\" in msg"'

# Ajout d'un CHECKPOINT post-compaction suivi d'un petit tour (25k tokens)
printf '{"type":"CHECKPOINT"}\n{"type":"PLANNER_RESPONSE","input_tokens":15000,"cache_read_tokens":10000}\n' >> "${TRANSCRIPT_JSONL}"
PRE_POST_COMPACT=$(echo "{\"workspacePaths\":[\"${TMP_COMPACT_WS}\"],\"transcriptPath\":\"${TRANSCRIPT_JSONL}\"}" | node "${SCRIPTS_DIR}/pre_invocation.mjs")
assert_true "Après CHECKPOINT (25k < 120k), pre_invocation.mjs redevient silencieux (injectSteps: [])" \
  'echo "${PRE_POST_COMPACT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get(\"injectSteps\") == []"'

rm -rf "${TMP_COMPACT_WS}"

# ------------------------------------------------------------------------------
# 5. Test du script PreToolUse Guard (pre_tool_guard.mjs)
# ------------------------------------------------------------------------------
info "5. Test de pre_tool_guard.mjs (Règles de garde fail-closed, multi-dialectes & 'ask')"

ARCHIVE_DENY_INPUT='{"toolCall":{"name":"write_file","args":{"Path":"roadmaps/archives/2026-unfinished.md","Content":"# Roadmap\n- [x] T1\n- [ ] T2 reste\n"}}}'
run_hook_timed ARCHIVE_DENY_OUT LAT_PTG "${SCRIPTS_DIR}/pre_tool_guard.mjs" "${ARCHIVE_DENY_INPUT}"

assert_true "pre_tool_guard.mjs répond en moins de 150ms (${LAT_PTG}ms)" \
  '[ "${LAT_PTG}" -lt 150 ]'

assert_true "Règle 1 : bloque (decision: deny) l'archivage d'une roadmap contenant '- [ ]' ([SAN HARNESS GUARD])" \
  'echo "${ARCHIVE_DENY_OUT}" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get(\"decision\")==\"deny\" and \"[SAN HARNESS GUARD]\" in d.get(\"reason\",\"\")"'

ARCHIVE_EDIT_DECISION=$(echo '{"toolCall":{"name":"edit_file","args":{"Path":"roadmaps/archives/V1.md","Replacement":"* [ ] Encore un oubli"}}}' | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys,json; print(json.load(sys.stdin).get('decision',''))")
assert_true "Règle 1 : bloque également edit_file (Replacement) avec '* [ ]'" \
  '[ "${ARCHIVE_EDIT_DECISION}" = "deny" ]'

ARCHIVE_ALLOW_DECISION=$(echo '{"toolCall":{"name":"write_file","args":{"Path":"roadmaps/archives/done.md","Content":"# Done\n- [x] T1\n- [x] T2\n"}}}' | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys,json; print(json.load(sys.stdin).get('decision',''))")
assert_true "Règle 1 : émet 'ask' pour une roadmap 100% cochée dans archives/" \
  '[ "${ARCHIVE_ALLOW_DECISION}" = "ask" ]'

LOREM_CODE_DECISION=$(echo '{"toolCall":{"name":"write_file","args":{"Path":"src/App.tsx","Content":"<p>Lorem ipsum dolor sit amet</p>"}}}' | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys,json; print(json.load(sys.stdin).get('decision',''))")
assert_true "Règle 2 : bloque (deny) Lorem Ipsum dans src/App.tsx" \
  '[ "${LOREM_CODE_DECISION}" = "deny" ]'

LOREM_DESIGN_DECISION=$(echo '{"toolCall":{"name":"edit_file","args":{"Path":"design/screen.html","Replacement":"<div>dolor sit amet</div>"}}}' | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys,json; print(json.load(sys.stdin).get('decision',''))")
assert_true "Règle 2 : bloque (deny) faux texte dans design/*.html" \
  '[ "${LOREM_DESIGN_DECISION}" = "deny" ]'

CLEAN_CODE_DECISION=$(echo '{"toolCall":{"name":"write_file","args":{"Path":"src/components/UserProfile.tsx","Content":"export function UserProfile({ name }: { name: string }) { return <span>{name}</span>; }"}}}' | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "import sys,json; print(json.load(sys.stdin).get('decision',''))")
assert_true "Cas Nominal : renvoie strictement 'ask' sur du code propre (jamais 'allow')" \
  '[ "${CLEAN_CODE_DECISION}" = "ask" ]'

# ------------------------------------------------------------------------------
# 6. Validation officielle Antigravity Plugin Engine (agy plugin validate)
# ------------------------------------------------------------------------------
info "6. Validation officielle Antigravity Plugin Engine (agy plugin validate --strict --json)"

TMP_PLUGIN_DIR=$(mktemp -d /tmp/san-v3-hooks-validation.XXXXXX)
trap 'rm -rf "${TMP_PLUGIN_DIR}"' EXIT

mkdir -p "${TMP_PLUGIN_DIR}/assets" "${TMP_PLUGIN_DIR}/hooks/scripts"

cat << 'EOF' > "${TMP_PLUGIN_DIR}/plugin.json"
{
  "name": "san-ai-harness",
  "version": "3.0.0",
  "description": "SAN AI Harness san_* v3.0 - 3 Garde-fous Sobres & Compaction 120k",
  "logo": "assets/logo.svg"
}
EOF

cp "${ROOT_DIR}/logos/san_harness_icon.svg" "${TMP_PLUGIN_DIR}/assets/logo.svg"
cp "${HOOKS_DIR}/hooks.json" "${TMP_PLUGIN_DIR}/hooks.json"
cp "${SCRIPTS_DIR}"/*.mjs "${TMP_PLUGIN_DIR}/hooks/scripts/"

VALIDATION_EXIT=0
VALIDATION_OUTPUT=$(agy plugin validate "${TMP_PLUGIN_DIR}" --strict --json 2>/dev/null) || VALIDATION_EXIT=$?
VALIDATION_EXIT=${VALIDATION_EXIT:-0}

assert_true "agy plugin validate s'exécute avec succès (exit code 0)" \
  '[ "${VALIDATION_EXIT}" -eq 0 ]'

HOOKS_DETECTED=$(echo "${VALIDATION_OUTPUT}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('components',{}).get('hooks',0))")
assert_true "Le validateur Antigravity détecte 1 configuration de hooks" \
  '[ "${HOOKS_DETECTED}" -eq 1 ]'

FINDINGS_COUNT=$(echo "${VALIDATION_OUTPUT}" | python3 -c "import sys,json; print(len([f for f in json.load(sys.stdin).get('findings',[]) if f.get('severity') in ('error','warning')]))")
assert_true "Le validateur Antigravity ne remonte 0 erreur et 0 warning sur hooks.json" \
  '[ "${FINDINGS_COUNT}" -eq 0 ]'

echo ""
echo "======================================================================"
echo "  RÉSULTATS PHASE 3 : ${PASSED_TESTS} passés, ${FAILED_TESTS} échecs"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "TOUTES LES ASSERTIONS PHASE 3 SONT AU VERT ! SUCCÈS TOTAL."
  exit 0
else
  red "DES ASSERTIONS ONT ÉCHOUÉ DANS LA PHASE 3."
  exit 1
fi
