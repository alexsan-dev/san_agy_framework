#!/usr/bin/env bash
# ==============================================================================
# SCRIPT : changelog_helper.sh
# FRAMEWORK : Antigravity (san_*)
# AUTEUR : san_doc_keeper
# DESCRIPTION : Insertion automatisée et déterministe d'entrées dans CHANGELOG.md
#               selon Keep a Changelog v1.1.0 et Semantic Versioning 2.0.0.
#
# USAGE :
#   Syntaxe avec options :
#     bash changelog_helper.sh --type <Added|Changed|Fixed|...> --desc <description> [--version <Unreleased|x.y.z>] [--file <path>]
#   Syntaxe positionnelle :
#     bash changelog_helper.sh <CATEGORY> <MESSAGE> [VERSION] [CHANGELOG_PATH]
#
# EXEMPLES :
#   bash changelog_helper.sh --type Added --desc "Support du paiement Mobile Money MTN et Airtel"
#   bash changelog_helper.sh Fixed "Correction d'une condition de course lors du webhook"
#   bash changelog_helper.sh -t Security -d "Validation HMAC-SHA256 sur les callbacks" -f docs/CHANGELOG.md
# ==============================================================================

set -euo pipefail

# Définition des styles et couleurs
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] ou <CATEGORY> <MESSAGE> [VERSION] [CHANGELOG_PATH]

Insertion automatisée et déterministe d'entrées dans CHANGELOG.md (Keep a Changelog 1.1.0).

Options :
  -t, --type <TYPE>         Catégorie Keep a Changelog obligatoire :
                            Added, Changed, Deprecated, Removed, Fixed, Security, Performance
  -d, --desc <DESCRIPTION>  Description du changement apporté
  -m, --message <MSG>       Alias de --desc
  -v, --version <VERSION>   Version cible (défaut : Unreleased)
  -f, --file <PATH>         Chemin du fichier changelog (défaut : CHANGELOG.md)
  -h, --help                Affiche cette aide et quitte

Exemples :
  $(basename "$0") --type Added --desc "Authentification à deux facteurs par SMS"
  $(basename "$0") Fixed "Correction du calcul de TVA pour la zone CEMAC"
  $(basename "$0") -t Security -d "Durcissement des cookies SameSite" -v "1.2.0"
EOF
}

CATEGORY=""
DESCRIPTION=""
VERSION="Unreleased"
CHANGELOG_FILE="CHANGELOG.md"
POS_INDEX=0

# Analyse des arguments CLI
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type|-t)
      CATEGORY="${2:-}"
      shift 2
      ;;
    --desc|-d|--message|-m)
      DESCRIPTION="${2:-}"
      shift 2
      ;;
    --version|-v)
      VERSION="${2:-}"
      shift 2
      ;;
    --file|-f)
      CHANGELOG_FILE="${2:-}"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    -*)
      echo -e "${RED}[ERREUR] Option inconnue : $1${NC}" >&2
      show_help >&2
      exit 1
      ;;
    *)
      case $POS_INDEX in
        0)
          CATEGORY="$1"
          ;;
        1)
          DESCRIPTION="$1"
          ;;
        2)
          VERSION="$1"
          ;;
        3)
          CHANGELOG_FILE="$1"
          ;;
        *)
          echo -e "${RED}[ERREUR] Trop d'arguments positionnels fournis : $1${NC}" >&2
          show_help >&2
          exit 1
          ;;
      esac
      POS_INDEX=$((POS_INDEX + 1))
      shift
      ;;
  esac
done

if [[ -z "$CATEGORY" || -z "$DESCRIPTION" ]]; then
  echo -e "${RED}[ERREUR] Catégorie et description obligatoires.${NC}" >&2
  show_help >&2
  exit 1
fi

# Normalisation insensible à la casse de la catégorie vers les 7 rubriques officielles
NORM_CAT="$(echo "${CATEGORY}" | tr '[:upper:]' '[:lower:]')"
case "${NORM_CAT}" in
  added)
    CANONICAL_CATEGORY="Added"
    ;;
  changed)
    CANONICAL_CATEGORY="Changed"
    ;;
  deprecated)
    CANONICAL_CATEGORY="Deprecated"
    ;;
  removed)
    CANONICAL_CATEGORY="Removed"
    ;;
  fixed)
    CANONICAL_CATEGORY="Fixed"
    ;;
  security)
    CANONICAL_CATEGORY="Security"
    ;;
  performance|perf)
    CANONICAL_CATEGORY="Performance"
    ;;
  *)
    echo -e "${RED}[ERREUR] Catégorie invalide : '${CATEGORY}'${NC}" >&2
    echo -e "${YELLOW}Les 7 catégories normatives Keep a Changelog v1.1.0 sont :${NC}" >&2
    echo "  - Added       : Nouvelles fonctionnalités" >&2
    echo "  - Changed     : Modifications de comportements existants" >&2
    echo "  - Deprecated  : Fonctionnalités vouées à suppression" >&2
    echo "  - Removed     : Fonctionnalités ou dépendances supprimées" >&2
    echo "  - Fixed       : Résolutions de bugs ou anomalies" >&2
    echo "  - Security    : Correctifs de sécurité et durcissement" >&2
    echo "  - Performance : Optimisations de vitesse, requêtes, bundle" >&2
    exit 1
    ;;
esac

# Création du fichier avec gabarit officiel s'il n'existe pas encore
if [[ ! -f "${CHANGELOG_FILE}" ]]; then
  echo -e "${YELLOW}[san_doc_keeper] Création d'un nouveau fichier ${CHANGELOG_FILE} conforme Keep a Changelog...${NC}"
  mkdir -p "$(dirname "${CHANGELOG_FILE}")"
  cat << 'EOF' > "${CHANGELOG_FILE}"
# Changelog
Toutes les modifications notables apportées à ce projet sont consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

EOF
fi

# Injection déterministe via Python 3 ou Node.js
if command -v python3 &>/dev/null; then
  python3 - "$VERSION" "$CANONICAL_CATEGORY" "$DESCRIPTION" "$CHANGELOG_FILE" << 'PY_EOF'
import sys
import re

version = sys.argv[1]
category = sys.argv[2]
message = sys.argv[3].strip()
changelog_path = sys.argv[4]

with open(changelog_path, 'r', encoding='utf-8') as f:
    content = f.read()

version_header = f"## [{version}]"
if version_header not in content:
    # Insérer la section de version sous le titre principal
    m = re.search(r'(# Changelog[^\n]*\n(?:\n|[^#\n][^\n]*\n)*)', content)
    if m:
        insert_pos = m.end()
        content = content[:insert_pos] + f"\n{version_header}\n" + content[insert_pos:]
    else:
        content = f"# Changelog\n\nToutes les modifications notables apportées à ce projet sont consignées dans ce fichier.\n\nLe format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),\net ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).\n\n{version_header}\n\n" + content

v_pos = content.find(version_header)
# Trouver la fin de la section de version (prochain "## [")
next_v = re.search(r'\n## \[', content[v_pos + len(version_header):])
if next_v:
    end_v_pos = v_pos + len(version_header) + next_v.start()
    version_block = content[v_pos:end_v_pos]
else:
    end_v_pos = len(content)
    version_block = content[v_pos:]

category_header = f"### {category}"
bullet_point = f"- {message}"

if category_header in version_block:
    cat_pos = version_block.find(category_header)
    newline_pos = version_block.find('\n', cat_pos)
    if newline_pos == -1:
        new_version_block = version_block + f"\n{bullet_point}\n"
    else:
        new_version_block = version_block[:newline_pos + 1] + f"{bullet_point}\n" + version_block[newline_pos + 1:]
else:
    # Ordre canonique des 7 rubriques
    cat_order = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security", "Performance"]
    cat_idx = cat_order.index(category) if category in cat_order else 0
    
    # Trouver l'emplacement optimal parmi les catégories existantes
    inserted = False
    for other_cat in cat_order[cat_idx+1:]:
        other_header = f"### {other_cat}"
        if other_header in version_block:
            o_pos = version_block.find(other_header)
            new_version_block = version_block[:o_pos] + f"{category_header}\n{bullet_point}\n\n" + version_block[o_pos:]
            inserted = True
            break
            
    if not inserted:
        # Insérer à la fin du bloc de version
        new_version_block = version_block.rstrip() + f"\n\n{category_header}\n{bullet_point}\n\n"

# Normalisation des sauts de ligne multiples
new_version_block = re.sub(r'\n{3,}', '\n\n', new_version_block)
new_content = content[:v_pos] + new_version_block.rstrip() + "\n\n" + content[end_v_pos:].lstrip()
new_content = re.sub(r'\n{3,}', '\n\n', new_content).rstrip() + "\n"

with open(changelog_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
PY_EOF

elif command -v node &>/dev/null; then
  node - "$VERSION" "$CANONICAL_CATEGORY" "$DESCRIPTION" "$CHANGELOG_FILE" << 'NODE_EOF'
const fs = require('fs');
const [,, targetVersion, targetCategory, message, changelogFile] = process.argv;

let content = fs.readFileSync(changelogFile, 'utf-8');
const versionHeader = `## [${targetVersion}]`;

if (!content.includes(versionHeader)) {
  const mainHeader = '# Changelog';
  const pos = content.indexOf(mainHeader);
  if (pos !== -1) {
    const endPos = content.indexOf('\n\n', pos);
    const insertPos = endPos !== -1 ? endPos + 2 : content.length;
    content = content.slice(0, insertPos) + `${versionHeader}\n\n` + content.slice(insertPos);
  } else {
    content = `# Changelog\n\n${versionHeader}\n\n` + content;
  }
}

const vPos = content.indexOf(versionHeader);
const nextVMatch = content.slice(vPos + versionHeader.length).match(/\n## \[/);
const endVPos = nextVMatch ? vPos + versionHeader.length + nextVMatch.index : content.length;
let versionBlock = content.slice(vPos, endVPos);

const catHeader = `### ${targetCategory}`;
const bulletPoint = `- ${message.trim()}`;

if (versionBlock.includes(catHeader)) {
  const catPos = versionBlock.indexOf(catHeader);
  const newlinePos = versionBlock.indexOf('\n', catPos);
  versionBlock = versionBlock.slice(0, newlinePos + 1) + `${bulletPoint}\n` + versionBlock.slice(newlinePos + 1);
} else {
  versionBlock = versionBlock.trimEnd() + `\n\n${catHeader}\n${bulletPoint}\n\n`;
}

versionBlock = versionBlock.replace(/\n{3,}/g, '\n\n');
let newContent = content.slice(0, vPos) + versionBlock.trimEnd() + '\n\n' + content.slice(endVPos).trimStart();
newContent = newContent.replace(/\n{3,}/g, '\n\n').trimEnd() + '\n';
fs.writeFileSync(changelogFile, newContent, 'utf-8');
NODE_EOF

else
  echo -e "${RED}[ERREUR] python3 ou node est requis pour exécuter ce script.${NC}" >&2
  exit 1
fi

echo -e "${GREEN}✅ [san_doc_keeper] Entrée ajoutée avec succès dans ${CHANGELOG_FILE} :${NC}"
echo -e "   ${CYAN}Version :${NC} [${VERSION}]"
echo -e "   ${CYAN}Catégorie :${NC} ${CANONICAL_CATEGORY}"
echo -e "   ${CYAN}Détail :${NC} ${DESCRIPTION}"
exit 0
