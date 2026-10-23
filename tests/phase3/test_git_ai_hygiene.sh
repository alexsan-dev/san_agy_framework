#!/usr/bin/env bash
# Test unitaire et d'intégration pour git_ai_hygiene.sh
# Framework Antigravity (san_*)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HYGIENE_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_init/scripts/git_ai_hygiene.sh"

echo "============================================================"
echo "TEST SUITE : git_ai_hygiene.sh"
echo "============================================================"

if [[ ! -f "${HYGIENE_SCRIPT}" ]]; then
  echo "[-] ERREUR: Le script cible n'existe pas : ${HYGIENE_SCRIPT}"
  exit 1
fi

TMP_REPO="$(mktemp -d /tmp/test_git_ai_hygiene_XXXXXX)"
echo "[+] Création d'un environnement de test isolé dans : ${TMP_REPO}"

cleanup() {
  echo "[+] Nettoyage de l'environnement temporaire..."
  rm -rf "${TMP_REPO}"
}
trap cleanup EXIT

# 1. Initialiser un repo Git factice
cd "${TMP_REPO}"
git init -q
git config user.name "Test AI"
git config user.email "test-ai@alexsan.pro"

# 2. Créer des résidus d'anciens agents et fichiers sensibles
echo "# Legacy Claude Config" > CLAUDE.md
echo "rule: no ai" > .cursorrules
mkdir -p .cursor
echo '{"key": "val"}' > .cursor/settings.json
mkdir -p .copilot
echo "copilot config" > .copilot/config
echo "windsurf rules" > .windsurfrules

# Créer l'arborescence .agents/
mkdir -p .agents/skills/dummy_skill
echo "dummy skill" > .agents/skills/dummy_skill/SKILL.md
echo "dummy secret" > .agents/secret.txt

# Créer des fichiers de projet légitimes
echo "# Mon Projet Réel" > README.md
echo '{"name": "test-project"}' > package.json

# 3. Committer les fichiers pour simuler un historique "pollué"
git add .
git commit -qm "feat: commit initial avec fichiers pollues"

echo "[+] Dépôt pollué créé avec succès."
TRACKED_AGENTS=$(git ls-files .agents)
if [[ -z "${TRACKED_AGENTS}" ]]; then
  echo "[-] Échec du setup : .agents/ devrait être suivi par Git."
  exit 1
fi
echo "[+] Fichiers .agents/ initialement suivis dans l'index Git :"
echo "${TRACKED_AGENTS}"

# 4. Exécuter le script de nettoyage git_ai_hygiene.sh
echo "[+] Exécution de git_ai_hygiene.sh..."
bash "${HYGIENE_SCRIPT}"

# 5. Assertions

echo "[+] Vérification des assertions post-nettoyage..."

# Assertion A : Les résidus d'anciens agents doivent être purgés ou supprimés
for legacy in "CLAUDE.md" ".cursorrules" ".cursor" ".copilot" ".windsurfrules"; do
  if [[ -e "${legacy}" ]]; then
    echo "[-] ÉCHEC: Le résidu legacy ${legacy} existe toujours !"
    exit 1
  fi
done
echo "  [OK] Tous les résidus d'anciens agents ont été supprimés."

# Assertion B : Les fichiers du projet légitime doivent TOUJOURS exister
for legit in "README.md" "package.json"; do
  if [[ ! -f "${legit}" ]]; then
    echo "[-] ÉCHEC: Le fichier légitime ${legit} a été supprimé par erreur !"
    exit 1
  fi
done
echo "  [OK] Les fichiers légitimes du projet sont intacts."

# Assertion C : Le répertoire .agents/ physique existe toujours mais est dé-indexé de Git
if [[ ! -d ".agents" ]]; then
  echo "[-] ÉCHEC: Le dossier .agents physique ne doit PAS être détruit !"
  exit 1
fi
echo "  [OK] Le dossier .agents/ local est préservé."

TRACKED_AFTER=$(git ls-files .agents)
if [[ -n "${TRACKED_AFTER}" ]]; then
  echo "[-] ÉCHEC: .agents/ est toujours indexé dans Git :"
  echo "${TRACKED_AFTER}"
  exit 1
fi
echo "  [OK] .agents/ a été totalement désindexé du cache Git (git rm --cached)."

# Assertion D : .gitignore et .git/info/exclude contiennent le verrouillage .agents/
if ! grep -q ".agents" .gitignore 2>/dev/null; then
  echo "[-] ÉCHEC: .gitignore ne contient pas de règle pour .agents !"
  exit 1
fi
echo "  [OK] .gitignore est verrouillé pour .agents/."

if ! grep -q ".agents" .git/info/exclude 2>/dev/null; then
  echo "[-] ÉCHEC: .git/info/exclude ne contient pas de règle pour .agents !"
  exit 1
fi
echo "  [OK] .git/info/exclude est verrouillé à double tour pour .agents/."

echo "============================================================"
echo "[SUCCESS] TOUS LES TESTS DE git_ai_hygiene.sh ONT PASSÉ AVEC SUCCÈS !"
echo "============================================================"
