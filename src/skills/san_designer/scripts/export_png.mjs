#!/usr/bin/env node
/**
 * scripts/export_png.mjs
 * Pipeline Playwright d'export PNG déterministe haute résolution pour Antigravity san_designer.
 * 
 * Usage:
 *   node scripts/export_png.mjs --file=design/mockup/online-shop/mobile/01-accueil.html --scale=3
 *   node scripts/export_png.mjs --target=design/screenshots/play-store/ --scale=1
 */

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

// Analyse des arguments en ligne de commande
const args = process.argv.slice(2).reduce((acc, arg) => {
  const [key, value] = arg.replace(/^--/, '').split('=');
  acc[key] = value || true;
  return acc;
}, {});

if (args.help || args.h) {
  console.log(`\x1b[36m=== ANTIGRAVITY SAN_DESIGNER : PIPELINE PLAYWRIGHT EXPORT PNG ===\x1b[0m
Usage:
  node scripts/export_png.mjs --file=<chemin.html> [--scale=2] [--out=<output.png>]
  node scripts/export_png.mjs --target=<dossier/> [--scale=2]
`);
  process.exit(0);
}

const TARGET_FILE = args.file;
const TARGET_DIR = args.target;
const SCALE_FACTOR = parseFloat(args.scale || '2');
const CUSTOM_OUT = args.out;

if (!TARGET_FILE && !TARGET_DIR) {
  console.error('\x1b[31m[ERREUR] Vous devez spécifier --file=<chemin.html> ou --target=<dossier/>\x1b[0m');
  process.exit(1);
}

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

// Extraction unifiée du tag CANVAS_SPEC
function parseCanvasSpec(htmlContent, fallbackPresetKey, defaultScale = SCALE_FACTOR) {
  let width = 390;
  let height = 844;
  let scale = defaultScale;
  let device = 'Standard Canvas';
  let detectedTarget = '';

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

  return { width, height, scale, device, detectedTarget };
}

// Micro-serveur HTTP éphémère pour neutraliser les blocages CORS et charger polices et styles
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

async function renderHtmlToPng(browser, filePath, outputPath, forcedScale, serverBaseUrl, rootDir) {
  const startTs = Date.now();
  const absoluteHtmlPath = path.resolve(filePath);
  const fileContent = fs.readFileSync(absoluteHtmlPath, 'utf-8');
  const spec = parseCanvasSpec(fileContent);

  const width = spec.width;
  const height = spec.height;
  const scale = forcedScale || spec.scale;
  const deviceName = spec.device;

  const context = await browser.newContext({
    viewport: { width, height },
    deviceScaleFactor: scale,
  });

  const page = await context.newPage();

  try {
    // Calcul de l'URL HTTP via le micro-serveur éphémère (contourne le blocage CORS de file://)
    const relativeToRoot = path.relative(rootDir, absoluteHtmlPath).split(path.sep).join('/');
    const targetUrl = `${serverBaseUrl}/${encodeURI(relativeToRoot)}`;

    await page.goto(targetUrl, {
      waitUntil: 'networkidle',
      timeout: 30000,
    });

    // Attente impérative de la résolution intégrale des polices
    await page.evaluate(async () => {
      if (document.fonts && document.fonts.ready) {
        await document.fonts.ready;
      }
    });

    // Stabilisation cinétique (fin des transitions CSS initiales)
    await page.waitForTimeout(300);

    const outDir = path.dirname(outputPath);
    if (!fs.existsSync(outDir)) {
      fs.mkdirSync(outDir, { recursive: true });
    }

    // Capture d'écran fidèle au canvas
    await page.screenshot({
      path: outputPath,
      type: 'png',
      clip: { x: 0, y: 0, width, height },
    });

    const elapsed = Date.now() - startTs;
    const fileSize = (fs.statSync(outputPath).size / 1024).toFixed(1);
    console.log(`\x1b[32m✔ EXPORT RÉUSSI\x1b[0m : ${path.basename(filePath)} -> ${path.basename(outputPath)} [${width}x${height} @${scale}x | ${fileSize} Ko | ${elapsed}ms | ${deviceName}]`);
  } catch (err) {
    console.error(`\x1b[31m✖ ÉCHEC EXPORT\x1b[0m sur ${filePath} : ${err.message}`);
    throw err;
  } finally {
    await context.close();
  }
}

async function main() {
  console.log('\x1b[36m=== ANTIGRAVITY SAN_DESIGNER : PIPELINE PLAYWRIGHT EXPORT PNG ===\x1b[0m');

  // Fallback gracieux si Playwright n'est pas installé
  let chromium;
  try {
    const playwright = await import('playwright');
    chromium = playwright.chromium;
  } catch (err) {
    console.error('\x1b[31m\x1b[1m[san_designer] Le module d\'automatisation "playwright" n\'est pas installé.\x1b[0m');
    console.error('\x1b[33mPour effectuer des captures PNG haute résolution, exécutez :\x1b[0m');
    console.error('  pnpm add -D playwright && npx playwright install chromium');
    process.exit(1);
  }

  let browser;
  try {
    browser = await chromium.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });
  } catch (launchErr) {
    console.error('\x1b[31m\x1b[1m❌ Impossible d\'initialiser Chromium headless :\x1b[0m', launchErr.message);
    console.error('\x1b[33mAssurez-vous que Chromium est installé via : npx playwright install chromium\x1b[0m');
    process.exit(1);
  }

  // Détermination du répertoire racine pour le micro-serveur éphémère
  const targetPath = TARGET_FILE ? path.resolve(TARGET_FILE) : path.resolve(TARGET_DIR);
  const serveRootDir = fs.statSync(targetPath).isDirectory() ? targetPath : path.dirname(targetPath);

  let ephemeralServer = null;
  try {
    ephemeralServer = await createEphemeralServer(serveRootDir);
    console.log(`\x1b[90m📡 Micro-serveur éphémère actif sur ${ephemeralServer.baseUrl} (anti-CORS)\x1b[0m`);

    if (TARGET_FILE) {
      const defaultOut = TARGET_FILE.replace(/\.html$/i, '.png');
      const out = CUSTOM_OUT || defaultOut;
      await renderHtmlToPng(browser, TARGET_FILE, out, SCALE_FACTOR, ephemeralServer.baseUrl, serveRootDir);
    } else if (TARGET_DIR) {
      const dirPath = path.resolve(TARGET_DIR);
      const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.html'));
      if (files.length === 0) {
        console.warn(`\x1b[33m[AVERTISSEMENT] Aucun fichier .html trouvé dans ${TARGET_DIR}\x1b[0m`);
      }
      for (const file of files) {
        const fullPath = path.join(dirPath, file);
        const outPath = path.join(dirPath, file.replace(/\.html$/i, '.png'));
        await renderHtmlToPng(browser, fullPath, outPath, SCALE_FACTOR, ephemeralServer.baseUrl, serveRootDir);
      }
    }
  } finally {
    if (ephemeralServer) {
      await ephemeralServer.close();
      console.log('\x1b[90m🛑 Micro-serveur éphémère fermé proprement.\x1b[0m');
    }
    await browser.close();
    console.log('\x1b[36m=== FIN DU TRAITEMENT D\'EXPORT ===\x1b[0m');
  }
}

main().catch(err => {
  console.error('\x1b[31m[ERREUR FATALE]\x1b[0m', err.message);
  process.exit(1);
});
