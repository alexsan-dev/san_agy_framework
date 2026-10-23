#!/usr/bin/env node
/**
 * scripts/export_png.mjs
 * Pipeline Playwright d'export PNG déterministe haute résolution pour Antigravity san_designer.
 * 
 * Usage:
 *   node scripts/export_png.mjs --file=design/mockup/online-shop/mobile/01-accueil.html --scale=3
 *   node scripts/export_png.mjs --target=design/screenshots/play-store/ --scale=1
 */

import { chromium } from 'playwright';
import { readFileSync, readdirSync, statSync, existsSync, mkdirSync } from 'fs';
import { resolve, dirname, basename, join } from 'path';

// Analyse des arguments en ligne de commande
const args = process.argv.slice(2).reduce((acc, arg) => {
  const [key, value] = arg.replace(/^--/, '').split('=');
  acc[key] = value || true;
  return acc;
}, {});

const TARGET_FILE = args.file;
const TARGET_DIR = args.target;
const SCALE_FACTOR = parseFloat(args.scale || '2');
const CUSTOM_OUT = args.out;

if (!TARGET_FILE && !TARGET_DIR) {
  console.error('\x1b[31m[ERREUR] Vous devez spécifier --file=<chemin.html> ou --target=<dossier/>\x1b[0m');
  process.exit(1);
}

// Extraction du tag CANVAS_SPEC
function parseCanvasSpec(htmlContent) {
  const specRegex = /<!--\s*CANVAS_SPEC:\s*width=(\d+)px\s*height=(\d+)px(?:\s*device="([^"]*)")?(?:\s*export_scale=(\d+))?\s*-->/i;
  const match = htmlContent.match(specRegex);
  if (match) {
    return {
      width: parseInt(match[1], 10),
      height: parseInt(match[2], 10),
      device: match[3] || 'Standard Canvas',
      scale: match[4] ? parseFloat(match[4]) : SCALE_FACTOR
    };
  }
  return null;
}

async function renderHtmlToPng(browser, filePath, outputPath, forcedScale) {
  const startTs = Date.now();
  const absoluteHtmlPath = resolve(filePath);
  const fileContent = readFileSync(absoluteHtmlPath, 'utf-8');
  const spec = parseCanvasSpec(fileContent);

  const width = spec ? spec.width : 390;
  const height = spec ? spec.height : 844;
  const scale = forcedScale || (spec ? spec.scale : SCALE_FACTOR);
  const deviceName = spec ? spec.device : 'Custom Viewport';

  const context = await browser.newContext({
    viewport: { width, height },
    deviceScaleFactor: scale,
  });

  const page = await context.newPage();

  try {
    // Navigation vers le fichier HTML local avec attente réseau
    await page.goto(`file://${absoluteHtmlPath}`, {
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

    const outDir = dirname(outputPath);
    if (!existsSync(outDir)) {
      mkdirSync(outDir, { recursive: true });
    }

    // Capture d'écran fidèle au canvas
    await page.screenshot({
      path: outputPath,
      type: 'png',
      clip: { x: 0, y: 0, width, height },
    });

    const elapsed = Date.now() - startTs;
    const fileSize = (statSync(outputPath).size / 1024).toFixed(1);
    console.log(`\x1b[32m✔ EXPORT RÉUSSI\x1b[0m : ${basename(filePath)} -> ${basename(outputPath)} [${width}x${height} @${scale}x | ${fileSize} Ko | ${elapsed}ms | ${deviceName}]`);
  } catch (err) {
    console.error(`\x1b[31m✖ ÉCHEC EXPORT\x1b[0m sur ${filePath} : ${err.message}`);
    throw err;
  } finally {
    await context.close();
  }
}

async function main() {
  console.log('\x1b[36m=== ANTIGRAVITY SAN_DESIGNER : PIPELINE PLAYWRIGHT EXPORT PNG ===\x1b[0m');
  const browser = await chromium.launch({ headless: true });

  try {
    if (TARGET_FILE) {
      const defaultOut = TARGET_FILE.replace(/\.html$/i, '.png');
      const out = CUSTOM_OUT || defaultOut;
      await renderHtmlToPng(browser, TARGET_FILE, out, SCALE_FACTOR);
    } else if (TARGET_DIR) {
      const dirPath = resolve(TARGET_DIR);
      const files = readdirSync(dirPath).filter(f => f.endsWith('.html'));
      if (files.length === 0) {
        console.warn(`\x1b[33m[AVERTISSEMENT] Aucun fichier .html trouvé dans ${TARGET_DIR}\x1b[0m`);
      }
      for (const file of files) {
        const fullPath = join(dirPath, file);
        const outPath = join(dirPath, file.replace(/\.html$/i, '.png'));
        await renderHtmlToPng(browser, fullPath, outPath, SCALE_FACTOR);
      }
    }
  } finally {
    await browser.close();
    console.log('\x1b[36m=== FIN DU TRAITEMENT D\'EXPORT ===\x1b[0m');
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
