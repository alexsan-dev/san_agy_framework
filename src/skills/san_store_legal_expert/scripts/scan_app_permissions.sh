#!/usr/bin/env bash
# ==============================================================================
# Script      : scan_app_permissions.sh
# Description : Analyse statique déterministe des permissions (Android/iOS/Expo)
#               et détection des SDKs tiers collecteurs de données personnelles.
# Framework   : Google Antigravity (san_*) — alexsan.pro
# ==============================================================================
set -euo pipefail

TARGET_DIR="${1:-.}"

# Couleurs ANSI
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BOLD}${BLUE}    ANTIGRAVITY STORE PERMISSIONS & DATA-COLLECTION SDK SCANNER   ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "${CYAN}Cible d'analyse : ${BOLD}${TARGET_DIR}${NC}\n"

TOTAL_ANDROID_PERMS=0
TOTAL_IOS_PERMS=0
TOTAL_EXPO_PERMS=0
TOTAL_SDKS_FOUND=0

# ------------------------------------------------------------------------------
# 1. Analyse des permissions Android (AndroidManifest.xml)
# ------------------------------------------------------------------------------
echo -e "${BLUE}[1/4] Recherche des permissions Android (AndroidManifest.xml)...${NC}"
ANDROID_MANIFESTS=$(find "$TARGET_DIR" -type f -name "AndroidManifest.xml" \
  -not -path "*/node_modules/*" \
  -not -path "*/build/*" \
  -not -path "*/.gradle/*" \
  -not -path "*/dist/*" 2>/dev/null || true)

if [ -n "$ANDROID_MANIFESTS" ]; then
  echo -e "${GREEN}✓ Fichiers AndroidManifest.xml détectés :${NC}"
  while IFS= read -r manifest; do
    [ -z "$manifest" ] && continue
    echo -e "  ${BOLD}Fichier :${NC} $manifest"
    PERMS=$(grep -o 'android:name="android.permission.[^"]*"' "$manifest" 2>/dev/null | cut -d'"' -f2 | sort -u || true)
    if [ -n "$PERMS" ]; then
      while IFS= read -r perm; do
        [ -z "$perm" ] && continue
        echo -e "    ${YELLOW}↳ Android Permission : $perm${NC}"
        TOTAL_ANDROID_PERMS=$((TOTAL_ANDROID_PERMS + 1))
      done <<< "$PERMS"
    else
      echo "    ↳ Aucune balise <uses-permission> standard trouvée."
    fi
  done <<< "$ANDROID_MANIFESTS"
else
  echo -e "${YELLOW}ℹ Aucun fichier AndroidManifest.xml direct détecté (peut être un projet Expo Managed).${NC}"
fi

# ------------------------------------------------------------------------------
# 2. Analyse des permissions iOS (Info.plist)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/4] Recherche des permissions iOS (Info.plist / Usage Descriptions)...${NC}"
INFO_PLISTS=$(find "$TARGET_DIR" -type f -name "Info.plist" \
  -not -path "*/node_modules/*" \
  -not -path "*/build/*" \
  -not -path "*/Pods/*" \
  -not -path "*/DerivedData/*" 2>/dev/null || true)

if [ -n "$INFO_PLISTS" ]; then
  echo -e "${GREEN}✓ Fichiers Info.plist détectés :${NC}"
  while IFS= read -r plist; do
    [ -z "$plist" ] && continue
    echo -e "  ${BOLD}Fichier :${NC} $plist"
    # Extrait les clés NS.*UsageDescription et leur valeur immédiate
    USAGE_LINES=$(grep -E "<key>NS[A-Za-z]+UsageDescription</key>" "$plist" -A 1 2>/dev/null || true)
    if [ -n "$USAGE_LINES" ]; then
      CURRENT_KEY=""
      while IFS= read -r line; do
        if echo "$line" | grep -q "<key>"; then
          CURRENT_KEY=$(echo "$line" | sed -E 's/.*<key>(.*)<\/key>.*/\1/')
          echo -e "    ${YELLOW}↳ iOS Usage Key : $CURRENT_KEY${NC}"
          TOTAL_IOS_PERMS=$((TOTAL_IOS_PERMS + 1))
        elif echo "$line" | grep -q "<string>" && [ -n "$CURRENT_KEY" ]; then
          VAL=$(echo "$line" | sed -E 's/.*<string>(.*)<\/string>.*/\1/' | sed 's/^[ \t]*//')
          echo -e "      ${CYAN}Texte de justification : \"$VAL\"${NC}"
          CURRENT_KEY=""
        fi
      done <<< "$USAGE_LINES"
    else
      echo "    ↳ Aucune clé NS*UsageDescription trouvée dans ce plist."
    fi
  done <<< "$INFO_PLISTS"
else
  echo -e "${YELLOW}ℹ Aucun fichier Info.plist direct détecté (peut être généré dynamiquement via Expo Prebuild).${NC}"
fi

# ------------------------------------------------------------------------------
# 3. Analyse de la configuration Expo (app.json / app.config.js / app.config.ts)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/4] Analyse de la configuration Expo (app.json / app.config.*)...${NC}"
EXPO_CONFIGS=$(find "$TARGET_DIR" -maxdepth 3 \( -name "app.json" -o -name "app.config.js" -o -name "app.config.ts" \) \
  -not -path "*/node_modules/*" 2>/dev/null || true)

if [ -n "$EXPO_CONFIGS" ]; then
  while IFS= read -r cfg; do
    [ -z "$cfg" ] && continue
    echo -e "${GREEN}✓ Configuration Expo trouvée : $cfg${NC}"
    
    # Permissions déclarées dans app.json
    if grep -q '"permissions"' "$cfg" 2>/dev/null; then
      echo -e "  ${BOLD}Bloc 'permissions' détecté :${NC}"
      EXPO_PERMS=$(grep -A 15 '"permissions"' "$cfg" | grep -o '"[A-Z0-9_]*"' | tr -d '"' || true)
      if [ -n "$EXPO_PERMS" ]; then
        while IFS= read -r p; do
          [ -z "$p" ] && continue
          echo -e "    ${YELLOW}↳ Expo Permission : $p${NC}"
          TOTAL_EXPO_PERMS=$((TOTAL_EXPO_PERMS + 1))
        done <<< "$EXPO_PERMS"
      fi
    fi

    # Plugins Expo avec permissions (camera, location, notifications, contacts, etc.)
    if grep -q '"plugins"' "$cfg" 2>/dev/null; then
      echo -e "  ${BOLD}Inspection des plugins Expo déclarés :${NC}"
      grep -E '"(expo-camera|expo-location|expo-image-picker|expo-notifications|expo-contacts|expo-media-library|expo-tracking-transparency)"' "$cfg" | while read -r plugin_line; do
        PLUGIN_NAME=$(echo "$plugin_line" | grep -o '"expo-[^"]*"' | head -n 1 | tr -d '"')
        if [ -n "$PLUGIN_NAME" ]; then
          echo -e "    ${YELLOW}↳ Expo Plugin sensible : $PLUGIN_NAME${NC}"
        fi
      done || true
    fi
  done <<< "$EXPO_CONFIGS"
else
  echo -e "${YELLOW}ℹ Aucun fichier app.json / app.config.* détecté.${NC}"
fi

# ------------------------------------------------------------------------------
# 4. Détection des SDKs tiers collecteurs de données (package.json)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[4/4] Détection des SDKs tiers de tracking, analytics, crash & paiements...${NC}"
PACKAGE_JSONS=$(find "$TARGET_DIR" -maxdepth 3 -name "package.json" \
  -not -path "*/node_modules/*" 2>/dev/null || true)

if [ -n "$PACKAGE_JSONS" ]; then
  # Base de connaissances des SDKs à déclaration obligatoire
  KNOWN_SDKS=(
    "@react-native-firebase/analytics:Google Analytics for Firebase:Analytics & Comportement"
    "@react-native-firebase/crashlytics:Firebase Crashlytics:Diagnostic & Crash Reporting"
    "@react-native-firebase/messaging:Firebase Cloud Messaging:Notifications Push"
    "@react-native-firebase/auth:Firebase Authentication:Identifiants & Connexion"
    "react-native-fbsdk-next:Meta / Facebook SDK:Publicité & Attribution"
    "expo-tracking-transparency:Apple App Tracking Transparency:Attribution & Consentement"
    "@sentry/react-native:Sentry SDK:Diagnostic d'Erreurs & Performance"
    "react-native-onesignal:OneSignal SDK:Marketing & Notifications Push"
    "expo-location:Expo Location:Géolocalisation Précise/Approximative"
    "expo-camera:Expo Camera:Appareil Photo & Scan QR"
    "expo-image-picker:Expo Image Picker:Bibliothèque Photo & Médias"
    "expo-media-library:Expo Media Library:Stockage & Accès Fichiers"
    "expo-contacts:Expo Contacts:Carnet d'Adresses & Contacts"
    "react-native-adjust:Adjust SDK:Attribution Publicitaire"
    "react-native-appsflyer:AppsFlyer SDK:Attribution Mobile"
    "mixpanel-react-native:Mixpanel SDK:Product Analytics"
    "@segment/analytics-react-native:Segment SDK:Customer Data Platform"
    "@stripe/stripe-react-native:Stripe SDK:Paiements Bancaires"
  )

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    echo -e "${GREEN}✓ Fichier package.json analysé : $pkg${NC}"
    for entry in "${KNOWN_SDKS[@]}"; do
      SDK_PKG=$(echo "$entry" | cut -d':' -f1)
      SDK_NAME=$(echo "$entry" | cut -d':' -f2)
      SDK_PURPOSE=$(echo "$entry" | cut -d':' -f3)

      if grep -q "\"$SDK_PKG\"" "$pkg" 2>/dev/null; then
        echo -e "  ${RED}[SDK DÉTECTÉ] ${BOLD}$SDK_NAME${NC} (${CYAN}$SDK_PKG${NC})"
        echo -e "    ↳ Finalité technique : ${YELLOW}$SDK_PURPOSE${NC}"
        echo -e "    ↳ ${BOLD}Action : Déclaration obligatoire dans docs/PRIVACY_POLICY.md & docs/DATA_MAP.md${NC}"
        TOTAL_SDKS_FOUND=$((TOTAL_SDKS_FOUND + 1))
      fi
    done
  done <<< "$PACKAGE_JSONS"
else
  echo -e "${YELLOW}ℹ Aucun package.json trouvé dans le périmètre analysé.${NC}"
fi

# ------------------------------------------------------------------------------
# Synthèse & Rapport
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}==================================================================${NC}"
echo -e "${BOLD}SYNTHÈSE DU SCAN STATIQUE :${NC}"
echo -e "  - Permissions Android trouvées : ${BOLD}$TOTAL_ANDROID_PERMS${NC}"
echo -e "  - Clés Usage iOS trouvées      : ${BOLD}$TOTAL_IOS_PERMS${NC}"
echo -e "  - Permissions Expo trouvées    : ${BOLD}$TOTAL_EXPO_PERMS${NC}"
echo -e "  - SDKs collecteurs détectés    : ${BOLD}$TOTAL_SDKS_FOUND${NC}"
echo -e "${BLUE}==================================================================${NC}"

if [ "$TOTAL_SDKS_FOUND" -gt 0 ] || [ "$TOTAL_ANDROID_PERMS" -gt 0 ] || [ "$TOTAL_IOS_PERMS" -gt 0 ]; then
  echo -e "${GREEN}✓ Scan terminé. Reportez ces éléments dans docs/STORE_CHECKLIST.md et docs/DATA_MAP.md.${NC}"
else
  echo -e "${YELLOW}ℹ Aucune permission sensible ni SDK tiers collecteur détecté dans ce répertoire.${NC}"
fi

exit 0
