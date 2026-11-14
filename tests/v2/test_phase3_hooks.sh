#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 3 — GARDE-FOUS MÉCANIQUES DU CYCLE DE VIE (HOOKS NATIFS)
# ==============================================================================
# Vérification formelle du fichier hooks.json, de la syntaxe native Antigravity à
# clé nommée, des 4 scripts ESM (session_start, pre_invocation, pre_tool_guard, post_tool_indexer),
# de leur latence (< 150ms), du blocage de l'archivage incomplet, du blocage
# de l'injection de lorem ipsum dans le code/design, de la préservation stricte
# des permissions utilisateur ('ask'), et de la validation agy plugin validate.
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

echo "======================================================================"
echo "  TEST PHASE 3 : GARDE-FOUS MÉCANIQUES DU CYCLE DE VIE (HOOKS NATIFS)"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 1. Existence physique des fichiers
# ------------------------------------------------------------------------------
info "1. Vérification physique des fichiers de hooks"

assert_true "hooks.json existe dans src/hooks/" \
  '[ -f "${HOOKS_DIR}/hooks.json" ]'

assert_true "session_start.mjs existe dans src/hooks/scripts/" \
  '[ -f "${SCRIPTS_DIR}/session_start.mjs" ]'

assert_true "pre_invocation.mjs existe dans src/hooks/scripts/" \
  '[ -f "${SCRIPTS_DIR}/pre_invocation.mjs" ]'

assert_true "pre_tool_guard.mjs existe dans src/hooks/scripts/" \
  '[ -f "${SCRIPTS_DIR}/pre_tool_guard.mjs" ]'

assert_true "post_tool_indexer.mjs existe dans src/hooks/scripts/" \
  '[ -f "${SCRIPTS_DIR}/post_tool_indexer.mjs" ]'

assert_true "stop_guard.mjs existe dans src/hooks/scripts/" \
  '[ -f "${SCRIPTS_DIR}/stop_guard.mjs" ]'

# ------------------------------------------------------------------------------
# 2. Droits d'exécution des scripts (.mjs)
# ------------------------------------------------------------------------------
info "2. Vérification des permissions d'exécution (chmod +x)"

assert_true "session_start.mjs est exécutable" \
  '[ -x "${SCRIPTS_DIR}/session_start.mjs" ]'

assert_true "pre_invocation.mjs est exécutable" \
  '[ -x "${SCRIPTS_DIR}/pre_invocation.mjs" ]'

assert_true "pre_tool_guard.mjs est exécutable" \
  '[ -x "${SCRIPTS_DIR}/pre_tool_guard.mjs" ]'

assert_true "post_tool_indexer.mjs est exécutable" \
  '[ -x "${SCRIPTS_DIR}/post_tool_indexer.mjs" ]'

assert_true "stop_guard.mjs est exécutable" \
  '[ -x "${SCRIPTS_DIR}/stop_guard.mjs" ]'

# ------------------------------------------------------------------------------
# 3. Structure et syntaxe native de hooks.json
# ------------------------------------------------------------------------------
info "3. Validation structurelle de hooks.json (syntaxe à clé nommée)"

HOOKS_JSON="${HOOKS_DIR}/hooks.json"

assert_true "hooks.json est un JSON valide" \
  'python3 -m json.tool "${HOOKS_JSON}" > /dev/null 2>&1'

assert_true "hooks.json contient la clé nommée 'san-lifecycle-enforcer'" \
  'grep -q "\"san-lifecycle-enforcer\"" "${HOOKS_JSON}"'

assert_true "hooks.json configure SessionStart" \
  'grep -q "\"SessionStart\"" "${HOOKS_JSON}"'

assert_true "hooks.json configure PreInvocation" \
  'grep -q "\"PreInvocation\"" "${HOOKS_JSON}"'

assert_true "hooks.json configure PreToolUse" \
  'grep -q "\"PreToolUse\"" "${HOOKS_JSON}"'

assert_true "hooks.json filtre PreToolUse avec matcher 'write_file|edit_file'" \
  'grep -q "\"matcher\": \"write_file|edit_file\"" "${HOOKS_JSON}"'

assert_true "hooks.json configure PostToolUse" \
  'grep -q "\"PostToolUse\"" "${HOOKS_JSON}"'

assert_true "hooks.json filtre PostToolUse avec post_tool_indexer.mjs" \
  'grep -q "post_tool_indexer.mjs" "${HOOKS_JSON}"'

assert_true "hooks.json configure Stop avec stop_guard.mjs" \
  'grep -q "\"Stop\"" "${HOOKS_JSON}" && grep -q "stop_guard.mjs" "${HOOKS_JSON}"'

assert_true "Les timeouts sont configurés à 5s" \
  'grep -q "\"timeout\": 5" "${HOOKS_JSON}"'

# ------------------------------------------------------------------------------
# 4. Test du script SessionStart (session_start.mjs)
# ------------------------------------------------------------------------------
info "4. Test de session_start.mjs (détection roadmap, constitution, filtres & latence)"

SESSION_START_INPUT=$(cat << EOF
{
  "workspacePaths": ["${ROOT_DIR}"],
  "conversationId": "session-test-uuid-001"
}
EOF
)

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
SESSION_START_OUTPUT=$(echo "${SESSION_START_INPUT}" | node "${SCRIPTS_DIR}/session_start.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY=$((END_TIME - START_TIME))

assert_true "session_start.mjs répond en moins de 150ms (${LATENCY}ms)" \
  '[ "${LATENCY}" -lt 150 ]'

assert_true "session_start.mjs produit un JSON valide" \
  'echo "${SESSION_START_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

HAS_SYSTEM_MESSAGE=$(echo "${SESSION_START_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
steps = data.get('injectSteps', [])
has_sm = any('systemMessage' in s for s in steps)
print('true' if has_sm else 'false')
")

assert_true "session_start.mjs émet une étape 'systemMessage'" \
  '[ "${HAS_SYSTEM_MESSAGE}" = "true" ]'

CONTAINS_CONSTITUTION=$(echo "${SESSION_START_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if '[SAN.AGY CONSTITUTION v2.0]' in msg and '8 native subagents' in msg else 'false')
")

assert_true "session_start.mjs injecte la Constitution v2.0 et les 8 sous-agents" \
  '[ "${CONTAINS_CONSTITUTION}" = "true" ]'

# Test de session_start.mjs avec roadmap active
ROADMAP_WORKSPACE=$(mktemp -d /tmp/san-active-roadmap.XXXXXX)
mkdir -p "${ROADMAP_WORKSPACE}/roadmaps"
echo "# Active Test Roadmap" > "${ROADMAP_WORKSPACE}/roadmaps/ACTIVE_ROADMAP_TEST.md"

ROADMAP_TEST_OUTPUT=$(echo '{"workspacePaths":["'"${ROADMAP_WORKSPACE}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
rm -rf "${ROADMAP_WORKSPACE}"

DETECTED_ROADMAP=$(echo "${ROADMAP_TEST_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if 'ACTIVE_ROADMAP_TEST.md' in msg else 'false')
")

assert_true "session_start.mjs détecte la roadmap active (ACTIVE_ROADMAP_TEST.md)" \
  '[ "${DETECTED_ROADMAP}" = "true" ]'

# Test de session_start.mjs sans roadmap active
EMPTY_WORKSPACE=$(mktemp -d /tmp/san-empty-workspace.XXXXXX)
NO_ROADMAP_OUTPUT=$(echo '{"workspacePaths":["'"${EMPTY_WORKSPACE}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
rm -rf "${EMPTY_WORKSPACE}"

NO_ROADMAP_FOUND=$(echo "${NO_ROADMAP_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if 'Roadmap: none' in msg else 'false')
")

assert_true "session_start.mjs retourne 'Roadmap: none' si aucune roadmap active" \
  '[ "${NO_ROADMAP_FOUND}" = "true" ]'

# Test de session_start.mjs avec README.md et template.md ignorés dans roadmaps/
TEMP_WORKSPACE_README=$(mktemp -d /tmp/san-ws-readme.XXXXXX)
mkdir -p "${TEMP_WORKSPACE_README}/roadmaps"
cat << 'EOF' > "${TEMP_WORKSPACE_README}/roadmaps/README.md"
# Roadmaps Directory
This directory contains active and archived roadmaps.
EOF
cat << 'EOF' > "${TEMP_WORKSPACE_README}/roadmaps/template.md"
# Roadmap Template
- [ ] Task
EOF
cat << 'EOF' > "${TEMP_WORKSPACE_README}/roadmaps/feature_template.md"
# Feature Template
- [ ] Feature task
EOF

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
README_ROADMAP_OUTPUT=$(echo '{"workspacePaths":["'"${TEMP_WORKSPACE_README}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY_README=$((END_TIME - START_TIME))
rm -rf "${TEMP_WORKSPACE_README}"

README_ROADMAP_IGNORED=$(echo "${README_ROADMAP_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if 'Roadmap: none' in msg else 'false')
")

assert_true "session_start.mjs ignore README.md et les templates dans roadmaps/ ('Roadmap: none')" \
  '[ "${README_ROADMAP_IGNORED}" = "true" ]'

assert_true "session_start.mjs avec filtrage README répond en moins de 150ms (${LATENCY_README}ms)" \
  '[ "${LATENCY_README}" -lt 150 ]'

# Test de session_start.mjs avec PROJECT_PROFILE entre quotes ("cli_devtools")
TEMP_WORKSPACE_PROFILE=$(mktemp -d /tmp/san-ws-profile.XXXXXX)
mkdir -p "${TEMP_WORKSPACE_PROFILE}/.agents/rules"
cat << 'EOF' > "${TEMP_WORKSPACE_PROFILE}/.agents/rules/PROJECT.md"
# Project Rules
PROJECT_PROFILE: "cli_devtools"
EOF

PROFILE_OUTPUT=$(echo '{"workspacePaths":["'"${TEMP_WORKSPACE_PROFILE}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
rm -rf "${TEMP_WORKSPACE_PROFILE}"

PROFILE_DETECTED=$(echo "${PROFILE_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if '(Profile: cli_devtools)' in msg else 'false')
")

assert_true "session_start.mjs extrait correctement PROJECT_PROFILE avec quotes (\"cli_devtools\")" \
  '[ "${PROFILE_DETECTED}" = "true" ]'

# Test de session_start.mjs avec .agents/cache/whats_new_pending.json (injection unique)
TEMP_WS_WHATSNEW=$(mktemp -d /tmp/san-ws-whatsnew.XXXXXX)
mkdir -p "${TEMP_WS_WHATSNEW}/.agents/cache"
cat << 'EOF' > "${TEMP_WS_WHATSNEW}/.agents/cache/whats_new_pending.json"
{
  "version": "2.1.0",
  "updatedAt": "2026-11-14T10:00:00.000Z",
  "seen": false,
  "highlights": [
    "Swarm gemini-4-hydrogen-xhigh autonome",
    "Hook Stop avec Circuit Breaker anti-boucle"
  ]
}
EOF

WN_OUT_1=$(echo '{"workspacePaths":["'"${TEMP_WS_WHATSNEW}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
WN_FIRST_HAS_BANNER=$(echo "${WN_OUT_1}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
ok = (\"[WHAT'S NEW ON SAN.AGY v2.1.0]\" in msg and 'Swarm gemini-4-hydrogen-xhigh autonome' in msg)
print('true' if ok else 'false')
")
assert_true "session_start.mjs injecte [WHAT'S NEW ON SAN.AGY v2.1.0] au 1er démarrage quand seen=false" \
  '[ "${WN_FIRST_HAS_BANNER}" = "true" ]'

WN_SEEN_MARKED=$(python3 -c "
import json
with open('${TEMP_WS_WHATSNEW}/.agents/cache/whats_new_pending.json') as f:
    d = json.load(f)
print('true' if d.get('seen') is True else 'false')
")
assert_true "session_start.mjs marque seen: true dans .agents/cache/whats_new_pending.json" \
  '[ "${WN_SEEN_MARKED}" = "true" ]'

WN_OUT_2=$(echo '{"workspacePaths":["'"${TEMP_WS_WHATSNEW}"'"]}' | node "${SCRIPTS_DIR}/session_start.mjs")
WN_SECOND_SKIPPED=$(echo "${WN_OUT_2}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
print('true' if \"[WHAT'S NEW ON SAN.AGY v2.1.0]\" not in msg else 'false')
")
assert_true "session_start.mjs n'injecte plus [WHAT'S NEW ON SAN.AGY v2.1.0] au 2ème démarrage (one-shot)" \
  '[ "${WN_SECOND_SKIPPED}" = "true" ]'

rm -rf "${TEMP_WS_WHATSNEW}"

# ------------------------------------------------------------------------------
# 5. Test du script PreInvocation (pre_invocation.mjs)
# ------------------------------------------------------------------------------
info "5. Test de pre_invocation.mjs (Hooks API v2 systemMessage, swarm & latence)"

# Test 5.1 : Prompt positif avec verbe d'action de feature ("Développe le système d'authentification")
PRE_INV_FEATURE_INPUT=$(cat << EOF
{
  "lastUserInput": "Développe le système d'authentification",
  "conversationId": "pre-inv-feat-001"
}
EOF
)

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
PRE_INV_FEATURE_OUTPUT=$(echo "${PRE_INV_FEATURE_INPUT}" | node "${SCRIPTS_DIR}/pre_invocation.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY_FEATURE=$((END_TIME - START_TIME))

assert_true "pre_invocation.mjs répond en moins de 150ms pour feature prompt (${LATENCY_FEATURE}ms)" \
  '[ "${LATENCY_FEATURE}" -lt 150 ]'

assert_true "pre_invocation.mjs produit un JSON valide sur prompt de feature" \
  'echo "${PRE_INV_FEATURE_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

FEATURE_HAS_SYSTEM_MSG=$(echo "${PRE_INV_FEATURE_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
steps = data.get('injectSteps', [])
ok = (
    len(steps) > 0 and
    isinstance(steps[0].get('systemMessage'), dict) and
    isinstance(steps[0]['systemMessage'].get('systemMessage'), str) and
    'ephemeralMessage' not in steps[0]
)
print('true' if ok else 'false')
")

assert_true "pre_invocation.mjs utilise le format Hooks API v2 (systemMessage, zéro ephemeralMessage)" \
  '[ "${FEATURE_HAS_SYSTEM_MSG}" = "true" ]'

CONTAINS_ENFORCER_TEXT=$(echo "${PRE_INV_FEATURE_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
ok = ('[SAN.AGY ENFORCER]' in msg and
      'swarm' in msg and
      'gemini-4-hydrogen-xhigh' in msg and
      'REPO_MAP.md' in msg and
      'san-qa-auditor' in msg)
print('true' if ok else 'false')
")

assert_true "pre_invocation.mjs rappelle Map-First, swarm gemini-4-hydrogen-xhigh et san-qa-auditor" \
  '[ "${CONTAINS_ENFORCER_TEXT}" = "true" ]'

TOKEN_COUNT_CHECK=$(echo "${PRE_INV_FEATURE_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['injectSteps'][0]['systemMessage']['systemMessage']
words = len(msg.split())
estimated_tokens = int(words * 1.3)
print('true' if estimated_tokens < 120 else 'false')
")

assert_true "Le systemMessage de pre_invocation.mjs reste compact (< 120 tokens)" \
  '[ "${TOKEN_COUNT_CHECK}" = "true" ]'

# Test 5.2 : Prompt neutre / conversationnel (test négatif : injectSteps doit être vide [])
PRE_INV_NEUTRAL_INPUT=$(cat << EOF
{
  "lastUserInput": "Bonjour comment ça va",
  "conversationId": "pre-inv-neutral-002"
}
EOF
)

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
PRE_INV_NEUTRAL_OUTPUT=$(echo "${PRE_INV_NEUTRAL_INPUT}" | node "${SCRIPTS_DIR}/pre_invocation.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY_NEUTRAL=$((END_TIME - START_TIME))

assert_true "pre_invocation.mjs répond en moins de 150ms pour prompt neutre (${LATENCY_NEUTRAL}ms)" \
  '[ "${LATENCY_NEUTRAL}" -lt 150 ]'

assert_true "pre_invocation.mjs produit un JSON valide sur prompt neutre" \
  'echo "${PRE_INV_NEUTRAL_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

NEUTRAL_INJECT_EMPTY=$(echo "${PRE_INV_NEUTRAL_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
steps = data.get('injectSteps', None)
print('true' if isinstance(steps, list) and len(steps) == 0 else 'false')
")

assert_true "pre_invocation.mjs renvoie 'injectSteps: []' (aucun bruit) pour prompt neutre ('Bonjour comment ça va')" \
  '[ "${NEUTRAL_INJECT_EMPTY}" = "true" ]'

# ------------------------------------------------------------------------------
# 6. Test du script PreToolUse Guard (pre_tool_guard.mjs)
# ------------------------------------------------------------------------------
info "6. Test de pre_tool_guard.mjs (Règles de garde fail-closed, multi-dialectes & 'ask')"

# Test 6.1 : Blocage de l'archivage d'une roadmap avec tâche non cochée (- [ ])
ARCHIVE_DENY_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "write_file",
    "args": {
      "Path": "${ROOT_DIR}/roadmaps/archives/2026-10-unfinished.md",
      "Content": "# Roadmap\n- [x] Tâche 1\n- [ ] Tâche non terminée restante\n"
    }
  }
}
EOF
)

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
ARCHIVE_DENY_OUTPUT=$(echo "${ARCHIVE_DENY_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY=$((END_TIME - START_TIME))

assert_true "pre_tool_guard.mjs répond en moins de 150ms (${LATENCY}ms)" \
  '[ "${LATENCY}" -lt 150 ]'

ARCHIVE_DECISION=$(echo "${ARCHIVE_DENY_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('decision', ''))
")

assert_true "Règle 1 : pre_tool_guard bloque (decision: deny) l'archivage d'une roadmap contenant '- [ ]'" \
  '[ "${ARCHIVE_DECISION}" = "deny" ]'

ARCHIVE_REASON_CHECK=$(echo "${ARCHIVE_DENY_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
reason = data.get('reason', '')
print('true' if '[SAN.AGY GUARD]' in reason and '- [ ] ou * [ ]' in reason else 'false')
")

assert_true "Règle 1 : La raison du blocage d'archivage est explicite et actionnable" \
  '[ "${ARCHIVE_REASON_CHECK}" = "true" ]'

# Test 6.2 : Blocage de l'archivage via edit_file et 'Replacement'
ARCHIVE_EDIT_DENY_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "edit_file",
    "args": {
      "Path": "roadmaps/archives/V1_FINISH.md",
      "Replacement": "- [ ] Encore un oubli"
    }
  }
}
EOF
)
ARCHIVE_EDIT_DECISION=$(echo "${ARCHIVE_EDIT_DENY_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('decision', ''))
")

assert_true "Règle 1 : pre_tool_guard bloque également via edit_file (Replacement)" \
  '[ "${ARCHIVE_EDIT_DECISION}" = "deny" ]'

# Test 6.3 : Autorisation 'ask' d'une roadmap complètement terminée dans archives
ARCHIVE_ALLOW_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "write_file",
    "args": {
      "Path": "${ROOT_DIR}/roadmaps/archives/2026-10-finished.md",
      "Content": "# Roadmap\n- [x] Tâche 1 terminée\n- [x] Tâche 2 terminée\n"
    }
  }
}
EOF
)
ARCHIVE_ALLOW_DECISION=$(echo "${ARCHIVE_ALLOW_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('decision', ''))
")

assert_true "Règle 1 : pre_tool_guard émet 'ask' pour une roadmap 100% cochée dans archives/" \
  '[ "${ARCHIVE_ALLOW_DECISION}" = "ask" ]'

# Test 6.4 : Blocage de l'injection de lorem ipsum dans le code source (App.tsx)
LOREM_CODE_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "write_file",
    "args": {
      "Path": "${ROOT_DIR}/src/App.tsx",
      "Content": "export function Card() { return <p>Lorem ipsum dolor sit amet</p>; }"
    }
  }
}
EOF
)
LOREM_CODE_DECISION=$(echo "${LOREM_CODE_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('decision', ''))
")

assert_true "Règle 2 : pre_tool_guard bloque (decision: deny) l'injection de Lorem Ipsum dans src/App.tsx" \
  '[ "${LOREM_CODE_DECISION}" = "deny" ]'

# Test 6.5 : Blocage de l'injection de lorem ipsum dans le dossier design (mockup.html)
LOREM_DESIGN_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "edit_file",
    "args": {
      "Path": "design/screen_dashboard.html",
      "Replacement": "<div class='text-sm'>dolor sit amet, consectetur</div>"
    }
  }
}
EOF
)
LOREM_DESIGN_DECISION=$(echo "${LOREM_DESIGN_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('decision', ''))
")

assert_true "Règle 2 : pre_tool_guard bloque l'injection de faux texte dans design/*.html" \
  '[ "${LOREM_DESIGN_DECISION}" = "deny" ]'

# Test 6.6 : Tolérance nominale (ask) sur du code source propre avec données réalistes
CLEAN_CODE_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "write_file",
    "args": {
      "Path": "${ROOT_DIR}/src/components/UserProfile.tsx",
      "Content": "export function UserProfile({ name }: { name: string }) { return <span>{name}</span>; }"
    }
  }
}
EOF
)
CLEAN_CODE_DECISION=$(echo "${CLEAN_CODE_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs" | python3 -c "
import sys, json
print(json.load(sys.stdin).get('decision', ''))
")

assert_true "Cas Nominal : pre_tool_guard renvoie scrupuleusement 'ask' sur du code propre" \
  '[ "${CLEAN_CODE_DECISION}" = "ask" ]'

# Test 6.7 : Garantie absolue qu'aucun chemin conforme ne renvoie 'allow' (fail-safe permissions)
assert_true "Garantie critique : la décision nominale n'est JAMAIS 'allow' (préserve permissions agy)" \
  '[ "${CLEAN_CODE_DECISION}" != "allow" ]'

# Test 6.8 : Arguments Jetski/Antigravity (TargetFile + CodeEdit) sur tâche astérisque non cochée (* [ ])
JETSKI_ARCHIVE_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "edit_file",
    "args": {
      "TargetFile": "roadmaps/archives/plan.md",
      "CodeEdit": "* [ ] Tâche avec astérisque"
    }
  }
}
EOF
)

JETSKI_ARCHIVE_OUTPUT=$(echo "${JETSKI_ARCHIVE_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs")
JETSKI_ARCHIVE_DECISION=$(echo "${JETSKI_ARCHIVE_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('decision', ''))
")

assert_true "Règle 1 Jetski : pre_tool_guard bloque (deny) TargetFile+CodeEdit avec '* [ ]' dans archives/" \
  '[ "${JETSKI_ARCHIVE_DECISION}" = "deny" ]'

# Test 6.9 : Arguments Jetski/Antigravity (TargetFile + CodeEdit) sur Lorem Ipsum dans code applicatif
JETSKI_LOREM_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "edit_file",
    "args": {
      "TargetFile": "src/App.tsx",
      "CodeEdit": "<p>Lorem ipsum dolor sit amet</p>"
    }
  }
}
EOF
)

JETSKI_LOREM_OUTPUT=$(echo "${JETSKI_LOREM_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs")
JETSKI_LOREM_DECISION=$(echo "${JETSKI_LOREM_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('decision', ''))
")

assert_true "Règle 2 Jetski : pre_tool_guard bloque (deny) TargetFile+CodeEdit avec Lorem Ipsum dans src/App.tsx" \
  '[ "${JETSKI_LOREM_DECISION}" = "deny" ]'

# Test 6.10 : Tolérance formelle dans les répertoires et fichiers de tests (tests/unit/guard.test.ts)
TEST_FILE_LOREM_INPUT=$(cat << EOF
{
  "toolCall": {
    "name": "write_file",
    "args": {
      "TargetFile": "tests/unit/guard.test.ts",
      "CodeEdit": "const dummy = 'Lorem ipsum dolor sit amet';"
    }
  }
}
EOF
)

TEST_FILE_LOREM_OUTPUT=$(echo "${TEST_FILE_LOREM_INPUT}" | node "${SCRIPTS_DIR}/pre_tool_guard.mjs")
TEST_FILE_LOREM_DECISION=$(echo "${TEST_FILE_LOREM_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('decision', ''))
")

assert_true "Règle 2 : pre_tool_guard autorise (ask) le Lorem Ipsum dans les fichiers de tests (tests/unit/guard.test.ts)" \
  '[ "${TEST_FILE_LOREM_DECISION}" = "ask" ]'

# Test 6.11 : Vérification de la raison explicite dans le cas nominal conforme
NOMINAL_REASON_CHECK=$(echo "${TEST_FILE_LOREM_OUTPUT}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
reason = data.get('reason', '')
print('true' if '[SAN.AGY GUARD]' in reason and 'confirmation utilisateur' in reason else 'false')
")

assert_true "Cas Nominal : pre_tool_guard inclut une raison explicite de confirmation utilisateur" \
  '[ "${NOMINAL_REASON_CHECK}" = "true" ]'

# ------------------------------------------------------------------------------
# 6B. Test du script PostToolUse (post_tool_indexer.mjs)
# ------------------------------------------------------------------------------
info "6B. Test de post_tool_indexer.mjs (indexation AST & génération du cache)"

POST_INDEX_WORKSPACE=$(mktemp -d /tmp/san-post-index-workspace.XXXXXX)
mkdir -p "${POST_INDEX_WORKSPACE}/.agents/cache"
mkdir -p "${POST_INDEX_WORKSPACE}/src"
cat << 'EOF' > "${POST_INDEX_WORKSPACE}/src/service.ts"
export class UserService {
  async findUser(id: string) {
    return { id, name: 'Alice' };
  }
}
export function helper() { return true; }
EOF

POST_INDEX_INPUT=$(cat << EOF
{
  "workspacePaths": ["${POST_INDEX_WORKSPACE}"],
  "toolCall": {
    "name": "write_file",
    "args": {
      "Path": "${POST_INDEX_WORKSPACE}/src/service.ts"
    }
  }
}
EOF
)

START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
POST_INDEX_OUTPUT=$(echo "${POST_INDEX_INPUT}" | node "${SCRIPTS_DIR}/post_tool_indexer.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY=$((END_TIME - START_TIME))

assert_true "post_tool_indexer.mjs répond en moins de 250ms (${LATENCY}ms)" \
  '[ "${LATENCY}" -lt 250 ]'

assert_true "post_tool_indexer.mjs produit un JSON valide" \
  'echo "${POST_INDEX_OUTPUT}" | python3 -m json.tool > /dev/null 2>&1'

assert_true "post_tool_indexer.mjs met à jour .agents/cache/repo-index.json" \
  '[ -f "${POST_INDEX_WORKSPACE}/.agents/cache/repo-index.json" ] && grep -q "UserService" "${POST_INDEX_WORKSPACE}/.agents/cache/repo-index.json"'

assert_true "post_tool_indexer.mjs met à jour .agents/cache/REPO_MAP.md" \
  '[ -f "${POST_INDEX_WORKSPACE}/.agents/cache/REPO_MAP.md" ] && grep -q "UserService" "${POST_INDEX_WORKSPACE}/.agents/cache/REPO_MAP.md"'

rm -rf "${POST_INDEX_WORKSPACE}"

# ------------------------------------------------------------------------------
# 6C. Test du script Stop Guard (stop_guard.mjs)
# ------------------------------------------------------------------------------
info "6C. Test de stop_guard.mjs (Circuit Breaker, exemptions & Quality Gate)"

STOP_WS=$(mktemp -d /tmp/san-stop-guard-ws.XXXXXX)
(
  cd "${STOP_WS}"
  git init -q
  git config user.name "Stop Tester"
  git config user.email "stop@alexsan.pro"
  mkdir -p src .agents/cache
  echo "export const v = 1;" > src/app.js
  echo "# Doc" > README.md
  git add .
  git commit -m "init" -q
)

# 6C.1 Repo propre -> {}
START_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
STOP_CLEAN_OUT=$(echo '{"workspacePaths":["'"${STOP_WS}"'"],"terminationReason":"NO_TOOL_CALL","continuationActive":false}' | node "${SCRIPTS_DIR}/stop_guard.mjs")
END_TIME=$(python3 -c "import time; print(int(time.time() * 1000))")
LATENCY=$((END_TIME - START_TIME))

assert_true "stop_guard.mjs répond en moins de 150ms (${LATENCY}ms)" \
  '[ "${LATENCY}" -lt 150 ]'

assert_true "stop_guard.mjs autorise l'arrêt ({}) quand le repo est propre" \
  '[ "$(echo "${STOP_CLEAN_OUT}" | python3 -c "import sys,json; print(json.load(sys.stdin))")" = "{}" ]'

# 6C.2 Session DOC_ONLY (README.md modifié uniquement) -> {}
echo "mise à jour doc" >> "${STOP_WS}/README.md"
STOP_DOC_OUT=$(echo '{"workspacePaths":["'"${STOP_WS}"'"],"terminationReason":"CONVERSATION_TURN_COMPLETE","continuationActive":false}' | node "${SCRIPTS_DIR}/stop_guard.mjs")
assert_true "stop_guard.mjs autorise l'arrêt ({}) en session DOC_ONLY (exemption *.md)" \
  '[ "$(echo "${STOP_DOC_OUT}" | python3 -c "import sys,json; print(json.load(sys.stdin))")" = "{}" ]'

# 6C.3 Interruption utilisateur (USER_CANCELED) -> {} même avec code modifié
echo "export const v = 2;" > "${STOP_WS}/src/app.js"
STOP_CANCEL_OUT=$(echo '{"workspacePaths":["'"${STOP_WS}"'"],"terminationReason":"USER_CANCELED","continuationActive":false}' | node "${SCRIPTS_DIR}/stop_guard.mjs")
assert_true "stop_guard.mjs autorise l'arrêt ({}) sur terminationReason=USER_CANCELED" \
  '[ "$(echo "${STOP_CANCEL_OUT}" | python3 -c "import sys,json; print(json.load(sys.stdin))")" = "{}" ]'

# 6C.4 Code applicatif modifié sans Quality Gate -> Relance 1/2, 2/2, puis Circuit Breaker ({})
STOP_PAYLOAD='{"workspacePaths":["'"${STOP_WS}"'"],"conversationId":"stop-conv-1","terminationReason":"CONVERSATION_TURN_COMPLETE","continuationActive":false}'

STOP_TRY1=$(echo "${STOP_PAYLOAD}" | node "${SCRIPTS_DIR}/stop_guard.mjs")
STOP_TRY1_OK=$(echo "${STOP_TRY1}" | python3 -c "import sys,json; d=json.load(sys.stdin); print('true' if d.get('decision')=='continue' and 'Relance 1/2' in d.get('reason','') else 'false')")
assert_true "stop_guard.mjs bloque (decision: continue, Relance 1/2) si code modifié sans gate" \
  '[ "${STOP_TRY1_OK}" = "true" ]'

STOP_TRY2=$(echo "${STOP_PAYLOAD}" | node "${SCRIPTS_DIR}/stop_guard.mjs")
STOP_TRY2_OK=$(echo "${STOP_TRY2}" | python3 -c "import sys,json; d=json.load(sys.stdin); print('true' if d.get('decision')=='continue' and 'Relance 2/2' in d.get('reason','') else 'false')")
assert_true "stop_guard.mjs bloque (decision: continue, Relance 2/2) au 2ème essai" \
  '[ "${STOP_TRY2_OK}" = "true" ]'

STOP_TRY3=$(echo "${STOP_PAYLOAD}" | node "${SCRIPTS_DIR}/stop_guard.mjs")
STOP_TRY3_OK=$(echo "${STOP_TRY3}" | python3 -c "import sys,json; d=json.load(sys.stdin); print('true' if d == {} else 'false')")
assert_true "stop_guard.mjs déclenche le Circuit Breaker ({}) au 3ème essai (max 2 relances)" \
  '[ "${STOP_TRY3_OK}" = "true" ]'

# 6C.5 continuationActive: true autorise l'arrêt et remet retryCount à 0
echo '{"workspacePaths":["'"${STOP_WS}"'"],"conversationId":"stop-conv-2","forceBlockForTest":true,"continuationActive":false}' | node "${SCRIPTS_DIR}/stop_guard.mjs" > /dev/null
STOP_CONT_OUT=$(echo '{"workspacePaths":["'"${STOP_WS}"'"],"conversationId":"stop-conv-2","continuationActive":true}' | node "${SCRIPTS_DIR}/stop_guard.mjs")
STOP_CONT_OK=$(echo "${STOP_CONT_OUT}" | python3 -c "import sys,json; print('true' if json.load(sys.stdin) == {} else 'false')")
assert_true "stop_guard.mjs autorise l'arrêt ({}) quand continuationActive === true" \
  '[ "${STOP_CONT_OK}" = "true" ]'

# 6C.6 Quality Gate récent et vert (.agents/cache/last-gate-status.json) -> {}
NOW_ISO=$(node -e "console.log(new Date().toISOString())")
cat << EOF > "${STOP_WS}/.agents/cache/last-gate-status.json"
{
  "passed": true,
  "timestamp": "${NOW_ISO}"
}
EOF
STOP_GATE_OK=$(echo "${STOP_PAYLOAD}" | node "${SCRIPTS_DIR}/stop_guard.mjs" | python3 -c "import sys,json; print('true' if json.load(sys.stdin) == {} else 'false')")
assert_true "stop_guard.mjs autorise l'arrêt ({}) si .agents/cache/last-gate-status.json est vert et récent" \
  '[ "${STOP_GATE_OK}" = "true" ]'

# 6C.7 Mode test unitaire forceBlockForTest: true -> decision: continue
STOP_FORCE_OK=$(echo '{"workspacePaths":["'"${STOP_WS}"'"],"conversationId":"stop-conv-force","forceBlockForTest":true,"continuationActive":false}' | node "${SCRIPTS_DIR}/stop_guard.mjs" | python3 -c "import sys,json; print('true' if json.load(sys.stdin).get('decision')=='continue' else 'false')")
assert_true "stop_guard.mjs supporte forceBlockForTest: true pour tests déterministes" \
  '[ "${STOP_FORCE_OK}" = "true" ]'

rm -rf "${STOP_WS}"

# ------------------------------------------------------------------------------
# 7. Validation officielle Antigravity Plugin Engine (agy plugin validate)
# ------------------------------------------------------------------------------
info "7. Validation officielle Antigravity Plugin Engine (agy plugin validate --strict --json)"

TMP_PLUGIN_DIR=$(mktemp -d /tmp/san-v2-hooks-validation.XXXXXX)
trap 'rm -rf "${TMP_PLUGIN_DIR}"' EXIT

mkdir -p "${TMP_PLUGIN_DIR}/assets" "${TMP_PLUGIN_DIR}/hooks/scripts"

cat << 'EOF' > "${TMP_PLUGIN_DIR}/plugin.json"
{
  "name": "san-framework",
  "version": "2.1.0",
  "description": "Framework Antigravity san_* v2.1 - Cycle de vie & Garde-fous d'orchestration",
  "logo": "assets/logo.svg"
}
EOF

cp "${ROOT_DIR}/logos/san_framework_icon.svg" "${TMP_PLUGIN_DIR}/assets/logo.svg"
cp "${HOOKS_DIR}/hooks.json" "${TMP_PLUGIN_DIR}/hooks.json"
cp "${SCRIPTS_DIR}"/*.mjs "${TMP_PLUGIN_DIR}/hooks/scripts/"

VALIDATION_EXIT=0
VALIDATION_OUTPUT=$(agy plugin validate "${TMP_PLUGIN_DIR}" --strict --json 2>/dev/null) || VALIDATION_EXIT=$?
VALIDATION_EXIT=${VALIDATION_EXIT:-0}

assert_true "agy plugin validate s'exécute avec succès (exit code 0)" \
  '[ "${VALIDATION_EXIT}" -eq 0 ]'

HOOKS_DETECTED=$(echo "${VALIDATION_OUTPUT}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('components', {}).get('hooks', 0))
except Exception:
    print(-1)
")

assert_true "Le validateur Antigravity a détecté exactement 1 configuration de hooks" \
  '[ "${HOOKS_DETECTED}" -eq 1 ]'

FINDINGS_COUNT=$(echo "${VALIDATION_OUTPUT}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    findings = data.get('findings', [])
    errors_or_warns = [f for f in findings if f.get('severity') in ('error', 'warning')]
    print(len(errors_or_warns))
except Exception:
    print(-1)
")

assert_true "Le validateur Antigravity ne remonte 0 erreur et 0 warning sur hooks.json" \
  '[ "${FINDINGS_COUNT}" -eq 0 ]'

# ------------------------------------------------------------------------------
# Synthèse Finale
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  RÉSULTATS DE LA SUITE DE TEST PHASE 3 : HOOKS DU CYCLE DE VIE"
echo "======================================================================"
echo -e "  Tests réussis : \033[32m${PASSED_TESTS}\033[0m"
echo -e "  Tests échoués : \033[31m${FAILED_TESTS}\033[0m"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "🎉 TOUTES LES ASSERTIONS PHASE 3 SONT AU VERT ! SUCCÈS TOTAL."
  exit 0
else
  red "❌ DES ASSERTIONS ONT ÉCHOUÉ DANS LA PHASE 3."
  exit 1
fi
