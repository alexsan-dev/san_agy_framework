#!/usr/bin/env node
// ==============================================================================
// SCRIPT : validate_copy_length.mjs
// FRAMEWORK : Antigravity (san_*)
// AUTEUR : san_copywriter
// DESCRIPTION : Contrôle déterministe des limites de caractères imposées par
//               l'App Store d'Apple, le Google Play Store et les composants UI étroits.
//
// USAGE :
//   node scripts/validate_copy_length.mjs [CHEMIN_STORE_COPY.md]
// ==============================================================================

import fs from 'fs';
import path from 'path';

const SPEC_LIMITS = {
  store_title: 30,             // Titre Google Play & App Store (30 car.)
  store_subtitle: 30,          // Sous-titre App Store (30 car.)
  store_short_description: 80, // Description courte Play Store (80 car.)
  cta_button: 28,              // Longueur max recommandée pour bouton mobile 360px
  push_title: 40,              // Titre notification push
  push_body: 120               // Corps notification push
};

const targetFile = process.argv[2] || 'docs/STORE_COPY.md';

console.log(`\x1b[34m\x1b[1m=== [san_copywriter] Audit de Longueur de Micro-Copie ===\x1b[0m`);
console.log(`\x1b[36mFichier analysé :\x1b[0m ${targetFile}`);

if (!fs.existsSync(targetFile)) {
  console.log(`\x1b[33m[INFO] Fichier ${targetFile} non présent. Audit terminé sans erreur.\x1b[0m`);
  process.exit(0);
}

const content = fs.readFileSync(targetFile, 'utf-8');
let hasViolations = false;

function checkLimit(label, text, maxLimit) {
  if (!text) return;
  const len = text.length;
  if (len > maxLimit) {
    console.error(`\x1b[31m❌ [DÉPASSEMENT] ${label} (${len}/${maxLimit} car.) :\x1b[0m "${text}"`);
    hasViolations = true;
  } else {
    console.log(`\x1b[32m✔ [CONFORME] ${label} (${len}/${maxLimit} car.) :\x1b[0m "${text}"`);
  }
}

// 1. Audit Titre App Store & Google Play
const titleMatch = content.match(/Titre \(Max 30 car\.\)\s*:\s*([^\n]+)/i) ||
                   content.match(/Nom de l'application \(Max 30 car\.\)\s*:\s*([^\n]+)/i);
if (titleMatch) {
  checkLimit('Titre Store (App Store / Play Store)', titleMatch[1].trim(), SPEC_LIMITS.store_title);
}

// 2. Audit Sous-titre App Store
const subtitleMatch = content.match(/Sous-titre \(Max 30 car\.\)\s*:\s*([^\n]+)/i);
if (subtitleMatch) {
  checkLimit('Sous-titre App Store', subtitleMatch[1].trim(), SPEC_LIMITS.store_subtitle);
}

// 3. Audit Description Courte Play Store
const shortDescMatch = content.match(/Description courte \(Max 80 car\.\)\s*:\s*([^\n]+)/i);
if (shortDescMatch) {
  checkLimit('Description courte Play Store', shortDescMatch[1].trim(), SPEC_LIMITS.store_short_description);
}

if (hasViolations) {
  console.error(`\n\x1b[31m\x1b[1m🚨 [ÉCHEC] Le fichier comporte des longueurs de micro-copie non conformes aux stores.\x1b[0m`);
  console.error(`Raccourcissez les phrases pour respecter les contraintes strictes d'Apple et Google.`);
  process.exit(1);
} else {
  console.log(`\n\x1b[32m\x1b[1m🎉 [SUCCÈS] Toutes les métadonnées respectent scrupuleusement les quotas de caractères.\x1b[0m\n`);
  process.exit(0);
}
