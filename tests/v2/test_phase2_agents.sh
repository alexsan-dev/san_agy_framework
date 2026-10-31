#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 2 — LES 8 SOUS-AGENTS NATIFS & HARNESS PSYCHOLOGIQUE
# ==============================================================================
# Vérification formelle des 8 sous-agents natifs Antigravity dans src/agents/,
# de leurs frontmatters YAML, de leurs permissions d'outils, des skills officiels,
# du protocole déterministe send_message, des clauses d'ingénierie psychologique
# (Pre-Mortem, Dialectique, Présomption de Défaut, Stale-While-Revalidate) et
# validation officielle stricte via agy plugin validate.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
AGENTS_DIR="${ROOT_DIR}/src/agents"

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
echo "  TEST PHASE 2 : LES 8 SOUS-AGENTS NATIFS & CLAUSES PSYCHOLOGIQUES"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 1. Existence physique des 8 sous-agents dans src/agents/
# ------------------------------------------------------------------------------
info "1. Vérification de l'existence des 8 sous-agents natifs"

EXPECTED_AGENTS=(
  "san-researcher.md"
  "san-architect.md"
  "san-designer-worker.md"
  "san-coder-back.md"
  "san-coder-front.md"
  "san-qa-auditor.md"
  "san-ops-devops.md"
  "san-growth-legal.md"
)

for agent in "${EXPECTED_AGENTS[@]}"; do
  assert_true "Agent physique '${agent}' existe dans src/agents/" \
    '[ -f "${AGENTS_DIR}/${agent}" ]'
done

ACTUAL_COUNT=$(find "${AGENTS_DIR}" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
assert_true "Exactement 8 fichiers agents .md présents dans src/agents/ (${ACTUAL_COUNT}/8)" \
  '[ "${ACTUAL_COUNT}" -eq 8 ]'

# ------------------------------------------------------------------------------
# 2. Structure YAML & Déclarations requises
# ------------------------------------------------------------------------------
echo ""
info "2. Vérification des frontmatters YAML officiels"

for agent in "${EXPECTED_AGENTS[@]}"; do
  AGENT_FILE="${AGENTS_DIR}/${agent}"
  BASE_NAME="${agent%.md}"
  
  assert_true "${agent} commence par un délimiteur YAML '---'" \
    '[ "$(head -n 1 "${AGENT_FILE}")" = "---" ]'

  assert_true "${agent} déclare name: ${BASE_NAME}" \
    'grep -q "^name:[[:space:]]*${BASE_NAME}" "${AGENT_FILE}"'

  assert_true "${agent} déclare mainAgent: false" \
    'grep -q "^mainAgent:[[:space:]]*false" "${AGENT_FILE}"'

  assert_true "${agent} déclare subagent: true" \
    'grep -q "^subagent:[[:space:]]*true" "${AGENT_FILE}"'

  assert_true "${agent} déclare commandExecutionPolicy" \
    'grep -q "^commandExecutionPolicy:" "${AGENT_FILE}"'

  assert_true "${agent} déclare une section tools" \
    'grep -q "^tools:" "${AGENT_FILE}"'

  assert_true "${agent} déclare une section skills" \
    'grep -q "^skills:" "${AGENT_FILE}"'
done

# ------------------------------------------------------------------------------
# 3. Vérification stricte des skills déclarés selon la table officielle
# ------------------------------------------------------------------------------
echo ""
info "3. Vérification stricte des associations d'outils/skills selon la table officielle"

for agent in "${EXPECTED_AGENTS[@]}"; do
  assert_true "${agent} déclare fidèlement ses skills officiels" \
    "python3 -c \"
import yaml
expected_table = {
  'san-researcher.md': ['skills/san_searcher'],
  'san-architect.md': ['skills/san_planner'],
  'san-designer-worker.md': ['skills/san_design_tokens', 'skills/san_copywriter', 'skills/san_exporter'],
  'san-coder-back.md': ['skills/san_backend_expert'],
  'san-coder-front.md': ['skills/san_ux_ui_expert', 'skills/san_copywriter', 'skills/san_design_tokens'],
  'san-qa-auditor.md': ['skills/san_qa_security_expert'],
  'san-ops-devops.md': ['skills/san_devops_expert'],
  'san-growth-legal.md': ['skills/san_store_legal_expert', 'skills/san_growth_expert', 'skills/san_copywriter']
}
expected = expected_table['${agent}']
with open('${AGENTS_DIR}/${agent}') as f:
    fm = yaml.safe_load(f.read().split('---', 2)[1])
    actual = fm.get('skills', [])
    assert actual == expected, f'Agent ${agent} skills discordants: attendu {expected}, obtenu {actual}'
\""
done

# ------------------------------------------------------------------------------
# 4. Répartition des Modèles Cognitifs (Flash vs Pro)
# ------------------------------------------------------------------------------
echo ""
info "4. Vérification de l'attribution des modèles d'IA (pro vs flash)"

# Modèles 'pro' pour modélisation conceptuelle et inquisition sceptique
for agent in "san-architect.md" "san-qa-auditor.md"; do
  assert_true "${agent} utilise le modèle 'pro'" \
    "python3 -c \"
import yaml
with open('${AGENTS_DIR}/${agent}') as f:
    fm = yaml.safe_load(f.read().split('---', 2)[1])
assert fm.get('model') == 'pro'
\""
done

# Modèles 'flash' pour exploration rapide et implémentation atomique
for agent in "san-researcher.md" "san-designer-worker.md" "san-coder-back.md" "san-coder-front.md" "san-ops-devops.md" "san-growth-legal.md"; do
  assert_true "${agent} utilise le modèle 'flash'" \
    "python3 -c \"
import yaml
with open('${AGENTS_DIR}/${agent}') as f:
    fm = yaml.safe_load(f.read().split('---', 2)[1])
assert fm.get('model') == 'flash'
\""
done

# ------------------------------------------------------------------------------
# 5. Garde-fous d'Outillage & Politiques d'Exécution de Commandes
# ------------------------------------------------------------------------------
echo ""
info "5. Vérification des permissions d'outils et politiques d'exécution (Principe de moindre privilège)"

# Agents en LECTURE SEULE STRICTE ou AUDIT PASSIF : zéro write_file, zéro edit_file
READONLY_AGENTS=("san-researcher.md" "san-architect.md" "san-qa-auditor.md")
for agent in "${READONLY_AGENTS[@]}"; do
  AGENT_FILE="${AGENTS_DIR}/${agent}"
  FM=$(python3 -c "
with open('${AGENT_FILE}') as f:
    parts = f.read().split('---', 2)
    print(parts[1] if len(parts) >= 3 else '')
")
  assert_true "${agent} n'a PAS l'outil write_file" \
    '! echo "${FM}" | grep -q "write_file"'

  assert_true "${agent} n'a PAS l'outil edit_file" \
    '! echo "${FM}" | grep -q "edit_file"'
done

# san-architect est commandExecutionPolicy: off et tools: [read_file]
assert_true "san-architect.md a commandExecutionPolicy: off" \
  'grep -Eq "^commandExecutionPolicy:[[:space:]]*[\"'\'']?off[\"'\'']?" "${AGENTS_DIR}/san-architect.md"'

# san-researcher a commandExecutionPolicy: sandbox
assert_true "san-researcher.md a commandExecutionPolicy: sandbox" \
  'grep -Eq "^commandExecutionPolicy:[[:space:]]*[\"'\'']?sandbox[\"'\'']?" "${AGENTS_DIR}/san-researcher.md"'

# Les 5 bâtisseurs ET san-qa-auditor ont commandExecutionPolicy: auto
AUTO_EXEC_AGENTS=(
  "san-designer-worker.md"
  "san-coder-back.md"
  "san-coder-front.md"
  "san-qa-auditor.md"
  "san-ops-devops.md"
  "san-growth-legal.md"
)
for agent in "${AUTO_EXEC_AGENTS[@]}"; do
  assert_true "${agent} a commandExecutionPolicy: auto" \
    'grep -Eq "^commandExecutionPolicy:[[:space:]]*[\"'\'']?auto[\"'\'']?" "${AGENTS_DIR}/${agent}"'
done

# Bâtisseurs ayant les droits d'écriture
BUILDER_AGENTS=("san-designer-worker.md" "san-coder-back.md" "san-coder-front.md" "san-ops-devops.md" "san-growth-legal.md")
for agent in "${BUILDER_AGENTS[@]}"; do
  AGENT_FILE="${AGENTS_DIR}/${agent}"
  FM=$(python3 -c "
with open('${AGENT_FILE}') as f:
    parts = f.read().split('---', 2)
    print(parts[1] if len(parts) >= 3 else '')
")
  assert_true "${agent} dispose de write_file et edit_file" \
    'echo "${FM}" | grep -q "write_file" && echo "${FM}" | grep -q "edit_file"'
done

# ------------------------------------------------------------------------------
# 6. Protocole de Reddition Déterministe (send_message) sur les 8 Sous-Agents
# ------------------------------------------------------------------------------
echo ""
info "6. Vérification formelle du protocole send_message sur l'intégralité des 8 sous-agents"

for agent in "${EXPECTED_AGENTS[@]}"; do
  AGENT_FILE="${AGENTS_DIR}/${agent}"
  assert_true "${agent} intègre la directive impérative 'send_message'" \
    'grep -q "send_message" "${AGENT_FILE}"'
  assert_true "${agent} contient la section 'PROTOCOLE DE REDDITION DÉTERMINISTE'" \
    'grep -qi "PROTOCOLE DE REDDITION DÉTERMINISTE" "${AGENT_FILE}"'
done

# ------------------------------------------------------------------------------
# 7. Clauses Psychologiques Obligatoires (Anti-Médiocrité du 1er Jet)
# ------------------------------------------------------------------------------
echo ""
info "7. Vérification des clauses d'ingénierie psychologique du doute et de rigueur"

# Pre-Mortem dans san-architect
assert_true "san-architect.md contient le protocole obligatoire 'Pre-Mortem'" \
  'grep -qi "Pre-Mortem" "${AGENTS_DIR}/san-architect.md"'

assert_true "san-architect.md contient la projection '6 mois après la mise en production'" \
  'grep -qi "6 mois après" "${AGENTS_DIR}/san-architect.md"'

# Dialectique dans san-coder-back & san-researcher
assert_true "san-coder-back.md contient la règle 'Dialectique Avant Frappe' / alternatives écartées" \
  'grep -qi "Dialectique" "${AGENTS_DIR}/san-coder-back.md"'

assert_true "san-coder-back.md interdit expressément le 'Mocking Theater'" \
  'grep -qi "Mocking Theater" "${AGENTS_DIR}/san-coder-back.md"'

assert_true "san-researcher.md impose une matrice comparative d'au moins 2 approches" \
  'grep -qi "2 approches" "${AGENTS_DIR}/san-researcher.md"'

# Dialectique Frontend dans san-coder-front
assert_true "san-coder-front.md contient la règle 'Dialectique Avant Frappe Frontend'" \
  'grep -qi "Dialectique Avant Frappe Frontend" "${AGENTS_DIR}/san-coder-front.md"'

# Présomption de Défaut dans san-qa-auditor
assert_true "san-qa-auditor.md contient la clause 'Présomption de Défaut'" \
  'grep -qi "Présomption de Défaut" "${AGENTS_DIR}/san-qa-auditor.md"'

assert_true "san-qa-auditor.md contient l'injonction 'Toute validation complaisante est une faute grave'" \
  'grep -qi "Toute validation complaisante est une faute grave" "${AGENTS_DIR}/san-qa-auditor.md"'

assert_true "san-qa-auditor.md impose la critique visuelle multimodale sur pixels réels (PNG)" \
  'grep -qi "multimodale" "${AGENTS_DIR}/san-qa-auditor.md" && grep -qi "PNG" "${AGENTS_DIR}/san-qa-auditor.md"'

assert_true "san-qa-auditor.md impose le verdict binaire LIVRABLE ou RETOUR_ATELIER" \
  'grep -q "LIVRABLE" "${AGENTS_DIR}/san-qa-auditor.md" && grep -q "RETOUR_ATELIER" "${AGENTS_DIR}/san-qa-auditor.md"'

# Stale-While-Revalidate & Modularité dans san-coder-front
assert_true "san-coder-front.md impose la chorégraphie 'Stale-While-Revalidate'" \
  'grep -qi "Stale-While-Revalidate" "${AGENTS_DIR}/san-coder-front.md"'

assert_true "san-coder-front.md interdit le Skeleton destructeur lors des refetch" \
  'grep -qi "Skeleton" "${AGENTS_DIR}/san-coder-front.md" && grep -qi "interdiction" "${AGENTS_DIR}/san-coder-front.md"'

assert_true "san-coder-front.md impose le plafond strict de < 220 lignes par composant" \
  'grep -q "220 lignes" "${AGENTS_DIR}/san-coder-front.md"'

assert_true "san-coder-front.md impose tabular-nums et focus-visible" \
  'grep -q "tabular-nums" "${AGENTS_DIR}/san-coder-front.md" && grep -q "focus-visible" "${AGENTS_DIR}/san-coder-front.md"'

# Direction artistique dans san-designer-worker (exigence stricte export_png.mjs)
assert_true "san-designer-worker.md impose l'exécution stricte de export_png.mjs" \
  'grep -q "export_png.mjs" "${AGENTS_DIR}/san-designer-worker.md"'

# Résilience et réversibilité dans san-ops-devops (rollback < 30s et docker run --rm)
assert_true "san-ops-devops.md impose le rollback < 30s et la sauvegarde testée" \
  'grep -qi "rollback" "${AGENTS_DIR}/san-ops-devops.md" && grep -qi "sauvegarde testée" "${AGENTS_DIR}/san-ops-devops.md"'

assert_true "san-ops-devops.md exige le test de restauration en conteneur éphémère docker run --rm" \
  'grep -q "docker run --rm" "${AGENTS_DIR}/san-ops-devops.md"'

# Conformité code réel dans san-growth-legal (vérité du code et code réel)
assert_true "san-growth-legal.md impose la conformité dérivée de la vérité du code réel" \
  'grep -qi "vérité.*code" "${AGENTS_DIR}/san-growth-legal.md" && grep -qi "code réel" "${AGENTS_DIR}/san-growth-legal.md"'

assert_true "san-growth-legal.md impose la conformité Apple 5.1.1 (suppression de compte)" \
  'grep -qi "5\.1\.1" "${AGENTS_DIR}/san-growth-legal.md"'

# ------------------------------------------------------------------------------
# 8. Validation Officielle via Antigravity Plugin Validator (agy plugin validate)
# ------------------------------------------------------------------------------
echo ""
info "8. Validation officielle Antigravity Plugin Engine (agy plugin validate --strict --json)"

TMP_PLUGIN_DIR=$(mktemp -d /tmp/san-v2-agents-validation.XXXXXX)
trap 'rm -rf "${TMP_PLUGIN_DIR}"' EXIT

# Construire un bundle plugin valide avec les 8 agents
cat << 'EOF' > "${TMP_PLUGIN_DIR}/plugin.json"
{
  "name": "san-framework",
  "version": "2.0.0",
  "description": "Framework Antigravity san_* v2.0 - Suite de 8 sous-agents natifs"
}
EOF

mkdir -p "${TMP_PLUGIN_DIR}/agents"
cp "${AGENTS_DIR}"/*.md "${TMP_PLUGIN_DIR}/agents/"

# Exécuter agy plugin validate de façon fail-safe sous set -e
VALIDATION_EXIT=0
VALIDATION_OUTPUT=$(agy plugin validate "${TMP_PLUGIN_DIR}" --strict --json 2>/dev/null) || VALIDATION_EXIT=$?
VALIDATION_EXIT=${VALIDATION_EXIT:-0}

assert_true "agy plugin validate s'exécute avec succès (exit code 0)" \
  '[ "${VALIDATION_EXIT}" -eq 0 ]'

# Parser la sortie JSON via stdin de façon sécurisée (sans crash sous set -e)
AGENTS_DETECTED=$(echo "${VALIDATION_OUTPUT}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('components', {}).get('agents', 0))
except Exception:
    print(-1)
")

assert_true "Le validateur Antigravity a détecté exactement 8 sous-agents" \
  '[ "${AGENTS_DETECTED}" -eq 8 ]'

FINDINGS_ERRORS=$(echo "${VALIDATION_OUTPUT}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    findings = data.get('findings', [])
    errors = [f for f in findings if f.get('severity') in ('error', 'warning')]
    print(len(errors))
except Exception:
    print(-1)
")

assert_true "Le validateur Antigravity ne remonte 0 erreur et 0 warning sur les agents" \
  '[ "${FINDINGS_ERRORS}" -eq 0 ]'

# ------------------------------------------------------------------------------
# Synthèse Finale
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  RÉSULTATS DE LA SUITE DE TEST PHASE 2 : AGENTS NATIFS"
echo "======================================================================"
echo -e "  Tests réussis : \033[32m${PASSED_TESTS}\033[0m"
echo -e "  Tests échoués : \033[31m${FAILED_TESTS}\033[0m"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "🎉 TOUTES LES ASSERTIONS PHASE 2 SONT AU VERT ! SUCCÈS TOTAL."
  exit 0
else
  red "❌ DES ASSERTIONS ONT ÉCHOUÉ DANS LA PHASE 2."
  exit 1
fi
