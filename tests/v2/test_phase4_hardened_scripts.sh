#!/usr/bin/env bash
# ==============================================================================
# TEST SUITE : PHASE 4 — DURCISSEMENT CHIRURGICAL DES SCRIPTS & QUALITY GATES
# ==============================================================================
# Banc d'essai automatisé vérifiant l'éradication absolue du "Testing Theater" :
# (a) qa_security_gate.sh : fail-closed sur repo sans test & détection secrets BDD
# (b) backend_quality_gate.sh : fail-closed si 0 check & multi-stacks valides
# (c) front_quality_gate.sh : zéro || true, détection fuites useEffect & A11y
# (d) detect_stack_versions.sh --json : sortie JSON 100% parseable
# (e) score_idea.py --profile : élimination des faux vetoes 3G/MoMo hors emerging_market
# (f) git_ai_hygiene.sh : archivage réversible dans .agents/backups/ & sanctuaire AGENTS.md
# (g) build_tokens.mjs --strict : blocage sur mauvais contraste WCAG
# (h) check_lorem.sh : blocage lorem ipsum & tolérance placeholders réels / toto
# (i) DevOps & Légal : zéro alexsan.pro en dur, workflow CI propre sans .agents/
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PASSED_TESTS=0
FAILED_TESTS=0
TMP_WORKSPACES=()

cleanup() {
  for dir in "${TMP_WORKSPACES[@]}"; do
    if [ -d "$dir" ]; then
      rm -rf "$dir"
    fi
  done
}
trap cleanup EXIT

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
echo "  TEST PHASE 4 : DURCISSEMENT DES SCRIPTS, GATES & TEMPLATES (V2.0)"
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# 1. TEST SUITE (a) : qa_security_gate.sh (Fail-Closed & Secret Scanning BDD)
# ------------------------------------------------------------------------------
info "1. Test qa_security_gate.sh (Fail-Closed sans test & Secrets BDD)"

QA_GATE="${ROOT_DIR}/src/skills/san_qa_security_expert/scripts/qa_security_gate.sh"
assert_true "qa_security_gate.sh existe et est exécutable" '[ -x "${QA_GATE}" ]'

# (a.1) Échec strict si aucun test n'existe dans le projet (Plus de --passWithNoTests)
TMP_EMPTY=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_EMPTY")
(
  cd "$TMP_EMPTY"
  git init -q
  # Création d'un package.json sans suite de tests
  echo '{"name": "test-notest", "version": "1.0.0"}' > package.json
)
QA_OUTPUT_EMPTY=$(cd "$TMP_EMPTY" && bash "${QA_GATE}" 2>&1 || true)
assert_true "qa_security_gate.sh échoue (exit 1) sur repo sans test (Fail-Closed)" \
  '(cd "$TMP_EMPTY" && ! bash "${QA_GATE}" >/dev/null 2>&1)'
assert_true "qa_security_gate.sh signale l'absence de tests automatisés" \
  'echo "$QA_OUTPUT_EMPTY" | grep -qiE "aucun test|0 test|échec|anomalie"'

# (a.2) Détection des URLs BDD avec mot de passe (postgres://user:pass@host/db)
TMP_SECRET=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_SECRET")
(
  cd "$TMP_SECRET"
  git init -q
  echo 'DATABASE_URL="postgres://admin:superSecretPass42@db.internal.corp:5432/production"' > config.env
  echo '{"name": "test-sec", "scripts": {"test": "exit 0"}}' > package.json
)
QA_OUTPUT_SECRET=$(cd "$TMP_SECRET" && bash "${QA_GATE}" 2>&1 || true)
assert_true "qa_security_gate.sh détecte une URL BDD contenant un mot de passe" \
  'echo "$QA_OUTPUT_SECRET" | grep -qiE "secret|base de données|database|anomalie"'

# (a.3) Détection des URLs canoniques postgresql:// (Prisma/Supabase/SQLAlchemy)
TMP_SECRET_PG=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_SECRET_PG")
(
  cd "$TMP_SECRET_PG"
  git init -q
  echo 'DATABASE_URL="postgresql://user:secret@localhost:5432/mydb"' > config.env
  echo '{"name": "test-sec-pg", "scripts": {"test": "exit 0"}}' > package.json
)
QA_OUTPUT_SECRET_PG=$(cd "$TMP_SECRET_PG" && bash "${QA_GATE}" 2>&1 || true)
assert_true "qa_security_gate.sh bloque une URL postgresql:// avec mot de passe" \
  'echo "$QA_OUTPUT_SECRET_PG" | grep -qiE "secret|base de données|database|anomalie"'

# ------------------------------------------------------------------------------
# 2. TEST SUITE (b) : backend_quality_gate.sh (Fail-Closed & Multi-Stacks)
# ------------------------------------------------------------------------------
info "2. Test backend_quality_gate.sh (Fail-Closed si 0 check & Multi-Stacks)"

BACKEND_GATE="${ROOT_DIR}/src/skills/san_backend_expert/scripts/backend_quality_gate.sh"
assert_true "backend_quality_gate.sh existe et est exécutable" '[ -x "${BACKEND_GATE}" ]'

# (b.1) Échec si aucune stack ou 0 check exécuté
TMP_NOSTACK=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_NOSTACK")
assert_true "backend_quality_gate.sh échoue sur répertoire vide (Fail-Closed)" \
  '(cd "$TMP_NOSTACK" && ! bash "${BACKEND_GATE}" >/dev/null 2>&1)'

# (b.2) Succès sur mini-projet Python valide (pytest)
TMP_PY=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_PY")
(
  cd "$TMP_PY"
  echo '[project]' > pyproject.toml
  echo 'name = "mini-py"' >> pyproject.toml
  echo 'version = "0.1.0"' >> pyproject.toml
  mkdir -p tests
  echo 'def test_nominal(): assert 1 + 1 == 2' > tests/test_math.py
)
if command -v pytest >/dev/null 2>&1; then
  assert_true "backend_quality_gate.sh valide un mini-projet Python avec tests" \
    '(cd "$TMP_PY" && bash "${BACKEND_GATE}" >/dev/null 2>&1)'
else
  info "pytest non installé dans le PATH de test, validation structurelle Python du script"
  assert_true "backend_quality_gate.sh contient la logique Python (pytest/ruff)" \
    'grep -q "STACK=\"PYTHON\"" "${BACKEND_GATE}"'
fi

# (b.3) Succès sur mini-projet Go valide
TMP_GO=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_GO")
(
  cd "$TMP_GO"
  echo 'module example.com/minigo' > go.mod
  echo 'go 1.22' >> go.mod
  cat << 'EOF' > main.go
package main
func Add(a, b int) int { return a + b }
func main() {}
EOF
  cat << 'EOF' > main_test.go
package main
import "testing"
func TestAdd(t *testing.T) {
    if Add(2, 3) != 5 { t.Fail() }
}
EOF
)
if command -v go >/dev/null 2>&1; then
  assert_true "backend_quality_gate.sh valide un mini-projet Go avec tests" \
    '(cd "$TMP_GO" && bash "${BACKEND_GATE}" >/dev/null 2>&1)'
else
  info "Go non installé dans le PATH de test, validation structurelle Go du script"
  assert_true "backend_quality_gate.sh contient la logique Go (go.mod / go test)" \
    'grep -q "STACK=\"GOLANG\"" "${BACKEND_GATE}"'
fi

# ------------------------------------------------------------------------------
# 3. TEST SUITE (c) : front_quality_gate.sh (Accessibilité, Fuites & Suppression || true)
# ------------------------------------------------------------------------------
info "3. Test front_quality_gate.sh (Contrôle A11y, fuites useEffect & zéro || true)"

FRONT_GATE="${ROOT_DIR}/src/skills/san_ux_ui_expert/scripts/front_quality_gate.sh"
assert_true "front_quality_gate.sh existe et est exécutable" '[ -x "${FRONT_GATE}" ]'

assert_true "front_quality_gate.sh ne masque plus les failles avec '|| true' sur audit" \
  '! grep -E "(npm|pnpm) audit.*\|\| true" "${FRONT_GATE}"'

# Test de détection de fuite mémoire useEffect
TMP_FRONT=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_FRONT")
(
  cd "$TMP_FRONT"
  echo '{"name": "test-front", "scripts": {"test": "exit 0"}}' > package.json
  mkdir -p src
  cat << 'EOF' > src/LeakyComponent.tsx
import React, { useEffect } from 'react';
export const Leaky = () => {
  useEffect(() => {
    window.addEventListener('resize', () => console.log('resized'));
  }, []);
  return <div>Test</div>;
};
EOF
)
FRONT_LEAK_OUTPUT=$(cd "$TMP_FRONT" && bash "${FRONT_GATE}" 2>&1 || true)
assert_true "front_quality_gate.sh détecte une fuite mémoire useEffect (listener sans cleanup)" \
  'echo "$FRONT_LEAK_OUTPUT" | grep -qiE "fuite|addEventListener|cleanup"'

# Test Fail-Closed front_quality_gate.sh sans script de test
TMP_NO_TEST_UI=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_NO_TEST_UI")
(
  cd "$TMP_NO_TEST_UI"
  mkdir -p src
  echo '{"name": "no-test-ui"}' > package.json
  echo 'export const Comp = () => <div>Hello</div>;' > src/Comp.tsx
)
assert_true "front_quality_gate.sh échoue (exit 1) sur projet avec UI sans script de test (Fail-Closed)" \
  '(cd "$TMP_NO_TEST_UI" && ! bash "${FRONT_GATE}" >/dev/null 2>&1)'

# Test détection fuite useEffect sans tableau de dépendances
TMP_NODEPS=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_NODEPS")
(
  cd "$TMP_NODEPS"
  mkdir -p src
  echo '{"name": "test-nodeps", "scripts": {"test": "exit 0"}}' > package.json
  cat << 'EOF' > src/NoDepsComponent.tsx
import React, { useEffect } from 'react';
export const NoDeps = () => {
  useEffect(() => {
    window.addEventListener('resize', () => console.log('resized'));
  });
  return <div>NoDeps</div>;
};
EOF
)
FRONT_NODEPS_OUTPUT=$(cd "$TMP_NODEPS" && bash "${FRONT_GATE}" 2>&1 || true)
assert_true "front_quality_gate.sh détecte fuite useEffect sans tableau de dépendances" \
  'echo "$FRONT_NODEPS_OUTPUT" | grep -qiE "fuite|addEventListener|cleanup"'

# Test validation useEffect avec fonction cleanup nommée (return cleanup;)
TMP_CLEANUP_FN=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_CLEANUP_FN")
(
  cd "$TMP_CLEANUP_FN"
  mkdir -p src
  echo '{"name": "test-clean-fn", "scripts": {"test": "exit 0"}}' > package.json
  cat << 'EOF' > src/CleanComponent.tsx
import React, { useEffect } from 'react';
export const Clean = () => {
  useEffect(() => {
    const handle = () => console.log('resize');
    window.addEventListener('resize', handle);
    const cleanup = () => window.removeEventListener('resize', handle);
    return cleanup;
  }, []);
  return <div>Clean</div>;
};
EOF
)
assert_true "front_quality_gate.sh valide un useEffect avec return cleanup; (exit 0)" \
  '(cd "$TMP_CLEANUP_FN" && bash "${FRONT_GATE}" >/dev/null 2>&1)'

# Test e2e_verification_gate.sh en Fail-Closed sur dossier vide (aucun check exécuté)
E2E_GATE="${ROOT_DIR}/src/skills/san_executer/scripts/e2e_verification_gate.sh"
TMP_E2E_EMPTY=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_E2E_EMPTY")
assert_true "e2e_verification_gate.sh échoue (exit 1) si aucun check n'est exécuté (tout skipped)" \
  '(cd "$TMP_E2E_EMPTY" && ! bash "${E2E_GATE}" >/dev/null 2>&1)'

# ------------------------------------------------------------------------------
# 4. TEST SUITE (d) : detect_stack_versions.sh --json (JSON 100% Parseable)
# ------------------------------------------------------------------------------
info "4. Test detect_stack_versions.sh --json (Sortie JSON valide & parseable)"

DETECT_SCRIPT="${ROOT_DIR}/src/skills/san_searcher/scripts/detect_stack_versions.sh"
assert_true "detect_stack_versions.sh existe et est exécutable" '[ -x "${DETECT_SCRIPT}" ]'

STACK_JSON=$(bash "${DETECT_SCRIPT}" "${ROOT_DIR}" --json 2>/dev/null || echo "")
assert_true "detect_stack_versions.sh émet une sortie non vide en mode --json" \
  '[ -n "${STACK_JSON}" ]'

assert_true "La sortie de detect_stack_versions.sh --json est un JSON parseable valide" \
  'echo "${STACK_JSON}" | node -e "const d = JSON.parse(require(\"fs\").readFileSync(0, \"utf8\")); if (!d.languages) process.exit(1);"'

# ------------------------------------------------------------------------------
# 5. TEST SUITE (e) : score_idea.py --profile (Pas de faux veto 3G/MoMo)
# ------------------------------------------------------------------------------
info "5. Test score_idea.py --profile (Piliers adaptatifs selon le profil)"

SCORE_SCRIPT="${ROOT_DIR}/src/skills/san_brainstorming/scripts/score_idea.py"
assert_true "score_idea.py existe" '[ -f "${SCORE_SCRIPT}" ]'

# Profil cli_devtools sans veto absurde 3G
CLI_SCORE_OUTPUT=$(python3 "${SCORE_SCRIPT}" --profile cli_devtools --impact 9.0 --effort 8.5 --terrain 8.0 --risques 8.5 --json)
assert_true "score_idea.py --profile cli_devtools valide avec succès sans mention 3G/MoMo" \
  'echo "${CLI_SCORE_OUTPUT}" | grep -q "\"statut\": \"GO_MVP_PRIORITAIRE\""'

assert_true "score_idea.py --profile cli_devtools adapte le nom du Pilier 3" \
  'echo "${CLI_SCORE_OUTPUT}" | grep -q "Adéquation Workflow"'

# Profil emerging_market conserve la réalité terrain 3G/MoMo
EM_SCORE_OUTPUT=$(python3 "${SCORE_SCRIPT}" --profile emerging_market --impact 9.0 --effort 8.5 --terrain 3.0 --risques 8.5 --json 2>/dev/null || true)
assert_true "score_idea.py --profile emerging_market déclenche le veto 3G/MoMo si terrain < 4" \
  'echo "${EM_SCORE_OUTPUT}" | grep -q "VETO TERRAIN DÉCLENCHÉ"'

# Profil cli_devtools déclenche le veto workflow/adoption si terrain/workflow < 4 sans mention 3G
CLI_VETO_OUTPUT=$(python3 "${SCORE_SCRIPT}" --profile cli_devtools --impact 9.0 --effort 8.5 --terrain 3.0 --risques 8.5 --json 2>/dev/null || true)
assert_true "score_idea.py --profile cli_devtools déclenche le veto workflow (sans mention 3G)" \
  'echo "${CLI_VETO_OUTPUT}" | grep -q "VETO WORKFLOW/ADOPTION DÉCLENCHÉ"'

# ------------------------------------------------------------------------------
# 6. TEST SUITE (f) : git_ai_hygiene.sh (Sauvegarde réversible & Sanctuaire AGENTS.md)
# ------------------------------------------------------------------------------
info "6. Test git_ai_hygiene.sh (Sauvegarde non destructive & Préservation AGENTS.md)"

HYGIENE_SCRIPT="${ROOT_DIR}/src/skills/san_init/scripts/git_ai_hygiene.sh"
assert_true "git_ai_hygiene.sh existe et est exécutable" '[ -x "${HYGIENE_SCRIPT}" ]'

TMP_GIT=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_GIT")
(
  cd "$TMP_GIT"
  git init -q
  echo "CONSTITUTION SOVERAINE" > AGENTS.md
  echo "LEGACY CLAUDE" > CLAUDE.md
  echo "LEGACY CURSOR" > .cursorrules
  mkdir -p .cursor
  echo "CURSOR CONFIG" > .cursor/settings.json
)

(cd "$TMP_GIT" && bash "${HYGIENE_SCRIPT}" >/dev/null 2>&1)

assert_true "git_ai_hygiene.sh préserve STRICTEMENT AGENTS.md intact à la racine" \
  '[ -f "${TMP_GIT}/AGENTS.md" ] && grep -q "CONSTITUTION SOVERAINE" "${TMP_GIT}/AGENTS.md"'

assert_true "git_ai_hygiene.sh retire les fichiers tiers résiduels de la racine" \
  '[ ! -f "${TMP_GIT}/CLAUDE.md" ] && [ ! -f "${TMP_GIT}/.cursorrules" ] && [ ! -d "${TMP_GIT}/.cursor" ]'

BACKUPS_COUNT=$(find "${TMP_GIT}/.agents/backups/legacy-ai-configs/" -type f 2>/dev/null | wc -l)
assert_true "git_ai_hygiene.sh sauvegarde réversiblement les fichiers dans .agents/backups/" \
  '[ "${BACKUPS_COUNT}" -ge 2 ]'

# ------------------------------------------------------------------------------
# 7. TEST SUITE (g) : build_tokens.mjs --strict (Échec sur mauvais contraste WCAG)
# ------------------------------------------------------------------------------
info "7. Test build_tokens.mjs --strict (Validation déterministe des contrastes WCAG)"

TOKENS_SCRIPT="${ROOT_DIR}/src/skills/san_design_tokens/scripts/build_tokens.mjs"
assert_true "build_tokens.mjs existe" '[ -f "${TOKENS_SCRIPT}" ]'

TMP_BRAND_BAD=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_BRAND_BAD")
cat << 'EOF' > "${TMP_BRAND_BAD}/BRAND.md"
# Brand Guidelines
### 1.1 Palette Chromatique & Tokens Fonctionnels
| Rôle Sémantique | Token Figma | Mode Sombre (Défaut) | Mode Clair |
| :--- | :--- | :--- | :--- |
| **Fond Principal** | `bg-primary` | `#ffffff` | `#ffffff` |
| **Texte Principal** | `text-primary` | `#cccccc` | `#cccccc` |
| **Bouton Primaire (Fond)** | `btn-primary-bg` | `#ffffff` | `#ffffff` |
| **Bouton Primaire (Texte)** | `btn-primary-fg` | `#cccccc` | `#cccccc` |
EOF

assert_true "build_tokens.mjs --strict échoue (exit 1) sur un mauvais contraste (< 4.5:1)" \
  '! node "${TOKENS_SCRIPT}" --input "${TMP_BRAND_BAD}/BRAND.md" --out-dir "${TMP_BRAND_BAD}/out" --strict >/dev/null 2>&1'

TMP_OUT_GOOD=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_OUT_GOOD")
assert_true "build_tokens.mjs --strict valide avec succès les contrastes WCAG de BRAND_TEMPLATE.md" \
  'node "${TOKENS_SCRIPT}" --input "${ROOT_DIR}/src/skills/san_init/templates/rules/BRAND_TEMPLATE.md" --out-dir "${TMP_OUT_GOOD}" --strict >/dev/null 2>&1'

# ------------------------------------------------------------------------------
# 8. TEST SUITE (h) : check_lorem.sh (Traque lorem ipsum & tolérance placeholders réels)
# ------------------------------------------------------------------------------
info "8. Test check_lorem.sh (Traque des faux textes & absence de faux positifs)"

LOREM_SCRIPT="${ROOT_DIR}/src/skills/san_copywriter/scripts/check_lorem.sh"
assert_true "check_lorem.sh existe et est exécutable" '[ -x "${LOREM_SCRIPT}" ]'

TMP_LOREM_BAD=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_LOREM_BAD")
echo '<h1>Lorem ipsum dolor sit amet</h1>' > "${TMP_LOREM_BAD}/page.html"

assert_true "check_lorem.sh bloque et échoue (exit 1) sur 'lorem ipsum'" \
  '! bash "${LOREM_SCRIPT}" "${TMP_LOREM_BAD}" >/dev/null 2>&1'

TMP_LOREM_GOOD=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_LOREM_GOOD")
echo '<input type="text" placeholder="Entrez votre adresse email..." />' > "${TMP_LOREM_GOOD}/form.html"
echo 'const toto = "variable de test technique légitime";' >> "${TMP_LOREM_GOOD}/app.js"

assert_true "check_lorem.sh tolère les attributs placeholder réels et les identifiants techniques (toto)" \
  'bash "${LOREM_SCRIPT}" "${TMP_LOREM_GOOD}" >/dev/null 2>&1'

# ------------------------------------------------------------------------------
# 9. TEST SUITE (i) : DevOps Templates, Infra & Légal (Lot 4C)
# ------------------------------------------------------------------------------
info "9. Test DevOps & Légal (Zéro alexsan.pro en dur & DEPLOYMENT_WORKFLOW.yml pur)"

DEPLOY_WORKFLOW="${ROOT_DIR}/src/skills/san_devops_expert/templates/DEPLOYMENT_WORKFLOW.yml"
assert_true "DEPLOYMENT_WORKFLOW.yml existe" '[ -f "${DEPLOY_WORKFLOW}" ]'

assert_true "DEPLOYMENT_WORKFLOW.yml ne référence AUCUN chemin .agents/ (inexistant en CI)" \
  '! grep -q "\.agents/" "${DEPLOY_WORKFLOW}"'

assert_true "DEPLOYMENT_WORKFLOW.yml est un fichier YAML syntaxiquement valide" \
  'python3 -c "import yaml; yaml.safe_load(open(\"${DEPLOY_WORKFLOW}\"))"'

INFRA_SCRIPT="${ROOT_DIR}/src/skills/san_devops_expert/scripts/infra_health_check.sh"
assert_true "infra_health_check.sh existe et est exécutable" '[ -x "${INFRA_SCRIPT}" ]'

assert_true "infra_health_check.sh ne contient aucun domaine alexsan.pro codé en dur" \
  '! grep -q "alexsan\.pro" "${INFRA_SCRIPT}"'

assert_true "infra_health_check.sh --local termine avec succès (exit 0)" \
  'bash "${INFRA_SCRIPT}" --local >/dev/null 2>&1'

SEO_LEGAL_SCRIPT="${ROOT_DIR}/src/skills/san_store_legal_expert/scripts/verify_tracking_and_seo.sh"
SEO_GROWTH_SCRIPT="${ROOT_DIR}/src/skills/san_growth_expert/scripts/verify_tracking_and_seo.sh"

assert_true "verify_tracking_and_seo.sh existe dans san_store_legal_expert" '[ -x "${SEO_LEGAL_SCRIPT}" ]'
assert_true "verify_tracking_and_seo.sh existe dans san_growth_expert" '[ -x "${SEO_GROWTH_SCRIPT}" ]'

assert_true "verify_tracking_and_seo.sh ne contient aucun domaine alexsan.pro codé en dur" \
  '! grep -q "alexsan\.pro" "${SEO_LEGAL_SCRIPT}" && ! grep -q "alexsan\.pro" "${SEO_GROWTH_SCRIPT}"'

TMP_SEO_SITE=$(mktemp -d)
TMP_WORKSPACES+=("$TMP_SEO_SITE")
cat << 'EOF' > "${TMP_SEO_SITE}/robots.txt"
User-agent: *
Allow: /
Sitemap: https://example.org/sitemap.xml
EOF
cat << 'EOF' > "${TMP_SEO_SITE}/sitemap.xml"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <loc>https://example.org/</loc>
</urlset>
EOF
cat << 'EOF' > "${TMP_SEO_SITE}/index.html"
<!DOCTYPE html><html><head>
<title>Site Test</title>
<meta name="description" content="Site de test SEO">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="canonical" href="https://example.org/">
<meta property="og:title" content="Test">
<meta property="og:description" content="Test">
<meta property="og:image" content="https://example.org/og.png">
<script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite","name":"Test"}</script>
</head><body>Test</body></html>
EOF

assert_true "verify_tracking_and_seo.sh analyse avec succès un dossier statique local (exit 0)" \
  'bash "${SEO_LEGAL_SCRIPT}" "${TMP_SEO_SITE}" >/dev/null 2>&1'

DOC_SCRAPER_SCRIPT="${ROOT_DIR}/src/skills/san_searcher/scripts/doc_scraper.sh"
assert_true "doc_scraper.sh existe et est exécutable" '[ -x "${DOC_SCRAPER_SCRIPT}" ]'
assert_true "doc_scraper.sh ne contient plus aucun domaine alexsan.pro en dur" \
  '! grep -q "alexsan\.pro" "${DOC_SCRAPER_SCRIPT}"'

# ------------------------------------------------------------------------------
# BILAN DES ASSERTIONS
# ------------------------------------------------------------------------------
echo ""
echo "======================================================================"
echo "  BILAN DE VALIDATION PHASE 4 : ${PASSED_TESTS} SUCCÈS, ${FAILED_TESTS} ÉCHECS"
echo "======================================================================"

if [ "${FAILED_TESTS}" -eq 0 ]; then
  echo -e "\033[32m\033[1m✔ FÉLICITATIONS : TOUS LES SCRIPTS ET QUALITY GATES SONT DURCIS ET CONFORMES.\033[0m"
  exit 0
else
  echo -e "\033[31m\033[1m✘ ÉCHEC : ${FAILED_TESTS} ASSERTION(S) NON CONFORME(S) DÉTECTÉE(S) !\033[0m"
  exit 1
fi
