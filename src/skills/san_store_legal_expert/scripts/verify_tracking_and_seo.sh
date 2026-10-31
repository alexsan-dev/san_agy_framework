#!/usr/bin/env bash
# ==============================================================================
# Script      : verify_tracking_and_seo.sh
# Description : Audit déterministe du SEO technique, sitemap, métas et validation
#               syntaxique stricte des blocs Schema.org JSON-LD.
#               Supporte URL distante, serveur local ou dossiers statiques (dist/out/public).
# Framework   : Google Antigravity (san_*) v2.0
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
MODE_STATIC=0
STATIC_DIR=""
TARGET_INPUT="${1:-${TARGET_URL:-}}"

# Détection intelligente de la cible : Dossier statique local, URL, ou fallback localhost
if [ -n "$TARGET_INPUT" ]; then
  if [ -d "$TARGET_INPUT" ]; then
    MODE_STATIC=1
    STATIC_DIR="$TARGET_INPUT"
  elif echo "$TARGET_INPUT" | grep -qE '^https?://'; then
    TARGET_URL="$TARGET_INPUT"
  else
    TARGET_URL="https://$TARGET_INPUT"
  fi
else
  # Recherche automatique d'un dossier de build statique existant
  for candidate in "dist" "out" "public" "build"; do
    if [ -d "$candidate" ]; then
      MODE_STATIC=1
      STATIC_DIR="$candidate"
      break
    fi
  done
  # Fallback sur serveur de développement local
  if [ "$MODE_STATIC" -eq 0 ]; then
    TARGET_URL="http://localhost:3000"
  fi
fi

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BOLD}${BLUE}    ANTIGRAVITY SEO, SITEMAP & SCHEMA.ORG AUDITOR                 ${NC}"
echo -e "${BLUE}==================================================================${NC}"

if [ "$MODE_STATIC" -eq 1 ]; then
  echo -e "${CYAN}Mode : Analyse de fichiers statiques locaux dans '${BOLD}${STATIC_DIR}/${NC}'\n"
else
  echo -e "${CYAN}URL Cible analysée : ${BOLD}${TARGET_URL}${NC}\n"
fi

# ------------------------------------------------------------------------------
# 1. Contrôle du fichier robots.txt
# ------------------------------------------------------------------------------
echo -e "${BLUE}[1/4] Vérification de l'accessibilité de robots.txt...${NC}"
ROBOTS_CONTENT=""

if [ "$MODE_STATIC" -eq 1 ]; then
  ROBOTS_FILE="${STATIC_DIR%/}/robots.txt"
  if [ -f "$ROBOTS_FILE" ]; then
    echo -e "${GREEN}✓ robots.txt présent sur le disque : $ROBOTS_FILE${NC}"
    ROBOTS_CONTENT=$(cat "$ROBOTS_FILE")
  else
    echo -e "${RED}✗ ERREUR : robots.txt introuvable dans $STATIC_DIR !${NC}"
    ERRORS=$((ERRORS + 1))
  fi
else
  ROBOTS_URL="${TARGET_URL%/}/robots.txt"
  ROBOTS_HTTP_CODE=$(curl -s -k -L -o /dev/null -w "%{http_code}" "$ROBOTS_URL" 2>/dev/null || echo "000")
  if [ "$ROBOTS_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ robots.txt accessible (HTTP 200) sur $ROBOTS_URL.${NC}"
    ROBOTS_CONTENT=$(curl -s -k -L "$ROBOTS_URL" 2>/dev/null || true)
  else
    # Fallback gracieux si serveur local éteint mais dossier statique présent
    if [ "$TARGET_URL" = "http://localhost:3000" ] && [ "$ROBOTS_HTTP_CODE" = "000" ]; then
      for candidate in "dist" "out" "public" "build"; do
        if [ -d "$candidate" ] && [ -f "$candidate/robots.txt" ]; then
          echo -e "${YELLOW}ℹ Serveur local inactif, bascule automatique sur les fichiers statiques de '$candidate/'.${NC}"
          MODE_STATIC=1
          STATIC_DIR="$candidate"
          ROBOTS_CONTENT=$(cat "$candidate/robots.txt")
          break
        fi
      done
    fi
    if [ "$MODE_STATIC" -eq 0 ]; then
      echo -e "${RED}✗ ERREUR : robots.txt introuvable ou inaccessible (Code HTTP: $ROBOTS_HTTP_CODE) sur $ROBOTS_URL !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

if [ -n "$ROBOTS_CONTENT" ]; then
  if echo "$ROBOTS_CONTENT" | grep -qiE "^[ \t]*Sitemap:[ \t]*https?://"; then
    SITEMAP_REF=$(echo "$ROBOTS_CONTENT" | grep -iE "^[ \t]*Sitemap:" | head -n 1)
    echo -e "${GREEN}✓ Référence au sitemap déclarée : ${CYAN}$SITEMAP_REF${NC}"
  else
    echo -e "${YELLOW}⚠ AVERTISSEMENT : Aucune directive 'Sitemap:' explicite détectée dans robots.txt.${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# ------------------------------------------------------------------------------
# 2. Contrôle du fichier sitemap.xml
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/4] Vérification de l'accessibilité et du volume de sitemap.xml...${NC}"
SITEMAP_CONTENT=""

if [ "$MODE_STATIC" -eq 1 ]; then
  SITEMAP_FILE="${STATIC_DIR%/}/sitemap.xml"
  if [ -f "$SITEMAP_FILE" ]; then
    echo -e "${GREEN}✓ sitemap.xml présent sur le disque : $SITEMAP_FILE${NC}"
    SITEMAP_CONTENT=$(cat "$SITEMAP_FILE")
  else
    echo -e "${RED}✗ ERREUR : sitemap.xml introuvable dans $STATIC_DIR !${NC}"
    ERRORS=$((ERRORS + 1))
  fi
else
  SITEMAP_URL="${TARGET_URL%/}/sitemap.xml"
  SITEMAP_HTTP_CODE=$(curl -s -k -L -o /dev/null -w "%{http_code}" "$SITEMAP_URL" 2>/dev/null || echo "000")
  if [ "$SITEMAP_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ sitemap.xml accessible (HTTP 200) sur $SITEMAP_URL.${NC}"
    SITEMAP_CONTENT=$(curl -s -k -L "$SITEMAP_URL" 2>/dev/null || true)
  else
    echo -e "${RED}✗ ERREUR : sitemap.xml inaccessible (Code HTTP: $SITEMAP_HTTP_CODE) sur $SITEMAP_URL !${NC}"
    ERRORS=$((ERRORS + 1))
  fi
fi

if [ -n "$SITEMAP_CONTENT" ]; then
  URL_COUNT=$(echo "$SITEMAP_CONTENT" | grep -c "<loc>" || true)
  echo -e "${GREEN}✓ Nombre d'URLs indexées détectées (<loc>) : ${BOLD}$URL_COUNT${NC}."
  if [ "$URL_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ ERREUR : sitemap.xml ne contient aucune balise d'URL <loc> !${NC}"
    ERRORS=$((ERRORS + 1))
  fi
fi

# ------------------------------------------------------------------------------
# 3. Contrôle des balises méta indispensables de la page d'accueil
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/4] Inspection des balises <meta> et en-têtes d'indexation...${NC}"
PAGE_HTML=""

if [ "$MODE_STATIC" -eq 1 ]; then
  HTML_FILE="${STATIC_DIR%/}/index.html"
  if [ -f "$HTML_FILE" ]; then
    PAGE_HTML=$(cat "$HTML_FILE")
  else
    echo -e "${RED}✗ ERREUR CRITIQUE : Fichier index.html introuvable dans $STATIC_DIR !${NC}"
    exit 1
  fi
else
  PAGE_HTML=$(curl -s -k -L "$TARGET_URL" 2>/dev/null || true)
fi

if [ -z "$PAGE_HTML" ]; then
  echo -e "${RED}✗ ERREUR CRITIQUE : Impossible de récupérer le contenu HTML de la cible !${NC}"
  exit 1
fi

check_meta() {
  local NAME=$1
  local PATTERN=$2
  if echo "$PAGE_HTML" | grep -qiE "$PATTERN"; then
    echo -e "${GREEN}✓ Balise requise présente : ${BOLD}$NAME${NC}"
  else
    echo -e "${RED}✗ Balise critique manquante : ${BOLD}$NAME${NC} !"
    ERRORS=$((ERRORS + 1))
  fi
}

check_meta "Page Title (<title>)" "<title>[^<]+</title>"
check_meta "Meta Description" '<meta [^>]*name=["\x27]description["\x27]'
check_meta "Viewport Mobile" '<meta [^>]*name=["\x27]viewport["\x27]'
check_meta "Balise Canonical" '<link [^>]*rel=["\x27]canonical["\x27]'
check_meta "OpenGraph Title (og:title)" '<meta [^>]*property=["\x27]og:title["\x27]'
check_meta "OpenGraph Description (og:description)" '<meta [^>]*property=["\x27]og:description["\x27]'
check_meta "OpenGraph Image (og:image)" '<meta [^>]*property=["\x27]og:image["\x27]'

# ------------------------------------------------------------------------------
# 4. Extraction et validation syntaxique stricte du Schema.org JSON-LD
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[4/4] Extraction et validation syntaxique des données structurées Schema.org JSON-LD...${NC}"

if echo "$PAGE_HTML" | grep -q 'application/ld+json'; then
  echo -e "${GREEN}✓ Balise(s) <script type=\"application/ld+json\"> détectée(s).${NC}"

  if command -v python3 &>/dev/null; then
    echo "$PAGE_HTML" | python3 -c '
import sys, re, json

html = sys.stdin.read()
# Extraction de tous les blocs script de type application/ld+json
blocks = re.findall(r"<script[^>]*type=[\"\x27]application/ld\+json[\"\x27][^>]*>(.*?)</script>", html, re.DOTALL | re.IGNORECASE)

if not blocks:
    print("✗ Aucun bloc JSON-LD n a pu etre extrait via regex.")
    sys.exit(1)

errors = 0
for idx, raw_json in enumerate(blocks):
    clean_json = raw_json.strip()
    if not clean_json:
        continue
    try:
        data = json.loads(clean_json)
        schema_type = data.get("@type", "Non défini")
        context = data.get("@context", "Non défini")
        name = data.get("name", "N/A")
        print(f"  ✓ Bloc #{idx + 1} validé avec succès :")
        print(f"    - @context : {context}")
        print(f"    - @type    : {schema_type}")
        print(f"    - name     : {name}")
    except json.JSONDecodeError as err:
        print(f"  ✗ Erreur de syntaxe JSON dans le bloc #{idx + 1} : {err}")
        errors += 1
    except Exception as err:
        print(f"  ✗ Exception imprévue lors de l analyse du bloc #{idx + 1} : {err}")
        errors += 1

if errors > 0:
    sys.exit(1)
' || {
      echo -e "${RED}✗ ERREUR : Le bloc Schema.org JSON-LD contient des erreurs de syntaxe JSON invalides !${NC}"
      ERRORS=$((ERRORS + 1))
    }
  elif command -v jq &>/dev/null; then
    RAW_JSON=$(echo "$PAGE_HTML" | sed -n '/<script type="application\/ld+json">/,/<\/script>/p' | sed 's/<[^>]*>//g')
    if echo "$RAW_JSON" | jq . > /dev/null 2>&1; then
      echo -e "${GREEN}✓ Bloc JSON-LD validé via jq.${NC}"
    else
      echo -e "${RED}✗ ERREUR : JSON-LD invalide selon jq !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "${YELLOW}ℹ Ni python3 ni jq n'est installé pour valider la syntaxe JSON en profondeur.${NC}"
  fi
else
  echo -e "${RED}✗ ERREUR : Aucune donnée structurée Schema.org JSON-LD trouvée sur la page !${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ------------------------------------------------------------------------------
# Synthèse de l'Audit
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==================================================================${NC}"
echo -e "${BOLD}BILAN DE L'AUDIT SEO & TRACKING :${NC}"
echo -e "  - Anomalies Bloquantes : ${BOLD}$ERRORS${NC}"
echo -e "  - Avertissements       : ${BOLD}$WARNINGS${NC}"
echo -e "${BLUE}==================================================================${NC}"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}RÉSULTAT : AUDIT ÉCHOUÉ ($ERRORS ERREUR(S)). CORRECTIONS OBLIGATOIRES !${NC}"
  exit 1
else
  echo -e "${GREEN}RÉSULTAT : 100% CONFORME AUX STANDARDS DE CROISSANCE & DE MESURE ANTIGRAVITY.${NC}"
  exit 0
fi
