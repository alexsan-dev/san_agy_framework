#!/usr/bin/env node
// ==============================================================================
// SCRIPT : export_png.mjs (v2.2.0)
// MODULES : san_designer & san_exporter
// FRAMEWORK : Antigravity / Dual-Harness (san_*)
// DESCRIPTION : Pipeline Playwright de capture PNG multi-viewports sur instance
//               Chromium unique : fichiers locaux HTML (micro-serveur HTTP
//               éphémère anti-CORS) ET URLs web distantes (--url), mode --full-page,
//               Linter Géométrique DOM (--audit-dom), rapport JSON (--report)
//               et registre d'intégrité SHA-256.
// ==============================================================================

import http from 'node:http';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

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

// Presets stores & formats normatifs existants (compatibilité ascendante 100 %)
const TARGET_PRESETS = {
  mobile: { width: 390, height: 844, label: 'Mobile Prototype (390x844)' },
  tablet: { width: 820, height: 1180, label: 'Tablet Portrait (820x1180)' },
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

// Presets multi-viewports responsives pour Studio UI (--viewports / --multi-viewport)
const VIEWPORT_PRESETS = {
  mobile: { name: 'mobile', width: 390, height: 844, label: 'Mobile (390x844)' },
  tablet: { name: 'tablet', width: 820, height: 1180, label: 'Tablet (820x1180)' },
  desktop: { name: 'desktop', width: 1440, height: 900, label: 'Desktop (1440x900)' }
};

function printHelp() {
  console.log(`
${ANSI.bold}${ANSI.blue}=== Moteur d'Exportation & Linter Géométrique DOM (export_png.mjs v2.2) ===${ANSI.reset}

${ANSI.bold}UTILISATION :${ANSI.reset}
  node export_png.mjs [options]
  node export_png.mjs --input <mockup.html> [--output <out.png>] [--target <cible>]
  node export_png.mjs --input <mockup.html> --viewports=mobile,tablet,desktop --audit-dom --report=audit.json
  node export_png.mjs --url=<https://exemple.com[,https://...]> [--viewports=desktop,mobile] [--full-page]

${ANSI.bold}OPTIONS COMPATIBLES :${ANSI.reset}
  -i, --input, -f, --file <fichier>   Fichier HTML source à capturer
  -u, --url <url[,url2,...]>          URL(s) distante(s) HTTP(S) à capturer en live (défaut: desktop,mobile)
      --full-page                     Capture la page complète scrollable (fullPage: true)
  -o, --output, --out <fichier|dir>   Chemin du PNG généré ou dossier de sortie (en mode --url)
  -t, --target <cible|dossier>        Preset (playstore, appstore, web, feature, desktop, print, ipad, banner) ou dossier
  -d, --dir <dossier>                 Mode lot HTML (ou dossier de sortie en mode --url, défaut: design/references)
  -w, --width <px>                    Largeur explicite du viewport en pixels
      --height <px>                   Hauteur explicite du viewport en pixels
  -s, --scale <float>                 Facteur d'échelle DPI (deviceScaleFactor, défaut: 1 ou CANVAS_SPEC)
      --wait <ms>                     Délai de stabilisation après chargement/resize en ms (défaut: 250)
  -m, --manifest <fichier>            Registre SHA-256 (défaut: design/export_manifest.json, --no-manifest pour désactiver)

${ANSI.bold}OPTIONS MULTI-VIEWPORTS & LINTER DOM (v2.2) :${ANSI.reset}
      --viewports <liste>             Liste CSV sur Chromium unique (ex: mobile,tablet,desktop ou 390x844)
      --multi-viewport                Raccourci pour --viewports=mobile,tablet,desktop (390x844, 820x1180, 1440x900)
      --audit-dom                     Exécute le linter géométrique DOM via page.evaluate() (actif par défaut sur HTML)
      --no-audit-dom                  Désactive le linter géométrique DOM
      --report <path.json>            Écrit le rapport JSON complet de l'audit géométrique DOM
      --strict-dom                    Retourne un code non-zéro si un horizontalOverflow bloquant est détecté
  -h, --help                          Affiche cette aide et termine l'exécution
`);
}

function appendParsedUrls(targetList, rawValue) {
  const tokens = String(rawValue || '').split(',').map(s => s.trim()).filter(Boolean);
  if (tokens.length === 0) {
    throw new Error('URL vide fournie pour --url.');
  }
  for (const token of tokens) {
    let parsed;
    try {
      parsed = new URL(token);
    } catch {
      throw new Error(`URL invalide : ${token}`);
    }
    if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
      throw new Error(`Protocole non supporté pour --url (http/https requis) : ${token}`);
    }
    if (!targetList.includes(token)) {
      targetList.push(token);
    }
  }
}

/**
 * Parse les arguments CLI en supportant --cle=valeur, --cle valeur, flags courts et argument positionnel.
 */
function parseCliArgs(argv) {
  const opts = {
    help: false,
    inputFile: '',
    urls: [],
    fullPage: false,
    targetDir: '',
    targetPresetName: '',
    rawTargetArg: '',
    outputFile: '',
    hasExplicitOutput: false,
    cliWidth: null,
    cliHeight: null,
    cliScale: null,
    waitMs: 250,
    viewportsRaw: '',
    multiViewport: false,
    auditDom: true,
    auditDomExplicit: false,
    strictDom: false,
    reportPath: '',
    manifestPath: 'design/export_manifest.json',
    noManifest: false
  };

  const readValue = (arg, index) => {
    const eqIdx = arg.indexOf('=');
    if (eqIdx !== -1) {
      return { val: arg.slice(eqIdx + 1), consumedNext: false };
    }
    if (index + 1 >= argv.length) {
      throw new Error(`Valeur manquante pour l'option ${arg}`);
    }
    return { val: argv[index + 1], consumedNext: true };
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const flag = arg.includes('=') ? arg.slice(0, arg.indexOf('=')) : arg;

    if (flag === '--help' || flag === '-h') {
      opts.help = true;
    } else if (flag === '--file' || flag === '-f' || flag === '--input' || flag === '-i') {
      const { val, consumedNext } = readValue(arg, i);
      opts.inputFile = val;
      if (consumedNext) i++;
    } else if (flag === '--url' || flag === '-u') {
      const { val, consumedNext } = readValue(arg, i);
      appendParsedUrls(opts.urls, val);
      if (consumedNext) i++;
    } else if (flag === '--full-page' || flag === '--fullpage') {
      opts.fullPage = true;
    } else if (flag === '--no-full-page') {
      opts.fullPage = false;
    } else if (flag === '--target' || flag === '-t') {
      const { val, consumedNext } = readValue(arg, i);
      opts.rawTargetArg = val;
      if (consumedNext) i++;
    } else if (flag === '--dir' || flag === '-d') {
      const { val, consumedNext } = readValue(arg, i);
      opts.targetDir = val;
      if (consumedNext) i++;
    } else if (flag === '--out' || flag === '-o' || flag === '--output') {
      const { val, consumedNext } = readValue(arg, i);
      opts.outputFile = val;
      opts.hasExplicitOutput = Boolean(val);
      if (consumedNext) i++;
    } else if (flag === '--width' || flag === '-w') {
      const { val, consumedNext } = readValue(arg, i);
      const parsed = parseInt(val, 10);
      if (!Number.isFinite(parsed) || parsed <= 0) {
        throw new Error(`Largeur --width invalide : ${val}`);
      }
      opts.cliWidth = parsed;
      if (consumedNext) i++;
    } else if (flag === '--height') {
      const { val, consumedNext } = readValue(arg, i);
      const parsed = parseInt(val, 10);
      if (!Number.isFinite(parsed) || parsed <= 0) {
        throw new Error(`Hauteur --height invalide : ${val}`);
      }
      opts.cliHeight = parsed;
      if (consumedNext) i++;
    } else if (flag === '--scale' || flag === '-s') {
      const { val, consumedNext } = readValue(arg, i);
      const parsed = parseFloat(val);
      if (!Number.isFinite(parsed) || parsed <= 0) {
        throw new Error(`Échelle --scale invalide : ${val}`);
      }
      opts.cliScale = parsed;
      if (consumedNext) i++;
    } else if (flag === '--wait') {
      const { val, consumedNext } = readValue(arg, i);
      const parsed = parseInt(val, 10);
      if (!Number.isFinite(parsed) || parsed < 0) {
        throw new Error(`Délai --wait invalide : ${val}`);
      }
      opts.waitMs = parsed;
      if (consumedNext) i++;
    } else if (flag === '--viewports' || flag === '--viewport') {
      const { val, consumedNext } = readValue(arg, i);
      opts.viewportsRaw = val;
      if (consumedNext) i++;
    } else if (flag === '--multi-viewport' || flag === '--multi-viewports') {
      opts.multiViewport = true;
    } else if (flag === '--audit-dom') {
      opts.auditDom = true;
      opts.auditDomExplicit = true;
    } else if (flag === '--no-audit-dom') {
      opts.auditDom = false;
      opts.auditDomExplicit = true;
    } else if (flag === '--strict-dom') {
      opts.strictDom = true;
      opts.auditDom = true;
      opts.auditDomExplicit = true;
    } else if (flag === '--report') {
      const { val, consumedNext } = readValue(arg, i);
      opts.reportPath = val;
      opts.auditDom = true;
      opts.auditDomExplicit = true;
      if (consumedNext) i++;
    } else if (flag === '--manifest' || flag === '-m') {
      const { val, consumedNext } = readValue(arg, i);
      opts.manifestPath = val;
      if (consumedNext) i++;
    } else if (flag === '--no-manifest') {
      opts.noManifest = true;
    } else if (!arg.startsWith('-')) {
      if (/^https?:\/\//i.test(arg)) {
        appendParsedUrls(opts.urls, arg);
      } else if (fs.existsSync(arg) && fs.statSync(arg).isDirectory()) {
        opts.targetDir = arg;
      } else if (!opts.inputFile) {
        opts.inputFile = arg;
      }
    } else {
      throw new Error(`Option inconnue : ${arg}`);
    }
  }

  if (opts.rawTargetArg) {
    if (fs.existsSync(opts.rawTargetArg) && fs.statSync(opts.rawTargetArg).isDirectory()) {
      opts.targetDir = opts.rawTargetArg;
    } else if (TARGET_PRESETS[opts.rawTargetArg.toLowerCase()]) {
      opts.targetPresetName = opts.rawTargetArg.toLowerCase();
    } else {
      throw new Error(`Cible --target introuvable ou preset inconnu : ${opts.rawTargetArg}`);
    }
  }

  // En mode --url, l'audit DOM ne s'exécute que s'il est explicitement demandé (--audit-dom / --report / --strict-dom)
  if (opts.urls.length > 0 && !opts.inputFile && !opts.auditDomExplicit) {
    opts.auditDom = false;
  }

  return opts;
}

/**
 * Résout la liste ordonnée des viewports pour le mode Multi-Viewports (et le défaut --url).
 */
function resolveViewports(opts) {
  let tokens = [];
  if (opts.viewportsRaw) {
    tokens = opts.viewportsRaw.split(',').map(s => s.trim().toLowerCase()).filter(Boolean);
  } else if (opts.multiViewport) {
    tokens = ['mobile', 'tablet', 'desktop'];
  } else if (opts.urls.length > 0 && !opts.inputFile) {
    if (opts.targetPresetName && TARGET_PRESETS[opts.targetPresetName]) {
      tokens = [opts.targetPresetName];
    } else if (opts.cliWidth || opts.cliHeight) {
      const w = opts.cliWidth || 1440;
      const h = opts.cliHeight || 900;
      return [{ name: `${w}x${h}`, width: w, height: h, label: `Custom (${w}x${h})` }];
    } else {
      tokens = ['desktop', 'mobile'];
    }
  }

  if (tokens.length === 0) return [];

  const resolved = [];
  const seen = new Set();

  for (const token of tokens) {
    if (seen.has(token)) continue;
    seen.add(token);

    if (VIEWPORT_PRESETS[token]) {
      resolved.push({ ...VIEWPORT_PRESETS[token] });
    } else if (TARGET_PRESETS[token]) {
      resolved.push({
        name: token,
        width: TARGET_PRESETS[token].width,
        height: TARGET_PRESETS[token].height,
        label: TARGET_PRESETS[token].label
      });
    } else {
      const match = token.match(/^(\d+)x(\d+)$/);
      if (!match) {
        throw new Error(`Viewport inconnu "${token}". Valeurs attendues : mobile, tablet, desktop ou <largeur>x<hauteur>.`);
      }
      const w = parseInt(match[1], 10);
      const h = parseInt(match[2], 10);
      resolved.push({ name: token, width: w, height: h, label: `Custom (${w}x${h})` });
    }
  }

  return resolved;
}

/**
 * Extraction unifiée du commentaire <!-- CANVAS_SPEC ... --> avec surcharges CLI prioritaires.
 */
function parseCanvasSpec(htmlContent, opts) {
  let width = 390;
  let height = 844;
  let scale = 1;
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
  }

  if (opts.targetPresetName && TARGET_PRESETS[opts.targetPresetName]) {
    const preset = TARGET_PRESETS[opts.targetPresetName];
    width = preset.width;
    height = preset.height;
    device = preset.label;
    detectedTarget = opts.targetPresetName;
  }

  if (opts.cliWidth) width = opts.cliWidth;
  if (opts.cliHeight) height = opts.cliHeight;
  if (opts.cliScale) scale = opts.cliScale;

  return { width, height, scale, device, detectedTarget };
}

function computeSha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

/**
 * Collecte les répertoires parents jusqu'à la racine du système de fichiers.
 */
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
 * Résout Playwright depuis le projet client, NODE_PATH, le script (ou realpath),
 * le plugin san-ai-harness/san-framework, san_ai_harness/node_modules ou le cache ~/.npm/_npx.
 */
async function loadPlaywright() {
  const normalize = (mod) => (mod?.chromium ? mod : (mod?.default?.chromium ? mod.default : mod));
  try {
    const primary = normalize(await import('playwright'));
    if (primary && primary.chromium) return primary;
  } catch (primaryErr) {
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
    addBase(path.join(homeDir, '.npm-global', 'lib'));
    addBase('/usr/local/lib');

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
        // Ignore erreur lecture cache _npx
      }
    }

    for (const pkgName of ['playwright', 'playwright-core']) {
      for (const baseDir of candidateBases) {
        try {
          const req = createRequire(path.join(baseDir, '_san_resolve_.cjs'));
          const mod = normalize(req(pkgName));
          if (mod && mod.chromium) return mod;
        } catch {
          // Essaie la base suivante
        }
      }
    }
    throw primaryErr;
  }
}

/**
 * Localise un binaire Chromium dans ~/.cache/ms-playwright ou le système si besoin.
 */
function findCachedChromiumExecutable(chromium) {
  const envExe = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH;
  if (envExe && fs.existsSync(envExe)) return envExe;

  try {
    const defaultExe = chromium.executablePath();
    if (defaultExe && fs.existsSync(defaultExe)) return defaultExe;
  } catch {
    // Ignore si executablePath() échoue
  }

  const browsersRoot = process.env.PLAYWRIGHT_BROWSERS_PATH || path.join(os.homedir(), '.cache', 'ms-playwright');
  if (fs.existsSync(browsersRoot)) {
    try {
      const dirs = fs.readdirSync(browsersRoot, { withFileTypes: true })
        .filter(d => d.isDirectory() && /^chromium(?:_headless_shell)?-\d+/.test(d.name))
        .map(d => {
          const rev = parseInt(d.name.split('-').pop(), 10) || 0;
          const isHeadlessShell = d.name.startsWith('chromium_headless_shell');
          return { name: d.name, rev, isHeadlessShell };
        })
        .sort((a, b) => (b.rev - a.rev) || (Number(a.isHeadlessShell) - Number(b.isHeadlessShell)));

      const relCandidates = [
        'chrome-linux64/chrome',
        'chrome-linux/chrome',
        'chrome-headless-shell-linux64/chrome-headless-shell',
        'chrome-headless-shell-linux/chrome-headless-shell',
        'chrome-mac/Chromium.app/Contents/MacOS/Chromium',
        'chrome-win/chrome.exe'
      ];
      for (const dir of dirs) {
        for (const rel of relCandidates) {
          const candidate = path.join(browsersRoot, dir.name, rel);
          if (fs.existsSync(candidate)) return candidate;
        }
      }
    } catch {
      // Ignore erreur parcours ms-playwright
    }
  }

  for (const sysBin of ['/usr/bin/chromium', '/usr/bin/chromium-browser', '/usr/bin/google-chrome', '/usr/bin/google-chrome-stable']) {
    if (fs.existsSync(sysBin)) return sysBin;
  }
  return null;
}

/**
 * Lance Chromium headless avec fallback automatique sur ~/.cache/ms-playwright.
 */
async function launchChromiumBrowser(chromium) {
  const args = ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'];
  try {
    return await chromium.launch({ headless: true, args });
  } catch (primaryErr) {
    const fallbackExe = findCachedChromiumExecutable(chromium);
    if (fallbackExe) {
      return chromium.launch({ headless: true, executablePath: fallbackExe, args });
    }
    throw primaryErr;
  }
}

/**
 * Micro-serveur HTTP éphémère anti-CORS pour charger polices locales et feuilles de style.
 */
function createEphemeralServer(rootDir) {
  return new Promise((resolve, reject) => {
    const mimeTypes = {
      '.html': 'text/html; charset=utf-8',
      '.css': 'text/css; charset=utf-8',
      '.js': 'application/javascript; charset=utf-8',
      '.mjs': 'application/javascript; charset=utf-8',
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

    const server = http.createServer((req, res) => {
      let rawPath = decodeURIComponent((req.url || '/').split('?')[0]);
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
        res.writeHead(200, {
          'Content-Type': mimeTypes[ext] || 'application/octet-stream',
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

/**
 * Linter Géométrique DOM exécuté dans Chromium via page.evaluate().
 */
async function runDomGeometricAudit(page) {
  return page.evaluate(() => {
    const round2 = (n) => Math.round(n * 100) / 100;
    const INTERACTIVE_SELECTOR = 'button, a, input, select, textarea, [role="button"]';
    const IGNORED_TAGS = new Set(['SCRIPT', 'STYLE', 'NOSCRIPT', 'TEMPLATE']);
    const METRIC_REGEX = /\d+[.,]\d+|\$\d+|\d+%/;

    const describeElement = (el) => {
      const tag = el.tagName.toLowerCase();
      const id = el.id ? `#${el.id}` : '';
      const cls = typeof el.className === 'string' && el.className.trim()
        ? '.' + el.className.trim().split(/\s+/).slice(0, 3).join('.')
        : '';
      const text = (el.innerText || el.textContent || '').trim().replace(/\s+/g, ' ').slice(0, 48);
      return {
        selector: `${tag}${id}${cls}`,
        tag,
        id: el.id || null,
        text: text || null
      };
    };

    const isVisuallyHidden = (el, style) => {
      if (el.classList && el.classList.contains('sr-only')) return true;
      if (style.clip === 'rect(0px, 0px, 0px, 0px)') return true;
      if (style.clipPath === 'inset(50%)') return true;
      return false;
    };

    const isVisible = (el) => {
      if (!el || el.nodeType !== 1 || IGNORED_TAGS.has(el.tagName)) return null;
      if (el.tagName === 'INPUT' && el.type === 'hidden') return null;
      const style = window.getComputedStyle(el);
      if (style.display === 'none' || style.visibility === 'hidden' || parseFloat(style.opacity || '1') <= 0) {
        return null;
      }
      if (isVisuallyHidden(el, style)) return null;
      if (typeof el.checkVisibility === 'function') {
        try {
          if (!el.checkVisibility({ checkOpacity: true, checkVisibilityCSS: true })) return null;
        } catch {
          // Ignore checkVisibility edge cases on SVG internals
        }
      }
      const rect = el.getBoundingClientRect();
      if (rect.width <= 0 || rect.height <= 0) return null;
      return { style, rect };
    };

    const hasHorizontalClipAncestor = (el) => {
      let cur = el.parentElement;
      while (cur && cur !== document.body && cur !== document.documentElement) {
        const ox = window.getComputedStyle(cur).overflowX;
        if (ox === 'hidden' || ox === 'clip' || ox === 'auto' || ox === 'scroll') return true;
        cur = cur.parentElement;
      }
      return false;
    };

    const getEffectiveZIndex = (el, style, parentStyle) => {
      const parentDisplay = parentStyle ? parentStyle.display : '';
      const isFlexOrGridChild = parentDisplay.includes('flex') || parentDisplay.includes('grid');
      const canStack = style.position !== 'static' || isFlexOrGridChild;
      return canStack && style.zIndex !== 'auto' ? style.zIndex : '0';
    };

    // 1. Débordement horizontal (scrollWidth > clientWidth + éléments hors viewport)
    const docEl = document.documentElement;
    const scrollWidth = docEl.scrollWidth;
    const clientWidth = docEl.clientWidth;
    const documentOverflow = scrollWidth > clientWidth;
    const overflowingElements = [];

    const allBodyEls = Array.from(document.querySelectorAll('body *'));
    for (const el of allBodyEls) {
      const info = isVisible(el);
      if (!info) continue;
      const { rect } = info;
      if ((rect.right > clientWidth + 1 || rect.left < -1) && !hasHorizontalClipAncestor(el)) {
        overflowingElements.push({
          ...describeElement(el),
          left: round2(rect.left),
          right: round2(rect.right),
          width: round2(rect.width),
          overflowRightPx: round2(Math.max(0, rect.right - clientWidth)),
          overflowLeftPx: round2(Math.max(0, -rect.left))
        });
      }
    }

    // 2. Cibles tactiles inférieures à 44x44 px
    const smallTouchTargets = [];
    for (const el of document.querySelectorAll(INTERACTIVE_SELECTOR)) {
      const info = isVisible(el);
      if (!info) continue;
      const { rect } = info;
      if (rect.width < 43.99 || rect.height < 43.99) {
        smallTouchTargets.push({
          ...describeElement(el),
          width: round2(rect.width),
          height: round2(rect.height),
          minRequired: 44
        });
      }
    }

    // 3. Collisions de boîtes entre frères visibles (boutons/textes sur même z-index)
    const boxCollisions = [];
    const containers = document.body ? [document.body, ...allBodyEls] : [];
    for (const parent of containers) {
      if (!parent.children || parent.children.length < 2) continue;
      const parentStyle = window.getComputedStyle(parent);
      const visibleSiblings = [];

      for (const child of parent.children) {
        const info = isVisible(child);
        if (!info) continue;
        const isInteractive = child.matches(INTERACTIVE_SELECTOR);
        const hasText = (child.innerText || '').trim().length > 0;
        if (!isInteractive && !hasText) continue;
        visibleSiblings.push({
          el: child,
          style: info.style,
          rect: info.rect,
          zIndex: getEffectiveZIndex(child, info.style, parentStyle)
        });
      }

      for (let i = 0; i < visibleSiblings.length; i++) {
        for (let j = i + 1; j < visibleSiblings.length; j++) {
          const a = visibleSiblings[i];
          const b = visibleSiblings[j];
          if (a.zIndex !== b.zIndex) continue;
          if (
            a.style.display === 'inline' && b.style.display === 'inline' &&
            a.style.position === 'static' && b.style.position === 'static'
          ) {
            continue;
          }

          const overlapW = Math.min(a.rect.right, b.rect.right) - Math.max(a.rect.left, b.rect.left);
          const overlapH = Math.min(a.rect.bottom, b.rect.bottom) - Math.max(a.rect.top, b.rect.top);
          if (overlapW > 2 && overlapH > 2) {
            boxCollisions.push({
              first: describeElement(a.el),
              second: describeElement(b.el),
              zIndex: a.zIndex,
              overlapWidth: round2(overlapW),
              overlapHeight: round2(overlapH)
            });
          }
        }
      }
    }

    // 4. Métriques numériques / prix sans font-variant-numeric: tabular-nums
    const missingTabularNums = [];
    const textCandidates = document.body ? [document.body, ...allBodyEls] : [];
    for (const el of textCandidates) {
      const info = isVisible(el);
      if (!info) continue;
      let directText = '';
      for (const node of el.childNodes) {
        if (node.nodeType === Node.TEXT_NODE && node.nodeValue) {
          directText += node.nodeValue;
        }
      }
      const trimmed = directText.trim();
      if (!trimmed || !METRIC_REGEX.test(trimmed)) continue;
      if (!info.style.fontVariantNumeric.includes('tabular-nums')) {
        missingTabularNums.push({
          ...describeElement(el),
          sample: trimmed.slice(0, 60),
          fontVariantNumeric: info.style.fontVariantNumeric
        });
      }
    }

    return {
      viewport: { width: window.innerWidth, height: window.innerHeight },
      horizontalOverflow: {
        detected: documentOverflow || overflowingElements.length > 0,
        documentOverflow,
        scrollWidth,
        clientWidth,
        overflowPx: Math.max(0, scrollWidth - clientWidth),
        count: overflowingElements.length,
        elements: overflowingElements.slice(0, 50)
      },
      smallTouchTargets: {
        detected: smallTouchTargets.length > 0,
        minRequiredPx: 44,
        count: smallTouchTargets.length,
        elements: smallTouchTargets.slice(0, 50)
      },
      boxCollisions: {
        detected: boxCollisions.length > 0,
        count: boxCollisions.length,
        pairs: boxCollisions.slice(0, 50)
      },
      missingTabularNums: {
        detected: missingTabularNums.length > 0,
        count: missingTabularNums.length,
        elements: missingTabularNums.slice(0, 50)
      }
    };
  });
}

function deriveViewportOutputPath(baseOutPath, viewportName) {
  const resolved = path.resolve(baseOutPath);
  const ext = path.extname(resolved) || '.png';
  const stem = path.extname(resolved) ? resolved.slice(0, -ext.length) : resolved;
  return `${stem}-${viewportName}${ext}`;
}

function formatSourceRef(sourcePathOrUrl) {
  return /^https?:\/\//i.test(sourcePathOrUrl)
    ? sourcePathOrUrl
    : path.relative(process.cwd(), sourcePathOrUrl);
}

function recordAssetManifest(manifestList, resolvedOutPath, sourcePathOrUrl, width, height, scale) {
  const sha = computeSha256(resolvedOutPath);
  const stats = fs.statSync(resolvedOutPath);
  manifestList.push({
    file: path.relative(process.cwd(), resolvedOutPath),
    source: formatSourceRef(sourcePathOrUrl),
    width: Math.round(width * scale),
    height: Math.round(height * scale),
    scale,
    size_bytes: stats.size,
    sha256: sha,
    created_at: new Date().toISOString()
  });
  return { sha, sizeBytes: stats.size };
}

function printDomAuditSummary(label, domAudit) {
  const ov = domAudit.horizontalOverflow;
  const st = domAudit.smallTouchTargets;
  const bc = domAudit.boxCollisions;
  const tn = domAudit.missingTabularNums;
  const hasAny = ov.detected || st.detected || bc.detected || tn.detected;
  const prefix = ov.detected ? ANSI.red : hasAny ? ANSI.yellow : ANSI.green;

  console.log(
    `   ${prefix}[DOM AUDIT ${label}]${ANSI.reset} ` +
    `overflow=${ov.detected ? `OUI(${ov.overflowPx}px/${ov.count}el)` : '0'} | ` +
    `touch<44=${st.count} | collisions=${bc.count} | no-tabular=${tn.count}`
  );
}

/**
 * Exécute la boucle multi-viewports, captures PNG et audit DOM sur une page Chromium ouverte.
 */
async function captureViewportSet(page, activeViewports, opts, resolveOutPath, sourcePathOrUrl, scale, manifestList, auditResults) {
  const renderedItems = [];
  const sourceRef = formatSourceRef(sourcePathOrUrl);

  for (const vp of activeViewports) {
    const startTs = Date.now();
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.evaluate(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))));
    if (opts.waitMs > 0) {
      await page.waitForTimeout(opts.waitMs);
    }

    const outPath = resolveOutPath(vp);
    fs.mkdirSync(path.dirname(outPath), { recursive: true });
    await page.screenshot({ path: outPath, type: 'png', fullPage: opts.fullPage });

    const { sha, sizeBytes } = recordAssetManifest(
      manifestList,
      outPath,
      sourcePathOrUrl,
      vp.width,
      vp.height,
      scale
    );
    const elapsed = Date.now() - startTs;

    console.log(
      `   ${ANSI.green}✔ EXPORT RÉUSSI${ANSI.reset} : ${path.relative(process.cwd(), outPath)} ` +
      `[${vp.width}x${vp.height} @${scale}x | ${(sizeBytes / 1024).toFixed(1)} Ko | ${elapsed}ms | ${vp.label}]`
    );
    console.log(`   ${ANSI.gray}SHA-256 : ${sha.slice(0, 16)}...${ANSI.reset}`);

    if (opts.auditDom) {
      const domAudit = await runDomGeometricAudit(page);
      printDomAuditSummary(vp.name, domAudit);
      auditResults.push({
        source: sourceRef,
        output: path.relative(process.cwd(), outPath),
        viewport: { name: vp.name, width: vp.width, height: vp.height, scale },
        domAudit
      });
    }

    renderedItems.push({ viewport: vp, outputPath: outPath });
  }

  return renderedItems;
}

/**
 * Capture un fichier HTML en mode mono-viewport ou multi-viewports sur une seule page Chromium.
 */
async function captureHtmlFile(browser, filePath, baseOutPath, opts, viewports, serverBaseUrl, rootDir, manifestList, auditResults) {
  const absoluteHtmlPath = path.resolve(filePath);
  if (!fs.existsSync(absoluteHtmlPath)) {
    throw new Error(`Fichier HTML introuvable : ${absoluteHtmlPath}`);
  }

  const content = fs.readFileSync(absoluteHtmlPath, 'utf-8');
  const spec = parseCanvasSpec(content, opts);
  const activeViewports = viewports.length > 0
    ? viewports
    : [{ name: spec.detectedTarget || 'default', width: spec.width, height: spec.height, label: spec.device }];

  const isMulti = viewports.length > 0;
  console.log(`\n${ANSI.bold}${ANSI.cyan}📸 [export_png] Traitement de : ${path.basename(filePath)}${ANSI.reset}`);

  const context = await browser.newContext({
    viewport: { width: activeViewports[0].width, height: activeViewports[0].height },
    deviceScaleFactor: spec.scale
  });
  const page = await context.newPage();

  try {
    const relativeToRoot = path.relative(rootDir, absoluteHtmlPath).split(path.sep).join('/');
    const fileUrl = `${serverBaseUrl}/${encodeURI(relativeToRoot)}`;

    await page.goto(fileUrl, { waitUntil: 'networkidle', timeout: 30000 });
    await page.evaluate(async () => {
      if (document.fonts && document.fonts.ready) {
        await document.fonts.ready;
      }
    });

    const renderedItems = await captureViewportSet(
      page,
      activeViewports,
      opts,
      (vp) => (isMulti ? deriveViewportOutputPath(baseOutPath, vp.name) : path.resolve(baseOutPath)),
      absoluteHtmlPath,
      spec.scale,
      manifestList,
      auditResults
    );

    // En mode multi-viewports avec --output/--out explicite sur fichier unique, copie le rendu principal vers --output
    if (isMulti && opts.hasExplicitOutput && opts.inputFile && renderedItems.length > 0) {
      const resolvedExplicit = path.resolve(baseOutPath);
      const primary = renderedItems.find(r => r.viewport.name === 'desktop') || renderedItems[renderedItems.length - 1];
      if (primary.outputPath !== resolvedExplicit) {
        fs.mkdirSync(path.dirname(resolvedExplicit), { recursive: true });
        fs.copyFileSync(primary.outputPath, resolvedExplicit);
        recordAssetManifest(
          manifestList,
          resolvedExplicit,
          absoluteHtmlPath,
          primary.viewport.width,
          primary.viewport.height,
          spec.scale
        );
        console.log(`   ${ANSI.cyan}↳ Rendu principal (${primary.viewport.name}) copié vers :${ANSI.reset} ${path.relative(process.cwd(), resolvedExplicit)}`);
      }
    }
  } finally {
    await context.close();
  }
}

function buildUrlSlug(urlStr) {
  const u = new URL(urlStr);
  const hostname = u.hostname.replace(/[^a-zA-Z0-9.-]/g, '_');
  const rawPath = u.pathname.replace(/^\/+|\/+$/g, '');
  const pathname = rawPath ? rawPath.replace(/[^a-zA-Z0-9._-]+/g, '-').replace(/^-+|-+$/g, '') : 'home';
  const querySuffix = u.search
    ? '-' + u.search.slice(1).replace(/[^a-zA-Z0-9_-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 32)
    : '';
  return `${hostname}-${pathname}${querySuffix}`;
}

function resolveUrlOutputPath(urlStr, vpName, opts, totalUrls, totalViewports) {
  const slug = buildUrlSlug(urlStr);
  if (opts.hasExplicitOutput) {
    const out = opts.outputFile;
    const isDirTarget = out.endsWith('/') || out.endsWith(path.sep) || (fs.existsSync(out) && fs.statSync(out).isDirectory());
    if (isDirTarget) {
      return path.resolve(out, `${slug}-${vpName}.png`);
    }
    if (totalUrls === 1) {
      return totalViewports === 1 ? path.resolve(out) : deriveViewportOutputPath(out, vpName);
    }
    const resolved = path.resolve(out);
    const ext = path.extname(resolved) || '.png';
    const stem = path.extname(resolved) ? resolved.slice(0, -ext.length) : resolved;
    return `${stem}-${slug}-${vpName}${ext}`;
  }
  const baseDir = opts.targetDir || 'design/references';
  return path.resolve(baseDir, `${slug}-${vpName}.png`);
}

/**
 * Capture une URL web distante en live via Playwright (domcontentloaded + networkidle 5s max + fonts.ready).
 */
async function captureLiveUrl(browser, targetUrl, opts, activeViewports, totalUrls, manifestList, auditResults) {
  const scale = opts.cliScale || 1;
  console.log(`\n${ANSI.bold}${ANSI.cyan}🌐 [export_png] Capture Live URL : ${targetUrl}${ANSI.reset}`);

  const context = await browser.newContext({
    viewport: { width: activeViewports[0].width, height: activeViewports[0].height },
    deviceScaleFactor: scale,
    ignoreHTTPSErrors: true
  });
  const page = await context.newPage();

  try {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
    try {
      await page.waitForLoadState('networkidle', { timeout: 5000 });
    } catch {
      // Ne pas timeout sur les sites maintenant des flux analytics/SSE continus
    }
    try {
      await page.evaluate(async () => {
        if (document.fonts && document.fonts.ready) {
          await Promise.race([
            document.fonts.ready,
            new Promise(r => setTimeout(r, 3000))
          ]);
        }
      });
    } catch {
      // Ignore si document.fonts.ready indisponible
    }

    const renderedItems = await captureViewportSet(
      page,
      activeViewports,
      opts,
      (vp) => resolveUrlOutputPath(targetUrl, vp.name, opts, totalUrls, activeViewports.length),
      targetUrl,
      scale,
      manifestList,
      auditResults
    );

    if (opts.hasExplicitOutput && totalUrls === 1 && activeViewports.length > 1 && renderedItems.length > 0) {
      const out = opts.outputFile;
      const isDirTarget = out.endsWith('/') || out.endsWith(path.sep) || (fs.existsSync(out) && fs.statSync(out).isDirectory());
      if (!isDirTarget) {
        const resolvedExplicit = path.resolve(out);
        const primary = renderedItems.find(r => r.viewport.name === 'desktop') || renderedItems[renderedItems.length - 1];
        if (primary.outputPath !== resolvedExplicit) {
          fs.mkdirSync(path.dirname(resolvedExplicit), { recursive: true });
          fs.copyFileSync(primary.outputPath, resolvedExplicit);
          recordAssetManifest(
            manifestList,
            resolvedExplicit,
            targetUrl,
            primary.viewport.width,
            primary.viewport.height,
            scale
          );
          console.log(`   ${ANSI.cyan}↳ Rendu principal (${primary.viewport.name}) copié vers :${ANSI.reset} ${path.relative(process.cwd(), resolvedExplicit)}`);
        }
      }
    }
  } finally {
    await context.close();
  }
}

function writeDomReportIfRequested(reportPath, auditResults, strictDom) {
  const summary = {
    filesAudited: new Set(auditResults.map(r => r.source)).size,
    viewportsAudited: auditResults.length,
    totalHorizontalOverflow: auditResults.filter(r => r.domAudit.horizontalOverflow.detected).length,
    totalSmallTouchTargets: auditResults.reduce((sum, r) => sum + r.domAudit.smallTouchTargets.count, 0),
    totalBoxCollisions: auditResults.reduce((sum, r) => sum + r.domAudit.boxCollisions.count, 0),
    totalMissingTabularNums: auditResults.reduce((sum, r) => sum + r.domAudit.missingTabularNums.count, 0)
  };

  const blockingFailures = summary.totalHorizontalOverflow;
  const payload = {
    tool: 'san_designer/export_png.mjs',
    version: '2.2.0',
    generatedAt: new Date().toISOString(),
    strictDom,
    passed: blockingFailures === 0,
    blockingFailures,
    summary,
    results: auditResults
  };

  if (reportPath) {
    const resolvedReport = path.resolve(reportPath);
    fs.mkdirSync(path.dirname(resolvedReport), { recursive: true });
    fs.writeFileSync(resolvedReport, JSON.stringify(payload, null, 2), 'utf-8');
    console.log(`\n${ANSI.bold}${ANSI.cyan}📐 Rapport d'audit DOM écrit :${ANSI.reset} ${path.relative(process.cwd(), resolvedReport)}`);
  }

  return payload;
}

function updateIntegrityManifest(manifestPath, manifestList) {
  if (manifestList.length === 0) return;

  const resolvedManifest = path.resolve(manifestPath);
  fs.mkdirSync(path.dirname(resolvedManifest), { recursive: true });

  let existing = { assets: [] };
  if (fs.existsSync(resolvedManifest)) {
    try {
      existing = JSON.parse(fs.readFileSync(resolvedManifest, 'utf-8'));
    } catch {
      existing = { assets: [] };
    }
  }

  const combined = [...(existing.assets || [])];
  for (const item of manifestList) {
    const idx = combined.findIndex(a => a.file === item.file);
    if (idx >= 0) combined[idx] = item;
    else combined.push(item);
  }

  const payload = {
    updated_at: new Date().toISOString(),
    engine: 'san_designer/san_exporter Playwright Headless v2.2',
    total_assets: combined.length,
    assets: combined
  };

  fs.writeFileSync(resolvedManifest, JSON.stringify(payload, null, 2), 'utf-8');
  console.log(`${ANSI.bold}${ANSI.green}📋 Registre d'intégrité mis à jour :${ANSI.reset} ${path.relative(process.cwd(), resolvedManifest)}`);
}

async function main() {
  const opts = parseCliArgs(process.argv.slice(2));
  if (opts.help) {
    printHelp();
    process.exit(0);
  }

  if (!opts.inputFile && !opts.targetDir && opts.urls.length === 0) {
    console.error(`${ANSI.red}❌ Vous devez spécifier --input <fichier.html>, --url <https://...> ou --dir / --target <dossier>.${ANSI.reset}`);
    printHelp();
    process.exit(1);
  }

  const viewports = resolveViewports(opts);
  console.log(`${ANSI.cyan}${ANSI.bold}=== ANTIGRAVITY STUDIO UI : PIPELINE PLAYWRIGHT EXPORT PNG v2.2 ===${ANSI.reset}`);

  let chromium;
  try {
    const playwrightModule = await loadPlaywright();
    chromium = playwrightModule.chromium;
  } catch {
    console.error(`\n${ANSI.bold}${ANSI.red}[export_png] Le module d'automatisation "playwright" n'est pas installé.${ANSI.reset}`);
    console.error(`${ANSI.yellow}Pour activer les captures PNG et l'audit géométrique DOM, exécutez :${ANSI.reset}`);
    console.error(`  pnpm add -D playwright && npx playwright install chromium`);
    process.exit(1);
  }

  let browser;
  try {
    browser = await launchChromiumBrowser(chromium);
  } catch (launchErr) {
    console.error(`\n${ANSI.bold}${ANSI.red}❌ Impossible d'initialiser Chromium headless :${ANSI.reset} ${launchErr.message}`);
    console.error(`${ANSI.yellow}Exécutez : npx playwright install chromium${ANSI.reset}`);
    process.exit(1);
  }

  const hasHtmlMode = Boolean(opts.inputFile || (opts.targetDir && opts.urls.length === 0));
  let serveRootDir = null;
  if (hasHtmlMode) {
    const targetPath = opts.inputFile ? path.resolve(opts.inputFile) : path.resolve(opts.targetDir);
    if (!fs.existsSync(targetPath)) {
      await browser.close();
      throw new Error(`Chemin cible introuvable : ${targetPath}`);
    }
    serveRootDir = fs.statSync(targetPath).isDirectory() ? targetPath : path.dirname(targetPath);
  }

  let ephemeralServer = null;
  const manifestList = [];
  const auditResults = [];
  let blockingDomFailures = 0;

  try {
    if (opts.urls.length > 0) {
      for (const targetUrl of opts.urls) {
        await captureLiveUrl(
          browser,
          targetUrl,
          opts,
          viewports,
          opts.urls.length,
          manifestList,
          auditResults
        );
      }
    }

    if (hasHtmlMode) {
      ephemeralServer = await createEphemeralServer(serveRootDir);
      console.log(`${ANSI.gray}📡 Micro-serveur éphémère actif sur ${ephemeralServer.baseUrl} (anti-CORS)${ANSI.reset}`);

      if (opts.inputFile) {
        const defaultOut = opts.inputFile.replace(/\.html$/i, '.png');
        const baseOut = opts.outputFile || (defaultOut === opts.inputFile ? `${opts.inputFile}.png` : defaultOut);
        await captureHtmlFile(
          browser,
          opts.inputFile,
          baseOut,
          opts,
          viewports,
          ephemeralServer.baseUrl,
          serveRootDir,
          manifestList,
          auditResults
        );
      } else if (opts.targetDir) {
        const resolvedDir = path.resolve(opts.targetDir);
        const files = fs.readdirSync(resolvedDir).filter(f => f.toLowerCase().endsWith('.html')).sort();
        if (files.length === 0) {
          console.warn(`${ANSI.yellow}⚠️ Aucun fichier .html trouvé dans ${resolvedDir}${ANSI.reset}`);
        }
        for (const f of files) {
          const fullHtml = path.join(resolvedDir, f);
          const baseOut = path.join(resolvedDir, f.replace(/\.html$/i, '.png'));
          await captureHtmlFile(
            browser,
            fullHtml,
            baseOut,
            opts,
            viewports,
            ephemeralServer.baseUrl,
            serveRootDir,
            manifestList,
            auditResults
          );
        }
      }
    }

    if (!opts.noManifest) {
      updateIntegrityManifest(opts.manifestPath, manifestList);
    }

    if (opts.auditDom && (opts.reportPath || opts.strictDom || auditResults.length > 0)) {
      const report = writeDomReportIfRequested(opts.reportPath, auditResults, opts.strictDom);
      blockingDomFailures = report.blockingFailures;
    }
  } finally {
    if (ephemeralServer) {
      await ephemeralServer.close();
      console.log(`${ANSI.gray}🛑 Micro-serveur éphémère fermé proprement.${ANSI.reset}`);
    }
    await browser.close();
  }

  if (opts.strictDom && blockingDomFailures > 0) {
    console.error(`\n${ANSI.bold}${ANSI.red}✖ ÉCHEC --strict-dom : ${blockingDomFailures} dépassement(s) horizontal(aux) détecté(s).${ANSI.reset}`);
    process.exit(2);
  }

  console.log(`\n${ANSI.bold}${ANSI.green}✨ [SUCCÈS] Exportation et contrôle DOM terminés.${ANSI.reset}`);
}

main().catch(err => {
  console.error(`\n${ANSI.bold}${ANSI.red}❌ Erreur critique :${ANSI.reset}`, err.message);
  process.exit(1);
});
