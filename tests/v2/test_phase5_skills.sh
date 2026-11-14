#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 5 — RUNBOOKS IMPÉRATIFS, LIMITES DE TAILLE & ZÉRO LIEN MORT
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SRC_SKILLS_DIR="${ROOT_DIR}/src/skills"
SKILLS_DIR="${ROOT_DIR}/skills"
SUB_SKILLS_DIR="${ROOT_DIR}/sub-skills"

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
echo "  TEST PHASE 5 : RUNBOOKS DES 19 SKILLS, TAILLES, FRONTMATTERS & LIENS"
echo "======================================================================"
echo ""

# Liste exhaustive des 19 skills du framework Antigravity
ALL_SKILLS=(
  "san_backend_expert"
  "san_brainstorming"
  "san_cartographer"
  "san_copywriter"
  "san_designer"
  "san_design_tokens"
  "san_devops_expert"
  "san_doc_keeper"
  "san_executer"
  "san_exporter"
  "san_growth_expert"
  "san_init"
  "san_planner"
  "san_qa_security_expert"
  "san_searcher"
  "san_store_legal_expert"
  "san_subagent_manager"
  "san_transcriber"
  "san_ux_ui_expert"
)

# ------------------------------------------------------------------------------
# 1. Vérification de l'existence et de la taille de chaque SKILL.md (<= 130 lignes)
# ------------------------------------------------------------------------------
info "1. Vérification de l'existence et de la taille de chaque SKILL.md (<= 130 lignes)"

for skill in "${ALL_SKILLS[@]}"; do
  skill_file="${SRC_SKILLS_DIR}/${skill}/SKILL.md"
  
  assert_true "Fichier existe : src/skills/${skill}/SKILL.md" \
    '[ -f "'"${skill_file}"'" ]'
  
  if [ -f "${skill_file}" ]; then
    line_count=$(wc -l < "${skill_file}" | tr -d ' ')
    assert_true "Taille <= 130 lignes pour ${skill} (${line_count} lignes)" \
      '[ "'"${line_count}"'" -le 130 ]'
  fi
done

# ------------------------------------------------------------------------------
# 2. Vérification de la validité du Frontmatter YAML et orientation intention
# ------------------------------------------------------------------------------
info "2. Vérification des Frontmatters YAML et descriptions d'intention"

for skill in "${ALL_SKILLS[@]}"; do
  skill_file="${SRC_SKILLS_DIR}/${skill}/SKILL.md"
  
  if [ -f "${skill_file}" ]; then
    # Doit débuter par ---
    first_line=$(head -n 1 "${skill_file}")
    assert_true "Frontmatter YAML débute par '---' : ${skill}" \
      '[ "'"${first_line}"'" = "---" ]'

    # Doit contenir name: san_<skill>
    assert_true "Nom déclaré dans frontmatter 'name: ${skill}'" \
      'grep -qE "^name:\s*${skill}\s*$" "'"${skill_file}"'"'

    # Doit contenir description: non vide
    assert_true "Description non vide présente pour ${skill}" \
      'grep -qE "^description:\s*.+" "'"${skill_file}"'"'

    # Description doit être orientée déclenchement d'intention
    assert_true "Description orientée intention/déclenchement pour ${skill}" \
      'grep -qiE "déclenché|invoqué|responsable|expert|moteur|point d'\''entrée|usine|artisan" "'"${skill_file}"'"'
  fi
done

# ------------------------------------------------------------------------------
# 3. Zéro occurrence des mots interdits (koteka, vunette)
# ------------------------------------------------------------------------------
info "3. Traque absolue des mentions interdites (koteka, vunette)"

for forbidden in "koteka" "vunette"; do
  assert_true "Zéro occurrence de '${forbidden}' dans src/skills/" \
    '! grep -r -i "'"${forbidden}"'" "'"${SRC_SKILLS_DIR}"'" 2>/dev/null'
  
  assert_true "Zéro occurrence de '${forbidden}' dans skills/" \
    '! grep -r -i "'"${forbidden}"'" "'"${SKILLS_DIR}"'" 2>/dev/null'

  assert_true "Zéro occurrence de '${forbidden}' dans sub-skills/" \
    '! grep -r -i "'"${forbidden}"'" "'"${SUB_SKILLS_DIR}"'" 2>/dev/null'
done

# ------------------------------------------------------------------------------
# 4. Vérification de l'intégrité de tous les liens relatifs (Zéro lien mort)
# ------------------------------------------------------------------------------
info "4. Contrôle de l'intégrité de tous les liens relatifs internes dans TOUS les .md de src/skills/ (y compris references/ et templates/)"

TOTAL_LINKS_CHECKED=0
DEAD_LINKS_COUNT=0
TOTAL_MD_FILES_CHECKED=0

while IFS= read -r md_file; do
  [ -z "${md_file}" ] && continue
  rel_file="${md_file#${SRC_SKILLS_DIR}/}"

  # Ignorer les gabarits d'exemple de cartographie contenant des liens relatifs fictifs
  if [[ "${rel_file}" =~ templates/REPO_MAP_TEMPLATE\.md$ ]]; then
    continue
  fi

  TOTAL_MD_FILES_CHECKED=$((TOTAL_MD_FILES_CHECKED + 1))
  file_dir="$(dirname "${md_file}")"

  # Extraction de tous les liens Markdown [texte](cible) hors code spans inline
  links=$(sed -E 's/`[^`]*`//g' "${md_file}" | grep -oE '\[[^]]*\]\(([^)]+)\)' | sed -E 's/\[[^]]*\]\(([^)]+)\)/\1/' || true)

  while IFS= read -r link; do
    [ -z "${link}" ] && continue
    
    # Ignorer URLs externes, mailto, schémas file:// et ancres locales pures (#)
    if [[ "${link}" =~ ^https?:// ]] || [[ "${link}" =~ ^mailto: ]] || [[ "${link}" =~ ^file:// ]] || [[ "${link}" =~ ^# ]]; then
      continue
    fi

    # Retirer ancre interne éventuelle (#section)
    target_path="${link%%#*}"
    [ -z "${target_path}" ] && continue

    TOTAL_LINKS_CHECKED=$((TOTAL_LINKS_CHECKED + 1))

    # Résoudre le chemin relatif par rapport au répertoire du fichier markdown courant
    resolved_target="${file_dir}/${target_path}"

    if [ -f "${resolved_target}" ] || [ -d "${resolved_target}" ]; then
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      red "LIEN MORT dans ${rel_file} -> ${link} (résolu: ${resolved_target})"
      FAILED_TESTS=$((FAILED_TESTS + 1))
      DEAD_LINKS_COUNT=$((DEAD_LINKS_COUNT + 1))
    fi
  done <<< "${links}"
done < <(find "${SRC_SKILLS_DIR}" -type f -name "*.md" | sort)

assert_true "Tous les liens relatifs pointent vers des fichiers existants (0 lien mort sur ${TOTAL_LINKS_CHECKED} vérifiés dans ${TOTAL_MD_FILES_CHECKED} fichiers .md)" \
  '[ "${DEAD_LINKS_COUNT}" -eq 0 ] && [ "${TOTAL_LINKS_CHECKED}" -gt 0 ]'

# ------------------------------------------------------------------------------
# 5. Vérification des gabarits spécifiques de Subagents v2.0 (Lot 5C)
# ------------------------------------------------------------------------------
info "5. Vérification des clauses spécifiques v2.0 dans les templates san_subagent_manager"

SUBAGENT_TPL="${SRC_SKILLS_DIR}/san_subagent_manager/templates/SUBAGENT_PROMPT_TEMPLATE.md"
AUDITOR_TPL="${SRC_SKILLS_DIR}/san_subagent_manager/templates/AUDITOR_PROMPT.md"

assert_true "SUBAGENT_PROMPT_TEMPLATE.md intègre la Dialectique Avant Frappe (2 approches viables)" \
  'grep -qi "Dialectique Avant Frappe" "'"${SUBAGENT_TPL}"'" && grep -qi "2 approches" "'"${SUBAGENT_TPL}"'"'

assert_true "AUDITOR_PROMPT.md intègre la Présomption de Défaut" \
  'grep -qi "Présomption de Défaut" "'"${AUDITOR_TPL}"'"'

assert_true "AUDITOR_PROMPT.md intègre la tolérance zéro au Testing Theater" \
  'grep -qi "Testing Theater" "'"${AUDITOR_TPL}"'"'

assert_true "AUDITOR_PROMPT.md impose le verdict binaire LIVRABLE | RETOUR_ATELIER" \
  'grep -qi "LIVRABLE" "'"${AUDITOR_TPL}"'" && grep -qi "RETOUR_ATELIER" "'"${AUDITOR_TPL}"'"'

# ------------------------------------------------------------------------------
# 6. Vérification des livrables v2.1 & v2.2 (Workflows Python, déduplication cmp -s,
#    export_png --url, san_transcriber & wrappers v2.2.0)
# ------------------------------------------------------------------------------
info "6. Vérification des livrables v2.1 / v2.2 (Workflows Python, déduplication cmp -s, transcriber & wrappers)"

SLICE_WF="${SRC_SKILLS_DIR}/san_executer/scripts/autonomous_slice_workflow.py"
INQ_WF="${SRC_SKILLS_DIR}/san_qa_security_expert/scripts/parallel_inquisition_workflow.py"
EXP_DESIGNER="${SRC_SKILLS_DIR}/san_designer/scripts/export_png.mjs"
EXP_EXPORTER="${SRC_SKILLS_DIR}/san_exporter/scripts/export_png.mjs"
ARC_PLANNER="${SRC_SKILLS_DIR}/san_planner/scripts/archive_roadmap.sh"
ARC_DOC_KEEPER="${SRC_SKILLS_DIR}/san_doc_keeper/scripts/archive_roadmap.sh"
SVG_INIT="${SRC_SKILLS_DIR}/san_init/scripts/svg_to_png.mjs"
SVG_EXPORTER="${SRC_SKILLS_DIR}/san_exporter/scripts/svg_to_png.mjs"
TRANSCRIPT_HELPER="${SRC_SKILLS_DIR}/san_transcriber/scripts/transcript_helper.mjs"

assert_true "autonomous_slice_workflow.py existe et est exécutable" \
  '[ -x "${SLICE_WF}" ]'

assert_true "autonomous_slice_workflow.py passe python3 -m py_compile et --self-test" \
  'python3 -m py_compile "${SLICE_WF}" && python3 "${SLICE_WF}" --self-test >/dev/null 2>&1'

assert_true "parallel_inquisition_workflow.py existe et est exécutable" \
  '[ -x "${INQ_WF}" ]'

assert_true "parallel_inquisition_workflow.py passe python3 -m py_compile et --self-test" \
  'python3 -m py_compile "${INQ_WF}" && python3 "${INQ_WF}" --self-test >/dev/null 2>&1'

# Strict cmp -s non-divergence sur les 3 paires de scripts partagés
assert_true "Paire 1 : export_png.mjs passe node --check et est strictement identique (cmp -s) entre san_designer et san_exporter" \
  'node --check "${EXP_DESIGNER}" && node --check "${EXP_EXPORTER}" && cmp -s "${EXP_DESIGNER}" "${EXP_EXPORTER}"'

assert_true "Paire 2 : archive_roadmap.sh passe bash -n et est strictement identique (cmp -s) entre san_planner et san_doc_keeper" \
  'bash -n "${ARC_PLANNER}" && bash -n "${ARC_DOC_KEEPER}" && cmp -s "${ARC_PLANNER}" "${ARC_DOC_KEEPER}"'

assert_true "Paire 3 : svg_to_png.mjs passe node --check et est strictement identique (cmp -s) entre san_init et san_exporter" \
  'node --check "${SVG_INIT}" && node --check "${SVG_EXPORTER}" && cmp -s "${SVG_INIT}" "${SVG_EXPORTER}"'

assert_true "export_png.mjs v2.2 supporte --url, --full-page, --viewports, --audit-dom et loadPlaywright" \
  'grep -q "viewports" "${EXP_DESIGNER}" && grep -q "audit-dom" "${EXP_DESIGNER}" && grep -q "horizontalOverflow" "${EXP_DESIGNER}" && grep -q "\-\-url" "${EXP_DESIGNER}" && grep -q "full-page" "${EXP_DESIGNER}" && grep -q "loadPlaywright" "${EXP_DESIGNER}"'

assert_true "san_designer/SKILL.md documente Studio Duel UI, --url et 5 États" \
  'grep -q "Studio Duel" "${SRC_SKILLS_DIR}/san_designer/SKILL.md" && grep -q "\-\-url" "${SRC_SKILLS_DIR}/san_designer/SKILL.md" && grep -q "Stale-While-Revalidate" "${SRC_SKILLS_DIR}/san_designer/SKILL.md"'

assert_true "san_planner/SKILL.md documente Contract-First, Fitness Functions et alignement préalable" \
  'grep -q "Contract-First" "${SRC_SKILLS_DIR}/san_planner/SKILL.md" && grep -q "Fitness Functions" "${SRC_SKILLS_DIR}/san_planner/SKILL.md" && grep -q "ask_question" "${SRC_SKILLS_DIR}/san_planner/SKILL.md"'

# Test comportemental réel de transcript_helper.mjs (san_transcriber)
assert_true "transcript_helper.mjs existe, est exécutable et passe node --check" \
  '[ -x "${TRANSCRIPT_HELPER}" ] && node --check "${TRANSCRIPT_HELPER}"'

TMP_TRANSCRIPT_WS=$(mktemp -d /tmp/san-phase5-transcript.XXXXXX)
trap 'rm -rf "${TMP_TRANSCRIPT_WS}"' EXIT
(
  cd "${TMP_TRANSCRIPT_WS}"
  git init -q
  git config user.name "Transcriber Tester"
  git config user.email "transcriber@alexsan.pro"
  mkdir -p roadmaps .agents
  cat << 'EOF' > .agents/models.json
{
  "version": "2.2.0",
  "agy": { "orchestrator": "gemini-4-argon-high", "executor": "gemini-4-hydrogen-xhigh" },
  "opencode": { "orchestrator": "opencode-go/hy4", "executor": "opencode-go/deepseek-v4-pro" }
}
EOF
  cat << 'EOF' > roadmaps/ROADMAP_V22_TEST.md
# Roadmap Test Relais
- [x] Etape 1 verifiee
- [ ] Etape 2 restante
EOF
  git add roadmaps/ROADMAP_V22_TEST.md
  git commit -m "chore: init roadmap for transcriber test" -q
)

TRANSCRIPT_OUT_PATH=$(node "${TRANSCRIPT_HELPER}" \
  --dir="${TMP_TRANSCRIPT_WS}" \
  --summary="Auth module livré avec Zod" \
  --why="Contract-First avant UI" \
  --doubts="Tests de charge Redis non exécutés" \
  --next="Implémenter refresh token et lancer npm test")

assert_true "transcript_helper.mjs génère réellement un fichier dans roadmaps/transcripts/" \
  '[ -n "${TRANSCRIPT_OUT_PATH}" ] && [ -f "${TRANSCRIPT_OUT_PATH}" ] && echo "${TRANSCRIPT_OUT_PATH}" | grep -q "/roadmaps/transcripts/TRANSCRIPT_ROADMAP_V22_TEST_"'

if [ -f "${TRANSCRIPT_OUT_PATH}" ]; then
  assert_true "Le transcript généré contient le Protocole de Relais Sceptique (Doubt & Verify)" \
    'grep -qi "PROTOCOLE DE RELAIS SCEPTIQUE" "${TRANSCRIPT_OUT_PATH}" && grep -qi "DOUBT & VERIFY" "${TRANSCRIPT_OUT_PATH}" && grep -q "NE FAIS PAS CONFIANCE AVEUGLÉMENT AU PREMIER AGENT" "${TRANSCRIPT_OUT_PATH}"'

  assert_true "Le transcript généré reflète les arguments réels (--summary, --why, --doubts, --next) et l'avancement roadmap" \
    'grep -q "Auth module livré avec Zod" "${TRANSCRIPT_OUT_PATH}" && grep -q "Contract-First avant UI" "${TRANSCRIPT_OUT_PATH}" && grep -q "Tests de charge Redis non exécutés" "${TRANSCRIPT_OUT_PATH}" && grep -q "Implémenter refresh token" "${TRANSCRIPT_OUT_PATH}" && grep -q "ROADMAP_V22_TEST.md" "${TRANSCRIPT_OUT_PATH}"'
fi

rm -rf "${TMP_TRANSCRIPT_WS}"

# Vérification des 19 wrappers skills/*.md et sub-skills/*.md (v2.2.0 strict)
info "7. Contrôle des 19 wrappers skills/*.md et sub-skills/*.md (version: \"2.2.0\", zéro 2.0.0 / argon-latest-max)"

for skill in "${ALL_SKILLS[@]}"; do
  assert_true "Wrapper présent pour ${skill} dans skills/ ou sub-skills/" \
    '[ -f "${SKILLS_DIR}/${skill}.md" ] || [ -f "${SUB_SKILLS_DIR}/${skill}.md" ]'
done

assert_true "Wrappers san_transcriber.md présents dans skills/ et sub-skills/" \
  '[ -f "${SKILLS_DIR}/san_transcriber.md" ] && [ -f "${SUB_SKILLS_DIR}/san_transcriber.md" ]'

WRAPPER_VERSION_ERRORS=0
WRAPPER_LEGACY_ERRORS=0
WRAPPER_COUNT=0
while IFS= read -r wrapper_file; do
  [ -z "${wrapper_file}" ] && continue
  WRAPPER_COUNT=$((WRAPPER_COUNT + 1))
  if ! grep -qE '^version:[[:space:]]*"2\.2\.0"[[:space:]]*$' "${wrapper_file}"; then
    red "Wrapper sans version: \"2.2.0\" -> ${wrapper_file}"
    WRAPPER_VERSION_ERRORS=$((WRAPPER_VERSION_ERRORS + 1))
  fi
  if grep -qE 'version:[[:space:]]*"2\.[01]\.0"|argon-latest-max' "${wrapper_file}"; then
    red "Mention obsolète (version 2.0.0/2.1.0 ou argon-latest-max) dans ${wrapper_file}"
    WRAPPER_LEGACY_ERRORS=$((WRAPPER_LEGACY_ERRORS + 1))
  fi
done < <(find "${SKILLS_DIR}" "${SUB_SKILLS_DIR}" -maxdepth 1 -type f -name "*.md" | sort)

assert_true "Tous les ${WRAPPER_COUNT} wrappers skills/*.md et sub-skills/*.md sont en version: \"2.2.0\"" \
  '[ "${WRAPPER_COUNT}" -ge 19 ] && [ "${WRAPPER_VERSION_ERRORS}" -eq 0 ]'

assert_true "Zéro version: \"2.0.0\", \"2.1.0\" ou argon-latest-max dans skills/*.md et sub-skills/*.md" \
  '[ "${WRAPPER_LEGACY_ERRORS}" -eq 0 ]'

# ------------------------------------------------------------------------------
# Bilan Récapitulatif
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  RÉSULTATS DE LA PHASE 5 : ${PASSED_TESTS} passés, ${FAILED_TESTS} échecs"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  green "TOUTES LES ASSERTIONS DE LA PHASE 5 SONT VALIDÉES À 100% !"
  exit 0
else
  red "ÉCHEC : ${FAILED_TESTS} assertion(s) n'ont pas été validées."
  exit 1
fi
