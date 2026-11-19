#!/usr/bin/env node
// ==============================================================================
// SCRIPT : svg_to_png.mjs (v2.2.0)
// MODULES : san_init & san_exporter
// FRAMEWORK : Antigravity / Dual-Harness (san_*)
// DESCRIPTION : Compilateur vectoriel SVG vers matriciel PNG multi-formats via Sharp
//               (ou fallback CLI rsvg-convert / inkscape / magick / convert).
//               Supporte le mode branding (--output-dir / --sizes / positionnel)
//               ET le mode matrice stores (--out-dir / DEFAULT_ICON_MATRIX) avec
//               aplatissement strict Apple ITMS-90717 (.removeAlpha().flatten).
// USAGE :
//   node svg_to_png.mjs --input <logo.svg> --output-dir <dist/> [--sizes <16,32,...>]
//   node svg_to_png.mjs --input <logo.svg> --out-dir <base_dir/>
//   node svg_to_png.mjs <input.svg> <output_dir>
// ==============================================================================

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
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

// Matrice normative Store / PWA / Mobile (mode san_exporter --out-dir)
const DEFAULT_ICON_MATRIX = [
  { path: 'public/icons/favicon-16x16.png', width: 16, height: 16, size: 16, alpha: true, label: 'Favicon 16px' },
  { path: 'public/icons/favicon-32x32.png', width: 32, height: 32, size: 32, alpha: true, label: 'Favicon 32px' },
  { path: 'public/icons/apple-touch-icon.png', width: 180, height: 180, size: 180, alpha: true, label: 'Apple Touch Icon 180px' },
  { path: 'public/icons/icon-192.png', width: 192, height: 192, size: 192, alpha: true, label: 'PWA Icon 192px' },
  { path: 'public/icons/icon-512.png', width: 512, height: 512, size: 512, alpha: true, label: 'PWA Icon 512px' },
  { path: 'assets/adaptive-icon.png', width: 1024, height: 1024, size: 1024, alpha: true, label: 'Android Adaptive Icon 1024px' },
  { path: 'assets/icon.png', width: 1024, height: 1024, size: 1024, alpha: false, label: 'iOS App Store Icon 1024px (ZÉRO ALPHA - Anti ITMS-90717)' },
  { path: 'assets/play-store-icon.png', width: 512, height: 512, size: 512, alpha: true, label: 'Google Play Icon 512px' }
];

// Matrice complète Branding / Web / Splash screens (mode san_init --output-dir)
const DEFAULT_TARGET_ASSETS = [
  { name: 'favicon-16x16.png', width: 16, height: 16, fit: 'contain', alpha: true },
  { name: 'favicon-32x32.png', width: 32, height: 32, fit: 'contain', alpha: true },
  { name: 'favicon-48x48.png', width: 48, height: 48, fit: 'contain', alpha: true },
  { name: 'favicon-64x64.png', width: 64, height: 64, fit: 'contain', alpha: true },
  { name: 'apple-touch-icon.png', width: 180, height: 180, fit: 'contain', alpha: true },
  { name: 'pwa-192x192.png', width: 192, height: 192, fit: 'contain', alpha: true },
  { name: 'pwa-512x512.png', width: 512, height: 512, fit: 'contain', alpha: true },
  {
    name: 'maskable-icon-512x512.png',
    width: 512,
    height: 512,
    fit: 'contain',
    alpha: true,
    background: { r: 15, g: 23, b: 42, alpha: 1 }
  },
  { name: 'logo-brand-512x128.png', width: 512, height: 128, fit: 'contain', alpha: true },
  { name: 'logo-brand-1024x256.png', width: 1024, height: 256, fit: 'contain', alpha: true },
  {
    name: 'splash-mobile-portrait-1242x2688.png',
    width: 1242,
    height: 2688,
    fit: 'contain',
    alpha: true,
    background: { r: 11, g: 15, b: 25, alpha: 1 }
  },
  {
    name: 'splash-square-2048x2048.png',
    width: 2048,
    height: 2048,
    fit: 'contain',
    alpha: true,
    background: { r: 11, g: 15, b: 25, alpha: 1 }
  }
];

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Compilateur Vectoriel SVG vers PNG (svg_to_png.mjs v2.2) ===${ANSI.reset}

${ANSI.bold}UTILISATION :${ANSI.reset}
  node svg_to_png.mjs [options]
  node svg_to_png.mjs <input.svg> <output_dir>

${ANSI.bold}OPTIONS :${ANSI.reset}
  -i, --input <fichier>       Fichier vectoriel SVG source
                              (Défaut auto: logos/san_framework_icon.svg ou .agents/rules/logo.svg)
      --output-dir <dossier>  Dossier de sortie plat pour pack branding/splash (Défaut: public/assets/branding)
      --out-dir <dossier>     Répertoire racine pour la matrice stores DEFAULT_ICON_MATRIX (Défaut: .)
  -o <dossier>                Alias raccourci de dossier de sortie
  -s, --sizes <liste>         Tailles personnalisées CSV (ex: "16,32,192,512" ou "512x128,1024x256")
      --matrix                Force le mode DEFAULT_ICON_MATRIX (avec assets/icon.png 0% alpha ITMS-90717)
      --no-alpha              Supprime le canal alpha (.removeAlpha().flatten({ background: '#FFFFFF' }))
      --strict                Retourne code 1 si aucun moteur (Sharp/CLI) n'est disponible
  -h, --help                  Affiche cette aide et termine l'exécution

${ANSI.bold}GARDE-FOU APPLE ITMS-90717 :${ANSI.reset}
  En mode matrice (--out-dir / --matrix), ${ANSI.bold}assets/icon.png${ANSI.reset} (1024x1024) subit automatiquement
  ${ANSI.cyan}.removeAlpha().flatten({ background: '#FFFFFF' })${ANSI.reset} pour prévenir le rejet App Store.

${ANSI.bold}EXEMPLES :${ANSI.reset}
  node svg_to_png.mjs --input logos/logo.svg --output-dir public/assets/branding
  node svg_to_png.mjs --input .agents/rules/logo.svg --out-dir .
  node svg_to_png.mjs -i src/assets/logo.svg -o assets/pwa/ --sizes 192,512
`);
}

function parseCliArgs(argv) {
  const opts = {
    help: false,
    inputSvg: '',
    outputDir: '',
    outBaseDir: '',
    shortOutDir: '',
    customSizesArg: '',
    forceMatrix: false,
    noAlpha: false,
    strict: false,
    positionalArgs: []
  };

  const readVal = (arg, idx) => {
    const eqIdx = arg.indexOf('=');
    if (eqIdx !== -1) return { val: arg.slice(eqIdx + 1), consumed: false };
    if (idx + 1 >= argv.length) throw new Error(`Valeur manquante pour l'option ${arg}`);
    return { val: argv[idx + 1], consumed: true };
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const flag = arg.includes('=') ? arg.slice(0, arg.indexOf('=')) : arg;

    if (flag === '--help' || flag === '-h') {
      opts.help = true;
    } else if (flag === '--input' || flag === '-i') {
      const { val, consumed } = readVal(arg, i);
      opts.inputSvg = val;
      if (consumed) i++;
    } else if (flag === '--output-dir') {
      const { val, consumed } = readVal(arg, i);
      opts.outputDir = val;
      if (consumed) i++;
    } else if (flag === '--out-dir') {
      const { val, consumed } = readVal(arg, i);
      opts.outBaseDir = val;
      if (consumed) i++;
    } else if (flag === '-o') {
      const { val, consumed } = readVal(arg, i);
      opts.shortOutDir = val;
      if (consumed) i++;
    } else if (flag === '--sizes' || flag === '-s') {
      const { val, consumed } = readVal(arg, i);
      opts.customSizesArg = val;
      if (consumed) i++;
    } else if (flag === '--matrix') {
      opts.forceMatrix = true;
    } else if (flag === '--no-alpha') {
      opts.noAlpha = true;
    } else if (flag === '--strict') {
      opts.strict = true;
    } else if (!arg.startsWith('-')) {
      opts.positionalArgs.push(arg);
    } else {
      throw new Error(`Option inconnue : ${arg}`);
    }
  }

  return opts;
}

function parseCustomSizes(sizesString, forceNoAlpha) {
  const parts = sizesString.split(',').map((s) => s.trim()).filter(Boolean);
  const assets = [];

  for (const part of parts) {
    if (part.includes('x')) {
      const [wStr, hStr] = part.split('x');
      const w = parseInt(wStr, 10);
      const h = parseInt(hStr, 10);
      if (Number.isFinite(w) && Number.isFinite(h) && w > 0 && h > 0) {
        assets.push({
          name: `icon-${w}x${h}.png`,
          label: `Custom ${w}x${h}`,
          width: w,
          height: h,
          fit: 'contain',
          alpha: !forceNoAlpha
        });
      }
    } else {
      const size = parseInt(part, 10);
      if (Number.isFinite(size) && size > 0) {
        assets.push({
          name: `icon-${size}x${size}.png`,
          label: `Custom ${size}x${size}`,
          width: size,
          height: size,
          fit: 'contain',
          alpha: !forceNoAlpha
        });
      }
    }
  }
  return assets;
}

function collectAncestorDirs(startDir) {
  const dirs = [];
  let current = path.resolve(startDir);
  while (current) {
    dirs.push(current);
    const parent = path.dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return dirs;
}

/**
 * Résout Sharp depuis le projet client, NODE_PATH, le framework ou ~/.npm/_npx.
 */
async function loadSharp() {
  const normalize = (mod) => mod?.default || mod;
  try {
    const mod = normalize(await import('sharp'));
    if (typeof mod === 'function') return mod;
  } catch {
    // Fallback multi-chemins
  }

  const homeDir = os.homedir();
  const candidateBases = [];
  const seen = new Set();
  const addBase = (dir) => {
    if (!dir) return;
    const resolved = path.resolve(dir);
    const base = path.basename(resolved) === 'node_modules' ? path.dirname(resolved) : resolved;
    if (!seen.has(base)) {
      seen.add(base);
      candidateBases.push(base);
    }
  };

  for (const dir of collectAncestorDirs(process.cwd())) addBase(dir);
  if (process.env.NODE_PATH) {
    for (const p of process.env.NODE_PATH.split(path.delimiter).filter(Boolean)) addBase(p);
  }

  const scriptPath = fileURLToPath(import.meta.url);
  for (const dir of collectAncestorDirs(path.dirname(scriptPath))) addBase(dir);
  try {
    const realScriptPath = fs.realpathSync(scriptPath);
    if (realScriptPath !== scriptPath) {
      for (const dir of collectAncestorDirs(path.dirname(realScriptPath))) addBase(dir);
    }
  } catch {
    // Ignore si realpath indisponible
  }

  addBase(path.join(homeDir, '.gemini', 'antigravity-cli', 'plugins', 'san-ai-harness', 'node_modules'));
  addBase(path.join(homeDir, '.gemini', 'antigravity-cli', 'plugins', 'san-framework', 'node_modules'));
  addBase('/home/alexsan-dev/PROJECTS/san_ai_harness/node_modules');
  addBase('/home/alexsan-dev/PROJECTS/san_agy_framework/node_modules');

  const npxCacheDir = path.join(homeDir, '.npm', '_npx');
  if (fs.existsSync(npxCacheDir)) {
    try {
      const entries = fs.readdirSync(npxCacheDir, { withFileTypes: true })
        .filter(e => e.isDirectory())
        .map(e => {
          const fullPath = path.join(npxCacheDir, e.name);
          let mtimeMs = 0;
          try { mtimeMs = fs.statSync(fullPath).mtimeMs; } catch {}
          return { fullPath, mtimeMs };
        })
        .sort((a, b) => b.mtimeMs - a.mtimeMs);
      for (const entry of entries) addBase(entry.fullPath);
    } catch {
      // Ignore erreur _npx
    }
  }

  for (const baseDir of candidateBases) {
    try {
      const req = createRequire(path.join(baseDir, '_san_resolve_.cjs'));
      const mod = normalize(req('sharp'));
      if (typeof mod === 'function') return mod;
    } catch {
      // Essaie la base suivante
    }
  }
  return null;
}

function computeSha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

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

async function renderWithSharp(sharp, resolvedSvg, targetJobs) {
  const svgBuffer = fs.readFileSync(resolvedSvg);
  let successCount = 0;

  for (const job of targetJobs) {
    fs.mkdirSync(path.dirname(job.destPath), { recursive: true });
    try {
      let pipeline = sharp(svgBuffer, { density: 300 }).resize(job.width, job.height, {
        fit: job.fit || 'contain',
        background: job.background || { r: 0, g: 0, b: 0, alpha: 0 }
      });

      if (job.alpha === false) {
        // Élimination formelle du canal alpha (exigence Apple App Store 1024x1024 - Erreur ITMS-90717)
        pipeline = pipeline.removeAlpha().flatten({ background: '#FFFFFF' });
      }

      await pipeline.png({ compressionLevel: 9, adaptiveFiltering: true }).toFile(job.destPath);
      const sha = computeSha256(job.destPath);
      const alphaBadge = job.alpha === false
        ? `${ANSI.green}${ANSI.bold}[0% Alpha - Conforme Apple ITMS-90717]${ANSI.reset}`
        : `${ANSI.gray}[SHA: ${sha.slice(0, 10)}]${ANSI.reset}`;

      console.log(`  ${ANSI.green}✓${ANSI.reset} ${job.displayLabel.padEnd(46)} [${job.width}x${job.height}] ${alphaBadge}`);
      successCount++;
    } catch (err) {
      console.error(`  ${ANSI.red}✗${ANSI.reset} Échec pour ${job.displayLabel} : ${err.message}`);
    }
  }

  return successCount;
}

function renderWithCliEngine(engine, resolvedSvg, targetJobs) {
  let successCount = 0;

  for (const job of targetJobs) {
    fs.mkdirSync(path.dirname(job.destPath), { recursive: true });
    try {
      if (engine === 'rsvg-convert') {
        let bgArg = '';
        if (job.alpha === false) {
          bgArg = '-b "#FFFFFF"';
        } else if (job.background) {
          bgArg = `-b "rgba(${job.background.r},${job.background.g},${job.background.b},${job.background.alpha})"`;
        }
        execSync(`rsvg-convert -w ${job.width} -h ${job.height} ${bgArg} -f png -o "${job.destPath}" "${resolvedSvg}"`, { stdio: 'pipe' });
      } else if (engine === 'inkscape') {
        execSync(`inkscape --export-filename="${job.destPath}" --export-width=${job.width} --export-height=${job.height} "${resolvedSvg}"`, { stdio: 'pipe' });
      } else if (engine === 'magick' || engine === 'convert') {
        const cmd = engine === 'magick' ? 'magick convert' : 'convert';
        let bgOption = '-background transparent';
        if (job.alpha === false) {
          bgOption = '-background "#FFFFFF" -alpha remove -alpha off';
        } else if (job.background) {
          bgOption = `-background "rgba(${job.background.r},${job.background.g},${job.background.b},${job.background.alpha})"`;
        }
        execSync(`${cmd} -density 300 -resize ${job.width}x${job.height} ${bgOption} -gravity center -extent ${job.width}x${job.height} "${resolvedSvg}" "${job.destPath}"`, { stdio: 'pipe' });
      }

      console.log(`  ${ANSI.green}✓${ANSI.reset} ${job.displayLabel.padEnd(46)} [${job.width}x${job.height}] (via ${engine})`);
      successCount++;
    } catch (err) {
      console.error(`  ${ANSI.red}✗${ANSI.reset} Échec pour ${job.displayLabel} via ${engine} : ${err.message}`);
    }
  }

  return successCount;
}

function resolveExecutionPlan(opts) {
  let inputSvg = opts.inputSvg;
  if (!inputSvg && opts.positionalArgs.length > 0) {
    inputSvg = opts.positionalArgs[0];
  }

  if (!inputSvg) {
    const candidates = [
      'logos/san_framework_icon.svg',
      '.agents/rules/logo.svg',
      'logos/san_framework_logo.svg',
      'logos/logo_icon.svg',
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
      inputSvg = 'logos/san_framework_icon.svg';
    }
  }

  let mode = 'branding';
  let targetDir = 'public/assets/branding';

  if (opts.customSizesArg) {
    mode = 'sizes';
    targetDir = opts.outputDir || opts.shortOutDir || opts.outBaseDir || 'public/assets/branding';
  } else if (opts.forceMatrix || opts.outBaseDir) {
    mode = 'matrix';
    targetDir = opts.outBaseDir || opts.shortOutDir || opts.outputDir || '.';
  } else if (opts.outputDir || opts.positionalArgs.length > 1) {
    mode = 'branding';
    targetDir = opts.outputDir || opts.positionalArgs[1];
  } else if (opts.shortOutDir) {
    if (inputSvg.endsWith('.agents/rules/logo.svg') || opts.shortOutDir === '.') {
      mode = 'matrix';
    } else {
      mode = 'branding';
    }
    targetDir = opts.shortOutDir;
  } else if (inputSvg.endsWith('.agents/rules/logo.svg')) {
    mode = 'matrix';
    targetDir = '.';
  }

  let jobs = [];
  if (mode === 'sizes') {
    const customAssets = parseCustomSizes(opts.customSizesArg, opts.noAlpha);
    if (customAssets.length === 0) {
      throw new Error(`Aucune taille valide spécifiée dans : ${opts.customSizesArg}`);
    }
    jobs = customAssets.map(a => ({
      ...a,
      destPath: path.resolve(targetDir, a.name),
      displayLabel: a.name
    }));
  } else if (mode === 'matrix') {
    jobs = DEFAULT_ICON_MATRIX.map(t => ({
      ...t,
      fit: 'contain',
      destPath: path.resolve(targetDir, t.path),
      displayLabel: `${t.path} (${t.label})`
    }));
  } else {
    jobs = DEFAULT_TARGET_ASSETS.map(a => ({
      ...a,
      alpha: opts.noAlpha ? false : a.alpha,
      destPath: path.resolve(targetDir, a.name),
      displayLabel: a.name
    }));
  }

  return { inputSvg, mode, targetDir, jobs };
}

async function main() {
  const opts = parseCliArgs(process.argv.slice(2));
  if (opts.help) {
    printHelp();
    process.exit(0);
  }

  const plan = resolveExecutionPlan(opts);
  const resolvedSvg = path.resolve(plan.inputSvg);
  if (!fs.existsSync(resolvedSvg)) {
    console.error(`${ANSI.red}[ERREUR] Fichier SVG source introuvable : ${resolvedSvg}${ANSI.reset}`);
    console.error(`${ANSI.yellow}[CONSEIL] Spécifiez un fichier valide via --input <chemin_vers_svg>${ANSI.reset}`);
    process.exit(1);
  }

  console.log(`${ANSI.blue}${ANSI.bold}=== [san_init / san_exporter] Déclinaison vectorielle SVG vers PNG ===${ANSI.reset}`);
  console.log(`${ANSI.cyan}Source SVG       :${ANSI.reset} ${plan.inputSvg}`);
  console.log(`${ANSI.cyan}Mode actif       :${ANSI.reset} ${plan.mode}`);
  console.log(`${ANSI.cyan}Dossier cible    :${ANSI.reset} ${plan.targetDir}`);
  console.log(`${ANSI.cyan}Nombre d'assets  :${ANSI.reset} ${plan.jobs.length}\n`);

  const sharp = await loadSharp();
  if (sharp) {
    console.log(`${ANSI.green}[MOTEUR ACTIF] Moteur graphique "Sharp" détecté. Rendu natif ultra-rapide.${ANSI.reset}\n`);
    const count = await renderWithSharp(sharp, resolvedSvg, plan.jobs);
    console.log(`\n${ANSI.green}${ANSI.bold}[SUCCÈS] ${count}/${plan.jobs.length} asset(s) PNG généré(s) dans ${plan.targetDir}.${ANSI.reset}`);
    return;
  }

  console.log(`${ANSI.yellow}[NOTE] La bibliothèque Node.js "sharp" n'est pas installée.${ANSI.reset}`);
  const fallbackEngine = detectCliFallbackEngine();
  if (fallbackEngine) {
    console.log(`${ANSI.green}[MOTEUR FALLBACK] Outil système détecté : "${fallbackEngine}". Rendu en cours...${ANSI.reset}\n`);
    const count = renderWithCliEngine(fallbackEngine, resolvedSvg, plan.jobs);
    console.log(`\n${ANSI.green}${ANSI.bold}[SUCCÈS] ${count}/${plan.jobs.length} asset(s) PNG généré(s) via ${fallbackEngine}.${ANSI.reset}`);
    return;
  }

  console.log(`
${ANSI.bold}${ANSI.yellow}[NOTICE D'INSTALLATION RECOMMANDÉE]${ANSI.reset}
Pour une conversion vectorielle instantanée sans dépendance système externe,
installez le paquet de développement ${ANSI.cyan}sharp${ANSI.reset} via votre gestionnaire de projet :

  ${ANSI.bold}pnpm add -D sharp${ANSI.reset}
  ${ANSI.bold}npm install --save-dev sharp${ANSI.reset}
`);
  if (opts.strict || plan.mode === 'matrix') {
    process.exit(1);
  }
  console.log(`${ANSI.yellow}[san_init] Phase de génération de logos différée jusqu'à l'installation de sharp.${ANSI.reset}`);
  process.exit(0);
}

main().catch((err) => {
  console.error(`\n${ANSI.red}[CRASH SCRIPT]${ANSI.reset}`, err.message || err);
  process.exit(1);
});
