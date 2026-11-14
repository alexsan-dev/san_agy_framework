#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

// Read all stdin synchronously
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

// Determine workspace root
const workspaceRoot = (Array.isArray(data.workspacePaths) && data.workspacePaths.length > 0 && data.workspacePaths[0])
  ? data.workspacePaths[0]
  : process.cwd();

// Detect active roadmap in roadmaps/*.md (excluding archives/, ideas/, templates, readme)
let activeRoadmap = null;
try {
  const roadmapsDir = path.join(workspaceRoot, 'roadmaps');
  if (fs.existsSync(roadmapsDir)) {
    const entries = fs.readdirSync(roadmapsDir, { withFileTypes: true });
    const candidates = entries
      .filter(entry => entry.isFile() && entry.name.endsWith('.md') && !/^(?:readme|template|.*_template)\.md$/i.test(entry.name))
      .map(entry => {
        const fullPath = path.join(roadmapsDir, entry.name);
        let mtime = 0;
        try {
          mtime = fs.statSync(fullPath).mtimeMs;
        } catch {
          mtime = 0;
        }
        return { name: entry.name, mtime };
      })
      .sort((a, b) => b.mtime - a.mtime);

    if (candidates.length > 0) {
      activeRoadmap = candidates[0].name;
    }
  }
} catch {
  activeRoadmap = null;
}

// Detect project profile in .agents/rules/PROJECT.md or template
let projectProfile = null;
const candidateProfiles = [
  path.join(workspaceRoot, '.agents', 'rules', 'PROJECT.md'),
  path.join(workspaceRoot, 'src', 'skills', 'san_init', 'templates', 'rules', 'PROJECT_TEMPLATE.md')
];

for (const profileFile of candidateProfiles) {
  try {
    if (fs.existsSync(profileFile)) {
      const content = fs.readFileSync(profileFile, 'utf8');
      const profileMatch = content.match(/PROJECT_PROFILE:\s*["']?([a-zA-Z0-9_-]+)["']?/i);
      if (profileMatch && profileMatch[1] && !profileMatch[1].startsWith('[')) {
        projectProfile = profileMatch[1];
        break;
      }
    }
  } catch {
    // Continue checking other candidates
  }
}

const roadmapDisplay = activeRoadmap || 'none';
const profileDisplay = projectProfile ? ` (Profile: ${projectProfile})` : '';

let message = `[SAN.AGY CONSTITUTION v2.0] Active Harness: 8 native subagents (san-*), mandatory pre-mortem & adversarial QA inquisition, zero solo-coding policy. Roadmap: ${roadmapDisplay}${profileDisplay}.`;

// Detect recent Skeptical Relay Transcript in roadmaps/transcripts/*.md
try {
  const transcriptsDir = path.join(workspaceRoot, 'roadmaps', 'transcripts');
  if (fs.existsSync(transcriptsDir)) {
    const MAX_TRANSCRIPT_AGE_MS = 7 * 24 * 60 * 60 * 1000;
    const nowMs = Date.now();
    const tEntries = fs.readdirSync(transcriptsDir, { withFileTypes: true });
    const recentTranscripts = tEntries
      .filter(
        entry =>
          entry.isFile() &&
          entry.name.endsWith('.md') &&
          !/^(?:readme|.*template.*)\.md$/i.test(entry.name)
      )
      .map(entry => {
        const fullPath = path.join(transcriptsDir, entry.name);
        let mtime = 0;
        try {
          mtime = fs.statSync(fullPath).mtimeMs;
        } catch {
          mtime = 0;
        }
        return { name: entry.name, mtime };
      })
      .filter(item => item.mtime > 0 && nowMs - item.mtime <= MAX_TRANSCRIPT_AGE_MS)
      .sort((a, b) => b.mtime - a.mtime);

    if (recentTranscripts.length > 0) {
      message += `\nActive Relay Transcript: roadmaps/transcripts/${recentTranscripts[0].name} (APPLY SKEPTICAL RELAY PROTOCOL: verify git diff & tests before trusting prior agent).`;
    }
  }
} catch {
  // Fail-safe: ignore transcript lookup errors without breaking session_start
}

// Cartographer radar: only run if .agents directory already exists
const agentsDir = path.join(workspaceRoot, '.agents');
if (fs.existsSync(agentsDir)) {
  try {
    const MAX_INDEX_FILE_BYTES = 256 * 1024;
    const MAX_INDEXED_FILES = 4000;
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

    const IGNORED_EXTENSIONS = new Set([
      '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.webp', '.bmp', '.tiff',
      '.pdf', '.zip', '.tar', '.gz', '.tgz', '.7z', '.rar', '.bz2', '.xz',
      '.exe', '.bin', '.dll', '.so', '.dylib', '.wasm', '.apk', '.aab', '.ipa', '.dmg', '.iso',
      '.woff', '.woff2', '.ttf', '.eot', '.otf', '.mp3', '.mp4',
      '.mov', '.avi', '.webm', '.wav', '.flac', '.ogg', '.m4a', '.map',
      '.lock', '.db', '.sqlite', '.sqlite3', '.pyc', '.pyo', '.class', '.jar', '.war', '.log'
    ]);

    const isBinaryBuffer = (buf) => {
      if (!buf || buf.length === 0) return false;
      const limit = Math.min(buf.length, 1024);
      for (let i = 0; i < limit; i++) {
        if (buf[i] === 0) return true;
      }
      return false;
    };

    const isExcludedRelPath = (relPath) => {
      const normalized = relPath.replace(/\\/g, '/').replace(/^\.\//, '');
      if (!normalized) return true;
      const parts = normalized.split('/');
      for (let i = 0; i < parts.length - 1; i++) {
        const seg = parts[i];
        if (!seg || IGNORED_DIRS.has(seg) || seg.startsWith('.')) return true;
      }
      const base = parts[parts.length - 1];
      if (!base) return true;
      const ext = path.extname(base).toLowerCase();
      return IGNORED_EXTENSIONS.has(ext);
    };

    const hasGitRepo = (dir) => {
      let cur = path.resolve(dir);
      while (true) {
        if (fs.existsSync(path.join(cur, '.git'))) return true;
        const parent = path.dirname(cur);
        if (parent === cur) return false;
        cur = parent;
      }
    };

    const cacheDir = path.join(agentsDir, 'cache');
    fs.mkdirSync(cacheDir, { recursive: true });

    const indexFile = path.join(cacheDir, 'repo-index.json');
    let cachedFiles = {};
    if (fs.existsSync(indexFile)) {
      try {
        if (fs.statSync(indexFile).size <= MAX_CACHE_JSON_BYTES) {
          const parsed = JSON.parse(fs.readFileSync(indexFile, 'utf8'));
          if (parsed && typeof parsed.files === 'object') {
            cachedFiles = parsed.files;
          }
        }
      } catch {}
    }

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

    const currentFiles = {};
    let indexedCount = 0;

    const indexSingleFile = (fullPath, relPath) => {
      if (indexedCount >= MAX_INDEXED_FILES) return;
      if (isExcludedRelPath(relPath)) return;
      try {
        const stat = fs.lstatSync(fullPath);
        if (stat.isSymbolicLink() || !stat.isFile() || stat.size > MAX_INDEX_FILE_BYTES) return;
        const cached = cachedFiles[relPath];
        if (cached && cached.mtimeMs === stat.mtimeMs && (cached.size === undefined || cached.size === stat.size)) {
          currentFiles[relPath] = cached;
          indexedCount++;
          return;
        }
        const rawBuf = fs.readFileSync(fullPath);
        if (isBinaryBuffer(rawBuf)) return;
        const content = rawBuf.toString('utf8');
        const lines = content ? content.split(/\r?\n/).length : 0;
        const symbols = extractSymbols(content, relPath);
        currentFiles[relPath] = {
          lines,
          lineCount: lines,
          size: stat.size,
          symbols,
          mtimeMs: stat.mtimeMs
        };
        indexedCount++;
      } catch {}
    };

    let usedGitList = false;
    if (hasGitRepo(workspaceRoot)) {
      try {
        const raw = execFileSync(
          'git',
          ['-c', 'safe.directory=*', 'ls-files', '-z', '-co', '--exclude-standard'],
          {
            cwd: workspaceRoot,
            encoding: 'buffer',
            maxBuffer: 32 * 1024 * 1024,
            stdio: ['ignore', 'pipe', 'ignore'],
            timeout: 4000
          }
        );
        usedGitList = true;
        for (const relPath of raw.toString('utf8').split('\0')) {
          if (!relPath) continue;
          if (indexedCount >= MAX_INDEXED_FILES) break;
          indexSingleFile(path.join(workspaceRoot, relPath), relPath);
        }
      } catch {
        usedGitList = false;
      }
    }

    function walk(dir) {
      if (indexedCount >= MAX_INDEXED_FILES) return;
      let entries = [];
      try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
      } catch {
        return;
      }
      for (const entry of entries) {
        if (indexedCount >= MAX_INDEXED_FILES) break;
        if (entry.isSymbolicLink()) continue;
        if (IGNORED_DIRS.has(entry.name)) continue;
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          if (entry.name.startsWith('.')) continue;
          walk(fullPath);
        } else if (entry.isFile()) {
          const relPath = path.relative(workspaceRoot, fullPath).replace(/\\/g, '/');
          indexSingleFile(fullPath, relPath);
        }
      }
    }

    if (!usedGitList) {
      walk(workspaceRoot);
    }

    const fileKeys = Object.keys(currentFiles);
    const fileCount = fileKeys.length;
    let symbolCount = 0;
    for (const k of fileKeys) {
      if (Array.isArray(currentFiles[k].symbols)) {
        symbolCount += currentFiles[k].symbols.length;
      }
    }

    // Load semantic summaries if present
    let semanticSummaries = {};
    const summariesFile = path.join(cacheDir, 'semantic-summaries.json');
    if (fs.existsSync(summariesFile)) {
      try {
        const rawSum = JSON.parse(fs.readFileSync(summariesFile, 'utf8'));
        semanticSummaries = rawSum.directories || rawSum || {};
      } catch {}
    }

    // Collect unique directories containing indexed files
    const dirsSet = new Set();
    for (const relPath of fileKeys) {
      const d = path.dirname(relPath).replace(/\\/g, '/');
      if (d !== '.' && d !== '') {
        dirsSet.add(d);
      }
    }

    const unsummarizedDirs = Array.from(dirsSet).filter(d => !semanticSummaries[d]);
    const unsummarizedCount = unsummarizedDirs.length;

    // Save updated index
    const indexData = {
      files: currentFiles,
      stats: { fileCount, symbolCount, totalFiles: fileCount, totalSymbols: symbolCount },
      updatedAt: new Date().toISOString()
    };
    fs.writeFileSync(
      indexFile,
      fileCount > 300 ? JSON.stringify(indexData) : JSON.stringify(indexData, null, 2),
      'utf8'
    );

    // Generate REPO_MAP.md
    const sortedDirs = Object.keys(
      fileKeys.reduce((acc, rel) => {
        const d = path.dirname(rel).replace(/\\/g, '/');
        if (!acc[d]) acc[d] = [];
        acc[d].push(rel);
        return acc;
      }, {})
    ).sort();

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
    const dirMap = fileKeys.reduce((acc, rel) => {
      const d = path.dirname(rel).replace(/\\/g, '/');
      if (!acc[d]) acc[d] = [];
      acc[d].push(rel);
      return acc;
    }, {});

    for (const dir of sortedDirs) {
      const dirLabel = dir === '.' ? 'Racine du projet (`/`)' : `\`${dir}/\``;
      const summary = semanticSummaries[dir];
      const summaryText = summary
        ? `> **Résumé sémantique :** ${summary}`
        : `> *(Non résumé — lancer \`san-researcher\` pour hydrater \`.agents/cache/semantic-summaries.json\`)*`;

      const fileList = (dirMap[dir] || []).map(rel => {
        const f = currentFiles[rel];
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

    fs.writeFileSync(path.join(cacheDir, 'REPO_MAP.md'), header.join('\n') + sections.join('\n'), 'utf8');

    // Append compact radar block (< 600 octets)
    const radarBlock = `\n[REPO RADAR] Map: .agents/cache/REPO_MAP.md (${fileCount} files, ${symbolCount} symbols${unsummarizedCount > 0 ? `, ${unsummarizedCount} unsummarized dirs -> run san-researcher to hydrate .agents/cache/semantic-summaries.json` : ', cache warm'}). Rule: Map-First -> consult REPO_MAP.md and use read_file(StartLine, EndLine).`;
    message += radarBlock;
  } catch {
    // Fail-safe: maintain base message without breaking session_start
  }

  // One-shot What's New notification post-update (.agents/cache/whats_new_pending.json)
  try {
    const whatsNewFile = path.join(agentsDir, 'cache', 'whats_new_pending.json');
    if (fs.existsSync(whatsNewFile)) {
      const pending = JSON.parse(fs.readFileSync(whatsNewFile, 'utf8'));
      if (pending && pending.seen === false) {
        const ver = pending.version || '2.1.0';
        const highlights = Array.isArray(pending.highlights)
          ? pending.highlights.filter(item => typeof item === 'string' && item.trim())
          : [];
        const bullets = highlights.map(item => `- ${item}`).join('\n');
        const whatsNewBlock = `\n[WHAT'S NEW ON SAN.AGY v${ver}]${bullets ? `\n${bullets}` : ''}`;
        message += whatsNewBlock;

        const updatedPending = {
          ...pending,
          seen: true,
          seenAt: new Date().toISOString()
        };
        fs.writeFileSync(whatsNewFile, JSON.stringify(updatedPending, null, 2) + '\n', 'utf8');
      }
    }
  } catch {
    // Fail-safe: ignore malformed whats_new_pending.json without crashing session_start
  }
}

const response = {
  injectSteps: [
    {
      systemMessage: {
        systemMessage: message
      }
    }
  ]
};

console.log(JSON.stringify(response, null, 2));
process.exit(0);
