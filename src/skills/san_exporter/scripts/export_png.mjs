#!/usr/bin/env node
// ==============================================================================
// SCRIPT : export_png.mjs
// MODULE : san_exporter
// FRAMEWORK : Antigravity (san_*)
// DESCRIPTION : Moteur de capture headless déterministe Playwright multi-formats
//               avec micro-serveur HTTP éphémère anti-CORS, synchronisation des
//               polices et calcul d'empreinte SHA-256.
// ==============================================================================

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import process from 'node:process';

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

// Matrices des formats normatifs officiels
const TARGET_PRESETS = {
  playstore: { width: 1080, height: 1920, label: 'Google Play Store Phone (1080x1920)' },
  appstore: { width: 1290, height: 2796, label: 'Apple App Store 6.7" iPhone (1290x2796)' },
  'appstore-6.5': { width: 1242, height: 2688, label: 'Apple App Store 6.5" iPhone (1242x2688)' },
  ipad: { width: 2048, height: 2732, label: 'Apple iPad Pro 12.9" (2048x2732)' },
  feature: { width: 1024, height: 500, label: 'Google Play Feature Graphic (1024x500)' },
  desktop: { width: 1920, height: 1080, label: 'Desktop Full HD 16:9 (1920x1080)' },
  web: { width: 1440, height: 900, label: 'Web Desktop Responsive (1440x900)' },
  print: { width: 2480, height: 3508, label: 'Print A4 Portrait 300 DPI (2480x3508)' },
  'print-landscape': { width: 3508, height: 2480, label: 'Print A4 Paysage 300 DPI (3508x2480)' },
  banner: { width: 1200, height: 630, label: 'Bannière OpenGraph / Social (1200x630)' }
};

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Moteur d'Exportation Headless Playwright (export_png.mjs) ===${ANSI.reset}

${ANSI.bold}UTILISATION :${ANSI.reset}
  node export_png.mjs [options]
  ./export_png.mjs --file <mockup.html> --target <cible> [--scale <int>] [--out <output.png>]

${ANSI.bold}OPTIONS :${ANSI.reset}
  -f, --file <fichier>       Chemin vers le fichier HTML à capturer
  -t, --target <cible>       Preset de résolution ou dossier de lot :
                             • playstore       (1080x1920 px - Play Store 9:16)
                             • appstore        (1290x2796 px - App Store iPhone 6.7")
                             • web             (1440x900 px  - Web Desktop Responsive)
                             • feature         (1024x500 px  - Play Store Feature Graphic)
                             • desktop         (1920x1080 px - Desktop Full HD 16:9)
                             • print           (2480x3508 px - Document A4 300 DPI)
                             • ipad            (2048x2732 px - iPad Pro 12.9")
                             • banner          (1200x630 px  - Bannière OpenGraph)
  -s, --scale <int>          Facteur d'échelle du périphérique (Défaut: 1, ou 2 pour Retina)
  -o, --out <fichier>        Chemin du fichier PNG généré (Défaut: même nom avec .png)
  -d, --dir <dossier>        Mode lot : exporte tous les .html d'un dossier
  -m, --manifest <fichier>   Chemin du registre d'intégrité (Défaut: design/export_manifest.json)
  -h, --help                 Affiche cette aide et termine l'exécution

${ANSI.bold}EXEMPLES :${ANSI.reset}
  node export_png.mjs --file design/mockups/home.html --target playstore --out screenshots/home.png
  node export_png.mjs -f design/mockups/store_banner.html -t feature
  node export_png.mjs --dir design/mockups/mobile/ --target appstore
`);
}

// 1. Analyse des arguments CLI
const rawArgs = process.argv.slice(2);
let targetFile = '';
let targetDir = '';
let targetPresetName = '';
let customScale = null;
let outputFile = '';
let manifestPath = 'design/export_manifest.json';

for (let i = 0; i < rawArgs.length; i++) {
  const arg = rawArgs[i];
  if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  } else if (arg === '--file' || arg === '-f') {
    targetFile = rawArgs[++i] || '';
  } else if (arg === '--target' || arg === '-t') {
    targetPresetName = rawArgs[++i] || '';
  } else if (arg === '--scale' || arg === '-s') {
    customScale = parseFloat(rawArgs[++i]);
  } else if (arg === '--out' || arg === '-o') {
    outputFile = rawArgs[++i] || '';
  } else if (arg === '--dir' || arg === '-d') {
    targetDir = rawArgs[++i] || '';
  } else if (arg === '--manifest' || arg === '-m') {
    manifestPath = rawArgs[++i] || 'design/export_manifest.json';
  } else if (arg.startsWith('--file=')) {
    targetFile = arg.split('=')[1];
  } else if (arg.startsWith('--target=')) {
    targetPresetName = arg.split('=')[1];
  } else if (arg.startsWith('--scale=')) {
    customScale = parseFloat(arg.split('=')[1]);
  } else if (arg.startsWith('--out=')) {
    outputFile = arg.split('=')[1];
  } else if (arg.startsWith('--dir=')) {
    targetDir = arg.split('=')[1];
  } else if (arg.startsWith('--manifest=')) {
    manifestPath = arg.split('=')[1];
  }
}

// 2. Détection d'un répertoire passé comme valeur de target
if (targetPresetName && fs.existsSync(targetPresetName) && fs.statSync(targetPresetName).isDirectory()) {
  targetDir = targetPresetName;
  targetPresetName = '';
}

// 3. Extraction Automatique et Unifiée des Métadonnées <!-- CANVAS_SPEC ... -->
function parseCanvasSpec(htmlContent, fallbackPresetKey, cliScale) {
  let width = 1080;
  let height = 1920;
  let scale = 1;
  let detectedTarget = '';
  let device = 'Standard Canvas';

  const specMatch = htmlContent.match(/<!--\s*CANVAS_SPEC:?\s*([^>]+)-->/i);
  if (specMatch) {
    const rawSpec = specMatch[1];

    const targetMatch = rawSpec.match(/target=["']?([a-zA-Z0-9_.-]+)["']?/i);
    if (targetMatch) {
      detectedTarget = targetMatch[1].toLowerCase();
      if (TARGET_PRESETS[detectedTarget]) {
        width = TARGET_PRESETS[detectedTarget].width;
        height = TARGET_PRESETS[detectedTarget].height;
        device = TARGET_PRESETS[detectedTarget].label;
      }
    }

    // Accepte width=1080, width=1080px, width="1080"
    const widthMatch = rawSpec.match(/width=["']?([0-9]+)(?:px)?["']?/i);
    const heightMatch = rawSpec.match(/height=["']?([0-9]+)(?:px)?["']?/i);
    const deviceMatch = rawSpec.match(/device=["']([^"']+)["']/i);
    const scaleMatch = rawSpec.match(/(?:export_scale|scale)=["']?([0-9.]+)(?:x)?["']?/i);

    if (widthMatch) width = parseInt(widthMatch[1], 10);
    if (heightMatch) height = parseInt(heightMatch[1], 10);
    if (deviceMatch) device = deviceMatch[1];
    if (scaleMatch) scale = parseFloat(scaleMatch[1]);
  } else if (fallbackPresetKey && TARGET_PRESETS[fallbackPresetKey.toLowerCase()]) {
    const preset = TARGET_PRESETS[fallbackPresetKey.toLowerCase()];
    width = preset.width;
    height = preset.height;
    device = preset.label;
    detectedTarget = fallbackPresetKey.toLowerCase();
  }

  // Surcharge prioritaire via arguments CLI explicites
  if (cliScale && !isNaN(cliScale) && cliScale > 0) {
    scale = cliScale;
  }
  if (fallbackPresetKey && TARGET_PRESETS[fallbackPresetKey.toLowerCase()]) {
    const preset = TARGET_PRESETS[fallbackPresetKey.toLowerCase()];
    width = preset.width;
    height = preset.height;
    device = preset.label;
  }

  return { width, height, scale, device, detectedTarget };
}

function computeSha256(filePath) {
  const fileBuffer = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(fileBuffer).digest('hex');
}

// Micro-serveur HTTP éphémère pour neutraliser les blocages CORS (Google Fonts / assets locaux)
function createEphemeralServer(rootDir) {
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => {
      let rawPath = decodeURIComponent(req.url.split('?')[0]);
      if (rawPath === '/') rawPath = '/index.html';
      const safePath = path.normalize(rawPath).replace(/^(\.\.[\/\\])+/, '');
      const filePath = path.join(rootDir, safePath);

      if (!filePath.startsWith(rootDir)) {
        res.statusCode = 403;
        res.end('Forbidden');
        return;
      }

      fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
          res.statusCode = 404;
          res.end('Not Found');
          return;
        }

        const ext = path.extname(filePath).toLowerCase();
        const mimeTypes = {
          '.html': 'text/html; charset=utf-8',
          '.css': 'text/css; charset=utf-8',
          '.js': 'application/javascript; charset=utf-8',
          '.json': 'application/json; charset=utf-8',
          '.png': 'image/png',
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.gif': 'image/gif',
          '.svg': 'image/svg+xml',
          '.webp': 'image/webp',
          '.woff': 'font/woff',
          '.woff2': 'font/woff2',
          '.ttf': 'font/ttf'
        };

        const contentType = mimeTypes[ext] || 'application/octet-stream';
        res.writeHead(200, {
          'Content-Type': contentType,
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'no-cache, no-store, must-revalidate'
        });
        fs.createReadStream(filePath).pipe(res);
      });
    });

    server.listen(0, '127.0.0.1', () => {
      const port = server.address().port;
      resolve({
        server,
        port,
        baseUrl: `http://127.0.0.1:${port}`,
        close: () => new Promise(resClose => server.close(resClose))
      });
    });

    server.on('error', reject);
  });
}

// 4. Exécution de la capture pour un fichier donné via HTTP local
async function captureHtmlFile(browser, filePath, outPath, presetKey, cliScale, manifestList, serverBaseUrl, rootDir) {
  const absoluteHtmlPath = path.resolve(filePath);
  if (!fs.existsSync(absoluteHtmlPath)) {
    throw new Error(`Fichier HTML introuvable : ${absoluteHtmlPath}`);
  }

  const content = fs.readFileSync(absoluteHtmlPath, 'utf-8');
  const spec = parseCanvasSpec(content, presetKey, cliScale);

  console.log(`\n${ANSI.bold}${ANSI.cyan}📸 [san_exporter] Traitement de : ${path.basename(filePath)}${ANSI.reset}`);
  console.log(`   Dimensions : ${spec.width}×${spec.height} px | Échelle (DPI) : ${spec.scale}x | Cible : ${spec.device}`);

  const page = await browser.newPage({
    viewport: { width: spec.width, height: spec.height },
    deviceScaleFactor: spec.scale
  });

  try {
    const relativeToRoot = path.relative(rootDir, absoluteHtmlPath).split(path.sep).join('/');
    const fileUrl = `${serverBaseUrl}/${encodeURI(relativeToRoot)}`;

    // 1. Synchronisation réseau : attente stricte de networkidle via serveur éphémère anti-CORS
    await page.goto(fileUrl, { waitUntil: 'networkidle', timeout: 30000 });

    // 2. Synchronisation typographique : attente de la rastérisation des polices
    await page.evaluate(async () => {
      if (document.fonts && document.fonts.ready) {
        await document.fonts.ready;
      }
    });

    // 3. Pause stabilisatrice déterministe pour absorber les transitions CSS initiales
    await page.waitForTimeout(200);

    const resolvedOutPath = path.resolve(outPath);
    fs.mkdirSync(path.dirname(resolvedOutPath), { recursive: true });

    // Capture PNG au pixel près
    await page.screenshot({
      path: resolvedOutPath,
      type: 'png',
      fullPage: false
    });

    const sha = computeSha256(resolvedOutPath);
    const stats = fs.statSync(resolvedOutPath);

    manifestList.push({
      file: path.relative(process.cwd(), resolvedOutPath),
      source: path.relative(process.cwd(), absoluteHtmlPath),
      width: Math.round(spec.width * spec.scale),
      height: Math.round(spec.height * spec.scale),
      scale: spec.scale,
      size_bytes: stats.size,
      sha256: sha,
      created_at: new Date().toISOString()
    });

    console.log(`   ${ANSI.green}✓ Capture réussie :${ANSI.reset} ${path.relative(process.cwd(), resolvedOutPath)}`);
    console.log(`   ${ANSI.gray}SHA-256 : ${sha.slice(0, 16)}... | Poids : ${(stats.size / 1024).toFixed(1)} Ko${ANSI.reset}`);
  } finally {
    await page.close();
  }
}

// 5. Point d'entrée principal avec gestion cartésienne de Playwright
async function main() {
  if (!targetFile && !targetDir) {
    console.error(`${ANSI.red}❌ Aucun fichier ou dossier spécifié.${ANSI.reset}`);
    printHelp();
    process.exit(1);
  }

  // Vérification de la disponibilité du module Playwright avec fallback gracieux
  let chromium;
  try {
    const playwrightModule = await import('playwright');
    chromium = playwrightModule.chromium;
  } catch (err) {
    console.error(`\n${ANSI.bold}${ANSI.red}[san_exporter] Le module d'automatisation "playwright" n'est pas encore installé.${ANSI.reset}`);
    console.error(`\n${ANSI.bold}${ANSI.yellow}=== DIAGNOSTIC & PROCÉDURE D'INSTALLATION ===${ANSI.reset}`);
    console.error(`Pour réaliser des captures d'écran déterministes de haute précision,`);
    console.error(`exécutez les deux commandes suivantes dans votre projet :\n`);
    console.error(`  ${ANSI.bold}${ANSI.cyan}1. Installation du package :${ANSI.reset}`);
    console.error(`     pnpm add -D playwright   ${ANSI.gray}(ou: npm install --save-dev playwright)${ANSI.reset}\n`);
    console.error(`  ${ANSI.bold}${ANSI.cyan}2. Téléchargement du binaire Chromium :${ANSI.reset}`);
    console.error(`     ${ANSI.bold}npx playwright install chromium${ANSI.reset}\n`);
    console.error(`${ANSI.gray}Une fois ces étapes accomplies, relancez cette commande d'exportation.${ANSI.reset}\n`);
    process.exit(1);
  }

  // Démarrage du navigateur headless
  let browser;
  try {
    browser = await chromium.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });
  } catch (launchErr) {
    console.error(`\n${ANSI.bold}${ANSI.red}❌ Impossible d'initialiser Chromium headless :${ANSI.reset}`);
    if (launchErr.message.includes('Executable doesn\'t exist') || launchErr.message.includes('playwright install')) {
      console.error(`${ANSI.yellow}Le binaire Chromium n'est pas installé sur votre machine.${ANSI.reset}`);
      console.error(`Exécutez la commande suivante pour le provisionner :`);
      console.error(`  ${ANSI.cyan}${ANSI.bold}npx playwright install chromium${ANSI.reset}\n`);
    } else {
      console.error(launchErr.message);
    }
    process.exit(1);
  }

  // Détermination du répertoire racine à servir via le micro-serveur éphémère
  const targetPath = targetFile ? path.resolve(targetFile) : path.resolve(targetDir);
  const serveRootDir = fs.existsSync(targetPath) && fs.statSync(targetPath).isDirectory()
    ? targetPath
    : path.dirname(targetPath);

  let ephemeralServer = null;
  const manifestList = [];

  try {
    ephemeralServer = await createEphemeralServer(serveRootDir);
    console.log(`${ANSI.gray}📡 Micro-serveur éphémère actif sur ${ephemeralServer.baseUrl} (anti-CORS)${ANSI.reset}`);

    if (targetFile) {
      const out = outputFile || targetFile.replace(/\.html$/i, '.png');
      await captureHtmlFile(browser, targetFile, out, targetPresetName, customScale, manifestList, ephemeralServer.baseUrl, serveRootDir);
    } else if (targetDir) {
      const resolvedDir = path.resolve(targetDir);
      if (!fs.existsSync(resolvedDir)) {
        throw new Error(`Dossier cible introuvable : ${resolvedDir}`);
      }
      const files = fs.readdirSync(resolvedDir).filter(f => f.endsWith('.html'));
      if (files.length === 0) {
        console.warn(`${ANSI.yellow}⚠️ Aucun fichier .html trouvé dans ${resolvedDir}${ANSI.reset}`);
      }
      for (const f of files) {
        const fullHtml = path.join(resolvedDir, f);
        const out = path.join(resolvedDir, f.replace(/\.html$/i, '.png'));
        await captureHtmlFile(browser, fullHtml, out, targetPresetName, customScale, manifestList, ephemeralServer.baseUrl, serveRootDir);
      }
    }

    // Mise à jour du registre d'intégrité (export_manifest.json)
    if (manifestList.length > 0) {
      const resolvedManifest = path.resolve(manifestPath);
      fs.mkdirSync(path.dirname(resolvedManifest), { recursive: true });

      let existingManifest = { assets: [] };
      if (fs.existsSync(resolvedManifest)) {
        try {
          existingManifest = JSON.parse(fs.readFileSync(resolvedManifest, 'utf-8'));
        } catch {
          existingManifest = { assets: [] };
        }
      }

      // Fusion avec mise à jour des entrées existantes
      const combinedAssets = [...(existingManifest.assets || [])];
      for (const newAsset of manifestList) {
        const existingIdx = combinedAssets.findIndex(a => a.file === newAsset.file);
        if (existingIdx >= 0) {
          combinedAssets[existingIdx] = newAsset;
        } else {
          combinedAssets.push(newAsset);
        }
      }

      const manifestPayload = {
        updated_at: new Date().toISOString(),
        engine: "san_exporter Playwright Headless",
        total_assets: combinedAssets.length,
        assets: combinedAssets
      };

      fs.writeFileSync(resolvedManifest, JSON.stringify(manifestPayload, null, 2), 'utf-8');
      console.log(`\n${ANSI.bold}${ANSI.green}📋 Registre d'intégrité mis à jour : ${path.relative(process.cwd(), resolvedManifest)}${ANSI.reset}`);
    }

    console.log(`\n${ANSI.bold}${ANSI.green}✨ [SUCCÈS] Opération d'exportation déterministe achevée avec succès.${ANSI.reset}`);
  } finally {
    if (ephemeralServer) {
      await ephemeralServer.close();
      console.log(`${ANSI.gray}🛑 Micro-serveur éphémère fermé proprement.${ANSI.reset}`);
    }
    await browser.close();
  }
}

main().catch(err => {
  console.error(`\n${ANSI.bold}${ANSI.red}❌ Erreur critique lors de la capture :${ANSI.reset}`, err.message);
  process.exit(1);
});
