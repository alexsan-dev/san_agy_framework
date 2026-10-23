#!/usr/bin/env bash
# scripts/validate_subagent_spec.sh
# Validation déterministe et cartésienne de la structure d'un prompt système de sous-agent Antigravity (san_*).
# Usage: ./validate_subagent_spec.sh <path/to/prompt.md> [flash|inherit]
# Options:
#   -h, --help    Affiche l'aide et quitte

set -euo pipefail

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
  cat << 'EOF'
Usage: validate_subagent_spec.sh <PROMPT_FILE> [MODEL_TARGET]

Arguments:
  PROMPT_FILE     Chemin vers le fichier Markdown contenant le prompt du sous-agent.
  MODEL_TARGET    Modèle alloué au sous-agent : 'flash' (défaut) ou 'inherit'.

Exemples:
  ./validate_subagent_spec.sh templates/SUBAGENT_PROMPT_TEMPLATE.md flash
  ./validate_subagent_spec.sh path/to/auditor_prompt.md inherit

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

PROMPT_FILE="${1:-}"
MODEL_TARGET="${2:-flash}"

if [[ -z "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Fichier de prompt non spécifié.${NC}"
  show_help
  exit 1
fi

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo -e "${RED}❌ Erreur : Le fichier '${PROMPT_FILE}' n'existe pas.${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 [san_subagent_manager] Audit cartésien du prompt : ${CYAN}${PROMPT_FILE}${NC} (Modèle visé : ${CYAN}${MODEL_TARGET}${NC})"
ERRORS=0
WARNINGS=0

# 1. Vérification des sections obligatoires (6 sections directives + reddition)
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

# 2. Vérification de l'interdiction formelle des outils récursifs (invoke_subagent / define_subagent)
if ! grep -qi "invoke_subagent" "${PROMPT_FILE}"; then
  echo -e "${RED}  ❌ Garde-fou manquant : L'interdiction formelle de 'invoke_subagent' doit figurer dans CONSTRAINTS.${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ Règle anti-récursion vérifiée ('invoke_subagent' mentionné).${NC}"
fi

# 3. Vérification du protocole de reddition par send_message
if ! grep -qi "send_message" "${PROMPT_FILE}"; then
  echo -e "${RED}  ❌ Protocole de reddition incomplet : L'instruction explicite d'utiliser 'send_message' est absente.${NC}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ Canal de reddition vérifié ('send_message' présent).${NC}"
fi

# 4. Vérification des statuts formels de reddition
if ! grep -qiE "(SUCCÈS_TOTAL|SUCCES_TOTAL|BLOCAGE)" "${PROMPT_FILE}"; then
  echo -e "${YELLOW}  ⚠️ Avertissement : Les statuts formels de livraison (SUCCÈS_TOTAL / BLOCAGE) devraient être explicités dans le protocole de reddition.${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 5. Détection des chemins relatifs vagues (Privilégier chemins absolus ou URI file:///)
if grep -qiE "(INPUTS|OUTPUTS)" "${PROMPT_FILE}"; then
  if grep -E '`\./|\.\./' "${PROMPT_FILE}" | grep -qv "file://" 2>/dev/null; then
    echo -e "${YELLOW}  ⚠️ Avertissement : Détection de chemins relatifs suspects (\`./\` ou \`../\`). Privilégiez des chemins absolus ou des URIs file:///.${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# 6. Vérification cartésienne de l'attribution du modèle (flash vs inherit)
case "${MODEL_TARGET}" in
  inherit)
    if grep -qiE "(écris le contrôleur|implémente la migration|code le composant|écris la vue)" "${PROMPT_FILE}"; then
      echo -e "${RED}  ❌ Violation de routage de modèle : Un sous-agent d'implémentation de code pur NE DOIT JAMAIS tourner sous 'Model: inherit'. Utilisez 'Model: flash'.${NC}"
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}  ✓ Cohérence de modèle 'inherit' validée pour mission d'audit, de recherche ou d'architecture.${NC}"
    fi
    ;;
  flash)
    if grep -qiE "(audit de sécurité owasp|pentest complet approfondi|arbitrage architectural majeur)" "${PROMPT_FILE}"; then
      echo -e "${YELLOW}  ⚠️ Avertissement de routage : Une mission d'audit de sécurité ou d'arbitrage architectural critique devrait être assignée à 'Model: inherit'.${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${GREEN}  ✓ Cohérence de modèle 'flash' validée pour exécution atomique déterministe.${NC}"
    fi
    ;;
  *)
    echo -e "${RED}  ❌ Modèle cible non reconnu : '${MODEL_TARGET}'. Les valeurs acceptées sont 'flash' ou 'inherit'.${NC}"
    ERRORS=$((ERRORS + 1))
    ;;
esac

# 7. Bilan final
echo "--------------------------------------------------------"
if [[ ${ERRORS} -gt 0 ]]; then
  echo -e "${RED}🚨 [san_subagent_manager] Validation ÉCHOUÉE : ${ERRORS} violation(s) critique(s), ${WARNINGS} avertissement(s).${NC}"
  exit 1
else
  if [[ ${WARNINGS} -gt 0 ]]; then
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification CONFORME (${WARNINGS} avertissement(s) mineur(s)). Prêt pour invoke_subagent.${NC}"
  else
    echo -e "${GREEN}✅ [san_subagent_manager] Spécification 100% CONFORME. Prêt pour invoke_subagent.${NC}"
  fi
  exit 0
fi
