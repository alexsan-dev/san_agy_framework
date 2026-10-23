#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : git_ai_hygiene.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : Alexsan.pro
# DESCRIPTION : Assainissement Git, désindexation de cache, purge des résidus
#               d'agents tiers et verrouillage hermétique à double étage.
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs de terminal
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}=== [san_init] Lancement de l'Hygiène et de l'Isolation Git ===${NC}"

# 1. Vérification et détection de la racine Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}[ERREUR] Le répertoire de travail actuel n'est pas un dépôt Git actif.${NC}" >&2
    echo -e "${YELLOW}[CONSEIL] Initialisez Git au préalable via : git init${NC}" >&2
    exit 1
fi

GIT_ROOT=$(git rev-parse --show-toplevel)
CURRENT_DIR=$(pwd -P)
GIT_DIR=$(git rev-parse --git-dir)

echo -e "${GREEN}[OK] Racine Git identifiée : ${GIT_ROOT}${NC}"

# Détection de sous-dossier ou Monorepo
if [ "$CURRENT_DIR" != "$GIT_ROOT" ]; then
    echo -e "${YELLOW}[INFO] Contexte Monorepo ou sous-répertoire détecté (${CURRENT_DIR#$GIT_ROOT/}).${NC}"
    echo -e "${YELLOW}[INFO] L'hygiène et l'isolation s'appliquent souverainement à la racine du dépôt : ${GIT_ROOT}${NC}"
fi

cd "$GIT_ROOT"

# 2. Définition des cibles IA (résidus tiers et isolation locale Antigravity)
AI_CACHE_TARGETS=(
    ".agents"
    ".agents/"
    "AGENTS.md"
    "GEMINI.md"
    ".claude"
    ".claude/"
    "CLAUDE.md"
    ".opencode"
    ".opencode/"
    ".poolside"
    ".poolside/"
    ".cursor"
    ".cursor/"
    ".cursorrules"
    ".windsurf"
    ".windsurf/"
    ".windsurfrules"
    ".copilot"
    ".copilot/"
    ".github/copilot-instructions.md"
)

# Résidus tiers à purger physiquement du disque s'ils existent
THIRD_PARTY_OBSOLETE_FILES=(
    "CLAUDE.md"
    ".cursorrules"
    ".windsurfrules"
    ".opencode"
    ".poolside"
    "AGENTS.md"
)

THIRD_PARTY_OBSOLETE_DIRS=(
    ".claude"
    ".cursor"
    ".windsurf"
    ".copilot"
)

# 3. Purge physique des configurations tierces obsolètes (Zero Placeholder / Clean State)
echo -e "\n${BLUE}[1/5] Analyse et purge des résidus d'anciens agents tiers...${NC}"
PURGED_COUNT=0

for stale_file in "${THIRD_PARTY_OBSOLETE_FILES[@]}"; do
    if [ -f "$stale_file" ]; then
        echo -e "${YELLOW} -> Détection et suppression du fichier obsolète : ${stale_file}${NC}"
        rm -f "$stale_file"
        PURGED_COUNT=$((PURGED_COUNT + 1))
    fi
done

for stale_dir in "${THIRD_PARTY_OBSOLETE_DIRS[@]}"; do
    if [ -d "$stale_dir" ]; then
        echo -e "${YELLOW} -> Détection et suppression du répertoire obsolète : ${stale_dir}${NC}"
        rm -rf "$stale_dir"
        PURGED_COUNT=$((PURGED_COUNT + 1))
    fi
done

if [ "$PURGED_COUNT" -eq 0 ]; then
    echo -e "${GREEN}[OK] Aucun résidu tiers polluant détecté sur le disque.${NC}"
else
    echo -e "${GREEN}[OK] ${PURGED_COUNT} résidu(s) tiers purgé(s) avec succès.${NC}"
fi

# 4. Désindexation sécurisée du cache Git (git rm -r --cached --ignore-unmatch)
echo -e "\n${BLUE}[2/5] Désindexation des artefacts IA dans l'index Git (sans supprimer les fichiers locaux)...${NC}"
UNSTAGE_COUNT=0

for target in "${AI_CACHE_TARGETS[@]}"; do
    if git ls-files --error-unmatch "$target" >/dev/null 2>&1; then
        echo -e "${YELLOW} -> Désindexation de l'élément suivi : ${target}${NC}"
        git rm -r --cached --ignore-unmatch "$target" >/dev/null 2>&1 || git rm --cached --ignore-unmatch "$target" >/dev/null 2>&1 || true
        UNSTAGE_COUNT=$((UNSTAGE_COUNT + 1))
    fi
done

# Désindexation globale spécifique pour .agents/ et ses sous-dossiers
if git ls-files --error-unmatch ".agents" >/dev/null 2>&1; then
    echo -e "${YELLOW} -> Désindexation récursive forcée de .agents/ de l'arbre Git...${NC}"
    git rm -r --cached --ignore-unmatch .agents/ >/dev/null 2>&1 || true
    UNSTAGE_COUNT=$((UNSTAGE_COUNT + 1))
fi

if [ "$UNSTAGE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}[OK] Aucun fichier IA n'était suivi dans l'index Git actif.${NC}"
else
    echo -e "${GREEN}[OK] ${UNSTAGE_COUNT} entrée(s) retirée(s) de l'index Git.${NC}"
fi

# 5. Protection active skip-worktree pour les fichiers restants suivis en amont
echo -e "\n${BLUE}[3/5] Application du verrou skip-worktree sur les fichiers suivis upstream...${NC}"
for target in "${AI_CACHE_TARGETS[@]}"; do
    if [ -f "$target" ] && git ls-files --error-unmatch "$target" >/dev/null 2>&1; then
        git update-index --skip-worktree "$target" 2>/dev/null || true
        echo -e "${CYAN} -> Protection skip-worktree appliquée sur : ${target}${NC}"
    fi
done

# 6. Verrouillage hermétique Étage 1 : .gitignore racine
echo -e "\n${BLUE}[4/5] Verrouillage hermétique dans le .gitignore racine...${NC}"
GITIGNORE_PATH="${GIT_ROOT}/.gitignore"
touch "$GITIGNORE_PATH"

GITIGNORE_MARKER="# --- ANTIGRAVITY AI ISOLATION (san_*) ---"

if ! grep -q "$GITIGNORE_MARKER" "$GITIGNORE_PATH"; then
    cat << 'EOF' >> "$GITIGNORE_PATH"

# --- ANTIGRAVITY AI ISOLATION (san_*) ---
# Espace souverain local Antigravity (Zéro fuite Git)
/.agents/
/AGENTS.md
/GEMINI.md

# Résidus tiers purgés
/.claude/
/CLAUDE.md
/.opencode/
/.poolside/
/.cursor/
/.cursorrules/
/.windsurf/
/.windsurfrules/
/.copilot/
# ----------------------------------------
EOF
    echo -e "${GREEN}[OK] Règles d'isolation insérées dans ${GITIGNORE_PATH}${NC}"
else
    echo -e "${GREEN}[OK] .gitignore contient déjà le bloc d'isolation Antigravity.${NC}"
fi

# 7. Verrouillage hermétique Étage 2 : .git/info/exclude (Exclusion locale non commitée)
echo -e "\n${BLUE}[5/5] Verrouillage hermétique dans l'exclusion locale (.git/info/exclude)...${NC}"
# Résolution robuste de l'exclude local même en cas de submodules ou git worktree
EXCLUDE_PATH=$(git rev-parse --git-path info/exclude)
EXCLUDE_DIR=$(dirname "$EXCLUDE_PATH")

mkdir -p "$EXCLUDE_DIR"
touch "$EXCLUDE_PATH"

if ! grep -q "$GITIGNORE_MARKER" "$EXCLUDE_PATH"; then
    cat << 'EOF' >> "$EXCLUDE_PATH"

# --- ANTIGRAVITY AI ISOLATION (san_*) ---
# Espace souverain local Antigravity (Zéro fuite Git)
/.agents/
/AGENTS.md
/GEMINI.md

# Résidus tiers purgés
/.claude/
/CLAUDE.md
/.opencode/
/.poolside/
/.cursor/
/.cursorrules/
/.windsurf/
/.windsurfrules/
/.copilot/
# ----------------------------------------
EOF
    echo -e "${GREEN}[OK] Règles d'isolation insérées dans ${EXCLUDE_PATH}${NC}"
else
    echo -e "${GREEN}[OK] ${EXCLUDE_PATH} contient déjà le bloc d'isolation Antigravity.${NC}"
fi

echo -e "\n${GREEN}${BOLD}=== [SUCCÈS] Isolation Git hermétique validée. Zéro fuite IA possible. ===${NC}"
exit 0
