#!/usr/bin/env bash
# scripts/doc_scraper.sh
# Téléchargement épuré et décontamination d'une page de documentation officielle (Context Shielding).
# Convertit le contenu HTML en Markdown dense purgé de tout balisage superflu (scripts, styles, nav, cookies).
# Usage: ./doc_scraper.sh <URL> [NOM_SUJET] [--force]
#
# Options:
#   -h, --help    Affiche l'aide
#   -f, --force   Force le téléchargement même si le domaine n'est pas dans la whitelist officielle

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET_URL=""
SUBJECT_NAME=""
FORCE_FLAG=false

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      cat << 'EOF'
Usage: doc_scraper.sh <URL> [NOM_SUJET] [--force]

Télécharge une page de documentation officielle, en extrait le contenu textuel et technique pur,
élimine le bruit (scripts, trackers, headers de navigation, styles) et produit une fiche Markdown
dense prête pour docs/research/ (Context Shielding).

Domaines d'autorité de confiance :
  - react.dev
  - laravel.com
  - docs.expo.dev
  - tailwindcss.com
  - owasp.org
  - developer.mozilla.org
  - php.net
  - nodejs.org
  - nextjs.org
  - typescriptlang.org
  - stripe.com
  - go.dev
  - github.com, devdocs.io, docs.*

Exemples:
  ./doc_scraper.sh https://laravel.com/docs/11.x/cache cache_locks
  ./doc_scraper.sh https://react.dev/reference/react/useActionState react_actions
EOF
      exit 0
      ;;
    -f|--force)
      FORCE_FLAG=true
      ;;
    *)
      if [[ -z "${TARGET_URL}" ]]; then
        TARGET_URL="$arg"
      elif [[ -z "${SUBJECT_NAME}" ]]; then
        SUBJECT_NAME="$arg"
      fi
      ;;
  esac
done

if [[ -z "${TARGET_URL}" ]]; then
  echo -e "${RED}❌ Erreur : URL cible manquante.${NC}"
  echo "Usage: $0 <URL> [NOM_SUJET] [--force]"
  exit 1
fi

if [[ -z "${SUBJECT_NAME}" ]]; then
  # Extraire un nom par défaut depuis l'URL
  SUBJECT_NAME=$(basename "${TARGET_URL}" | tr -cd '[:alnum:]_-' || echo "tech_doc")
  [[ -z "${SUBJECT_NAME}" ]] && SUBJECT_NAME="tech_doc"
fi

OUTPUT_DIR="docs/research"
DATE_STAMP=$(date +%d%m%Y)
SUBJECT_CLEAN=$(echo "${SUBJECT_NAME}" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]_')
TARGET_FILE="${OUTPUT_DIR}/TECH_INVESTIGATION_${SUBJECT_CLEAN}_${DATE_STAMP}.md"

# Whitelist de domaines d'autorité
WHITELIST_REGEX="^(https?://)?([a-zA-Z0-9-]+\.)*(laravel\.com|react\.dev|docs\.expo\.dev|tailwindcss\.com|owasp\.org|developer\.mozilla\.org|php\.net|nodejs\.org|nextjs\.org|typescriptlang\.org|stripe\.com|go\.dev)"

if ! echo "${TARGET_URL}" | grep -qE "${WHITELIST_REGEX}"; then
  echo -e "${YELLOW}⚠️ ALERTE [san_searcher] : L'URL demandée (${TARGET_URL}) n'appartient pas à la whitelist officielle de confiance.${NC}" >&2
  echo -e "${YELLOW}Domaines officiels de référence : laravel.com, react.dev, docs.expo.dev, tailwindcss.com, owasp.org, developer.mozilla.org, php.net, nodejs.org, nextjs.org, typescriptlang.org, stripe.com, go.dev${NC}" >&2

  if [[ "${FORCE_FLAG}" == "true" ]]; then
    echo -e "${YELLOW}Option --force active : poursuite du scraping sous la responsabilité de l'appelant.${NC}" >&2
  elif [[ -t 0 ]]; then
    read -rp "Souhaitez-vous tout de même continuer ? (y/N) : " CONFIRM
    if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
      echo -e "${RED}Opération annulée par sécurité contextuelle.${NC}"
      exit 1
    fi
  else
    # En environnement non-TTY (subagents, CI, pipelines), avertissement tracé sur stderr permettant l'extraction de GitHub, MDN, DevDocs, etc.
    echo -e "${YELLOW}ℹ️ [san_searcher] Mode non-interactif : extraction autorisée avec décontamination contextuelle renforcée.${NC}" >&2
  fi
fi

mkdir -p "${OUTPUT_DIR}"
echo -e "${BLUE}🌐 [san_searcher] Extraction & Décontamination Contextuelle : ${CYAN}${TARGET_URL}${NC}"

TEMP_HTML=$(mktemp)
trap 'rm -f "${TEMP_HTML:-}"' EXIT

# Téléchargement via curl avec User-Agent identifié et gestion des redirections
USER_AGENT="${SAN_SCRAPER_USER_AGENT:-Mozilla/5.0 (compatible; SanSearcherBot/1.0; +https://github.com/alexsan-dev/san_agy_framework; AntigravityFramework)}"
if ! curl -sSL --compressed -A "${USER_AGENT}" \
     --connect-timeout 10 --max-time 30 "${TARGET_URL}" -o "${TEMP_HTML}"; then
  echo -e "${RED}❌ Échec du téléchargement curl pour l'URL : ${TARGET_URL}${NC}"
  exit 1
fi

if [[ ! -s "${TEMP_HTML}" ]]; then
  echo -e "${RED}❌ Erreur : Le contenu téléchargé est vide.${NC}"
  exit 1
fi

# Sas de décontamination : Conversion HTML vers Markdown épuré via Node.js
node -e '
const fs = require("fs");
const tempFile = process.argv[1];
const targetFile = process.argv[2];
const targetUrl = process.argv[3];
const subjectName = process.argv[4];

let html = fs.readFileSync(tempFile, "utf8");

// 1. Élimination drastique des balises parasites et du bruit
html = html.replace(/<!--[\s\S]*?-->/g, "");
html = html.replace(/<head\b[^<]*(?:(?!<\/head>)<[^<]*)*<\/head>/gi, "");
html = html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "");
html = html.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, "");
html = html.replace(/<svg\b[^<]*(?:(?!<\/svg>)<[^<]*)*<\/svg>/gi, "");
html = html.replace(/<nav\b[^<]*(?:(?!<\/nav>)<[^<]*)*<\/nav>/gi, "");
html = html.replace(/<footer\b[^<]*(?:(?!<\/footer>)<[^<]*)*<\/footer>/gi, "");
html = html.replace(/<header\b[^<]*(?:(?!<\/header>)<[^<]*)*<\/header>/gi, "");
html = html.replace(/<aside\b[^<]*(?:(?!<\/aside>)<[^<]*)*<\/aside>/gi, "");
html = html.replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, "");

// Si une balise <main> ou <article> existe, privilégier son contenu
const mainMatch = html.match(/<(main|article)[^>]*>([\s\S]*?)<\/\1>/i);
if (mainMatch && mainMatch[2] && mainMatch[2].length > 200) {
  html = mainMatch[2];
}

// 2. Conversion structurée vers Markdown
let md = html
  .replace(/<h1[^>]*>([\s\S]*?)<\/h1>/gi, "\n\n# $1\n\n")
  .replace(/<h2[^>]*>([\s\S]*?)<\/h2>/gi, "\n\n## $1\n\n")
  .replace(/<h3[^>]*>([\s\S]*?)<\/h3>/gi, "\n\n### $1\n\n")
  .replace(/<h4[^>]*>([\s\S]*?)<\/h4>/gi, "\n\n#### $1\n\n")
  .replace(/<pre[^>]*><code[^>]*>([\s\S]*?)<\/code><\/pre>/gi, "\n\n```\n$1\n```\n\n")
  .replace(/<pre[^>]*>([\s\S]*?)<\/pre>/gi, "\n\n```\n$1\n```\n\n")
  .replace(/<code[^>]*>([\s\S]*?)<\/code>/gi, "`$1`")
  .replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, "\n- $1")
  .replace(/<p[^>]*>([\s\S]*?)<\/p>/gi, "\n\n$1\n\n")
  .replace(/<br\s*[\/]?>/gi, "\n")
  .replace(/<hr\s*[\/]?>/gi, "\n\n---\n\n")
  .replace(/<[^>]+>/g, " ");

// 3. Décodage des entités HTML courantes
const entities = {
  "&amp;": "&",
  "&lt;": "<",
  "&gt;": ">",
  "&quot;": "\"",
  "&#39;": "\x27",
  "&apos;": "\x27",
  "&nbsp;": " ",
  "&copy;": "©",
  "&reg;": "®",
  "&mdash;": "—",
  "&ndash;": "–"
};

for (const [entity, replacement] of Object.entries(entities)) {
  md = md.split(entity).join(replacement);
}

// 4. Nettoyage de la typographie et des retours à la ligne
md = md
  .replace(/[ \t]+/g, " ")
  .replace(/\n\s+\n/g, "\n\n")
  .replace(/\n{3,}/g, "\n\n")
  .trim();

// 5. En-tête de décontamination formel
const header = "# FICHE DE RECHERCHE TECHNIQUE : " + subjectName + "\n" +
  "- **Source Officielle :** " + targetUrl + "\n" +
  "- **Date d\x27Extraction :** " + new Date().toISOString() + "\n" +
  "- **Sas de Décontamination :** Actif (Bruit HTML, scripts, trackers et menus purgés)\n" +
  "- **Framework Antigravity :** `san_searcher` (Context Shielding)\n\n" +
  "---\n\n## CONTENU TECHNIQUE EXTRAIT\n\n";

fs.writeFileSync(targetFile, header + md + "\n", "utf8");
console.log("✅ Synthèse documentaire décontaminée écrite avec succès dans : " + targetFile);
' "${TEMP_HTML}" "${TARGET_FILE}" "${TARGET_URL}" "${SUBJECT_CLEAN}"

echo -e "${GREEN}🎯 [san_searcher] Sas étanche complété. Le contexte de l'orchestrateur est protégé.${NC}"
echo -e "${CYAN}📄 Livrable prêt : ${TARGET_FILE}${NC}"
exit 0
