#!/usr/bin/env bash
# Test unitaire et d'intégration pour archive_roadmap.sh
# Framework Antigravity (san_*)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ARCHIVE_SCRIPT="${FRAMEWORK_ROOT}/src/skills/san_planner/scripts/archive_roadmap.sh"

echo "============================================================"
echo "TEST SUITE : archive_roadmap.sh"
echo "============================================================"

if [[ ! -f "${ARCHIVE_SCRIPT}" ]]; then
  echo "[-] ERREUR: Le script cible n'existe pas : ${ARCHIVE_SCRIPT}"
  exit 1
fi

TMP_DIR="$(mktemp -d /tmp/test_archive_roadmap_XXXXXX)"
echo "[+] Création d'un environnement de test isolé dans : ${TMP_DIR}"

cleanup() {
  echo "[+] Nettoyage de l'environnement temporaire..."
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

cd "${TMP_DIR}"
mkdir -p roadmaps/archives

# -------------------------------------------------------------
# TEST 1 : Rejet d'une roadmap avec des cases non cochées (- [ ])
# -------------------------------------------------------------
echo "[+] Test 1 : Roadmap incomplète avec cases non cochées..."

cat << 'EOF' > roadmaps/MVP_INCOMPLETE.md
# ROADMAP INCOMPLETE
- [x] Tâche 1 complétée
- [ ] Tâche 2 EN COURS NON TERMINEE
- [x] Tâche 3 complétée
- [ ] Tâche 4 OUBLIEE
EOF

set +e
bash "${ARCHIVE_SCRIPT}" roadmaps/MVP_INCOMPLETE.md > test1_out.log 2>&1
EXIT_CODE=$?
set -e

if [[ "${EXIT_CODE}" -eq 0 ]]; then
  echo "[-] ÉCHEC: archive_roadmap.sh aurait dû échouer (exit code non nul) mais a réussi !"
  cat test1_out.log
  exit 1
fi

if [[ ! -f "roadmaps/MVP_INCOMPLETE.md" ]]; then
  echo "[-] ÉCHEC: Le fichier incomplet ne devait pas être déplacé !"
  exit 1
fi

if [[ -f "roadmaps/archives/MVP_INCOMPLETE.md" ]]; then
  echo "[-] ÉCHEC: Le fichier incomplet a été archivé par erreur !"
  exit 1
fi

echo "  [OK] Rejet strict et blocage de l'archivage lorsque des cases restent ouvertes (code: ${EXIT_CODE})."

# -------------------------------------------------------------
# TEST 2 : Rejet d'un fichier sans aucune tâche
# -------------------------------------------------------------
echo "[+] Test 2 : Fichier sans aucune case à cocher..."

cat << 'EOF' > roadmaps/MVP_EMPTY.md
# ROADMAP VIDE
Aucune tâche ici.
EOF

set +e
bash "${ARCHIVE_SCRIPT}" roadmaps/MVP_EMPTY.md > test2_out.log 2>&1
EXIT_CODE_EMPTY=$?
set -e

if [[ "${EXIT_CODE_EMPTY}" -eq 0 ]]; then
  echo "[-] ÉCHEC: Un fichier sans tâches ne doit pas être validé pour l'archivage !"
  exit 1
fi
echo "  [OK] Rejet strict d'une roadmap sans tâches (code: ${EXIT_CODE_EMPTY})."

# -------------------------------------------------------------
# TEST 3 : Succès d'archivage lorsque 100% des tâches sont cochées (- [x])
# -------------------------------------------------------------
echo "[+] Test 3 : Roadmap 100% cochée et validée..."

cat << 'EOF' > roadmaps/MVP_COMPLETE.md
# ROADMAP COMPLETE A 100%
- [x] Tâche 1 entièrement validée et testée
- [x] Tâche 2 entièrement validée et testée
- [x] Tâche 3 entièrement validée et testée
EOF

set +e
bash "${ARCHIVE_SCRIPT}" roadmaps/MVP_COMPLETE.md > test3_out.log 2>&1
EXIT_CODE_COMPLETE=$?
set -e

if [[ "${EXIT_CODE_COMPLETE}" -ne 0 ]]; then
  echo "[-] ÉCHEC: archive_roadmap.sh aurait dû réussir avec exit code 0 !"
  cat test3_out.log
  exit 1
fi

if [[ -f "roadmaps/MVP_COMPLETE.md" ]]; then
  echo "[-] ÉCHEC: Le fichier source est toujours présent dans roadmaps/ !"
  exit 1
fi

if [[ ! -f "roadmaps/archives/MVP_COMPLETE.md" ]]; then
  echo "[-] ÉCHEC: Le fichier source n'a pas été déplacé dans roadmaps/archives/ !"
  exit 1
fi

echo "  [OK] Déplacement et archivage déterministe réussi à 100%."

echo "============================================================"
echo "[SUCCESS] TOUS LES TESTS DE archive_roadmap.sh ONT PASSÉ AVEC SUCCÈS !"
echo "============================================================"
