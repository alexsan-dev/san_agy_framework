#!/usr/bin/env node
// ==============================================================================
// SCRIPT : svg_to_png.mjs
// FRAMEWORK : Antigravity (san_*)
// AUTEUR : Alexsan.pro
// USAGE :
//   node svg_to_png.mjs --input <logo.svg> --output-dir <dist/> [--sizes <16,32,192,...>]
//   OU : node svg_to_png.mjs <input.svg> <output_dir>
// ==============================================================================

import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

const ANSI = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m'
};

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Générateur d'assets matriciels PNG Antigravity (svg_to_png.mjs) ===${ANSI.reset}

${ANSI.bold}UTILISATION :${ANSI.reset}
  node svg_to_png.mjs [options]
  node svg_to_png.mjs <input.svg> <output_dir>

${ANSI.bold}OPTIONS :${ANSI.reset}
  -i, --input <chemin>       Chemin vers le fichier vectoriel SVG source
                             (Défaut: logos/san_framework_icon.svg)
  -o, --output-dir <dossier> Dossier de destination pour les fichiers PNG
                             (Défaut: public/assets/branding)
  -s, --sizes <liste>        Tailles personnalisées séparées par des virgules
                             Exemples: "16,32,48,64,180,192,512" ou "512x128,1024x256"
                             (Défaut: Matrice complète Web, PWA, Splash screens)
  -h, --help                 Affiche cette aide et termine l'exécution

${ANSI.bold}EXEMPLES :${ANSI.reset}
  node svg_to_png.mjs --input logos/logo.svg --output-dir public/icons/
  node svg_to_png.mjs -i src/assets/logo.svg -o assets/pwa/ --sizes 192,512
`);
}

// 1. Analyse des arguments CLI
const rawArgs = process.argv.slice(2);

let inputSvg = '';
let outputDir = '';
let customSizesArg = '';
const positionalArgs = [];

for (let i = 0; i < rawArgs.length; i++) {
  const arg = rawArgs[i];
  if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  } else if (arg === '--input' || arg === '-i') {
    inputSvg = rawArgs[++i] || '';
  } else if (arg === '--output-dir' || arg === '-o') {
    outputDir = rawArgs[++i] || '';
  } else if (arg === '--sizes' || arg === '-s') {
    customSizesArg = rawArgs[++i] || '';
  } else if (arg.startsWith('--input=')) {
    inputSvg = arg.split('=')[1];
  } else if (arg.startsWith('--output-dir=')) {
    outputDir = arg.split('=')[1];
  } else if (arg.startsWith('--sizes=')) {
    customSizesArg = arg.split('=')[1];
  } else if (!arg.startsWith('-')) {
    positionalArgs.push(arg);
  }
}

// Fallback sur arguments positionnels si non fournis par flags
if (!inputSvg && positionalArgs.length > 0) {
  inputSvg = positionalArgs[0];
}
if (!outputDir && positionalArgs.length > 1) {
  outputDir = positionalArgs[1];
}

// Valeurs par défaut cartésiennes
if (!inputSvg) {
  const defaultLocations = [
    'logos/san_framework_icon.svg',
    'logos/san_framework_logo.svg',
    'public/logo.svg',
    'src/assets/logo.svg'
  ];
  for (const loc of defaultLocations) {
    if (fs.existsSync(loc)) {
      inputSvg = loc;
      break;
    }
  }
  if (!inputSvg) {
    inputSvg = 'logos/san_framework_icon.svg';
  }
}

if (!outputDir) {
  outputDir = 'public/assets/branding';
}

// Vérification d'existence du fichier SVG source
if (!fs.existsSync(inputSvg)) {
  console.error(`${ANSI.red}[ERREUR] Fichier SVG source introuvable : ${inputSvg}${ANSI.reset}`);
  console.error(`${ANSI.yellow}[CONSEIL] Spécifiez le fichier SVG source via : --input <chemin_vers_svg>${ANSI.reset}`);
  process.exit(1);
}

// Préparation du dossier de sortie
try {
  fs.mkdirSync(outputDir, { recursive: true });
} catch (err) {
  console.error(`${ANSI.red}[ERREUR] Impossible de créer le dossier de sortie : ${outputDir}${ANSI.reset}`);
  console.error(err.message);
  process.exit(1);
}

// 2. Définition des cibles de conversion
function parseCustomSizes(sizesString) {
  const parts = sizesString.split(',').map((s) => s.trim()).filter(Boolean);
  const assets = [];

  for (const part of parts) {
    if (part.includes('x')) {
      const [wStr, hStr] = part.split('x');
      const w = parseInt(wStr, 10);
      const h = parseInt(hStr, 10);
      if (!isNaN(w) && !isNaN(h) && w > 0 && h > 0) {
        assets.push({
          name: `icon-${w}x${h}.png`,
          width: w,
          height: h,
          fit: 'contain'
        });
      }
    } else {
      const size = parseInt(part, 10);
      if (!isNaN(size) && size > 0) {
        assets.push({
          name: `icon-${size}x${size}.png`,
          width: size,
          height: size,
          fit: 'contain'
        });
      }
    }
  }
  return assets;
}

const DEFAULT_TARGET_ASSETS = [
  // Favicons standard pour navigateurs
  { name: 'favicon-16x16.png', width: 16, height: 16, fit: 'contain' },
  { name: 'favicon-32x32.png', width: 32, height: 32, fit: 'contain' },
  { name: 'favicon-48x48.png', width: 48, height: 48, fit: 'contain' },
  { name: 'favicon-64x64.png', width: 64, height: 64, fit: 'contain' },

  // Icône iOS Apple Touch
  { name: 'apple-touch-icon.png', width: 180, height: 180, fit: 'contain' },

  // Icônes PWA & Manifest Android
  { name: 'pwa-192x192.png', width: 192, height: 192, fit: 'contain' },
  { name: 'pwa-512x512.png', width: 512, height: 512, fit: 'contain' },
  {
    name: 'maskable-icon-512x512.png',
    width: 512,
    height: 512,
    fit: 'contain',
    background: { r: 15, g: 23, b: 42, alpha: 1 } // Fond neutre sombre
  },

  // Bannières & Headers d'application
  { name: 'logo-brand-512x128.png', width: 512, height: 128, fit: 'contain' },
  { name: 'logo-brand-1024x256.png', width: 1024, height: 256, fit: 'contain' },

  // Écrans de lancement (Splash screens) mobiles
  {
    name: 'splash-mobile-portrait-1242x2688.png',
    width: 1242,
    height: 2688,
    fit: 'contain',
    background: { r: 11, g: 15, b: 25, alpha: 1 }
  },
  {
    name: 'splash-square-2048x2048.png',
    width: 2048,
    height: 2048,
    fit: 'contain',
    background: { r: 11, g: 15, b: 25, alpha: 1 }
  }
];

const targetAssets = customSizesArg
  ? parseCustomSizes(customSizesArg)
  : DEFAULT_TARGET_ASSETS;

if (targetAssets.length === 0) {
  console.error(`${ANSI.red}[ERREUR] Aucune taille valide spécifiée dans : ${customSizesArg}${ANSI.reset}`);
  process.exit(1);
}

console.log(`${ANSI.blue}${ANSI.bold}=== [san_init] Déclinaison vectorielle SVG vers PNG ===${ANSI.reset}`);
console.log(`${ANSI.cyan}Source SVG       :${ANSI.reset} ${inputSvg}`);
console.log(`${ANSI.cyan}Dossier cible    :${ANSI.reset} ${outputDir}`);
console.log(`${ANSI.cyan}Nombre d'assets  :${ANSI.reset} ${targetAssets.length}\n`);

// 3. Détection du moteur de rendu : Sharp avec fallback CLI (rsvg-convert / inkscape / convert)
async function main() {
  let sharp = null;

  try {
    const sharpModule = await import('sharp');
    sharp = sharpModule.default;
  } catch (err) {
    // Sharp non disponible dans node_modules
    sharp = null;
  }

  if (sharp) {
    console.log(`${ANSI.green}[MOTEUR ACTIF] Moteur graphique "Sharp" détecté. Rendu natif ultra-rapide.${ANSI.reset}\n`);
    await renderWithSharp(sharp);
  } else {
    console.log(`${ANSI.yellow}[NOTE] La bibliothèque Node.js "sharp" n'est pas encore installée.${ANSI.reset}`);
    const fallbackEngine = detectCliFallbackEngine();

    if (fallbackEngine) {
      console.log(`${ANSI.green}[MOTEUR FALLBACK] Outil système détecté : "${fallbackEngine}". Exécution du rendu en cours...${ANSI.reset}\n`);
      renderWithCliEngine(fallbackEngine);
    } else {
      console.log(`
${ANSI.bold}${ANSI.yellow}[NOTICE D'INSTALLATION RECOMMANDEE]${ANSI.reset}
Pour une conversion vectorielle instantanée sans dépendance système externe,
installez le paquet de développement ${ANSI.cyan}sharp${ANSI.reset} via votre gestionnaire de projet :

  ${ANSI.bold}pnpm add -D sharp${ANSI.reset}
  ${ANSI.bold}npm install --save-dev sharp${ANSI.reset}
  ${ANSI.bold}yarn add -D sharp${ANSI.reset}
  ${ANSI.bold}bun add -d sharp${ANSI.reset}

${ANSI.gray}Dès l'installation effectuée, relancez cette commande pour générer l'ensemble des formats.${ANSI.reset}
`);
      // Ne pas échouer violemment si c'est une première exécution d'init sans sharp
      console.log(`${ANSI.yellow}[san_init] Phase de génération de logos différée jusqu'à l'installation de sharp.${ANSI.reset}`);
      process.exit(0);
    }
  }
}

// 4. Rendu avec Sharp
async function renderWithSharp(sharp) {
  const svgBuffer = fs.readFileSync(inputSvg);
  let successCount = 0;

  for (const asset of targetAssets) {
    const destPath = path.join(outputDir, asset.name);
    try {
      const resizeOptions = {
        fit: asset.fit || 'contain',
        background: asset.background || { r: 0, g: 0, b: 0, alpha: 0 }
      };

      const pipeline = sharp(svgBuffer, { density: 300 })
        .resize(asset.width, asset.height, resizeOptions)
        .png({
          compressionLevel: 9,
          adaptiveFiltering: true
        });

      await pipeline.toFile(destPath);
      console.log(`  ${ANSI.green}✓${ANSI.reset} ${asset.name.padEnd(38)} [${asset.width}x${asset.height}]`);
      successCount++;
    } catch (err) {
      console.error(`  ${ANSI.red}✗${ANSI.reset} Échec pour ${asset.name} : ${err.message}`);
    }
  }

  console.log(`\n${ANSI.green}${ANSI.bold}[SUCCÈS] ${successCount}/${targetAssets.length} asset(s) PNG généré(s) dans ${outputDir}.${ANSI.reset}`);
}

// 5. Détection des moteurs CLI de secours
function detectCliFallbackEngine() {
  const engines = ['rsvg-convert', 'inkscape', 'magick', 'convert'];
  for (const engine of engines) {
    try {
      execSync(`command -v ${engine}`, { stdio: 'ignore' });
      return engine;
    } catch {
      // Commande non trouvée
    }
  }
  return null;
}

// 6. Rendu avec les utilitaires système de secours
function renderWithCliEngine(engine) {
  let successCount = 0;

  for (const asset of targetAssets) {
    const destPath = path.join(outputDir, asset.name);
    try {
      if (engine === 'rsvg-convert') {
        const bgArg = asset.background ? `-b "rgba(${asset.background.r},${asset.background.g},${asset.background.b},${asset.background.alpha})"` : '';
        execSync(`rsvg-convert -w ${asset.width} -h ${asset.height} ${bgArg} -f png -o "${destPath}" "${inputSvg}"`, { stdio: 'pipe' });
      } else if (engine === 'inkscape') {
        execSync(`inkscape --export-filename="${destPath}" --export-width=${asset.width} --export-height=${asset.height} "${inputSvg}"`, { stdio: 'pipe' });
      } else if (engine === 'magick' || engine === 'convert') {
        const cmd = engine === 'magick' ? 'magick convert' : 'convert';
        const bgOption = asset.background
          ? `-background "rgba(${asset.background.r},${asset.background.g},${asset.background.b},${asset.background.alpha})"`
          : '-background transparent';
        execSync(`${cmd} -density 300 -resize ${asset.width}x${asset.height} ${bgOption} -gravity center -extent ${asset.width}x${asset.height} "${inputSvg}" "${destPath}"`, { stdio: 'pipe' });
      }

      console.log(`  ${ANSI.green}✓${ANSI.reset} ${asset.name.padEnd(38)} [${asset.width}x${asset.height}] (via ${engine})`);
      successCount++;
    } catch (err) {
      console.error(`  ${ANSI.red}✗${ANSI.reset} Échec pour ${asset.name} via ${engine} : ${err.message}`);
    }
  }

  console.log(`\n${ANSI.green}${ANSI.bold}[SUCCÈS] ${successCount}/${targetAssets.length} asset(s) PNG généré(s) dans ${outputDir}.${ANSI.reset}`);
}

main().catch((err) => {
  console.error(`\n${ANSI.red}[CRASH SCRIPT]${ANSI.reset}`, err);
  process.exit(1);
});
