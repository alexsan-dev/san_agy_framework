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
echo "  TEST PHASE 5 : RUNBOOKS DES 17 SKILLS, TAILLES, FRONTMATTERS & LIENS"
echo "======================================================================"
echo ""

# Liste exhaustive des 17 skills du framework Antigravity
ALL_SKILLS=(
  "san_backend_expert"
  "san_brainstorming"
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
  TOTAL_MD_FILES_CHECKED=$((TOTAL_MD_FILES_CHECKED + 1))
  file_dir="$(dirname "${md_file}")"
  rel_file="${md_file#${SRC_SKILLS_DIR}/}"

  # Extraction de tous les liens Markdown [texte](cible)
  links=$(grep -oE '\[[^]]*\]\(([^)]+)\)' "${md_file}" | sed -E 's/\[[^]]*\]\(([^)]+)\)/\1/' || true)

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
