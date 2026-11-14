#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function safelyExit() {
  console.log(JSON.stringify({}));
  process.exit(0);
}

const MAX_INDEX_FILE_BYTES = 512 * 1024;
const MAX_CACHE_JSON_BYTES = 10 * 1024 * 1024;

const IGNORED_DIRS = new Set([
  'node_modules',
  '.git',
  '.agents',
  'dist',
  'vendor',
  'build',
  'out',
  '.next',
  'coverage',
  'google-cloud-sdk',
  'Pods',
  '.expo',
  '.gradle',
  'target',
  'storage',
  'tmp',
  'temp',
  'logs',
  '.dart_tool',
  'bower_components'
]);

function extractSymbols(content, filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (!/\.(?:[cm]?[jt]sx?|php|py|go|rs|rb|java|c|cpp|h|hpp)$/.test(ext)) {
    return [];
  }
  const rawLines = content ? content.split(/\r?\n/) : [];
  const seen = new Set();
  const results = [];
  const symRe = /(?:(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s+([a-zA-Z0-9_$]+)|(?:export\s+)?(?:const|let|var)\s+([a-zA-Z0-9_$]+)\s*=\s*(?:async\s*)?(?:\([^)]*\)|[a-zA-Z0-9_$]+)\s*=>|(?:class|interface|type|struct|enum)\s+([a-zA-Z0-9_$]+)|def\s+([a-zA-Z0-9_]+)|func\s+(?:\([^)]+\)\s*)?([a-zA-Z0-9_]+)|fn\s+([a-zA-Z0-9_]+))/;
  for (let i = 0; i < rawLines.length; i++) {
    const m = rawLines[i].match(symRe);
    if (m) {
      const sym = m[1] || m[2] || m[3] || m[4] || m[5] || m[6];
      if (sym && sym.length > 1 && !seen.has(sym)) {
        seen.add(sym);
        const start = i + 1;
        const end = Math.min(rawLines.length, start + 35);
        results.push({ name: sym, start, end, signature: `${sym} [#L${start}-L${end}]` });
      }
    }
  }
  return results;
}

function renderRepoMap({ workspaceRoot, files, fileCount, symbolCount, semanticSummaries = {} }) {
  const fileKeys = Object.keys(files).sort();
  const dirs = {};
  for (const relPath of fileKeys) {
    const dir = path.dirname(relPath).replace(/\\/g, '/');
    if (!dirs[dir]) dirs[dir] = [];
    dirs[dir].push(relPath);
  }

  const sortedDirs = Object.keys(dirs).sort();
  const unsummarizedDirs = sortedDirs.filter(d => d !== '.' && !semanticSummaries[d]);
  const unsummarizedCount = unsummarizedDirs.length;

  const header = [
    '# REPOSITORY MAP (RADAR)',
    '<!-- san_cartographer (generated) -->',
    '',
    '> **Index AST & Synthèse de Codebase**',
    `> Fichiers indexés : **${fileCount}** | Symboles : **${symbolCount}** | Cache : **${unsummarizedCount > 0 ? `${unsummarizedCount} répertoires non résumés` : 'warm'}**`,
    '',
    '## Répertoires & Résumés Sémantiques',
    ''
  ];

  const sections = [];
  for (const dir of sortedDirs) {
    const dirLabel = dir === '.' ? 'Racine du projet (`/`)' : `\`${dir}/\``;
    const summary = semanticSummaries[dir];
    const summaryText = summary
      ? `> **Résumé sémantique :** ${summary}`
      : `> *(Non résumé — lancer \`san-researcher\` pour hydrater \`.agents/cache/semantic-summaries.json\`)*`;

    const fileList = dirs[dir].map(rel => {
      const f = files[rel];
      const absPath = path.resolve(workspaceRoot, rel).replace(/\\/g, '/');
      const lines = f.lines || f.lineCount || 1;
      const symList = Array.isArray(f.symbols)
        ? f.symbols.slice(0, 8).map(s => typeof s === 'string' ? s : `${s.name} (#L${s.start}-L${s.end})`)
        : [];
      const syms = symList.length > 0
        ? ` — *Symboles :* \`${symList.join('`, `')}${f.symbols.length > 8 ? '…' : ''}\``
        : '';
      return `- [${path.basename(rel)}](file:///${absPath}#L1-L${lines}) (${lines} lignes)${syms}`;
    }).join('\n');

    sections.push(`### ${dirLabel}\n${summaryText}\n\n${fileList}\n`);
  }

  return header.join('\n') + sections.join('\n');
}

try {
  let input = '';
  try {
    input = fs.readFileSync(0, 'utf8');
  } catch {
    input = '';
  }

  let data = {};
  try {
    if (input && input.trim()) {
      data = JSON.parse(input);
    }
  } catch {
    data = {};
  }

  const workspaceRoot = (Array.isArray(data.workspacePaths) && data.workspacePaths.length > 0 && data.workspacePaths[0])
    ? data.workspacePaths[0]
    : process.cwd();

  const toolCall = data.toolCall || {};
  const args = toolCall.args || {};
  const rawPath = (
    args.Path || args.path ||
    args.TargetFile || args.target_file ||
    args.FilePath || args.file_path ||
    args.AbsolutePath || args.absolute_path ||
    args.TargetFilePath || args.target_file_path || ''
  ).toString();

  if (!rawPath) {
    safelyExit();
  }

  // Only proceed if .agents or .agents/cache already exists
  const agentsDir = path.join(workspaceRoot, '.agents');
  const cacheDir = path.join(agentsDir, 'cache');
  if (!fs.existsSync(agentsDir) && !fs.existsSync(cacheDir)) {
    safelyExit();
  }

  let absPath = '';
  let relPath = '';
  if (path.isAbsolute(rawPath)) {
    absPath = path.normalize(rawPath);
    relPath = path.relative(workspaceRoot, absPath).replace(/\\/g, '/');
  } else {
    absPath = path.resolve(workspaceRoot, rawPath);
    relPath = path.normalize(rawPath).replace(/\\/g, '/').replace(/^\.\//, '');
  }

  // Ignore files in ignored directories
  const firstSegment = relPath.split('/')[0];
  if (IGNORED_DIRS.has(firstSegment)) {
    safelyExit();
  }

  fs.mkdirSync(cacheDir, { recursive: true });
  const indexFile = path.join(cacheDir, 'repo-index.json');
  let indexData = { files: {}, stats: { fileCount: 0, symbolCount: 0 } };
  if (fs.existsSync(indexFile)) {
    try {
      if (fs.statSync(indexFile).size <= MAX_CACHE_JSON_BYTES) {
        indexData = JSON.parse(fs.readFileSync(indexFile, 'utf8'));
        if (!indexData.files || typeof indexData.files !== 'object') {
          indexData.files = {};
        }
      }
    } catch {
      indexData = { files: {}, stats: { fileCount: 0, symbolCount: 0 } };
    }
  }

  // Incremental update of this single file
  try {
    if (fs.existsSync(absPath)) {
      const stat = fs.lstatSync(absPath);
      if (!stat.isSymbolicLink() && stat.isFile() && stat.size <= MAX_INDEX_FILE_BYTES) {
        const rawBuf = fs.readFileSync(absPath);
        const sampleLen = Math.min(rawBuf.length, 1024);
        let isBinary = false;
        for (let i = 0; i < sampleLen; i++) {
          if (rawBuf[i] === 0) {
            isBinary = true;
            break;
          }
        }
        if (!isBinary) {
          const content = rawBuf.toString('utf8');
          const lines = content ? content.split(/\r?\n/).length : 0;
          const symbols = extractSymbols(content, relPath);
          indexData.files[relPath] = {
            lines,
            size: stat.size,
            symbols,
            mtimeMs: stat.mtimeMs
          };
        } else {
          delete indexData.files[relPath];
        }
      } else {
        delete indexData.files[relPath];
      }
    } else {
      delete indexData.files[relPath];
    }
  } catch {
    delete indexData.files[relPath];
  }

  // Recalculate stats
  const fileKeys = Object.keys(indexData.files);
  const fileCount = fileKeys.length;
  let symbolCount = 0;
  for (const k of fileKeys) {
    if (Array.isArray(indexData.files[k].symbols)) {
      symbolCount += indexData.files[k].symbols.length;
    }
  }
  indexData.stats = { fileCount, symbolCount };
  indexData.updatedAt = new Date().toISOString();

  fs.writeFileSync(
    indexFile,
    fileCount > 300 ? JSON.stringify(indexData) : JSON.stringify(indexData, null, 2),
    'utf8'
  );

  // Load semantic summaries if present
  let semanticSummaries = {};
  const summariesFile = path.join(cacheDir, 'semantic-summaries.json');
  if (fs.existsSync(summariesFile)) {
    try {
      semanticSummaries = JSON.parse(fs.readFileSync(summariesFile, 'utf8'));
    } catch {}
  }

  // Regenerate REPO_MAP.md
  const repoMapContent = renderRepoMap({
    workspaceRoot,
    files: indexData.files,
    fileCount,
    symbolCount,
    semanticSummaries
  });
  fs.writeFileSync(path.join(cacheDir, 'REPO_MAP.md'), repoMapContent, 'utf8');
} catch {
  // Always fail-safe and never break Antigravity PostToolUse
} finally {
  safelyExit();
}
