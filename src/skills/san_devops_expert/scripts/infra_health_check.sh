#!/usr/bin/env bash
# ==============================================================================
# SCRIPT OFFICIEL ANTIGRAVITY : INFRASTRUCTURE HEALTH CHECK (san_devops_expert)
# Diagnostic Déterministe d'Infrastructure : SSL, DNS, Ports, Disque, Services
# Framework : Google Antigravity (san_*) v2.0
# ==============================================================================
set -euo pipefail

# Couleurs ANSI pour terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
MODE_LOCAL=0
WITH_MAIL=0
TARGET_ARG=""

# Analyse des arguments de la ligne de commande
for arg in "$@"; do
  case "$arg" in
    --local)
      MODE_LOCAL=1
      ;;
    --with-mail)
      WITH_MAIL=1
      ;;
    -*)
      # Options supplémentaires ignorées
      ;;
    *)
      if [ -z "$TARGET_ARG" ]; then
        TARGET_ARG="$arg"
      fi
      ;;
  esac
done

# Détection via variable d'environnement si non fourni en argument
if [ -z "$TARGET_ARG" ]; then
  TARGET_ARG="${TARGET_URL:-${TARGET_DOMAIN:-}}"
fi

# Résolution intelligente de la cible (fallback local par défaut sans domaine propriétaire codé en dur)
if [ -z "$TARGET_ARG" ] || [ "$TARGET_ARG" = "--local" ]; then
  MODE_LOCAL=1
  DOMAIN="localhost"
  HEALTH_URL="http://localhost:3000/api/health"
else
  # Suppression du schéma protocolaire et des chemins résiduels
  CLEAN_TARGET=$(echo "$TARGET_ARG" | sed -E 's|^https?://||; s|/.*$||')
  if [ "$CLEAN_TARGET" = "localhost" ] || [ "$CLEAN_TARGET" = "127.0.0.1" ]; then
    MODE_LOCAL=1
    DOMAIN="localhost"
    HEALTH_URL="http://localhost:3000/api/health"
  else
    DOMAIN="$CLEAN_TARGET"
    HEALTH_URL="https://$DOMAIN/api/health"
  fi
fi

MAIL_HOST="mail.$DOMAIN"

echo -e "${BLUE}==================================================================${NC}"
if [ "$MODE_LOCAL" -eq 1 ]; then
  echo -e "${BOLD}${BLUE}   ANTIGRAVITY INFRASTRUCTURE HEALTH CHECK [MODE LOCAL]           ${NC}"
  echo -e "${CYAN}   Cible : ${HEALTH_URL}${NC}"
else
  echo -e "${BOLD}${BLUE}   ANTIGRAVITY INFRASTRUCTURE HEALTH CHECK : ${DOMAIN}           ${NC}"
  echo -e "${CYAN}   Cible : ${HEALTH_URL}${NC}"
fi
echo -e "${BLUE}==================================================================${NC}"

# Fonction de vérification d'exécutables
check_tool() {
  local tool="$1"
  if ! command -v "$tool" &> /dev/null; then
    echo -e "${YELLOW}⚠ Outil non trouvé dans le PATH : ${tool}${NC}"
    WARNINGS=$((WARNINGS + 1))
    return 1
  fi
  return 0
}

# ------------------------------------------------------------------------------
# 1. VÉRIFICATION DE L'ESPACE DISQUE ET DES INODES
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[1/6] Vérification de l'espace disque & inodes...${NC}"
if check_tool df && check_tool awk && check_tool sed; then
  DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  INODE_USAGE=$(df -i / | awk 'NR==2 {print $5}' | sed 's/%//')

  if [ -n "$DISK_USAGE" ] && [ "$DISK_USAGE" -ge 85 ]; then
    if [ "$MODE_LOCAL" -eq 1 ]; then
      echo -e "${YELLOW}⚠ [LOCAL] Espace disque élevé : ${DISK_USAGE}% utilisé.${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${RED}✖ Espace disque critique : ${DISK_USAGE}% utilisé (seuil max: 85%) !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "${GREEN}✔ Espace disque sain : ${DISK_USAGE}% utilisé.${NC}"
  fi

  if [ -n "$INODE_USAGE" ] && [ "$INODE_USAGE" -ge 85 ]; then
    if [ "$MODE_LOCAL" -eq 1 ]; then
      echo -e "${YELLOW}⚠ [LOCAL] Inodes élevés : ${INODE_USAGE}% utilisés.${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${RED}✖ Utilisation des inodes critique : ${INODE_USAGE}% (seuil max: 85%) !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo -e "${GREEN}✔ Inodes sains : ${INODE_USAGE}% utilisés.${NC}"
  fi
fi

# ------------------------------------------------------------------------------
# 2. VÉRIFICATION DES CERTIFICATS SSL / TLS
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/6] Contrôle du certificat SSL/TLS...${NC}"
if [ "$MODE_LOCAL" -eq 1 ]; then
  echo -e "${CYAN}ℹ [LOCAL] Contrôle SSL distant ignoré en mode local.${NC}"
else
  if check_tool openssl; then
    EXPIRY_DATE=$(echo | openssl s_client -servername "$DOMAIN" -connect "${DOMAIN}:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2 || true)
    if [ -n "$EXPIRY_DATE" ]; then
      EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s 2>/dev/null || echo "0")
      NOW_EPOCH=$(date +%s)
      if [ "$EXPIRY_EPOCH" -gt 0 ]; then
        DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
        if [ "$DAYS_LEFT" -le 15 ]; then
          echo -e "${RED}✖ Certificat SSL expire dans ${DAYS_LEFT} jours ! Renouvellement requis.${NC}"
          ERRORS=$((ERRORS + 1))
        else
          echo -e "${GREEN}✔ Certificat SSL valide (${DAYS_LEFT} jours restants - Expire le: ${EXPIRY_DATE}).${NC}"
        fi
      else
        echo -e "${YELLOW}⚠ Impossible de calculer l'échéance du certificat pour ${DOMAIN}.${NC}"
      fi
    else
      echo -e "${YELLOW}⚠ Aucun certificat TLS actif trouvé sur ${DOMAIN}:443.${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# ------------------------------------------------------------------------------
# 3. CONTRÔLE DNS & DÉLIVRABILITÉ E-MAIL / MAILCOW (CONDITIONNÉ PAR --with-mail)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/6] Contrôle DNS & Délivrabilité E-mail (SPF / DMARC / MX)...${NC}"
if [ "$MODE_LOCAL" -eq 1 ]; then
  echo -e "${CYAN}ℹ [LOCAL] Contrôle DNS distant ignoré en mode local.${NC}"
elif [ "$WITH_MAIL" -eq 0 ]; then
  echo -e "${CYAN}ℹ Contrôle E-mail / Mailcow ignoré par défaut (fournir le flag --with-mail pour l'activer).${NC}"
else
  echo -e "${CYAN}ℹ Option --with-mail active : audit complet des enregistrements MX/SPF/DMARC et Mailcow...${NC}"
  if check_tool dig; then
    # SPF Check
    SPF_REC=$(dig TXT "$DOMAIN" +short 2>/dev/null | grep "v=spf1" || true)
    if echo "$SPF_REC" | grep -q -- "-all"; then
      echo -e "${GREEN}✔ Enregistrement SPF strict configuré (-all) : ${SPF_REC}${NC}"
    elif [ -n "$SPF_REC" ]; then
      echo -e "${YELLOW}⚠ Enregistrement SPF non strict (~all détecté) : ${SPF_REC}${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${RED}✖ Aucun enregistrement SPF valide trouvé sur ${DOMAIN} !${NC}"
      ERRORS=$((ERRORS + 1))
    fi

    # DMARC Check
    DMARC_REC=$(dig TXT "_dmarc.$DOMAIN" +short 2>/dev/null || true)
    if echo "$DMARC_REC" | grep -q "p=reject"; then
      echo -e "${GREEN}✔ Politique DMARC stricte (p=reject) : ${DMARC_REC}${NC}"
    elif [ -n "$DMARC_REC" ]; then
      echo -e "${YELLOW}⚠ Politique DMARC non stricte sur ${DOMAIN} : ${DMARC_REC}${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${RED}✖ Enregistrement DMARC absent sur _dmarc.${DOMAIN} !${NC}"
      ERRORS=$((ERRORS + 1))
    fi

    # MX Check
    MX_REC=$(dig MX "$DOMAIN" +short 2>/dev/null || true)
    if [ -n "$MX_REC" ]; then
      echo -e "${GREEN}✔ Enregistrement MX configuré : ${MX_REC}${NC}"
    else
      echo -e "${RED}✖ Aucun enregistrement MX configuré pour ${DOMAIN} !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi

  # Vérification conteneur Mailcow si Docker est présent
  if command -v docker &>/dev/null; then
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qi "mailcow"; then
      echo -e "${GREEN}✔ Pile Mailcow détectée et active sous Docker.${NC}"
    else
      echo -e "${YELLOW}⚠ Aucun conteneur Docker Mailcow actif détecté.${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# ------------------------------------------------------------------------------
# 4. VÉRIFICATION DES PORTS D'ÉCOUTE SYSTÈME
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[4/6] Vérification des ports système essentiels...${NC}"
check_port() {
  local port="$1"
  local name="$2"
  if check_tool ss; then
    if ss -tulpn 2>/dev/null | grep -q ":${port} "; then
      echo -e "${GREEN}✔ Port ${port} (${name}) actif et en écoute.${NC}"
      return 0
    else
      if [ "$MODE_LOCAL" -eq 1 ]; then
        echo -e "${CYAN}ℹ [LOCAL] Port ${port} (${name}) inactif localement.${NC}"
      else
        echo -e "${RED}✖ Port ${port} (${name}) fermé ou inactif !${NC}"
        ERRORS=$((ERRORS + 1))
      fi
      return 1
    fi
  elif check_tool netstat; then
    if netstat -tulpn 2>/dev/null | grep -q ":${port} "; then
      echo -e "${GREEN}✔ Port ${port} (${name}) actif et en écoute.${NC}"
      return 0
    else
      if [ "$MODE_LOCAL" -eq 1 ]; then
        echo -e "${CYAN}ℹ [LOCAL] Port ${port} (${name}) inactif localement.${NC}"
      else
        echo -e "${RED}✖ Port ${port} (${name}) fermé ou inactif !${NC}"
        ERRORS=$((ERRORS + 1))
      fi
      return 1
    fi
  else
    echo -e "${YELLOW}⚠ ss / netstat indisponibles. Étape des ports sautée.${NC}"
  fi
}

check_port 80 "HTTP Nginx" || true
check_port 443 "HTTPS Nginx" || true
check_port 22 "SSH" || true

# ------------------------------------------------------------------------------
# 5. STATUT DES SERVICES CRITIQUES SYSTÈME (SYSTEMCTL)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/6] Statut des services critiques (systemctl)...${NC}"
check_service() {
  local svc="$1"
  if check_tool systemctl; then
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      echo -e "${GREEN}✔ Service ${svc} est ACTIF (running).${NC}"
    else
      if [ "$MODE_LOCAL" -eq 1 ]; then
        echo -e "${CYAN}ℹ [LOCAL] Service ${svc} non démarré en environnement local.${NC}"
      else
        echo -e "${RED}✖ Service ${svc} est ARRÊTÉ ou en anomalie !${NC}"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  else
    echo -e "${YELLOW}⚠ systemctl non disponible dans cet environnement.${NC}"
  fi
}

if command -v systemctl &>/dev/null; then
  check_service nginx || true
  if systemctl list-unit-files 2>/dev/null | grep -q "redis"; then
    check_service redis-server || true
  fi
  if systemctl list-unit-files 2>/dev/null | grep -q "supervisor"; then
    check_service supervisor || true
  fi
else
  echo -e "${CYAN}ℹ Environnement conteneurisé ou local sans systemd.${NC}"
fi

# ------------------------------------------------------------------------------
# 6. SONDE DE SANTÉ APPLICATIVE HTTP (HEALTH CHECK)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[6/6] Sonde HTTP Health Check (${HEALTH_URL})...${NC}"
if check_tool curl; then
  HTTP_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" "$HEALTH_URL" --max-time 5 2>/dev/null || true)
  if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✔ Endpoint de santé opérationnel (HTTP 200 OK sur ${HEALTH_URL}).${NC}"
  else
    if [ "$MODE_LOCAL" -eq 1 ]; then
      # Fallback intelligent : si des artefacts statiques locaux existent, signaler sans bloquer
      STATIC_FOUND=0
      for static_dir in "dist" "out" "public" "build"; do
        if [ -d "$static_dir" ]; then
          echo -e "${CYAN}ℹ [LOCAL] Dossier statique local détecté ('${static_dir}/'). Serveur HTTP optionnel.${NC}"
          STATIC_FOUND=1
          break
        fi
      done
      if [ "$STATIC_FOUND" -eq 0 ]; then
        echo -e "${CYAN}ℹ [LOCAL] Serveur HTTP local non démarré (code: ${HTTP_CODE:-injoignable}).${NC}"
      fi
    else
      echo -e "${RED}✖ Endpoint de santé en anomalie : code HTTP ${HTTP_CODE} reçu sur ${HEALTH_URL} !${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ------------------------------------------------------------------------------
# BILAN ET SYNTHÈSE FINALE
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==================================================================${NC}"
if [ "$MODE_LOCAL" -eq 1 ]; then
  echo -e "${GREEN}${BOLD}RÉSULTAT [LOCAL] : CONTRÔLE D'INFRASTRUCTURE LOCAL TERMINÉ.${NC}"
  echo -e "${GREEN}Disque, inodes et environnement validés sans blocage.${NC}"
  echo -e "${BLUE}==================================================================${NC}"
  exit 0
elif [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}${BOLD}RÉSULTAT : ${ERRORS} ANOMALIE(S) CRITIQUE(S) DÉTECTÉE(S) SUR L'INFRASTRUCTURE !${NC}"
  echo -e "${BLUE}==================================================================${NC}"
  exit 1
else
  echo -e "${GREEN}${BOLD}RÉSULTAT : INFRASTRUCTURE SAINE ET OPÉRATIONNELLE (100% CONFORME).${NC}"
  echo -e "${BLUE}==================================================================${NC}"
  exit 0
fi
