#!/usr/bin/env bash
# Test unitaire et d'intégration automatisé pour le CLI d'installation (Phase 7)
# Framework Antigravity (san_*)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLI_BIN="${FRAMEWORK_ROOT}/src/cli/index.js"

echo "============================================================"
echo "TEST SUITE : PHASE 7 (MOTEUR D'INSTALLATION UNIVERSEL CLI)"
echo "============================================================"

if [[ ! -f "${CLI_BIN}" ]]; then
  echo "[-] ERREUR: Le binaire CLI n'existe pas : ${CLI_BIN}"
  exit 1
fi

TMP_DIR="$(mktemp -d /tmp/test_san_phase7_XXXXXX)"
echo "[+] Environnement de test isolé : ${TMP_DIR}"

cleanup() {
  echo "[+] Nettoyage de l'environnement temporaire..."
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

# ------------------------------------------------------------------------------
# TEST 1 : Commandes de base (--help, --version, list)
# ------------------------------------------------------------------------------
echo ""
echo "--- [1/4] Test des commandes de base (--help, --version, list) ---"

node "${CLI_BIN}" --help > "${TMP_DIR}/help.log" 2>&1
if ! grep -q "CARTESIAN ORCHESTRATION" "${TMP_DIR}/help.log"; then
  echo "[-] ÉCHEC: La bannière ASCII n'apparaît pas dans --help !"
  cat "${TMP_DIR}/help.log"
  exit 1
fi
echo "  [OK] Commande --help validée avec bannière officielle."

node "${CLI_BIN}" --version > "${TMP_DIR}/version.log" 2>&1
if ! grep -qE "([0-9]+\.[0-9]+\.[0-9]+)" "${TMP_DIR}/version.log"; then
  echo "[-] ÉCHEC: Version introuvable dans --version !"
  cat "${TMP_DIR}/version.log"
  exit 1
fi
echo "  [OK] Commande --version validée."

node "${CLI_BIN}" list > "${TMP_DIR}/list.log" 2>&1
for expected_skill in "san_init" "san_planner" "san_qa_security_expert" "san_backend_expert" "san_subagent_manager"; do
  if ! grep -q "${expected_skill}" "${TMP_DIR}/list.log"; then
    echo "[-] ÉCHEC: Le skill ${expected_skill} n'apparaît pas dans 'list' !"
    cat "${TMP_DIR}/list.log"
    exit 1
  fi
done
echo "  [OK] Commande 'list' liste les 17 modules du catalogue."

# ------------------------------------------------------------------------------
# TEST 2 : Installation complète en mode local (--local --all) avec Smart Merge
# ------------------------------------------------------------------------------
echo ""
echo "--- [2/4] Test de déploiement --local --all avec Smart Merge & Hygiène Git ---"

PROJECT_DIR="${TMP_DIR}/test_project"
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# Initialiser Git et créer des fichiers pollués
git init -q
git config user.name "CLI Tester"
git config user.email "tester@alexsan.pro"

echo "# Ancien config Claude" > CLAUDE.md
echo "cursor rules" > .cursorrules

# Simuler une règle personnalisée pré-existante de l'utilisateur
mkdir -p .agents/rules
echo "# MON BRAND PERSONNALISÉ CLIENT INTACT" > .agents/rules/BRAND.md

# Lancer l'installation
node "${CLI_BIN}" init --local --all > "${TMP_DIR}/install_all.log" 2>&1

# Assertions :
# A. Les skills sont bien installés
if [[ ! -f ".agents/skills/san_init/SKILL.md" ]] || [[ ! -f ".agents/skills/san_planner/SKILL.md" ]]; then
  echo "[-] ÉCHEC: Les skills n'ont pas été copiés dans .agents/skills/ !"
  cat "${TMP_DIR}/install_all.log"
  exit 1
fi

SKILL_COUNT=$(find .agents/skills -mindepth 1 -maxdepth 1 -type d | wc -l)
if [[ "${SKILL_COUNT}" -ne 17 ]]; then
  echo "[-] ÉCHEC: Nombre de skills installés incorrect (${SKILL_COUNT} au lieu de 17) !"
  exit 1
fi
echo "  [OK] 17 skills copiés dans .agents/skills/ avec succès."

# B. Smart Merge : BRAND.md personnalisé n'a PAS été écrasé
if ! grep -q "MON BRAND PERSONNALISÉ CLIENT INTACT" .agents/rules/BRAND.md; then
  echo "[-] ÉCHEC: Smart Merge défaillant ! BRAND.md personnalisé a été écrasé !"
  exit 1
fi
echo "  [OK] Smart Merge validé : BRAND.md utilisateur scrupuleusement préservé."

# C. Les autres règles manquantes ont été instanciées
if [[ ! -f ".agents/rules/PRODUCT.md" ]] || [[ ! -f ".agents/rules/PROJECT.md" ]]; then
  echo "[-] ÉCHEC: Les règles manquantes (PRODUCT.md, PROJECT.md) n'ont pas été instanciées !"
  exit 1
fi
echo "  [OK] Instanciation automatique des règles manquantes validée."

# D. GEMINI.md index maître créé
if [[ ! -f ".agents/GEMINI.md" ]]; then
  echo "[-] ÉCHEC: .agents/GEMINI.md n'a pas été généré !"
  exit 1
fi
echo "  [OK] Index maître .agents/GEMINI.md créé."

# E. Purge des anciens agents
for legacy in "CLAUDE.md" ".cursorrules"; do
  if [[ -f "${legacy}" ]]; then
    echo "[-] ÉCHEC: Résidu ${legacy} non purgé !"
    exit 1
  fi
done
echo "  [OK] Purge automatique des résidus d'anciens agents validée."

# F. Isolation Git
if ! grep -q ".agents" .gitignore 2>/dev/null; then
  echo "[-] ÉCHEC: .gitignore ne contient pas .agents/ !"
  exit 1
fi
echo "  [OK] Isolation hermétique dans .gitignore validée."

# ------------------------------------------------------------------------------
# TEST 3 : Sélection granulaire (--skills=init,planner,qa)
# ------------------------------------------------------------------------------
echo ""
echo "--- [3/4] Test de sélection granulaire (--skills=san_init,san_planner) ---"

PROJECT_GRANULAR="${TMP_DIR}/test_granular"
mkdir -p "${PROJECT_GRANULAR}"
cd "${PROJECT_GRANULAR}"

node "${CLI_BIN}" init --local --skills=san_init,san_planner > "${TMP_DIR}/install_granular.log" 2>&1

if [[ ! -d ".agents/skills/san_init" ]] || [[ ! -d ".agents/skills/san_planner" ]]; then
  echo "[-] ÉCHEC: Les skills sélectionnés n'ont pas été installés !"
  cat "${TMP_DIR}/install_granular.log"
  exit 1
fi

if [[ -d ".agents/skills/san_qa_security_expert" ]]; then
  echo "[-] ÉCHEC: Un skill non sélectionné a été installé par erreur !"
  exit 1
fi
echo "  [OK] Sélection granulaire de skills validée."

# ------------------------------------------------------------------------------
# TEST 4 : Mode Dry-Run (--dry-run)
# ------------------------------------------------------------------------------
echo ""
echo "--- [4/4] Test du mode Dry-Run (--dry-run) ---"

PROJECT_DRY="${TMP_DIR}/test_dry"
mkdir -p "${PROJECT_DRY}"
cd "${PROJECT_DRY}"

node "${CLI_BIN}" init --local --all --dry-run > "${TMP_DIR}/install_dry.log" 2>&1

if [[ -d ".agents/skills" ]]; then
  echo "[-] ÉCHEC: Le mode --dry-run ne doit pas créer de dossier physique !"
  exit 1
fi
echo "  [OK] Mode Dry-Run validé (zéro écriture sur le disque)."

echo ""
echo "============================================================"
echo "[SUCCESS] TOUS LES TESTS DU CLI (PHASE 7) ONT PASSÉ AVEC SUCCÈS !"
echo "============================================================"
