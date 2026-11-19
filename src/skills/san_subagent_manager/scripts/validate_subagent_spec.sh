#!/usr/bin/env bash
# scripts/validate_subagent_spec.sh
# Validation déterministe v3.0 Dual-Harness (Antigravity swarm + OpenCode V2.3 san_swarm/subagent)
# des définitions d'agents (src/agents/*.md) et prompts fermés (san_*).
# Usage: ./validate_subagent_spec.sh <path/to/spec.md> [unified-executor|pro|<provider/model>|<model-id>]
# Options:
#   -h, --help    Affiche l'aide et quitte

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
  cat << 'EOF'
Usage: validate_subagent_spec.sh <SPEC_FILE> [MODEL_TARGET]

Arguments:
  SPEC_FILE       Chemin vers un agent natif (src/agents/*.md) ou un prompt de sous-agent.
  MODEL_TARGET    Cible Dual-Harness v3.0 (défaut: unified-executor via .agents/models.json) :
                  - 'unified-executor' (référence abstraite .agents/models.json)
                  - 'pro' (compatibilité frontmatter YAML Antigravity CLI)
                  - '<provider>/<model>' (ex: opencode-go/deepseek-v4-pro)
                  - ou identifiant explicite configuré dans .agents/models.json
                  Les valeurs 'inherit' et 'flash' sont strictement interdites sur les workers.

Exemples:
  ./validate_subagent_spec.sh src/agents/san-architect.md
  ./validate_subagent_spec.sh src/agents/san-coder-back.md unified-executor
  ./validate_subagent_spec.sh templates/SUBAGENT_PROMPT_TEMPLATE.md pro

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

PROMPT_FILE="${1:-}"
MODEL_TARGET="${2:-unified-executor}"

if [[ -z "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Fichier de spécification non spécifié.${NC}"
  show_help
  exit 1
fi

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Le fichier '${PROMPT_FILE}' n'existe pas.${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 [san_subagent_manager v3.0] Audit : ${CYAN}${PROMPT_FILE}${NC} (Cible : ${CYAN}${MODEL_TARGET}${NC})"
ERRORS=0
WARNINGS=0

# 1. Contrôle de la cible worker Dual-Harness (refuse inherit / flash)
case "${MODEL_TARGET}" in
  unified-executor|pro)
    echo -e "${GREEN}  ✓ Cible worker conforme v3.0 Dual-Harness : '${MODEL_TARGET}'.${NC}"
    ;;
  inherit)
    echo -e "${RED}  ❌ Violation : 'inherit' est interdit sur les workers sous AGY (quota session orchestrateur). Utilisez .agents/models.json ('unified-executor').${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
  flash)
    echo -e "${RED}  ❌ Violation : 'flash' générique est déprécié pour les workers. Définissez un modèle explicite dans .agents/models.json.${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
  */*)
    if [[ "${MODEL_TARGET}" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._:-]+$ ]]; then
      echo -e "${GREEN}  ✓ Cible OpenCode V2.3 conforme : '${MODEL_TARGET}'.${NC}"
    else
      echo -e "${RED}  ❌ Format provider/model OpenCode invalide : '${MODEL_TARGET}'.${NC}"
      ERRORS=$((ERRORS + 1))
    fi
    ;;
  *)
    if [[ "${MODEL_TARGET}" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
      echo -e "${GREEN}  ✓ Identifiant modèle worker accepté : '${MODEL_TARGET}'.${NC}"
    else
      echo -e "${RED}  ❌ Modèle cible invalide : '${MODEL_TARGET}'.${NC}"
      ERRORS=$((ERRORS + 1))
    fi
    ;;
esac

# 2. Chasse aux modèles hardcodés / obsolètes dans les specs d'agents
if grep -qiE "gemini-3\.1-pro-high|gemini-3\.8-flash-high|gemini-4-hydrogen-xhigh|gemini-4-argon" "${PROMPT_FILE}"; then
  echo -e "${RED}  ❌ Modèle hardcodé détecté : utilisez les clés abstraites de .agents/models.json (agy.executor / opencode.executor).${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ Zéro nom de modèle vendor hardcodé dans la spec.${NC}"
fi

# 3. Détection du format : Agent Natif YAML (src/agents/*.md) vs Gabarit de Prompt Fermé
IS_NATIVE_AGENT=0
if [[ "$(head -n 1 "${PROMPT_FILE}")" == "---" ]] && grep -qE "^subagent:[[:space:]]*true" "${PROMPT_FILE}"; then
  IS_NATIVE_AGENT=1
fi

if [[ "${IS_NATIVE_AGENT}" -eq 1 ]]; then
  echo -e "${CYAN}  ℹ Format détecté : Définition d'agent natif Dual-Harness (YAML + Markdown).${NC}"

  FRONTMATTER=$(awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{exit} f{print}' "${PROMPT_FILE}")
  BODY=$(awk 'BEGIN{d=0} $0=="---"{d++; next} d>=2{print}' "${PROMPT_FILE}")

  for yaml_key in "name:" "description:" "mainAgent:" "subagent:" "model:" "commandExecutionPolicy:" "tools:" "skills:"; do
    if ! echo "${FRONTMATTER}" | grep -qE "^${yaml_key}"; then
      echo -e "${RED}  ❌ Champ frontmatter YAML manquant : '${yaml_key}'${NC}"
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}  ✓ Champ YAML présent : '${yaml_key}'${NC}"
    fi
  done

  FM_MODEL=$(echo "${FRONTMATTER}" | grep -E "^model:" | head -n 1 | sed -E 's/^model:[[:space:]]*["'\'']?([^"'\''[:space:]]+)["'\'']?/\1/' || true)
  if [[ "${FM_MODEL}" != "pro" ]] && [[ ! "${FM_MODEL}" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._:-]+$ ]]; then
    echo -e "${RED}  ❌ Frontmatter YAML 'model' invalide ('${FM_MODEL}') : doit être '\"pro\"' ou '<provider>/<model>', jamais 'flash' ni 'inherit'.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Frontmatter YAML 'model: \"${FM_MODEL}\"' conforme Dual-Harness.${NC}"
  fi

  if ! echo "${BODY}" | grep -qE "(\.agents/models\.json|san-harness models)"; then
    echo -e "${RED}  ❌ Corps d'agent incomplet : référence à '.agents/models.json' ou 'san-harness models' requise.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Routage abstrait (.agents/models.json) vérifié dans le corps.${NC}"
  fi

  if ! echo "${BODY}" | grep -qiE "(RÔLE|MISSION)"; then
    echo -e "${RED}  ❌ Section manquante : 'RÔLE' ou 'MISSION' absent.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Section détectée : 'RÔLE / MISSION'.${NC}"
  fi

  if ! echo "${BODY}" | grep -qiE "(GARDE-FOUS|PÉRIMÈTRE|INVARIANTS|RÈGLES|CONSTRAINTS)"; then
    echo -e "${RED}  ❌ Section manquante : 'GARDE-FOUS / PÉRIMÈTRE / INVARIANTS / RÈGLES'.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Section détectée : 'GARDE-FOUS / PÉRIMÈTRE'.${NC}"
  fi

  if ! echo "${BODY}" | grep -qi "PROTOCOLE DE REDDITION DÉTERMINISTE"; then
    echo -e "${RED}  ❌ Section obligatoire manquante : 'PROTOCOLE DE REDDITION DÉTERMINISTE'.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Section détectée : 'PROTOCOLE DE REDDITION DÉTERMINISTE'.${NC}"
  fi

  if ! echo "${BODY}" | grep -qi "invoke_subagent"; then
    echo -e "${RED}  ❌ Garde-fou manquant : l'interdiction formelle de 'invoke_subagent' doit figurer dans le corps.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Règle anti-récursion vérifiée ('invoke_subagent' mentionné).${NC}"
  fi

  if ! echo "${BODY}" | grep -qi "send_message"; then
    echo -e "${RED}  ❌ Protocole de reddition incomplet : 'send_message' est absent.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Canal de reddition vérifié ('send_message' présent).${NC}"
  fi

  if ! echo "${BODY}" | grep -qiE "(SUCCÈS_TOTAL|SUCCES_TOTAL|BLOCAGE|LIVRABLE|RETOUR_ATELIER)"; then
    echo -e "${YELLOW}  ⚠️ Avertissement : Les statuts formels de livraison devraient être explicités.${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "${CYAN}  ℹ Format détecté : Prompt fermé de sous-agent.${NC}"

  REQUIRED_SECTIONS=(
    "ROLE"
    "MISSION"
    "INPUTS"
    "OUTPUTS"
    "CONSTRAINTS"
    "VALIDATION_COMMAND"
    "REDDITION"
  )

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qiE "(###.*${section}|##.*${section}|#.*${section}|^${section}:)" "${PROMPT_FILE}"; then
      echo -e "${RED}  ❌ Section obligatoire manquante : '${section}'${NC}"
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}  ✓ Section détectée : '${section}'${NC}"
    fi
  done

  if ! grep -qi "invoke_subagent" "${PROMPT_FILE}"; then
    echo -e "${RED}  ❌ Garde-fou manquant : L'interdiction formelle de 'invoke_subagent' doit figurer dans CONSTRAINTS.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Règle anti-récursion vérifiée ('invoke_subagent' mentionné).${NC}"
  fi

  if ! grep -qi "send_message" "${PROMPT_FILE}"; then
    echo -e "${RED}  ❌ Protocole de reddition incomplet : L'instruction explicite d'utiliser 'send_message' est absente.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Canal de reddition vérifié ('send_message' présent).${NC}"
  fi
fi

# 4. Bilan final
echo "--------------------------------------------------------"
if [[ ${ERRORS} -gt 0 ]]; then
  echo -e "${RED}🚨 [san_subagent_manager] Validation ÉCHOUÉE : ${ERRORS} violation(s) critique(s), ${WARNINGS} avertissement(s).${NC}"
  exit 1
else
  if [[ ${WARNINGS} -gt 0 ]]; then
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification CONFORME (${WARNINGS} avertissement(s) mineur(s)). Prêt pour Dual-Harness.${NC}"
  else
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification 100% CONFORME. Prêt pour Dual-Harness.${NC}"
  fi
  exit 0
fi
