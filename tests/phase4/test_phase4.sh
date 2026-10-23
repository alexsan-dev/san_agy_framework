#!/usr/bin/env bash
# Test unitaire et d'intégration automatisé pour la Phase 4
# Framework Antigravity (san_*)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CHECK_LOREM_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_copywriter/scripts/check_lorem.sh"
BUILD_TOKENS_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_design_tokens/scripts/build_tokens.mjs"
CHANGELOG_HELPER_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_doc_keeper/scripts/changelog_helper.sh"
AUDIT_MAGIC_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_design_tokens/scripts/audit_magic_values.sh"
VALIDATE_SUBAGENT_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_subagent_manager/scripts/validate_subagent_spec.sh"

echo "============================================================"
echo "TEST SUITE : PHASE 4 (SOUS-SKILLS D'EXÉCUTION PACKAGÉS)"
echo "============================================================"

TMP_TEST_DIR="$(mktemp -d /tmp/test_san_phase4_XXXXXX)"
echo "[+] Environnement de test isolé : ${TMP_TEST_DIR}"

cleanup() {
  echo "[+] Nettoyage de l'environnement temporaire..."
  rm -rf "${TMP_TEST_DIR}"
}
trap cleanup EXIT

cd "${TMP_TEST_DIR}"

# ------------------------------------------------------------------------------
# TEST 1 : check_lorem.sh
# ------------------------------------------------------------------------------
echo ""
echo "--- [1/4] Test de check_lorem.sh ---"

mkdir -p src_lorem_dirty src_lorem_clean

# A. Cas avec faux texte
cat << 'EOF' > src_lorem_dirty/Page.tsx
import React from 'react';
export const Page = () => {
  return <div>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</div>;
};
EOF

set +e
bash "${CHECK_LOREM_SCRIPT}" --dir "${TMP_TEST_DIR}/src_lorem_dirty" > test_lorem_dirty.log 2>&1
LOREM_DIRTY_CODE=$?
set -e

if [[ "${LOREM_DIRTY_CODE}" -eq 0 ]]; then
  echo "[-] ÉCHEC: check_lorem.sh aurait dû détecter le faux texte et renvoyer code non nul !"
  cat test_lorem_dirty.log
  exit 1
fi
echo "  [OK] Détection stricte du Lorem Ipsum validée (exit code: ${LOREM_DIRTY_CODE})."

# B. Cas sans faux texte (texte réel et propre)
cat << 'EOF' > src_lorem_clean/Page.tsx
import React from 'react';
export const Page = () => {
  return <div>Bienvenue sur votre tableau de bord financier. Solde disponible : 25 000 FCFA.</div>;
};
EOF

set +e
bash "${CHECK_LOREM_SCRIPT}" --dir "${TMP_TEST_DIR}/src_lorem_clean" > test_lorem_clean.log 2>&1
LOREM_CLEAN_CODE=$?
set -e

if [[ "${LOREM_CLEAN_CODE}" -ne 0 ]]; then
  echo "[-] ÉCHEC: check_lorem.sh aurait dû réussir sur du code sans faux texte !"
  cat test_lorem_clean.log
  exit 1
fi
echo "  [OK] Code propre validé avec succès sans faux positif (exit code: 0)."

# ------------------------------------------------------------------------------
# TEST 2 : build_tokens.mjs
# ------------------------------------------------------------------------------
echo ""
echo "--- [2/4] Test de build_tokens.mjs ---"

cat << 'EOF' > test_brand.md
# Brand Guidelines & Design Tokens

## Palette de Couleurs
- `--color-primary`: `#0066FF`
- `--color-surface`: `#0F172A`
- `--color-on-surface`: `#F8FAFC`
- `--color-accent`: `#10B981`
- `--color-error`: `#EF4444`

## Espacement
- `--space-1`: `4px`
- `--space-2`: `8px`
- `--space-4`: `16px`
- `--space-6`: `24px`

## Rayons de courbure
- `--radius-sm`: `4px`
- `--radius-md`: `8px`
- `--radius-lg`: `16px`
EOF

mkdir -p tokens_output

node "${BUILD_TOKENS_SCRIPT}" --input test_brand.md --out-dir tokens_output --format all > test_build_tokens.log 2>&1

if [[ ! -f "tokens_output/tokens.css" ]] && [[ ! -f "tokens_output/theme.css" ]]; then
  echo "[-] ÉCHEC: build_tokens.mjs n'a pas généré de fichier CSS !"
  cat test_build_tokens.log
  exit 1
fi

if [[ ! -f "tokens_output/tokens.ts" ]] && [[ ! -f "tokens_output/tokens.js" ]]; then
  echo "[-] ÉCHEC: build_tokens.mjs n'a pas généré de fichier TS/JS !"
  cat test_build_tokens.log
  exit 1
fi

echo "  [OK] Compilation réussie des tokens vers CSS et TypeScript."

# ------------------------------------------------------------------------------
# TEST 3 : audit_magic_values.sh
# ------------------------------------------------------------------------------
echo ""
echo "--- [3/4] Test de audit_magic_values.sh ---"

mkdir -p src_magic_dirty src_magic_clean

cat << 'EOF' > src_magic_dirty/BadComponent.tsx
export const Bad = () => <div style={{ color: '#FF00AA', margin: '13px' }}>Magique</div>;
EOF

cat << 'EOF' > src_magic_clean/GoodComponent.tsx
export const Good = () => <div className="text-primary p-4">Conforme aux tokens</div>;
EOF

set +e
bash "${AUDIT_MAGIC_SCRIPT}" --dir "${TMP_TEST_DIR}/src_magic_dirty" > test_magic_dirty.log 2>&1
MAGIC_DIRTY_CODE=$?
set -e

if [[ "${MAGIC_DIRTY_CODE}" -eq 0 ]]; then
  echo "[-] ÉCHEC: audit_magic_values.sh aurait dû détecter les valeurs magiques en dur !"
  cat test_magic_dirty.log
  exit 1
fi
echo "  [OK] Détection stricte des valeurs magiques en dur (code: ${MAGIC_DIRTY_CODE})."

# ------------------------------------------------------------------------------
# TEST 4 : changelog_helper.sh
# ------------------------------------------------------------------------------
echo ""
echo "--- [4/4] Test de changelog_helper.sh ---"

cat << 'EOF' > test_CHANGELOG.md
# CHANGELOG

## [Unreleased]

### Added

## [0.1.0] - 2026-10-23
### Added
- Initial release
EOF

bash "${CHANGELOG_HELPER_SCRIPT}" --file test_CHANGELOG.md --type Added --desc "Nouvelle fonctionnalite testee" > test_changelog.log 2>&1

if ! grep -q "Nouvelle fonctionnalite testee" test_CHANGELOG.md; then
  echo "[-] ÉCHEC: L'entrée de changelog n'a pas été insérée dans test_CHANGELOG.md !"
  cat test_CHANGELOG.md
  exit 1
fi
echo "  [OK] Insertion automatisée Keep a Changelog validée."

echo ""
echo "============================================================"
echo "[SUCCESS] TOUS LES TESTS DE LA PHASE 4 ONT PASSÉ AVEC SUCCÈS !"
echo "============================================================"
