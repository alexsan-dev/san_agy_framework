#!/usr/bin/env node
// ==============================================================================
// SCRIPT : svg_to_png.mjs
// MODULE : san_exporter
// FRAMEWORK : Antigravity (san_*)
// DESCRIPTION : Compilateur vectoriel SVG vers matriciel PNG multi-formats via Sharp.
//               Élimination stricte du canal alpha pour iOS 1024x1024 (Anti-Rejet Apple ITMS-90717).
// ==============================================================================

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import process from 'node:process';
import { execSync } from 'node:child_process';

const ANSI = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m'
};

const DEFAULT_ICON_MATRIX = [
  { path: 'public/icons/favicon-16x16.png', size: 16, alpha: true, label: 'Favicon 16px' },
  { path: 'public/icons/favicon-32x32.png', size: 32, alpha: true, label: 'Favicon 32px' },
  { path: 'public/icons/apple-touch-icon.png', size: 180, alpha: true, label: 'Apple Touch Icon 180px' },
  { path: 'public/icons/icon-192.png', size: 192, alpha: true, label: 'PWA Icon 192px' },
  { path: 'public/icons/icon-512.png', size: 512, alpha: true, label: 'PWA Icon 512px' },
  { path: 'assets/adaptive-icon.png', size: 1024, alpha: true, label: 'Android Adaptive Icon 1024px' },
  { path: 'assets/icon.png', size: 1024, alpha: false, label: 'iOS App Store Icon 1024px (ZÉRO ALPHA - Anti ITMS-90717)' },
  { path: 'assets/play-store-icon.png', size: 512, alpha: true, label: 'Google Play Icon 512px' }
];

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Compilateur Vectoriel Matriciel (svg_to_png.mjs) ===${ANSI.reset}

${ANSI.bold}UTILISATION :${ANSI.reset}
  node svg_to_png.mjs [options]
  ./svg_to_png.mjs --input <logo.svg> [--out-dir <dir>]

${ANSI.bold}OPTIONS :${ANSI.reset}
  -i, --input <fichier>      Fichier SVG source (Défaut: .agents/rules/logo.svg)
  -o, --out-dir <dossier>    Répertoire de base pour l'arborescence d'assets (Défaut: .)
  -h, --help                 Affiche cette aide et termine l'exécution

${ANSI.bold}GARDE-FOU APPLE ITMS-90717 :${ANSI.reset}
  L'asset ${ANSI.bold}assets/icon.png${ANSI.reset} subit automatiquement un aplatissement
  sur fond blanc avec ${ANSI.cyan}.removeAlpha().flatten({ background: '#FFFFFF' })${ANSI.reset}
  pour éliminer tout risque de rejet binaire lors de la soumission iOS.
`);
}

// 1. Analyse des arguments CLI
const rawArgs = process.argv.slice(2);
let inputSvg = '';
let outBaseDir = '.';
const positionalArgs = [];

for (let i = 0; i < rawArgs.length; i++) {
  const arg = rawArgs[i];
  if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  } else if (arg === '--input' || arg === '-i') {
    inputSvg = rawArgs[++i] || '';
  } else if (arg === '--out-dir' || arg === '-o') {
    outBaseDir = rawArgs[++i] || '.';
  } else if (arg.startsWith('--input=')) {
    inputSvg = arg.split('=')[1];
  } else if (arg.startsWith('--out-dir=')) {
    outBaseDir = arg.split('=')[1];
  } else if (!arg.startsWith('-')) {
    positionalArgs.push(arg);
  }
}

if (!inputSvg && positionalArgs.length > 0) {
  inputSvg = positionalArgs[0];
}

if (!inputSvg) {
  const candidates = [
    '.agents/rules/logo.svg',
    'logos/san_framework_icon.svg',
    'logos/san_framework_logo.svg',
    'public/logo.svg',
    'src/assets/logo.svg'
  ];
  for (const c of candidates) {
    if (fs.existsSync(c)) {
      inputSvg = c;
      break;
    }
  }
  if (!inputSvg) {
    inputSvg = '.agents/rules/logo.svg';
  }
}

const resolvedSvg = path.resolve(inputSvg);
if (!fs.existsSync(resolvedSvg)) {
  console.error(`${ANSI.red}❌ Fichier SVG source introuvable : ${resolvedSvg}${ANSI.reset}`);
  console.error(`${ANSI.yellow}💡 Précisez un fichier valide via --input <logo.svg>${ANSI.reset}`);
  process.exit(1);
}

function computeSha256(filePath) {
  const fileBuffer = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(fileBuffer).digest('hex');
}

// 2. Détection du moteur graphique Sharp
async function main() {
  console.log(`\n${ANSI.bold}${ANSI.blue}🎨 [san_exporter] Génération de la suite d'icônes depuis : ${path.relative(process.cwd(), resolvedSvg)}${ANSI.reset}`);

  let sharp;
  try {
    const sharpModule = await import('sharp');
    sharp = sharpModule.default;
  } catch {
    sharp = null;
  }

  if (sharp) {
    console.log(`${ANSI.green}✓ Moteur graphique natif "Sharp" actif.${ANSI.reset}\n`);
    await renderWithSharp(sharp);
  } else {
    console.log(`${ANSI.yellow}⚠️ Bibliothèque "sharp" non installée. Recherche d'un moteur système de secours...${ANSI.reset}`);
    const cliEngine = detectCliFallback();
    if (cliEngine) {
      console.log(`${ANSI.green}✓ Outil système détecté : "${cliEngine}". Rendu en cours...${ANSI.reset}\n`);
      renderWithCliEngine(cliEngine);
    } else {
      console.log(`\n${ANSI.bold}${ANSI.yellow}=== PROCÉDURE D'INSTALLATION RECOMMANDÉE ===${ANSI.reset}`);
      console.log(`Pour convertir vos vecteurs instantanément en packs d'icônes haute définition :`);
      console.log(`  ${ANSI.cyan}pnpm add -D sharp${ANSI.reset}   (ou: ${ANSI.cyan}npm install --save-dev sharp${ANSI.reset})\n`);
      console.log(`${ANSI.gray}Puis relancez ce script d'exportation.${ANSI.reset}\n`);
      process.exit(1);
    }
  }
}

async function renderWithSharp(sharp) {
  const svgBuffer = fs.readFileSync(resolvedSvg);
  let generatedCount = 0;

  for (const target of DEFAULT_ICON_MATRIX) {
    const targetFile = path.resolve(outBaseDir, target.path);
    fs.mkdirSync(path.dirname(targetFile), { recursive: true });

    let pipeline = sharp(svgBuffer, { density: 300 }).resize(target.size, target.size, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 }
    });

    if (!target.alpha) {
      // Élimination formelle du canal alpha (exigence stricte Apple App Store 1024x1024 - Erreur ITMS-90717)
      pipeline = pipeline.removeAlpha().flatten({ background: '#FFFFFF' });
    }

    await pipeline.png({ compressionLevel: 9 }).toFile(targetFile);
    const sha = computeSha256(targetFile);

    const alphaBadge = target.alpha ? `${ANSI.gray}[Alpha: OUI]${ANSI.reset}` : `${ANSI.green}${ANSI.bold}[0% Alpha - Conforme Apple ITMS-90717]${ANSI.reset}`;
    console.log(`  ${ANSI.green}✓${ANSI.reset} ${target.label.padEnd(52)} ${alphaBadge}`);
    generatedCount++;
  }

  console.log(`\n${ANSI.bold}${ANSI.green}✨ [SUCCÈS] ${generatedCount} asset(s) matriciel(s) généré(s) sans perte vectorielle.${ANSI.reset}`);
}

function detectCliFallback() {
  const candidates = ['rsvg-convert', 'inkscape', 'magick', 'convert'];
  for (const c of candidates) {
    try {
      execSync(`command -v ${c}`, { stdio: 'ignore' });
      return c;
    } catch {
      // Non trouvé
    }
  }
  return null;
}

function renderWithCliEngine(engine) {
  let count = 0;
  for (const target of DEFAULT_ICON_MATRIX) {
    const targetFile = path.resolve(outBaseDir, target.path);
    fs.mkdirSync(path.dirname(targetFile), { recursive: true });

    if (engine === 'rsvg-convert') {
      const bgArg = !target.alpha ? '-b "#FFFFFF"' : '';
      execSync(`rsvg-convert -w ${target.size} -h ${target.size} ${bgArg} -f png -o "${targetFile}" "${resolvedSvg}"`, { stdio: 'pipe' });
    } else if (engine === 'inkscape') {
      execSync(`inkscape --export-filename="${targetFile}" --export-width=${target.size} --export-height=${target.size} "${resolvedSvg}"`, { stdio: 'pipe' });
    } else if (engine === 'magick' || engine === 'convert') {
      const cmd = engine === 'magick' ? 'magick convert' : 'convert';
      const bg = !target.alpha ? '-background "#FFFFFF" -alpha remove -alpha off' : '-background transparent';
      execSync(`${cmd} -density 300 -resize ${target.size}x${target.size} ${bg} -gravity center -extent ${target.size}x${target.size} "${resolvedSvg}" "${targetFile}"`, { stdio: 'pipe' });
    }

    console.log(`  ${ANSI.green}✓${ANSI.reset} ${target.label.padEnd(52)} (via ${engine})`);
    count++;
  }
  console.log(`\n${ANSI.bold}${ANSI.green}✨ [SUCCÈS] ${count} icône(s) générée(s) via ${engine}.${ANSI.reset}`);
}

main().catch(err => {
  console.error(`\n${ANSI.red}❌ Erreur de génération d'icônes :${ANSI.reset}`, err.message);
  process.exit(1);
});
