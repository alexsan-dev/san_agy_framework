#!/usr/bin/env node

/**
 * san_cartographer — repo_mapper.mjs
 * Moteur Hybride d'Indexation Déterministe & Générateur de Cache REPO_MAP.md
 * 
 * 100% natif Node.js ESM (Node >= 18). Zéro dépendance externe.
 * Performance : < 80ms en crawl complet, < 25ms en mode incrémental --update-file.
 */

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

// --- CONFIGURATION & FILTRES ---

const IGNORED_DIRS = new Set([
  '.git',
  'node_modules',
  'vendor',
  '.next',
  'dist',
  'build',
  'out',
  'coverage',
  '.agents',
  '.claude',
  '.cursor',
  '.opencode',
  '.idea',
  '.vscode',
  '.turbo',
  '.cache',
  '__pycache__',
  '.pytest_cache',
  '.venv',
  'venv',
  'env'
]);

const IGNORED_EXTENSIONS = new Set([
  '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.webp', '.bmp', '.tiff',
  '.pdf', '.zip', '.tar', '.gz', '.tgz', '.7z', '.rar', '.exe', '.bin', '.dll',
  '.so', '.dylib', '.woff', '.woff2', '.ttf', '.eot', '.otf', '.mp3', '.mp4',
  '.mov', '.avi', '.webm', '.wav', '.flac', '.ogg', '.m4a', '.map'
]);

const IGNORED_FILENAMES = new Set([
  'package-lock.json',
  'yarn.lock',
  'pnpm-lock.yaml',
  'composer.lock',
  'Cargo.lock',
  'go.sum',
  'Pipfile.lock',
  'poetry.lock',
  'bun.lockb',
  '.DS_Store',
  'Thumbs.db'
]);

const ENTRY_POINT_PATTERNS = [
  /^src\/(?:index|main|app)\.(?:ts|js|tsx|jsx)$/,
  /^(?:index|main|app|server)\.(?:ts|js|mjs|cjs)$/,
  /^main\.(?:py|go)$/,
  /^artisan$/,
  /^public\/index\.php$/,
  /^(?:src\/)?App\.(?:tsx|jsx|vue|svelte)$/,
  /^app\/(?:layout|page|route)\.(?:tsx|jsx|ts|js)$/,
  /^routes\/(?:api|web)\.php$/
];

// --- OUTILS DE PARSING & LOCALISATION DE LIGNES ---

/**
 * Trouve la fin d'un bloc délimité par accolades { ... }
 */
function findBlockEnd(lines, startLineIdx) {
  let openBraces = 0;
  let foundFirstBrace = false;
  let inBlockComment = false;

  for (let i = startLineIdx; i < lines.length; i++) {
    const rawLine = lines[i];
    let sanitized = '';
    let inString = null;

    for (let c = 0; c < rawLine.length; c++) {
      const char = rawLine[c];
      const nextChar = rawLine[c + 1];

      if (inBlockComment) {
        if (char === '*' && nextChar === '/') {
          inBlockComment = false;
          c++;
        }
        continue;
      }

      if (inString) {
        if (char === '\\') {
          c++;
        } else if (char === inString) {
          inString = null;
        }
        continue;
      }

      if (char === '/' && nextChar === '/') {
        break;
      }
      if (char === '/' && nextChar === '*') {
        inBlockComment = true;
        c++;
        continue;
      }

      if (char === '"' || char === "'" || char === '`') {
        inString = char;
        continue;
      }

      sanitized += char;
    }

    for (let c = 0; c < sanitized.length; c++) {
      if (sanitized[c] === '{') {
        openBraces++;
        foundFirstBrace = true;
      } else if (sanitized[c] === '}') {
        openBraces--;
        if (foundFirstBrace && openBraces <= 0) {
          return i + 1;
        }
      }
    }

    if (!foundFirstBrace && i - startLineIdx > 12) {
      for (let j = startLineIdx; j <= i; j++) {
        if (lines[j].includes(';')) return j + 1;
      }
      return startLineIdx + 1;
    }

    if (!foundFirstBrace && rawLine.includes(';')) {
      return i + 1;
    }
  }

  return startLineIdx + 1;
}

/**
 * Trouve la fin d'un bloc Python basé sur l'indentation
 */
function findPythonBlockEnd(lines, defLineIdx) {
  const defLine = lines[defLineIdx];
  const matchIndent = defLine.match(/^(\s*)/);
  const baseIndent = matchIndent ? matchIndent[1].length : 0;

  let lastContentLine = defLineIdx;
  let inDocstring = null;

  for (let i = defLineIdx + 1; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    if (inDocstring) {
      lastContentLine = i;
      if (trimmed.includes(inDocstring)) {
        inDocstring = null;
      }
      continue;
    }

    if (!trimmed) {
      continue;
    }

    if (trimmed.startsWith('#')) {
      lastContentLine = i;
      continue;
    }

    if (trimmed.startsWith('"""') || trimmed.startsWith("'''")) {
      const marker = trimmed.slice(0, 3);
      if (trimmed.length > 3 && trimmed.slice(3).includes(marker)) {
        lastContentLine = i;
        continue;
      } else {
        inDocstring = marker;
        lastContentLine = i;
        continue;
      }
    }

    const currentIndent = line.match(/^(\s*)/)[1].length;
    if (currentIndent <= baseIndent) {
      return lastContentLine + 1;
    }

    lastContentLine = i;
  }

  return lastContentLine + 1;
}

/**
 * Trouve la fin d'un bloc SQL
 */
function findSqlBlockEnd(lines, startLineIdx) {
  for (let i = startLineIdx; i < lines.length; i++) {
    if (lines[i].includes(';')) {
      return i + 1;
    }
  }
  return startLineIdx + 1;
}

// --- EXTRACTEURS PAR LANGAGE ---

function extractJsTs(lines) {
  const symbols = [];
  const imports = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // Import local ou distant
    const importMatch = trimmed.match(/^import\s+(?:(?:[\w*\s{},]+)\s+from\s+)?['"]([^'"]+)['"]/);
    if (importMatch) {
      imports.push(importMatch[1]);
      continue;
    }
    const reqMatch = trimmed.match(/(?:const|let|var)\s+(?:[\w*\s{},]+)\s*=\s*require\(['"]([^'"]+)['"]\)/);
    if (reqMatch) {
      imports.push(reqMatch[1]);
      continue;
    }

    // Routes Express / Fastify / Hono
    const routeMatch = trimmed.match(/(?:app|router|server|fastify|route)\.(get|post|put|delete|patch|options|head|all)\(\s*['"]([^'"]+)['"]/i);
    if (routeMatch) {
      const method = routeMatch[1].toUpperCase();
      const routePath = routeMatch[2];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name: `${method} ${routePath}`,
        type: 'route',
        start: i + 1,
        end: endLine,
        signature: `${method} ${routePath}`
      });
      continue;
    }

    // Routes Next.js App Router (export async function GET / POST ...)
    const nextRouteMatch = trimmed.match(/^export\s+(?:async\s+)?function\s+(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)\b/);
    if (nextRouteMatch) {
      const method = nextRouteMatch[1];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name: `ROUTE ${method}`,
        type: 'route',
        start: i + 1,
        end: endLine,
        signature: `export async function ${method}(request)`
      });
      continue;
    }

    // Fonctions exportées
    const funcMatch = trimmed.match(/^export\s+(?:default\s+)?(?:async\s+)?function\s*([a-zA-Z0-9_$]*)\s*\(([^)]*)\)/);
    if (funcMatch) {
      const name = funcMatch[1] || 'default';
      const args = funcMatch[2] ? funcMatch[2].replace(/\s+/g, ' ').slice(0, 35) : '';
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: 'function',
        start: i + 1,
        end: endLine,
        signature: `export function ${name}(${args})`
      });
      continue;
    }

    // Classes exportées
    const classMatch = trimmed.match(/^export\s+(?:default\s+)?class\s+([a-zA-Z0-9_$]+)(?:\s+extends\s+([a-zA-Z0-9_$]+))?/);
    if (classMatch) {
      const name = classMatch[1];
      const ext = classMatch[2] ? ` extends ${classMatch[2]}` : '';
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: 'class',
        start: i + 1,
        end: endLine,
        signature: `export class ${name}${ext}`
      });
      continue;
    }

    // Constantes et composants fléchés exportés
    const constMatch = trimmed.match(/^export\s+(?:const|let)\s+([a-zA-Z0-9_$]+)\s*(?::\s*[^=]+)?\s*=\s*(?:async\s*)?(?:\(([^)]*)\)|([a-zA-Z0-9_$]+))?\s*=>?/);
    if (constMatch) {
      const name = constMatch[1];
      const args = constMatch[2] || constMatch[3] || '';
      const isArrow = trimmed.includes('=>');
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: isArrow ? 'component/function' : 'const',
        start: i + 1,
        end: endLine,
        signature: isArrow ? `export const ${name} = (${args.slice(0, 25)}) => ...` : `export const ${name}`
      });
      continue;
    }

    // Interfaces TypeScript
    const ifaceMatch = trimmed.match(/^(?:export\s+)?interface\s+([a-zA-Z0-9_$]+)/);
    if (ifaceMatch) {
      const name = ifaceMatch[1];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: 'interface',
        start: i + 1,
        end: endLine,
        signature: `interface ${name}`
      });
      continue;
    }

    // Types TypeScript
    const typeMatch = trimmed.match(/^(?:export\s+)?type\s+([a-zA-Z0-9_$]+)\s*=/);
    if (typeMatch) {
      const name = typeMatch[1];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: 'type',
        start: i + 1,
        end: endLine,
        signature: `type ${name}`
      });
      continue;
    }
  }

  return { symbols, imports };
}

function extractPhp(lines) {
  const symbols = [];
  const imports = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    const useMatch = trimmed.match(/^use\s+([^;]+);/);
    if (useMatch) {
      imports.push(useMatch[1].trim());
      continue;
    }

    // Routes Laravel
    const routeMatch = trimmed.match(/Route::(get|post|put|delete|patch|options|any|resource|apiResource)\(\s*['"]([^'"]+)['"]/i);
    if (routeMatch) {
      const method = routeMatch[1].toUpperCase();
      const routePath = routeMatch[2];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name: `Route::${method.toLowerCase()}('${routePath}')`,
        type: 'route',
        start: i + 1,
        end: endLine,
        signature: `Route::${method.toLowerCase()}('${routePath}')`
      });
      continue;
    }

    // Classes, interfaces, traits
    const classMatch = trimmed.match(/^(?:abstract\s+|final\s+)?(class|interface|trait)\s+([a-zA-Z0-9_$]+)(?:\s+extends\s+([a-zA-Z0-9_\\]+))?/);
    if (classMatch) {
      const kind = classMatch[1];
      const name = classMatch[2];
      const ext = classMatch[3] ? ` extends ${classMatch[3]}` : '';
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: kind,
        start: i + 1,
        end: endLine,
        signature: `${kind} ${name}${ext}`
      });
      continue;
    }

    // Fonctions et méthodes
    const funcMatch = trimmed.match(/^(?:(public|protected|private)\s+)?(?:static\s+)?function\s+([a-zA-Z0-9_$]+)\s*\(([^)]*)\)/);
    if (funcMatch) {
      const visibility = funcMatch[1] || 'public';
      const name = funcMatch[2];
      const args = funcMatch[3] ? funcMatch[3].replace(/\s+/g, ' ').slice(0, 30) : '';
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: `${visibility} function`,
        start: i + 1,
        end: endLine,
        signature: `${visibility} function ${name}(${args})`
      });
      continue;
    }
  }

  return { symbols, imports };
}

function extractPython(lines) {
  const symbols = [];
  const imports = [];
  let pendingDecorators = [];
  let decoratorStart = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    const fromImport = trimmed.match(/^from\s+([\w.]+)\s+import/);
    if (fromImport) {
      imports.push(fromImport[1]);
      continue;
    }
    const directImport = trimmed.match(/^import\s+([\w.]+)/);
    if (directImport) {
      imports.push(directImport[1]);
      continue;
    }

    if (trimmed.startsWith('@')) {
      if (decoratorStart === null) decoratorStart = i;
      pendingDecorators.push(trimmed);
      continue;
    }

    // Fonctions / méthodes
    const defMatch = trimmed.match(/^(?:async\s+)?def\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)/);
    if (defMatch) {
      const name = defMatch[1];
      const args = defMatch[2] ? defMatch[2].replace(/\s+/g, ' ').slice(0, 30) : '';
      const startLine = (decoratorStart !== null ? decoratorStart : i) + 1;
      const endLine = findPythonBlockEnd(lines, i);
      const isAsync = trimmed.startsWith('async');

      let signature = `${isAsync ? 'async ' : ''}def ${name}(${args})`;
      let symbolType = 'function';
      if (pendingDecorators.length > 0) {
        const routeDec = pendingDecorators.find(d =>
          d.includes('.route') || d.includes('.get') || d.includes('.post') || d.includes('.put') || d.includes('.delete')
        );
        if (routeDec) {
          symbolType = 'route';
          signature = `${routeDec} -> ${signature}`;
        }
      }

      symbols.push({
        name,
        type: symbolType,
        start: startLine,
        end: endLine,
        signature
      });

      pendingDecorators = [];
      decoratorStart = null;
      continue;
    }

    // Classes
    const classMatch = trimmed.match(/^class\s+([a-zA-Z0-9_]+)(?:\(([^)]*)\))?:/);
    if (classMatch) {
      const name = classMatch[1];
      const parent = classMatch[2] ? `(${classMatch[2]})` : '';
      const startLine = (decoratorStart !== null ? decoratorStart : i) + 1;
      const endLine = findPythonBlockEnd(lines, i);

      symbols.push({
        name,
        type: 'class',
        start: startLine,
        end: endLine,
        signature: `class ${name}${parent}`
      });

      pendingDecorators = [];
      decoratorStart = null;
      continue;
    }

    if (trimmed && !trimmed.startsWith('#')) {
      pendingDecorators = [];
      decoratorStart = null;
    }
  }

  return { symbols, imports };
}

function extractGo(lines) {
  const symbols = [];
  const imports = [];
  let inImportBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    if (trimmed.startsWith('import (')) {
      inImportBlock = true;
      continue;
    }
    if (inImportBlock) {
      if (trimmed === ')') {
        inImportBlock = false;
      } else {
        const m = trimmed.match(/['"]([^'"]+)['"]/);
        if (m) imports.push(m[1]);
      }
      continue;
    }
    const singleImport = trimmed.match(/^import\s+['"]([^'"]+)['"]/);
    if (singleImport) {
      imports.push(singleImport[1]);
      continue;
    }

    // Types struct / interface
    const typeMatch = trimmed.match(/^type\s+([a-zA-Z0-9_]+)\s+(struct|interface)/);
    if (typeMatch) {
      const name = typeMatch[1];
      const kind = typeMatch[2];
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: kind,
        start: i + 1,
        end: endLine,
        signature: `type ${name} ${kind}`
      });
      continue;
    }

    // Fonctions et méthodes avec receiver
    const funcMatch = trimmed.match(/^func\s+(?:\(([^)]+)\)\s+)?([a-zA-Z0-9_]+)\s*\(([^)]*)\)/);
    if (funcMatch) {
      const receiver = funcMatch[1] ? `(${funcMatch[1].trim()}) ` : '';
      const name = funcMatch[2];
      const args = funcMatch[3] ? funcMatch[3].slice(0, 30) : '';
      const endLine = findBlockEnd(lines, i);
      symbols.push({
        name,
        type: receiver ? 'method' : 'function',
        start: i + 1,
        end: endLine,
        signature: `func ${receiver}${name}(${args})`
      });
      continue;
    }
  }

  return { symbols, imports };
}

function extractDbApi(ext, lines) {
  const symbols = [];
  const imports = [];

  if (ext === '.prisma') {
    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      const modelMatch = trimmed.match(/^(model|enum|type)\s+([a-zA-Z0-9_]+)/);
      if (modelMatch) {
        const kind = modelMatch[1];
        const name = modelMatch[2];
        const endLine = findBlockEnd(lines, i);
        symbols.push({
          name,
          type: kind,
          start: i + 1,
          end: endLine,
          signature: `${kind} ${name}`
        });
      }
    }
  } else if (ext === '.sql') {
    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      const tableMatch = trimmed.match(/^CREATE\s+(?:OR\s+REPLACE\s+)?(TABLE|VIEW|PROCEDURE|FUNCTION)\s+(?:IF\s+NOT\s+EXISTS\s+)?([`"']?[a-zA-Z0-9_]+[`"']?)/i);
      if (tableMatch) {
        const kind = tableMatch[1].toUpperCase();
        const name = tableMatch[2].replace(/[`"']/g, '');
        const endLine = findSqlBlockEnd(lines, i);
        symbols.push({
          name,
          type: kind.toLowerCase(),
          start: i + 1,
          end: endLine,
          signature: `CREATE ${kind} ${name}`
        });
      }
    }
  } else if (ext === '.bru') {
    let reqName = '';
    let reqMethod = '';
    let reqUrl = '';
    let blockStart = 1;
    let blockEnd = lines.length;

    for (let i = 0; i < lines.length; i++) {
      const trimmed = lines[i].trim();
      if (trimmed.startsWith('meta {')) {
        for (let j = i + 1; j < lines.length; j++) {
          const l = lines[j].trim();
          if (l.startsWith('name:')) reqName = l.replace(/^name:\s*/, '').trim();
          if (l === '}') break;
        }
      }
      const httpMatch = trimmed.match(/^(get|post|put|delete|patch|options)\s*\{/i);
      if (httpMatch) {
        reqMethod = httpMatch[1].toUpperCase();
        blockStart = i + 1;
        blockEnd = findBlockEnd(lines, i);
        for (let j = i + 1; j < lines.length; j++) {
          const l = lines[j].trim();
          if (l.startsWith('url:')) reqUrl = l.replace(/^url:\s*/, '').trim();
          if (l === '}') break;
        }
      }
    }

    if (reqMethod) {
      symbols.push({
        name: reqName ? `${reqName} (${reqMethod} ${reqUrl})` : `${reqMethod} ${reqUrl}`,
        type: 'http-request',
        start: blockStart,
        end: blockEnd,
        signature: `${reqMethod} ${reqUrl}`
      });
    } else if (reqName) {
      symbols.push({
        name: reqName,
        type: 'bruno-request',
        start: 1,
        end: lines.length,
        signature: reqName
      });
    }
  }

  return { symbols, imports };
}

/**
 * Analyse un fichier et extrait ses symboles, imports, métadonnées
 */
function parseFile(rootDir, relPath) {
  const fullPath = path.join(rootDir, relPath);
  if (!fs.existsSync(fullPath)) return null;

  const stat = fs.statSync(fullPath);
  if (stat.isDirectory()) return null;

  const content = fs.readFileSync(fullPath, 'utf8');
  const hash = crypto.createHash('sha256').update(content).digest('hex').slice(0, 16);
  const lines = content.split('\n');
  const lineCount = lines.length;
  const ext = path.extname(relPath).toLowerCase();

  let language = 'text';
  let symbols = [];
  let imports = [];

  if (['.js', '.mjs', '.cjs', '.ts', '.tsx', '.jsx'].includes(ext)) {
    language = ext.includes('ts') ? 'typescript' : 'javascript';
    const res = extractJsTs(lines);
    symbols = res.symbols;
    imports = res.imports;
  } else if (ext === '.php') {
    language = 'php';
    const res = extractPhp(lines);
    symbols = res.symbols;
    imports = res.imports;
  } else if (ext === '.py') {
    language = 'python';
    const res = extractPython(lines);
    symbols = res.symbols;
    imports = res.imports;
  } else if (ext === '.go') {
    language = 'go';
    const res = extractGo(lines);
    symbols = res.symbols;
    imports = res.imports;
  } else if (['.prisma', '.sql', '.bru'].includes(ext)) {
    language = ext.replace('.', '');
    const res = extractDbApi(ext, lines);
    symbols = res.symbols;
    imports = res.imports;
  } else if (['.json', '.yaml', '.yml', '.md', '.sh'].includes(ext)) {
    language = ext.replace('.', '');
  }

  return {
    hash,
    size: stat.size,
    lineCount,
    language,
    symbols,
    imports
  };
}

// --- EXPLORATION RÉCURSIVE DU DÉPÔT ---

function crawlRepo(rootDir, currentDir = '') {
  const fullCurrentDir = path.join(rootDir, currentDir);
  const entries = fs.readdirSync(fullCurrentDir, { withFileTypes: true });
  let files = [];

  for (const entry of entries) {
    const name = entry.name;
    const relPath = currentDir ? path.join(currentDir, name) : name;

    if (entry.isDirectory()) {
      if (IGNORED_DIRS.has(name) || name.startsWith('.')) {
        continue;
      }
      files = files.concat(crawlRepo(rootDir, relPath));
    } else if (entry.isFile()) {
      if (IGNORED_FILENAMES.has(name) || name.startsWith('.')) {
        continue;
      }
      const ext = path.extname(name).toLowerCase();
      if (IGNORED_EXTENSIONS.has(ext)) {
        continue;
      }
      files.push(relPath);
    }
  }

  return files;
}

// --- GESTION DU CACHE & REPO_MAP ---

function getCachePaths(rootDir) {
  const cacheDir = path.join(rootDir, '.agents', 'cache');
  return {
    cacheDir,
    indexPath: path.join(cacheDir, 'repo-index.json'),
    summariesPath: path.join(cacheDir, 'semantic-summaries.json'),
    mapPath: path.join(cacheDir, 'REPO_MAP.md')
  };
}

function loadIndex(indexPath) {
  if (fs.existsSync(indexPath)) {
    try {
      return JSON.parse(fs.readFileSync(indexPath, 'utf8'));
    } catch {
      // Index corrompu, recréation
    }
  }
  return {
    version: '2.0.0',
    updatedAt: new Date().toISOString(),
    stats: { totalFiles: 0, totalSymbols: 0, languages: {} },
    entryPoints: [],
    files: {}
  };
}

function loadSummaries(summariesPath) {
  if (fs.existsSync(summariesPath)) {
    try {
      return JSON.parse(fs.readFileSync(summariesPath, 'utf8'));
    } catch {
      // Ignorer
    }
  }
  return {
    version: '2.0.0',
    updatedAt: new Date().toISOString(),
    directories: {}
  };
}

function computeStats(index) {
  let totalFiles = 0;
  let totalSymbols = 0;
  const languages = {};
  const entryPoints = [];

  for (const [relPath, fileInfo] of Object.entries(index.files)) {
    totalFiles++;
    totalSymbols += (fileInfo.symbols || []).length;
    const lang = fileInfo.language || 'other';
    languages[lang] = (languages[lang] || 0) + 1;

    // Détection points d'entrée
    for (const pattern of ENTRY_POINT_PATTERNS) {
      if (pattern.test(relPath)) {
        entryPoints.push(relPath);
        break;
      }
    }
  }

  return {
    totalFiles,
    totalSymbols,
    languages,
    entryPoints: [...new Set(entryPoints)].sort()
  };
}

function generateRadar(index, summaries) {
  const stats = index.stats || {};
  const langs = Object.entries(stats.languages || {})
    .sort((a, b) => b[1] - a[1])
    .map(([lang, count]) => `${lang} (${Math.round((count / (stats.totalFiles || 1)) * 100)}%)`)
    .slice(0, 4)
    .join(', ') || 'N/A';

  const entryList = (index.entryPoints && index.entryPoints.length > 0)
    ? index.entryPoints.map(ep => `\`${ep}\``).join(', ')
    : '`src/index.ts`';

  // Identifier tous les dossiers distincts
  const dirs = new Set();
  for (const relPath of Object.keys(index.files)) {
    const dir = path.dirname(relPath);
    if (dir && dir !== '.') {
      dirs.add(dir);
    }
  }

  const sortedDirs = Array.from(dirs).sort();
  const domainLines = [];
  const unsummarized = [];

  for (const dir of sortedDirs) {
    const summary = summaries.directories && summaries.directories[dir];
    if (summary) {
      domainLines.push(`  - \`${dir}\`: ${summary}`);
    } else {
      unsummarized.push(dir);
      if (domainLines.length < 8) {
        domainLines.push(`  - \`${dir}\`: ⚠️ _[Non résumé — hydrater via san_researcher]_`);
      }
    }
  }

  const radar = [
    `# 🧭 REPO RADAR (v2.0)`,
    `- **Fichiers**: ${stats.totalFiles || 0} | **Symboles**: ${stats.totalSymbols || 0} | **Horodatage**: ${index.updatedAt || new Date().toISOString()}`,
    `- **Langages**: ${langs}`,
    `- **Points d'Entrée**: ${entryList}`,
    `- **Domaines Métier**:`,
    ...(domainLines.length > 0 ? domainLines : ['  - _Aucun dossier distinct_']),
    `- **Accès Rapide**: \`.agents/cache/REPO_MAP.md\` (Cartographie détaillée)`
  ].join('\n');

  return { radar, unsummarized };
}

function generateRepoMap(index, summaries, radarText) {
  // Regrouper par dossier
  const groups = {};
  for (const [relPath, info] of Object.entries(index.files)) {
    const dir = path.dirname(relPath);
    const key = (dir === '.' || !dir) ? 'Racine' : dir;
    if (!groups[key]) groups[key] = [];
    groups[key].push({ relPath, ...info });
  }

  const sections = [];
  sections.push(radarText);
  sections.push('');
  sections.push('---');
  sections.push('');
  sections.push('# 🗺️ CARTOGRAPHIE DÉTAILLÉE DU RÉPERTOIRE');
  sections.push('');

  const sortedGroups = Object.keys(groups).sort();

  for (const group of sortedGroups) {
    const dirSummary = (summaries.directories && summaries.directories[group])
      ? summaries.directories[group]
      : '_[Résumé métier en attente — hydrater via san-researcher]_';

    sections.push(`## 📁 \`${group}\``);
    sections.push(`> **Résumé Métier :** ${dirSummary}`);
    sections.push('');

    // Trier les fichiers
    const files = groups[group].sort((a, b) => a.relPath.localeCompare(b.relPath));

    for (const f of files) {
      sections.push(`### \`${f.relPath}\` (${f.lineCount} lignes)`);
      if (f.imports && f.imports.length > 0) {
        const displayImports = f.imports.slice(0, 8).map(i => `\`${i}\``).join(', ');
        const extra = f.imports.length > 8 ? ` (+${f.imports.length - 8} autres)` : '';
        sections.push(`- **Imports :** ${displayImports}${extra}`);
      }
      if (f.symbols && f.symbols.length > 0) {
        sections.push(`- **Symboles :**`);
        for (const s of f.symbols) {
          const loc = `[#L${s.start}-L${s.end}](${f.relPath}#L${s.start}-L${s.end})`;
          sections.push(`  - \`${s.signature || s.name}\` ${loc}`);
        }
      } else {
        sections.push(`  - _(Aucun symbole public exporté détecté)_`);
      }
      sections.push('');
    }
  }

  return sections.join('\n');
}

// --- TRAITEMENTS PRINCIPAUX ---

function runFullScan(rootDir) {
  const { cacheDir, indexPath, summariesPath, mapPath } = getCachePaths(rootDir);
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const existingIndex = loadIndex(indexPath);
  const summaries = loadSummaries(summariesPath);
  const filesList = crawlRepo(rootDir);

  const newFiles = {};

  for (const relPath of filesList) {
    const fullPath = path.join(rootDir, relPath);
    const stat = fs.statSync(fullPath);
    const existing = existingIndex.files[relPath];

    // Vérification rapide de taille
    if (existing && existing.size === stat.size) {
      // Optionnel : vérification de hash si modification suspecte
      const currentHash = crypto.createHash('sha256').update(fs.readFileSync(fullPath)).digest('hex').slice(0, 16);
      if (existing.hash === currentHash) {
        newFiles[relPath] = existing;
        continue;
      }
    }

    const parsed = parseFile(rootDir, relPath);
    if (parsed) {
      newFiles[relPath] = parsed;
    }
  }

  const newIndex = {
    version: '2.0.0',
    updatedAt: new Date().toISOString(),
    files: newFiles
  };

  const stats = computeStats(newIndex);
  newIndex.stats = stats;
  newIndex.entryPoints = stats.entryPoints;

  fs.writeFileSync(indexPath, JSON.stringify(newIndex, null, 2), 'utf8');

  const { radar, unsummarized } = generateRadar(newIndex, summaries);
  const mapContent = generateRepoMap(newIndex, summaries, radar);
  fs.writeFileSync(mapPath, mapContent, 'utf8');

  return {
    totalFiles: stats.totalFiles,
    totalSymbols: stats.totalSymbols,
    updatedFiles: Object.keys(newFiles).length,
    unsummarizedDirs: unsummarized,
    mapPath,
    radar
  };
}

function updateSingleFile(rootDir, targetFile) {
  const { cacheDir, indexPath, summariesPath, mapPath } = getCachePaths(rootDir);
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const index = loadIndex(indexPath);
  const summaries = loadSummaries(summariesPath);
  const relPath = path.relative(rootDir, path.resolve(rootDir, targetFile)).replace(/\\/g, '/');

  const fullPath = path.join(rootDir, relPath);

  if (!fs.existsSync(fullPath)) {
    // Fichier supprimé
    if (index.files[relPath]) {
      delete index.files[relPath];
    }
  } else {
    const parsed = parseFile(rootDir, relPath);
    if (parsed) {
      index.files[relPath] = parsed;
    }
  }

  index.updatedAt = new Date().toISOString();
  const stats = computeStats(index);
  index.stats = stats;
  index.entryPoints = stats.entryPoints;

  fs.writeFileSync(indexPath, JSON.stringify(index, null, 2), 'utf8');

  const { radar, unsummarized } = generateRadar(index, summaries);
  const mapContent = generateRepoMap(index, summaries, radar);
  fs.writeFileSync(mapPath, mapContent, 'utf8');

  return {
    totalFiles: stats.totalFiles,
    totalSymbols: stats.totalSymbols,
    updatedFiles: 1,
    unsummarizedDirs: unsummarized,
    mapPath,
    radar
  };
}

function setSummary(rootDir, summarySpec, summariesFilePath = null) {
  const { cacheDir, indexPath, summariesPath, mapPath } = getCachePaths(rootDir);
  if (!fs.existsSync(cacheDir)) {
    fs.mkdirSync(cacheDir, { recursive: true });
  }

  const summaries = loadSummaries(summariesPath);

  if (summariesFilePath) {
    if (fs.existsSync(summariesFilePath)) {
      const incoming = JSON.parse(fs.readFileSync(summariesFilePath, 'utf8'));
      if (incoming.directories) {
        Object.assign(summaries.directories, incoming.directories);
      }
    }
  }

  if (summarySpec) {
    const eqIdx = summarySpec.indexOf('=');
    if (eqIdx > 0) {
      const dir = summarySpec.slice(0, eqIdx).trim();
      const text = summarySpec.slice(eqIdx + 1).trim();
      summaries.directories[dir] = text;
    }
  }

  summaries.updatedAt = new Date().toISOString();
  fs.writeFileSync(summariesPath, JSON.stringify(summaries, null, 2), 'utf8');

  const index = loadIndex(indexPath);
  const { radar, unsummarized } = generateRadar(index, summaries);
  const mapContent = generateRepoMap(index, summaries, radar);
  fs.writeFileSync(mapPath, mapContent, 'utf8');

  return {
    summariesCount: Object.keys(summaries.directories).length,
    unsummarizedDirs: unsummarized,
    mapPath,
    radar
  };
}

function runQuery(rootDir, queryTerm) {
  const { indexPath } = getCachePaths(rootDir);
  const index = loadIndex(indexPath);
  const term = queryTerm.toLowerCase();
  const results = [];

  for (const [relPath, info] of Object.entries(index.files)) {
    const fileMatches = relPath.toLowerCase().includes(term);

    if (info.symbols && info.symbols.length > 0) {
      for (const s of info.symbols) {
        const nameMatches = (s.name || '').toLowerCase().includes(term);
        const sigMatches = (s.signature || '').toLowerCase().includes(term);

        if (nameMatches || sigMatches || fileMatches) {
          results.push({
            file: relPath,
            symbol: s.name,
            type: s.type,
            start: s.start,
            end: s.end,
            signature: s.signature || s.name
          });
        }
      }
    } else if (fileMatches) {
      results.push({
        file: relPath,
        symbol: path.basename(relPath),
        type: info.language,
        start: 1,
        end: info.lineCount,
        signature: `${relPath} (${info.lineCount} lignes)`
      });
    }
  }

  return results;
}

// --- CLI ROUTER ---

function main() {
  const args = process.argv.slice(2);
  let rootDir = process.cwd();
  let updateFile = null;
  let summarySpec = null;
  let summariesFile = null;
  let queryTerm = null;
  let showRadar = false;
  let showJson = false;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--root' && args[i + 1]) {
      rootDir = path.resolve(args[++i]);
    } else if (arg === '--update-file' && args[i + 1]) {
      updateFile = args[++i];
    } else if (arg === '--set-summary' && args[i + 1]) {
      summarySpec = args[++i];
    } else if (arg === '--summaries-file' && args[i + 1]) {
      summariesFile = path.resolve(args[++i]);
    } else if (arg === '--query' && args[i + 1]) {
      queryTerm = args[++i];
    } else if (arg === '--radar') {
      showRadar = true;
    } else if (arg === '--json') {
      showJson = true;
    } else if (arg === '--help' || arg === '-h') {
      console.log(`san_cartographer — repo_mapper.mjs CLI`);
      console.log(`Usage:`);
      console.log(`  node repo_mapper.mjs [--root <dir>] [--json]`);
      console.log(`  node repo_mapper.mjs --radar [--root <dir>]`);
      console.log(`  node repo_mapper.mjs --update-file <path> [--root <dir>]`);
      console.log(`  node repo_mapper.mjs --set-summary "<dir>=<résumé>" [--root <dir>]`);
      console.log(`  node repo_mapper.mjs --query <terme> [--root <dir>]`);
      process.exit(0);
    }
  }

  // 1. Mode Radar seul
  if (showRadar) {
    const { indexPath, summariesPath } = getCachePaths(rootDir);
    let index = loadIndex(indexPath);
    if (!index.files || Object.keys(index.files).length === 0 || !index.stats || typeof index.stats.totalFiles !== 'number') {
      runFullScan(rootDir);
      index = loadIndex(indexPath);
    }
    const summaries = loadSummaries(summariesPath);
    const { radar } = generateRadar(index, summaries);
    console.log(radar);
    return;
  }

  // 2. Mode Recherche / Query
  if (queryTerm) {
    const results = runQuery(rootDir, queryTerm);
    if (showJson) {
      console.log(JSON.stringify(results, null, 2));
    } else {
      if (results.length === 0) {
        console.log(`Aucune correspondance pour "${queryTerm}".`);
      } else {
        console.log(`🔎 ${results.length} correspondance(s) trouvée(s) :`);
        for (const r of results) {
          console.log(`${r.file}#L${r.start}-L${r.end}: [${r.type}] ${r.signature}`);
        }
      }
    }
    return;
  }

  // 3. Mode Mise à jour incrémentale d'un fichier
  if (updateFile) {
    const report = updateSingleFile(rootDir, updateFile);
    if (showJson) {
      console.log(JSON.stringify(report, null, 2));
    } else {
      console.log(`⚡ Fichier incrémenté : ${updateFile}`);
      console.log(`Cache mis à jour -> ${report.mapPath} (${report.totalFiles} fichiers, ${report.totalSymbols} symboles)`);
    }
    return;
  }

  // 4. Mode Résumé sémantique
  if (summarySpec || summariesFile) {
    const report = setSummary(rootDir, summarySpec, summariesFile);
    if (showJson) {
      console.log(JSON.stringify(report, null, 2));
    } else {
      console.log(`✨ Résumé(s) sémantique(s) appliqué(s). Total: ${report.summariesCount} dossier(s).`);
      console.log(`REPO_MAP.md actualisé.`);
    }
    return;
  }

  // 5. Scan complet par défaut
  const report = runFullScan(rootDir);
  if (showJson) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`🧭 Cartographie terminée avec succès !`);
    console.log(`- Fichiers indexés : ${report.totalFiles}`);
    console.log(`- Symboles extraits : ${report.totalSymbols}`);
    console.log(`- Dossiers sans résumé IA : ${report.unsummarizedDirs.length}`);
    console.log(`- Cache généré : ${report.mapPath}\n`);
    console.log(report.radar);
  }
}

main();
