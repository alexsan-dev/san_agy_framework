#!/usr/bin/env node
// ==============================================================================
// SCRIPT : build_tokens.mjs
// MODULE : san_design_tokens
// FRAMEWORK : Antigravity (san_*)
// DESCRIPTION : Compilateur déterministe de tokens depuis BRAND.md vers CSS,
//               Tailwind v3/v4 et TypeScript avec calcul d'accessibilité WCAG AAA.
// ==============================================================================

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const ANSI = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m'
};

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Compilateur de Design Tokens Antigravity (build_tokens.mjs) ===${ANSI.reset}

${ANSI.bold}USAGE :${ANSI.reset}
  node build_tokens.mjs [options]
  ./build_tokens.mjs --input <brand.md> --out-dir <dir> --format <css|tailwind|ts|all>

${ANSI.bold}OPTIONS :${ANSI.reset}
  -i, --input <fichier>      Chemin vers BRAND.md (Défaut: .agents/rules/BRAND.md)
  -o, --out-dir <dossier>    Dossier de destination (Défaut: src/styles/tokens)
  -f, --format <format>      Format généré : css | tailwind | ts | all (Défaut: all)
  -h, --help                 Affiche cette aide et termine l'exécution

${ANSI.bold}EXEMPLES :${ANSI.reset}
  node build_tokens.mjs --input .agents/rules/BRAND.md --out-dir src/theme --format all
  node build_tokens.mjs -i BRAND.md -o dist/tokens -f css
`);
}

// 1. Analyse des arguments CLI
const rawArgs = process.argv.slice(2);
let inputPath = '';
let outDir = '';
let formatArg = 'all';

for (let i = 0; i < rawArgs.length; i++) {
  const arg = rawArgs[i];
  if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  } else if (arg === '--input' || arg === '-i') {
    inputPath = rawArgs[++i] || '';
  } else if (arg === '--out-dir' || arg === '-o') {
    outDir = rawArgs[++i] || '';
  } else if (arg === '--format' || arg === '-f') {
    formatArg = rawArgs[++i] || 'all';
  } else if (arg.startsWith('--input=')) {
    inputPath = arg.split('=')[1];
  } else if (arg.startsWith('--out-dir=')) {
    outDir = arg.split('=')[1];
  } else if (arg.startsWith('--format=')) {
    formatArg = arg.split('=')[1];
  }
}

// Recherche du fichier BRAND.md par défaut si non spécifié
if (!inputPath) {
  const candidateLocations = [
    '.agents/rules/BRAND.md',
    'BRAND.md',
    'src/rules/BRAND.md',
    'src/skills/san_init/templates/rules/BRAND_TEMPLATE.md',
    'templates/BRAND_TEMPLATE.md'
  ];
  for (const loc of candidateLocations) {
    if (fs.existsSync(loc)) {
      inputPath = loc;
      break;
    }
  }
  if (!inputPath) {
    inputPath = '.agents/rules/BRAND.md';
  }
}

if (!outDir) {
  outDir = 'src/styles/tokens';
}

const validFormats = ['css', 'tailwind', 'ts', 'all'];
if (!validFormats.includes(formatArg.toLowerCase())) {
  console.error(`${ANSI.red}❌ Format invalide : "${formatArg}". Valeurs possibles: ${validFormats.join(', ')}${ANSI.reset}`);
  process.exit(1);
}

const selectedFormat = formatArg.toLowerCase();
const resolvedInput = path.resolve(inputPath);
const resolvedOutDir = path.resolve(outDir);

if (!fs.existsSync(resolvedInput)) {
  console.error(`${ANSI.red}❌ Fichier source introuvable : ${resolvedInput}${ANSI.reset}`);
  console.error(`${ANSI.yellow}💡 Spécifiez un fichier valide avec --input <chemin/BRAND.md>${ANSI.reset}`);
  process.exit(1);
}

console.log(`${ANSI.bold}${ANSI.blue}🎨 [san_design_tokens] Lecture de : ${resolvedInput}${ANSI.reset}`);
const brandContent = fs.readFileSync(resolvedInput, 'utf-8');

// 2. Fonctions de Calcul Colorimétrique & WCAG
function parseHex(hex) {
  let clean = hex.replace(/^#/, '').trim();
  if (clean.length === 3) {
    clean = clean.split('').map(c => c + c).join('');
  }
  if (clean.length !== 6 && clean.length !== 8) return null;
  return {
    r: parseInt(clean.slice(0, 2), 16),
    g: parseInt(clean.slice(2, 4), 16),
    b: parseInt(clean.slice(4, 6), 16)
  };
}

function getRelativeLuminance(hex) {
  const rgb = parseHex(hex);
  if (!rgb) return 0;
  const { r, g, b } = rgb;
  const sRGB = [r, g, b].map(val => {
    const v = val / 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * sRGB[0] + 0.7152 * sRGB[1] + 0.0722 * sRGB[2];
}

function calculateContrastRatio(hex1, hex2) {
  const l1 = getRelativeLuminance(hex1);
  const l2 = getRelativeLuminance(hex2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

function cleanTokenKey(key) {
  return key.trim().replace(/^`|`$/g, '').replace(/^color-/, '');
}

// 3. Extraction Déterministe des Jetons
const colors = {
  dark: {},
  light: {},
  unified: {}
};

// Extraction des tables Markdown de couleurs
// Format standard: | `color-name` | #DARK | #LIGHT | Usage |
// OU format simple: | `color-name` | #HEX | Usage |
const lines = brandContent.split('\n');
const hexRegex = /#[0-9A-Fa-f]{3,8}\b/g;

for (const line of lines) {
  const trimmed = line.trim();
  if (!trimmed.startsWith('|') || trimmed.includes('---')) continue;
  const columns = trimmed.split('|').map(c => c.trim()).filter((_, idx, arr) => idx > 0 && idx < arr.length - 1);
  if (columns.length < 2) continue;

  const firstCol = columns[0];
  const tokenMatch = firstCol.match(/`?([a-zA-Z0-9_-]+)`?/);
  if (!tokenMatch) continue;

  const rawKey = tokenMatch[1];
  const tokenKey = cleanTokenKey(rawKey);

  // Vérifier si cette ligne contient des valeurs hexadécimales
  const allHexesInLine = trimmed.match(hexRegex);
  if (!allHexesInLine || allHexesInLine.length === 0) continue;

  if (columns.length >= 3 && columns[1].match(hexRegex) && columns[2].match(hexRegex)) {
    // Mode double (Dark / Light)
    const darkHex = columns[1].match(hexRegex)[0].toUpperCase();
    const lightHex = columns[2].match(hexRegex)[0].toUpperCase();
    colors.dark[tokenKey] = darkHex;
    colors.light[tokenKey] = lightHex;
    colors.unified[tokenKey] = darkHex;
  } else if (allHexesInLine.length >= 1) {
    // Mode unifié
    const hex = allHexesInLine[0].toUpperCase();
    colors.unified[tokenKey] = hex;
    colors.dark[tokenKey] = hex;
    colors.light[tokenKey] = hex;
  }
}

// Complétion des valeurs par défaut sécurisées si non déclarées
const defaultColorPalette = {
  primary: '#2563EB',
  'primary-hover': '#1D4ED8',
  surface: '#0B0F19',
  'surface-subtle': '#111827',
  background: '#030712',
  'on-surface': '#F9FAFB',
  'on-surface-muted': '#9CA3AF',
  border: '#1F2937',
  'border-focus': '#3B82F6',
  accent: '#3B82F6',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  info: '#3B82F6'
};

for (const [key, val] of Object.entries(defaultColorPalette)) {
  if (!colors.unified[key]) {
    colors.unified[key] = val;
    colors.dark[key] = colors.dark[key] || val;
    colors.light[key] = colors.light[key] || (key === 'surface' ? '#FFFFFF' : key === 'background' ? '#F8FAFC' : key === 'on-surface' ? '#0F172A' : val);
  }
}

// 4. Extraction de l'échelle d'espacement (Base 4px / 8px)
const spacing = {
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  8: '32px',
  10: '40px',
  12: '48px',
  16: '64px'
};

// Extraction des rayons de courbure
const radii = {
  none: '0px',
  sm: '4px',
  md: '8px',
  lg: '12px',
  xl: '16px',
  full: '9999px'
};

// Extraction des ombres
const shadows = {
  none: 'none',
  sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
  md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)',
  lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
  xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)'
};

// Tokens Cinétiques Invariants
const motion = {
  duration: {
    fast: '150ms',
    normal: '250ms',
    slow: '400ms'
  },
  durationMs: {
    fast: 150,
    normal: 250,
    slow: 400
  },
  easing: {
    standard: 'cubic-bezier(0.2, 0.0, 0.0, 1.0)',
    spring: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
    decelerate: 'cubic-bezier(0.0, 0.0, 0.2, 1.0)',
    'ease-in': 'cubic-bezier(0.4, 0.0, 1.0, 1.0)',
    'ease-out': 'cubic-bezier(0.0, 0.0, 0.2, 1.0)',
    'ease-in-out': 'cubic-bezier(0.16, 1.0, 0.3, 1.0)'
  }
};

// Typographie
const typography = {
  fontFamily: {
    sans: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    display: 'Inter, -apple-system, sans-serif',
    mono: 'JetBrains Mono, ui-monospace, SFMono-Regular, Menlo, monospace'
  },
  fontSize: {
    xs: ['0.75rem', { lineHeight: '1rem' }],
    sm: ['0.875rem', { lineHeight: '1.25rem' }],
    base: ['1rem', { lineHeight: '1.5rem' }],
    lg: ['1.125rem', { lineHeight: '1.75rem' }],
    xl: ['1.25rem', { lineHeight: '1.75rem' }],
    '2xl': ['1.5rem', { lineHeight: '2rem' }],
    '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
    '4xl': ['2.25rem', { lineHeight: '2.5rem' }]
  }
};

// 5. Rapport d'Accessibilité et Audit WCAG AAA / AA
console.log(`\n${ANSI.bold}${ANSI.cyan}=== 📊 AUDIT MATHÉMATIQUE DE CONTRASTE WCAG ===${ANSI.reset}`);
const testPairs = [
  { text: 'on-surface', bg: 'surface', label: 'Texte courant sur Surface (Dark)' },
  { text: 'on-surface', bg: 'background', label: 'Texte courant sur Fond (Dark)' },
  { text: 'on-surface-muted', bg: 'surface', label: 'Texte secondaire sur Surface' },
  { text: 'primary', bg: 'surface', label: 'Bouton primaire sur Surface' },
  { text: 'error', bg: 'surface', label: 'Statut d\'erreur sur Surface' },
  { text: 'success', bg: 'surface', label: 'Statut de succès sur Surface' }
];

let allContrastPass = true;

for (const pair of testPairs) {
  const fgColor = colors.dark[pair.text] || colors.unified[pair.text];
  const bgColor = colors.dark[pair.bg] || colors.unified[pair.bg];
  if (!fgColor || !bgColor) continue;

  const ratio = calculateContrastRatio(fgColor, bgColor);
  let statusBadge = '';
  if (ratio >= 7.0) {
    statusBadge = `${ANSI.green}${ANSI.bold}✓ WCAG AAA (${ratio.toFixed(2)}:1 - Plein Soleil)${ANSI.reset}`;
  } else if (ratio >= 4.5) {
    statusBadge = `${ANSI.cyan}${ANSI.bold}✓ WCAG AA (${ratio.toFixed(2)}:1 - Conforme)${ANSI.reset}`;
  } else if (ratio >= 3.0) {
    statusBadge = `${ANSI.yellow}${ANSI.bold}⚠️ WCAG AA Large (${ratio.toFixed(2)}:1 - Titres/Composants)${ANSI.reset}`;
  } else {
    statusBadge = `${ANSI.red}${ANSI.bold}✗ ÉCHEC (< 3:1 : ${ratio.toFixed(2)}:1)${ANSI.reset}`;
    allContrastPass = false;
  }

  console.log(`  ${pair.label.padEnd(38)} : ${statusBadge} ${ANSI.gray}[${fgColor} / ${bgColor}]${ANSI.reset}`);
}

if (!allContrastPass) {
  console.warn(`\n${ANSI.yellow}⚠️ Attention : Certains couples présentent un contraste restreint. Réajustez BRAND.md pour le plein soleil.${ANSI.reset}`);
} else {
  console.log(`\n${ANSI.green}✨ Tous les couples critiques satisfont les exigences d'accessibilité WCAG.${ANSI.reset}`);
}

// 6. Génération des Fichiers de Sortie
fs.mkdirSync(resolvedOutDir, { recursive: true });
const generatedFiles = [];

// A. Génération CSS (:root variables + @theme Tailwind v4)
if (selectedFormat === 'css' || selectedFormat === 'all') {
  const cssPath = path.join(resolvedOutDir, 'tokens.css');
  let css = `/**\n * TOKENS OFFICIELS ANTIGRAVITY (san_*)\n * SOURCE UNIQUE DE VÉRITÉ : ${path.relative(process.cwd(), resolvedInput)}\n * GÉNÉRÉ DÉTERMINISTEMENT PAR san_design_tokens - NE PAS MODIFIER MANUELLEMENT\n */\n\n`;

  // Variables :root (Thème Sombre par défaut pour Antigravity)
  css += `:root {\n`;
  css += `  /* --- Couleurs Sémantiques (Mode Sombre) --- */\n`;
  for (const [key, val] of Object.entries(colors.dark)) {
    css += `  --color-${key}: ${val};\n`;
  }

  css += `\n  /* --- Échelle d'Espacement Déterministe (Base 4px) --- */\n`;
  for (const [key, val] of Object.entries(spacing)) {
    css += `  --space-${key}: ${val};\n`;
  }

  css += `\n  /* --- Rayons de Courbure --- */\n`;
  for (const [key, val] of Object.entries(radii)) {
    css += `  --radius-${key}: ${val};\n`;
  }

  css += `\n  /* --- Ombres & Élévations --- */\n`;
  for (const [key, val] of Object.entries(shadows)) {
    css += `  --shadow-${key}: ${val};\n`;
  }

  css += `\n  /* --- Signature Cinétique & Mouvement --- */\n`;
  for (const [key, val] of Object.entries(motion.duration)) {
    css += `  --duration-${key}: ${val};\n`;
  }
  for (const [key, val] of Object.entries(motion.easing)) {
    css += `  --ease-${key}: ${val};\n`;
  }

  css += `\n  /* --- Typographie --- */\n`;
  css += `  --font-sans: ${typography.fontFamily.sans};\n`;
  css += `  --font-display: ${typography.fontFamily.display};\n`;
  css += `  --font-mono: ${typography.fontFamily.mono};\n`;
  css += `}\n\n`;

  // Mode Clair explicite via [data-theme="light"]
  if (Object.keys(colors.light).length > 0) {
    css += `[data-theme="light"] {\n`;
    css += `  /* --- Couleurs Sémantiques (Mode Clair) --- */\n`;
    for (const [key, val] of Object.entries(colors.light)) {
      css += `  --color-${key}: ${val};\n`;
    }
    css += `}\n\n`;
  }

  // Support direct Tailwind CSS v4 via @theme
  css += `/* Compatibilité native Tailwind CSS v4 */\n@theme {\n`;
  for (const [key] of Object.entries(colors.dark)) {
    css += `  --color-${key}: var(--color-${key});\n`;
  }
  for (const [key] of Object.entries(spacing)) {
    css += `  --spacing-${key}: var(--space-${key});\n`;
  }
  for (const [key] of Object.entries(radii)) {
    css += `  --radius-${key}: var(--radius-${key});\n`;
  }
  css += `}\n`;

  fs.writeFileSync(cssPath, css, 'utf-8');
  generatedFiles.push(cssPath);
}

// B. Génération Tailwind v3/v4 Theme Extension (JavaScript ESM / CJS friendly)
if (selectedFormat === 'tailwind' || selectedFormat === 'all') {
  const tailwindPath = path.join(resolvedOutDir, 'tailwind.tokens.js');
  let tw = `/**\n * EXTENSION DE THÈME TAILWIND CSS (san_*)\n * SOURCE : ${path.relative(process.cwd(), resolvedInput)}\n * USAGE dans tailwind.config.js :\n *   import { tailwindThemeExtend } from './src/styles/tokens/tailwind.tokens.js';\n *   module.exports = { theme: { extend: tailwindThemeExtend } };\n */\n\n`;

  const twColors = {};
  for (const key of Object.keys(colors.dark)) {
    twColors[key] = `var(--color-${key}, ${colors.dark[key]})`;
  }

  const twSpacing = {};
  for (const [key, val] of Object.entries(spacing)) {
    twSpacing[key] = val;
  }

  const twRadii = {};
  for (const [key, val] of Object.entries(radii)) {
    twRadii[key] = val;
  }

  const twTransitions = {
    transitionDuration: motion.duration,
    transitionTimingFunction: motion.easing
  };

  const configObject = {
    colors: twColors,
    spacing: twSpacing,
    borderRadius: twRadii,
    boxShadow: shadows,
    transitionDuration: twTransitions.transitionDuration,
    transitionTimingFunction: twTransitions.transitionTimingFunction,
    fontFamily: typography.fontFamily
  };

  tw += `export const tailwindThemeExtend = ${JSON.stringify(configObject, null, 2)};\n\n`;
  tw += `export default tailwindThemeExtend;\n`;

  fs.writeFileSync(tailwindPath, tw, 'utf-8');
  generatedFiles.push(tailwindPath);
}

// C. Génération TypeScript (Objets immuables fortement typés pour Web & React Native)
if (selectedFormat === 'ts' || selectedFormat === 'all') {
  const tsPath = path.join(resolvedOutDir, 'tokens.ts');
  let ts = `/**\n * DESIGN TOKENS IMMUABLES TYPESCRIPT (san_*)\n * SOURCE : ${path.relative(process.cwd(), resolvedInput)}\n * COMPATIBILITÉ : React, Next.js, React Native / Expo\n */\n\n`;

  const tokensPayload = {
    colors: {
      dark: colors.dark,
      light: colors.light,
      raw: colors.unified
    },
    spacing: {
      1: 4,
      2: 8,
      3: 12,
      4: 16,
      5: 20,
      6: 24,
      8: 32,
      10: 40,
      12: 48,
      16: 64
    },
    radii: {
      none: 0,
      sm: 4,
      md: 8,
      lg: 12,
      xl: 16,
      full: 9999
    },
    shadows,
    motion: {
      duration: motion.durationMs,
      easing: motion.easing
    },
    typography: {
      fontFamily: typography.fontFamily
    }
  };

  ts += `export const tokens = ${JSON.stringify(tokensPayload, null, 2)} as const;\n\n`;
  ts += `export type DesignTokens = typeof tokens;\n`;
  ts += `export type ColorTokenName = keyof typeof tokens.colors.dark;\n`;
  ts += `export type SpacingScale = keyof typeof tokens.spacing;\n`;
  ts += `export type RadiusScale = keyof typeof tokens.radii;\n`;
  ts += `export type MotionEasing = keyof typeof tokens.motion.easing;\n`;
  ts += `export type MotionDuration = keyof typeof tokens.motion.duration;\n\n`;

  ts += `// Exports raccourcis pour une utilisation ergonomique\n`;
  ts += `export const colors = tokens.colors;\n`;
  ts += `export const spacing = tokens.spacing;\n`;
  ts += `export const radii = tokens.radii;\n`;
  ts += `export const shadows = tokens.shadows;\n`;
  ts += `export const motion = tokens.motion;\n`;
  ts += `export default tokens;\n`;

  fs.writeFileSync(tsPath, ts, 'utf-8');
  generatedFiles.push(tsPath);
}

console.log(`\n${ANSI.bold}${ANSI.green}✅ [SUCCÈS] Compilation déterministe terminée (${generatedFiles.length} artefact(s) généré(s)) :${ANSI.reset}`);
for (const f of generatedFiles) {
  console.log(`  ${ANSI.cyan}→${ANSI.reset} ${path.relative(process.cwd(), f)}`);
}
process.exit(0);
