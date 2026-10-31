#!/usr/bin/env bash
# ==============================================================================
# TEST AUTOMATISÉ : LOT 4A - DURCISSEMENT DES QUALITY GATES FAIL-CLOSED
# Framework : Google Antigravity (@alexsan/agy-framework)
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

QA_SECURITY_GATE="${FRAMEWORK_ROOT}/src/skills/san_qa_security_expert/scripts/qa_security_gate.sh"
BACKEND_GATE="${FRAMEWORK_ROOT}/src/skills/san_backend_expert/scripts/backend_quality_gate.sh"
FRONT_GATE="${FRAMEWORK_ROOT}/src/skills/san_ux_ui_expert/scripts/front_quality_gate.sh"
E2E_GATE="${FRAMEWORK_ROOT}/src/skills/san_executer/scripts/e2e_verification_gate.sh"

ASSERTION_COUNT_DIR="$(mktemp -d)"
touch "${ASSERTION_COUNT_DIR}/passed" "${ASSERTION_COUNT_DIR}/failed"
trap 'rm -rf "$ASSERTION_COUNT_DIR"' EXIT

assert_true() {
  local desc="$1"
  local condition="$2"
  if eval "$condition"; then
    echo -e "${GREEN}✔ ${desc}${NC}"
    echo 1 >> "${ASSERTION_COUNT_DIR}/passed"
  else
    echo -e "${RED}✖ ÉCHEC : ${desc}${NC}"
    echo 1 >> "${ASSERTION_COUNT_DIR}/failed"
  fi
}

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}   TEST SUITE : LOT 4A — HARDENED QUALITY GATES (FAIL-CLOSED)         ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# 1. TEST QA_SECURITY_GATE.SH
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- [1/4] Contrôle de qa_security_gate.sh ---${NC}"

assert_true "qa_security_gate.sh est exécutable" "[ -x '$QA_SECURITY_GATE' ]"
assert_true "--passWithNoTests est formellement supprimé du script" "! grep -q -- '--passWithNoTests' '$QA_SECURITY_GATE'"
assert_true "Détection d'URLs de BDD avec credentials présente" "grep -q 'postgres|postgresql|mysql|mariadb|mongodb|redis' '$QA_SECURITY_GATE'"
assert_true "Détection de webhook secrets Stripe présente" "grep -q 'whsec_' '$QA_SECURITY_GATE'"
assert_true "Détection de clés privées PGP/RSA présente" "grep -q 'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY' '$QA_SECURITY_GATE'"

TMP_QA="$(mktemp -d)"
(
  cd "$TMP_QA"
  # Cas A: Repo vide sans test -> doit échouer (exit 1)
  set +e
  "$QA_SECURITY_GATE" > qa_out1.log 2>&1
  QA_EMPTY_CODE=$?
  set -e
  assert_true "qa_security_gate.sh échoue (code 1) en mode Fail-Closed si aucun test n'existe" "[ '$QA_EMPTY_CODE' -eq 1 ]"
  assert_true "qa_security_gate.sh signale explicitement TESTS_FOUND=0" "grep -q 'TESTS_FOUND=0' qa_out1.log"

  # Cas B: Repo avec secret codé en dur (URL BDD postgres://) -> doit être bloqué
  cat << 'EOF' > config.env
DATABASE_URL=postgres://user_db:SecretP4ss@db.internal:5432/main_db
EOF
  set +e
  "$QA_SECURITY_GATE" > qa_out2.log 2>&1
  QA_SECRET_CODE=$?
  set -e
  assert_true "qa_security_gate.sh bloque (code 1) la présence d'une URL de BDD postgres://" "[ '$QA_SECRET_CODE' -eq 1 ]"
  assert_true "Alerte de sécurité explicite sur les credentials" "grep -q 'ALERTE SÉCURITÉ' qa_out2.log"
  rm config.env

  # Cas B.2: Repo avec secret canonique postgresql:// -> doit être bloqué
  cat << 'EOF' > config_pg.env
DATABASE_URL=postgresql://user:secret@localhost:5432/mydb
EOF
  set +e
  "$QA_SECURITY_GATE" > qa_out_pg.log 2>&1
  QA_PG_CODE=$?
  set -e
  assert_true "qa_security_gate.sh bloque (code 1) la présence d'une URL de BDD postgresql:// avec secret" "[ '$QA_PG_CODE' -eq 1 ]"
  rm config_pg.env

  # Cas C: Repo avec test npm passant
  cat << 'EOF' > package.json
{
  "name": "test-pkg",
  "scripts": { "test": "exit 0" }
}
EOF
  set +e
  "$QA_SECURITY_GATE" > qa_out3.log 2>&1
  QA_PASS_CODE=$?
  set -e
  assert_true "qa_security_gate.sh valide avec succès (code 0) un repo propre avec un test réel" "[ '$QA_PASS_CODE' -eq 0 ]"
)
rm -rf "$TMP_QA"

# ------------------------------------------------------------------------------
# 2. TEST BACKEND_QUALITY_GATE.SH
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- [2/4] Contrôle de backend_quality_gate.sh ---${NC}"

assert_true "backend_quality_gate.sh est exécutable" "[ -x '$BACKEND_GATE' ]"
assert_true "Éradication du faux succès 0/4 au vert" "! grep -q 'ÉTAPES AU VERT' '$BACKEND_GATE' | grep -v 'TOTAL_CHECKS'"
assert_true "Contrôle d'hygiène architecturale présent" "grep -q 'check_architectural_hygiene' '$BACKEND_GATE'"
assert_true "Détection de fichiers monolithiques (>300 lignes)" "grep -q '300' '$BACKEND_GATE'"
assert_true "Détection de declare(strict_types=1)" "grep -q 'declare(strict_types=1)' '$BACKEND_GATE'"

TMP_BACK="$(mktemp -d)"
(
  cd "$TMP_BACK"
  # Cas A: Aucune stack backend -> Rejet immédiat (code 1)
  set +e
  "$BACKEND_GATE" > back_out1.log 2>&1
  BACK_EMPTY_CODE=$?
  set -e
  assert_true "backend_quality_gate.sh échoue (code 1) si aucune stack backend n'est détectée" "[ '$BACK_EMPTY_CODE' -eq 1 ]"

  # Cas B: PHP Laravel / Composer propre
  mkdir php_app && cd php_app
  cat << 'EOF' > composer.json
{
  "name": "test/php-app",
  "scripts": { "test": "exit 0" }
}
EOF
  set +e
  "$BACKEND_GATE" > back_out2.log 2>&1
  BACK_PHP_CODE=$?
  set -e
  assert_true "backend_quality_gate.sh valide une stack PHP avec suite de tests (code 0)" "[ '$BACK_PHP_CODE' -eq 0 ]"
  assert_true "Affichage du succès avec nombre d'étapes > 0" "grep -q 'QUALITY GATE BACKEND VALIDÉ AVEC SUCCÈS' back_out2.log"
  cd ..

  # Cas C: Node/TS Express propre
  mkdir node_app && cd node_app
  cat << 'EOF' > package.json
{
  "name": "test-express",
  "dependencies": { "express": "^4.18.0" },
  "scripts": { "test": "exit 0" }
}
EOF
  set +e
  "$BACKEND_GATE" > back_out3.log 2>&1
  BACK_NODE_CODE=$?
  set -e
  assert_true "backend_quality_gate.sh valide une stack Node Backend avec tests (code 0)" "[ '$BACK_NODE_CODE' -eq 0 ]"
  cd ..

  # Cas D: Python pyproject.toml propre
  mkdir py_app && cd py_app
  cat << 'EOF' > pyproject.toml
[project]
name = "test-python"
EOF
  cat << 'EOF' > test_main.py
import unittest
class MainTest(unittest.TestCase):
    def test_ok(self): pass
EOF
  set +e
  "$BACKEND_GATE" > back_out4.log 2>&1
  BACK_PY_CODE=$?
  set -e
  assert_true "backend_quality_gate.sh valide une stack Python avec suite de tests (code 0)" "[ '$BACK_PY_CODE' -eq 0 ]"
  cd ..
)
rm -rf "$TMP_BACK"

# ------------------------------------------------------------------------------
# 3. TEST FRONT_QUALITY_GATE.SH
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- [3/4] Contrôle de front_quality_gate.sh ---${NC}"

assert_true "front_quality_gate.sh est exécutable" "[ -x '$FRONT_GATE' ]"
assert_true "Suppression du '|| true' étouffant l'audit npm/pnpm" "! grep -q 'audit --audit-level=high 2>/dev/null || true' '$FRONT_GATE'"
assert_true "Scan de fuites mémoires ciblé sur useEffect" "grep -q 'useEffectHeaderRegex' '$FRONT_GATE'"
assert_true "Détection de composant monolithique (>300 lignes)" "grep -q '300' '$FRONT_GATE'"
assert_true "Détection des div onClick inaccessibles" "grep -q 'onClick' '$FRONT_GATE'"

TMP_FRONT="$(mktemp -d)"
(
  cd "$TMP_FRONT"
  # Cas A: Fuite mémoire dans useEffect (addEventListener orphelin) -> rejet (code 1)
  mkdir -p leak_app/src
  cat << 'EOF' > leak_app/package.json
{ "name": "leak-app", "scripts": { "test": "exit 0" } }
EOF
  cat << 'EOF' > leak_app/src/Leak.tsx
import React, { useEffect } from "react";
export function Leak() {
  useEffect(() => {
    window.addEventListener("resize", () => {});
  }, []);
  return <div>Leak</div>;
}
EOF
  set +e
  (cd leak_app && "$FRONT_GATE") > front_out1.log 2>&1
  FRONT_LEAK_CODE=$?
  set -e
  assert_true "front_quality_gate.sh rejette (code 1) un composant avec useEffect sans fonction de retour" "[ '$FRONT_LEAK_CODE' -eq 1 ]"
  assert_true "Alerte explicite sur le listener sans cleanup" "grep -q 'Fuite mémoire potentielle' front_out1.log"

  # Cas B: Composant avec cleanup valide -> succès (code 0)
  mkdir -p clean_app/src
  cat << 'EOF' > clean_app/package.json
{ "name": "clean-app", "scripts": { "test": "exit 0" } }
EOF
  cat << 'EOF' > clean_app/src/Clean.tsx
import React, { useEffect } from "react";
export function Clean() {
  useEffect(() => {
    const handle = () => {};
    window.addEventListener("resize", handle);
    return () => window.removeEventListener("resize", handle);
  }, []);
  return <button type="button" onClick={() => {}}>OK</button>;
}
EOF
  set +e
  (cd clean_app && "$FRONT_GATE") > front_out2.log 2>&1
  FRONT_CLEAN_CODE=$?
  set -e
  assert_true "front_quality_gate.sh valide un composant avec cleanup conforme (code 0)" "[ '$FRONT_CLEAN_CODE' -eq 0 ]"

  # Cas C: Projet avec code UI sans script de test -> échec (code 1) Fail-Closed
  mkdir -p notest_app/src
  cat << 'EOF' > notest_app/package.json
{ "name": "notest-app" }
EOF
  cat << 'EOF' > notest_app/src/Button.tsx
export function Button() { return <button>Click</button>; }
EOF
  set +e
  (cd notest_app && "$FRONT_GATE") > front_out3.log 2>&1
  FRONT_NOTEST_CODE=$?
  set -e
  assert_true "front_quality_gate.sh échoue (code 1) sur projet UI sans script de test" "[ '$FRONT_NOTEST_CODE' -eq 1 ]"
  assert_true "Message d'erreur Fail-Closed explicite sur l'absence de tests" "grep -q 'FAIL-CLOSED.*Aucun script de test configuré' front_out3.log"

  # Cas D: Dossier vide -> échec (code 1) Fail-Closed (TOTAL_CHECKS == 0)
  mkdir -p empty_app
  set +e
  (cd empty_app && "$FRONT_GATE") > front_out4.log 2>&1
  FRONT_EMPTY_CODE=$?
  set -e
  assert_true "front_quality_gate.sh échoue (code 1) sur dossier vide sans contrôle (Fail-Closed)" "[ '$FRONT_EMPTY_CODE' -eq 1 ]"
  assert_true "Message explicite TOTAL_CHECKS == 0 sur dossier vide" "grep -q 'TOTAL_CHECKS == 0' front_out4.log"

  # Cas E: useEffect sans tableau de dépendances avec listener orphelin -> rejet (code 1)
  mkdir -p nodeps_app/src
  cat << 'EOF' > nodeps_app/package.json
{ "name": "nodeps-app", "scripts": { "test": "exit 0" } }
EOF
  cat << 'EOF' > nodeps_app/src/NoDeps.tsx
import React, { useEffect } from "react";
export function NoDeps() {
  useEffect(() => {
    window.addEventListener("scroll", () => {});
  });
  return <div>NoDeps</div>;
}
EOF
  set +e
  (cd nodeps_app && "$FRONT_GATE") > front_out5.log 2>&1
  FRONT_NODEPS_CODE=$?
  set -e
  assert_true "front_quality_gate.sh détecte fuite useEffect sans tableau de dépendances (code 1)" "[ '$FRONT_NODEPS_CODE' -eq 1 ]"

  # Cas F: useEffect avec fonction nommée en cleanup (return cleanup;) -> succès (code 0)
  mkdir -p named_cleanup_app/src
  cat << 'EOF' > named_cleanup_app/package.json
{ "name": "named-cleanup-app", "scripts": { "test": "exit 0" } }
EOF
  cat << 'EOF' > named_cleanup_app/src/NamedCleanup.tsx
import React, { useEffect } from "react";
export function NamedCleanup() {
  useEffect(() => {
    const handle = () => {};
    window.addEventListener("resize", handle);
    const cleanup = () => window.removeEventListener("resize", handle);
    return cleanup;
  }, []);
  return <div>Named</div>;
}
EOF
  set +e
  (cd named_cleanup_app && "$FRONT_GATE") > front_out6.log 2>&1
  FRONT_NAMED_CODE=$?
  set -e
  assert_true "front_quality_gate.sh valide un useEffect avec return cleanup; (code 0)" "[ '$FRONT_NAMED_CODE' -eq 0 ]"

  # Cas G: Anti-pattern useEffect(async () => ...) -> rejet (code 1)
  mkdir -p async_app/src
  cat << 'EOF' > async_app/package.json
{ "name": "async-app", "scripts": { "test": "exit 0" } }
EOF
  cat << 'EOF' > async_app/src/AsyncEffect.tsx
import React, { useEffect } from "react";
export function AsyncEffect() {
  useEffect(async () => {
    console.log("Async effect not allowed");
  }, []);
  return <div>Async</div>;
}
EOF
  set +e
  (cd async_app && "$FRONT_GATE") > front_out7.log 2>&1
  FRONT_ASYNC_CODE=$?
  set -e
  assert_true "front_quality_gate.sh bloque l'anti-pattern useEffect(async () => ...) (code 1)" "[ '$FRONT_ASYNC_CODE' -eq 1 ]"
  assert_true "Alerte explicite sur le callback async" "grep -q 'Anti-pattern critique.*callback async' front_out7.log"
)
rm -rf "$TMP_FRONT"

# ------------------------------------------------------------------------------
# 4. TEST E2E_VERIFICATION_GATE.SH
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- [4/4] Contrôle de e2e_verification_gate.sh ---${NC}"

assert_true "e2e_verification_gate.sh est exécutable" "[ -x '$E2E_GATE' ]"
assert_true "Statut STATIC_ONLY_UNVERIFIED géré" "grep -q 'STATIC_ONLY_UNVERIFIED' '$E2E_GATE'"
assert_true "Exigence d'une suite réelle de tests d'intégration API" "grep -q 'Fin du Testing Theater' '$E2E_GATE'"

TMP_E2E="$(mktemp -d)"
(
  cd "$TMP_E2E"
  # Cas A: Bruno présent sans bru CLI et sans tests backend -> Échec (code 1) Fail-Closed
  mkdir -p bruno_alone/bruno
  cat << 'EOF' > bruno_alone/bruno/test.bru
meta {
  name: Test API
  type: http
  seq: 1
}
get {
  url: https://api.local/health
}
EOF
  set +e
  (cd bruno_alone && "$E2E_GATE") > e2e_out1.log 2>&1
  E2E_SOLO_CODE=$?
  set -e
  assert_true "e2e_verification_gate.sh refuse (code 1) de décerner un PASS sur du simple grep Bruno sans exécution" "[ '$E2E_SOLO_CODE' -eq 1 ]"
  assert_true "e2e_verification_gate.sh affiche le statut STATIC_ONLY_UNVERIFIED" "grep -q 'STATIC_ONLY_UNVERIFIED' e2e_out1.log"

  # Cas B: Bruno présent sans bru CLI MAIS avec suite réelle d'intégration backend passante -> PASS (code 0)
  mkdir -p bruno_backed/bruno
  cat << 'EOF' > bruno_backed/bruno/test.bru
meta {
  name: Test API
  type: http
  seq: 1
}
get {
  url: https://api.local/health
}
EOF
  cat << 'EOF' > bruno_backed/composer.json
{
  "name": "api/service",
  "scripts": { "test": "exit 0" }
}
EOF
  set +e
  (cd bruno_backed && "$E2E_GATE") > e2e_out2.log 2>&1
  E2E_BACKED_CODE=$?
  set -e
  assert_true "e2e_verification_gate.sh valide les contrats d'API via la suite d'intégration backend (code 0)" "[ '$E2E_BACKED_CODE' -eq 0 ]"

  # Cas C: Dossier vide / aucun check réel (tout SKIPPED) -> Échec (code 1) Fail-Closed
  mkdir -p empty_e2e
  set +e
  (cd empty_e2e && "$E2E_GATE") > e2e_out3.log 2>&1
  E2E_EMPTY_CODE=$?
  set -e
  assert_true "e2e_verification_gate.sh échoue (code 1) en Fail-Closed si aucun check n'est exécuté (CHECKS_RUN == 0)" "[ '$E2E_EMPTY_CODE' -eq 1 ]"
  assert_true "e2e_verification_gate.sh signale CHECKS_RUN == 0" "grep -q 'CHECKS_RUN == 0' e2e_out3.log"
)
rm -rf "$TMP_E2E"

# ------------------------------------------------------------------------------
# SYNTHÈSE DES RÉSULTATS
# ------------------------------------------------------------------------------
PASSED_ASSERTIONS=$(wc -l < "${ASSERTION_COUNT_DIR}/passed" 2>/dev/null || echo 0)
FAILED_ASSERTIONS=$(wc -l < "${ASSERTION_COUNT_DIR}/failed" 2>/dev/null || echo 0)

echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${BOLD}RÉSULTATS DE LA SUITE DE TEST LOT 4A : QUALITY GATES FAIL-CLOSED${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "  Assertions réussies : ${GREEN}${PASSED_ASSERTIONS}${NC}"
echo -e "  Assertions échouées : ${RED}${FAILED_ASSERTIONS}${NC}"
echo -e "${BLUE}======================================================================${NC}"

if [ "$FAILED_ASSERTIONS" -gt 0 ]; then
  echo -e "${RED}${BOLD}✖ ÉCHEC : Certaines assertions ne sont pas satisfaites.${NC}"
  exit 1
fi

echo -e "${GREEN}${BOLD}✔ 🎉 100% DES ASSERTIONS DU LOT 4A SONT AU VERT ! SUCCÈS TOTAL.${NC}"
exit 0
