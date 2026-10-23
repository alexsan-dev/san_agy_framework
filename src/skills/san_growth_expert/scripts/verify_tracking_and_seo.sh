#!/usr/bin/env bash
# ==============================================================================
# Script      : verify_tracking_and_seo.sh
# Description : Audit déterministe du SEO technique, sitemap, métas et validation
#               syntaxique stricte des blocs Schema.org JSON-LD.
# Framework   : Google Antigravity (san_*) — alexsan.pro
# ==============================================================================
set -euo pipefail

TARGET_URL="${1:-https://alexsan.pro}"
SITEMAP_URL="${TARGET_URL%/}/sitemap.xml"
ROBOTS_URL="${TARGET_URL%/}/robots.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BOLD}${BLUE}    ANTIGRAVITY SEO, SITEMAP & SCHEMA.ORG AUDITOR                 ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "${CYAN}URL Cible analysée : ${BOLD}${TARGET_URL}${NC}\n"

# ------------------------------------------------------------------------------
# 1. Contrôle du fichier robots.txt
# ------------------------------------------------------------------------------
echo -e "${BLUE}[1/4] Vérification de l'accessibilité de robots.txt...${NC}"
ROBOTS_HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$ROBOTS_URL" 2>/dev/null || echo "000")

if [ "$ROBOTS_HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ robots.txt accessible (HTTP 200) sur $ROBOTS_URL.${NC}"
  ROBOTS_CONTENT=$(curl -s -L "$ROBOTS_URL" 2>/dev/null || true)
  if echo "$ROBOTS_CONTENT" | grep -qiE "^[ \t]*Sitemap:[ \t]*https?://"; then
    SITEMAP_REF=$(echo "$ROBOTS_CONTENT" | grep -iE "^[ \t]*Sitemap:" | head -n 1)
    echo -e "${GREEN}✓ Référence au sitemap déclarée : ${CYAN}$SITEMAP_REF${NC}"
  else
    echo -e "${YELLOW}⚠ AVERTISSEMENT : Aucune directive 'Sitemap:' explicite détectée dans robots.txt.${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "${RED}✗ ERREUR : robots.txt introuvable ou inaccessible (Code HTTP: $ROBOTS_HTTP_CODE) sur $ROBOTS_URL !${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ------------------------------------------------------------------------------
# 2. Contrôle du fichier sitemap.xml
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/4] Vérification de l'accessibilité et du volume de sitemap.xml...${NC}"
SITEMAP_HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$SITEMAP_URL" 2>/dev/null || echo "000")

if [ "$SITEMAP_HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✓ sitemap.xml accessible (HTTP 200) sur $SITEMAP_URL.${NC}"
  SITEMAP_CONTENT=$(curl -s -L "$SITEMAP_URL" 2>/dev/null || true)
  URL_COUNT=$(echo "$SITEMAP_CONTENT" | grep -c "<loc>" || true)
  echo -e "${GREEN}✓ Nombre d'URLs indexées détectées (<loc>) : ${BOLD}$URL_COUNT${NC}."
  if [ "$URL_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ ERREUR : sitemap.xml ne contient aucune balise d'URL <loc> !${NC}"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo -e "${RED}✗ ERREUR : sitemap.xml inaccessible (Code HTTP: $SITEMAP_HTTP_CODE) sur $SITEMAP_URL !${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ------------------------------------------------------------------------------
# 3. Contrôle des balises méta indispensables de la page
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/4] Inspection des balises <meta> et en-têtes d'indexation...${NC}"
PAGE_HTML=$(curl -s -L "$TARGET_URL" 2>/dev/null || true)

if [ -z "$PAGE_HTML" ]; then
  echo -e "${RED}✗ ERREUR CRITIQUE : Impossible de récupérer le contenu HTML de $TARGET_URL !${NC}"
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

        # Contrôles sémantiques ciblés
        if schema_type == "LocalBusiness":
            currency = data.get("currenciesAccepted", "")
            address = data.get("address", {})
            locality = address.get("addressLocality", "") if isinstance(address, dict) else ""
            curr_str = currency if currency else "Non spécifié"
            loc_str = locality if locality else "Non spécifié"
            print(f"    - Devise acceptée  : {curr_str}")
            print(f"    - Localité urbaine : {loc_str}")
        elif schema_type == "MobileApplication":
            os_val = data.get("operatingSystem", "")
            os_str = os_val if os_val else "Non spécifié"
            print(f"    - Systèmes supportés : {os_str}")

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
    # Fallback jq si python3 non disponible
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
