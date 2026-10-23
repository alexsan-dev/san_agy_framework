#!/usr/bin/env bash
# Test unitaire et d'intégration automatisé pour la Phase 5
# Framework Antigravity (san_*)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

FRONT_GATE_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_ux_ui_expert/scripts/front_quality_gate.sh"
BACKEND_GATE_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_backend_expert/scripts/backend_quality_gate.sh"
E2E_GATE_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_executer/scripts/e2e_verification_gate.sh"

echo "============================================================"
echo "TEST SUITE : PHASE 5 (PÔLE CONCEPTION VISUELLE & FULL-STACK)"
echo "============================================================"

TMP_TEST_DIR="$(mktemp -d /tmp/test_san_phase5_XXXXXX)"
echo "[+] Environnement de test isolé : ${TMP_TEST_DIR}"

cleanup() {
  echo "[+] Nettoyage de l'environnement temporaire..."
  rm -rf "${TMP_TEST_DIR}"
}
trap cleanup EXIT

cd "${TMP_TEST_DIR}"

# ------------------------------------------------------------------------------
# TEST 1 : front_quality_gate.sh - Détection d'erreur simulée
# ------------------------------------------------------------------------------
echo ""
echo "--- [1/3] Test de front_quality_gate.sh (Erreur & Succès) ---"

mkdir -p front_dirty front_clean

# A. Cas avec échec simulé (tests unitaires défaillants ou erreur TypeScript)
cat << 'EOF' > front_dirty/package.json
{
  "name": "front-dirty",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'Simulation echec Jest' && exit 1",
    "typecheck": "exit 1"
  }
}
EOF

set +e
(cd "${TMP_TEST_DIR}/front_dirty" && bash "${FRONT_GATE_SCRIPT}") > test_front_dirty.log 2>&1
FRONT_DIRTY_CODE=$?
set -e

if [[ "${FRONT_DIRTY_CODE}" -eq 0 ]]; then
  echo "[-] ÉCHEC: front_quality_gate.sh aurait dû renvoyer un code d'erreur (exit code 1) !"
  cat test_front_dirty.log
  exit 1
fi
echo "  [OK] front_quality_gate.sh rejette correctement une erreur simulée (code: ${FRONT_DIRTY_CODE})."

# B. Cas avec succès
cat << 'EOF' > front_clean/package.json
{
  "name": "front-clean",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'Tests Jest passants' && exit 0"
  }
}
EOF

set +e
(cd "${TMP_TEST_DIR}/front_clean" && bash "${FRONT_GATE_SCRIPT}") > test_front_clean.log 2>&1
FRONT_CLEAN_CODE=$?
set -e

if [[ "${FRONT_CLEAN_CODE}" -ne 0 ]]; then
  echo "[-] ÉCHEC: front_quality_gate.sh aurait dû réussir sur du code propre !"
  cat test_front_clean.log
  exit 1
fi
echo "  [OK] front_quality_gate.sh valide un environnement propre (code: 0)."

# ------------------------------------------------------------------------------
# TEST 2 : backend_quality_gate.sh - Détection d'erreur simulée
# ------------------------------------------------------------------------------
echo ""
echo "--- [2/3] Test de backend_quality_gate.sh (Erreur & Succès) ---"

mkdir -p back_dirty back_clean

# A. Cas d'échec simulé (ex: tests Pest ou PHPStan défaillants)
cat << 'EOF' > back_dirty/composer.json
{
  "name": "test/back-dirty",
  "scripts": {
    "test": "echo 'Simulation echec Pest/PHPUnit' && exit 1",
    "phpstan": "exit 1"
  }
}
EOF

set +e
(cd "${TMP_TEST_DIR}/back_dirty" && bash "${BACKEND_GATE_SCRIPT}") > test_back_dirty.log 2>&1
BACK_DIRTY_CODE=$?
set -e

if [[ "${BACK_DIRTY_CODE}" -eq 0 ]]; then
  echo "[-] ÉCHEC: backend_quality_gate.sh aurait dû renvoyer un code d'erreur (exit code 1) !"
  cat test_back_dirty.log
  exit 1
fi
echo "  [OK] backend_quality_gate.sh rejette correctement une erreur simulée (code: ${BACK_DIRTY_CODE})."

# B. Cas avec succès (stack propre)
cat << 'EOF' > back_clean/composer.json
{
  "name": "test/back-clean",
  "scripts": {
    "test": "echo 'Tests backend passants' && exit 0"
  }
}
EOF

set +e
(cd "${TMP_TEST_DIR}/back_clean" && bash "${BACKEND_GATE_SCRIPT}") > test_back_clean.log 2>&1
BACK_CLEAN_CODE=$?
set -e

if [[ "${BACK_CLEAN_CODE}" -ne 0 ]]; then
  echo "[-] ÉCHEC: backend_quality_gate.sh aurait dû réussir sur du code propre !"
  cat test_back_clean.log
  exit 1
fi
echo "  [OK] backend_quality_gate.sh valide un environnement propre (code: 0)."

# ------------------------------------------------------------------------------
# TEST 3 : e2e_verification_gate.sh - Gate global Full-Stack
# ------------------------------------------------------------------------------
echo ""
echo "--- [3/3] Test de e2e_verification_gate.sh ---"

mkdir -p fullstack_env
cat << 'EOF' > fullstack_env/package.json
{
  "name": "fullstack-clean",
  "scripts": {
    "test": "exit 0"
  }
}
EOF

set +e
(cd "${TMP_TEST_DIR}/fullstack_env" && bash "${E2E_GATE_SCRIPT}") > test_e2e.log 2>&1
E2E_CODE=$?
set -e

if [[ "${E2E_CODE}" -ne 0 ]]; then
  echo "[-] ÉCHEC: e2e_verification_gate.sh a échoué sur un environnement propre !"
  cat test_e2e.log
  exit 1
fi
echo "  [OK] e2e_verification_gate.sh fonctionne de manière coordonnée (code: 0)."

echo ""
echo "============================================================"
echo "[SUCCESS] TOUS LES TESTS DE LA PHASE 5 ONT PASSÉ AVEC SUCCÈS !"
echo "============================================================"
