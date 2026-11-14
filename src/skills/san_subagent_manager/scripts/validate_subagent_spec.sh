#!/usr/bin/env bash
# scripts/validate_subagent_spec.sh
# Validation déterministe v2.2.0 Dual-Harness (Antigravity swarm + OpenCode V2 subagent)
# des définitions d'agents (src/agents/*.md) et prompts fermés (san_*).
# Usage: ./validate_subagent_spec.sh <path/to/spec.md> [gemini-4-hydrogen-xhigh|pro|unified-executor|<provider/model>]
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
  MODEL_TARGET    Modèle cible v2.2 Dual-Harness :
                  - 'gemini-4-hydrogen-xhigh' (défaut Antigravity swarm)
                  - 'pro' (compat YAML Antigravity CLI)
                  - 'unified-executor' ou '<provider>/<model>' (ex: opencode-go/deepseek-v4-pro)
                  Les valeurs 'inherit' et 'flash' sont strictement interdites.

Exemples:
  ./validate_subagent_spec.sh src/agents/san-architect.md
  ./validate_subagent_spec.sh src/agents/san-coder-back.md gemini-4-hydrogen-xhigh
  ./validate_subagent_spec.sh templates/SUBAGENT_PROMPT_TEMPLATE.md pro

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

PROMPT_FILE="${1:-}"
MODEL_TARGET="${2:-gemini-4-hydrogen-xhigh}"

if [[ -z "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Fichier de spécification non spécifié.${NC}"
  show_help
  exit 1
fi

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Le fichier '${PROMPT_FILE}' n'existe pas.${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 [san_subagent_manager v2.2] Audit cartésien : ${CYAN}${PROMPT_FILE}${NC} (Modèle visé : ${CYAN}${MODEL_TARGET}${NC})"
ERRORS=0
WARNINGS=0

# 1. Contrôle strict de la doctrine Dual-Harness v2.2 (interdiction inherit/flash/3.1-pro/3.8-flash)
case "${MODEL_TARGET}" in
  gemini-4-hydrogen-xhigh|pro|unified-executor)
    echo -e "${GREEN}  ✓ Cible de modèle conforme v2.2 Dual-Harness : '${MODEL_TARGET}'.${NC}"
    ;;
  */*)
    if [[ "${MODEL_TARGET}" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._:-]+$ ]]; then
      echo -e "${GREEN}  ✓ Cible OpenCode V2 conforme Dual-Harness : '${MODEL_TARGET}'.${NC}"
    else
      echo -e "${RED}  ❌ Format provider/model OpenCode invalide : '${MODEL_TARGET}'.${NC}"
      ERRORS=$((ERRORS + 1))
    fi
    ;;
  inherit)
    echo -e "${RED}  ❌ Violation critique : 'inherit' est FORMELLEMENT INTERDIT sur Argon/Carbon (protection du quota hebdomadaire). Utilisez 'gemini-4-hydrogen-xhigh' (swarm) ou .agents/models.json.${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
  flash)
    echo -e "${RED}  ❌ Violation : 'flash' est obsolète (bascule silencieuse vers gemini-3.8-flash-tiered). Utilisez 'gemini-4-hydrogen-xhigh' (swarm), '<provider>/<model>' (OpenCode V2) et 'model: \"pro\"' en YAML.${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
  *)
    echo -e "${RED}  ❌ Modèle cible non reconnu : '${MODEL_TARGET}'. Valeurs acceptées : 'gemini-4-hydrogen-xhigh', 'pro', 'unified-executor' ou '<provider>/<model>'.${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
esac

# 2. Chasse aux modèles obsolètes gemini-3.1-pro-high / gemini-3.8-flash-high
if grep -qiE "gemini-3\.1-pro-high|gemini-3\.8-flash-high" "${PROMPT_FILE}"; then
  echo -e "${RED}  ❌ Modèle obsolète détecté : 'gemini-3.1-pro-high' ou 'gemini-3.8-flash-high' doit être remplacé par 'gemini-4-hydrogen-xhigh'.${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ Zéro référence obsolète (gemini-3.1-pro-high / gemini-3.8-flash-high).${NC}"
fi

# 3. Détection du format : Agent Natif YAML (src/agents/*.md) vs Gabarit de Prompt Fermé
IS_NATIVE_AGENT=0
if [[ "$(head -n 1 "${PROMPT_FILE}")" == "---" ]] && grep -qE "^subagent:[[:space:]]*true" "${PROMPT_FILE}"; then
  IS_NATIVE_AGENT=1
fi

if [[ "${IS_NATIVE_AGENT}" -eq 1 ]]; then
  echo -e "${CYAN}  ℹ Format détecté : Définition d'agent natif Antigravity (YAML + Markdown).${NC}"

  FRONTMATTER=$(awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{exit} f{print}' "${PROMPT_FILE}")
  BODY=$(awk 'BEGIN{d=0} $0=="---"{d++; next} d>=2{print}' "${PROMPT_FILE}")

  # 3a. Champs YAML obligatoires
  for yaml_key in "name:" "description:" "mainAgent:" "subagent:" "model:" "commandExecutionPolicy:" "tools:" "skills:"; do
    if ! echo "${FRONTMATTER}" | grep -qE "^${yaml_key}"; then
      echo -e "${RED}  ❌ Champ frontmatter YAML manquant : '${yaml_key}'${NC}"
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}  ✓ Champ YAML présent : '${yaml_key}'${NC}"
    fi
  done

  # 3b. Frontmatter model doit être "pro" (compat Antigravity CLI) ou "<provider>/<model>" (OpenCode V2)
  FM_MODEL=$(echo "${FRONTMATTER}" | grep -E "^model:" | head -n 1 | sed -E 's/^model:[[:space:]]*["'\'']?([^"'\''[:space:]]+)["'\'']?/\1/' || true)
  if [[ "${FM_MODEL}" != "pro" ]] && [[ ! "${FM_MODEL}" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._:-]+$ ]]; then
    echo -e "${RED}  ❌ Frontmatter YAML 'model' invalide ('${FM_MODEL}') : doit être '\"pro\"' (Antigravity CLI) ou '<provider>/<model>' (OpenCode V2), jamais 'flash' ni 'inherit'.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Frontmatter YAML 'model: \"${FM_MODEL}\"' conforme Dual-Harness.${NC}"
  fi

  # 3c. Présence explicite de gemini-4-hydrogen-xhigh ou .agents/models.json dans le corps de l'agent
  if ! echo "${BODY}" | grep -qE "(gemini-4-hydrogen-xhigh|\.agents/models\.json)"; then
    echo -e "${RED}  ❌ Corps d'agent incomplet : 'gemini-4-hydrogen-xhigh' ou '.agents/models.json' doit être spécifié dans le corps Markdown.${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ Doctrine runtime Dual-Harness vérifiée dans le corps.${NC}"
  fi

  # 3d. Sections structurelles de l'agent natif
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

  # 3e. Garde-fou anti-récursion et reddition
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

  if ! echo "${BODY}" | grep -q "REPO_MAP.md"; then
    echo -e "${YELLOW}  ⚠️ Avertissement : La référence Map-First (REPO_MAP.md) devrait figurer dans l'agent.${NC}"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${GREEN}  ✓ Discipline Map-First vérifiée ('REPO_MAP.md' présent).${NC}"
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

  if ! grep -qiE "(SUCCÈS_TOTAL|SUCCES_TOTAL|BLOCAGE|LIVRABLE|RETOUR_ATELIER)" "${PROMPT_FILE}"; then
    echo -e "${YELLOW}  ⚠️ Avertissement : Les statuts formels de livraison (SUCCÈS_TOTAL / BLOCAGE) devraient être explicités dans le protocole de reddition.${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi

  if grep -qiE "(INPUTS|OUTPUTS)" "${PROMPT_FILE}"; then
    if grep -E '`\./|\.\./' "${PROMPT_FILE}" | grep -qv "file://" 2>/dev/null; then
      echo -e "${YELLOW}  ⚠️ Avertissement : Détection de chemins relatifs suspects (\`./\` ou \`../\`). Privilégiez des chemins absolus ou des URIs file:///.${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# 4. Bilan final
echo "--------------------------------------------------------"
if [[ ${ERRORS} -gt 0 ]]; then
  echo -e "${RED}🚨 [san_subagent_manager] Validation ÉCHOUÉE : ${ERRORS} violation(s) critique(s), ${WARNINGS} avertissement(s).${NC}"
  exit 1
else
  if [[ ${WARNINGS} -gt 0 ]]; then
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification CONFORME (${WARNINGS} avertissement(s) mineur(s)). Prêt pour Dual-Harness (swarm / subagent).${NC}"
  else
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification 100% CONFORME. Prêt pour Dual-Harness (swarm / subagent).${NC}"
  fi
  exit 0
fi
