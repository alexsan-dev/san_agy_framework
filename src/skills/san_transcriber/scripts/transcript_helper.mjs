#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const TEMPLATE_PATH = path.resolve(__dirname, '../templates/TRANSCRIPT_TEMPLATE.md');

function printHelp() {
  console.log(`Usage: transcript_helper.mjs [options]

Génère un transcript de relais sceptique (Doubt & Verify) dans roadmaps/transcripts/.

Options:
  --roadmap=<path>    Chemin vers la roadmap active prioritaire (défaut: auto-détection dans roadmaps/*.md)
  --summary="<texte>" Ce qui a été accompli par l'agent sortant
  --why="<texte>"     Comment et pourquoi (décisions d'architecture et compromis)
  --doubts="<texte>"  Zones de doute, hypothèses fragiles et raccourcis potentiels
  --next="<texte>"    Prochaines étapes prioritaires restantes
  --harness="<texte>" Harnais / modèle sortant (ex: "Antigravity (gemini-4-argon-high)")
  --out=<path>        Fichier de sortie (défaut: roadmaps/transcripts/TRANSCRIPT_<ROADMAP_SLUG>_<DDMMYYYY>.md)
  --dir=<path>        Racine du projet (défaut: cwd)
  -h, --help          Affiche cette aide et quitte
`);
}

function parseArgs(argv) {
  const opts = {
    roadmap: null,
    summary: '',
    why: '',
    doubts: '',
    next: '',
    harness: '',
    out: null,
    dir: process.cwd(),
    help: false
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '-h' || arg === '--help') {
      opts.help = true;
      continue;
    }

    const eqIdx = arg.indexOf('=');
    let key = arg;
    let val = null;
    if (arg.startsWith('--') && eqIdx !== -1) {
      key = arg.slice(0, eqIdx);
      val = arg.slice(eqIdx + 1);
    } else if (arg.startsWith('--') && i + 1 < argv.length && !argv[i + 1].startsWith('--')) {
      val = argv[i + 1];
      i++;
    }

    if (key === '--roadmap' && val !== null) opts.roadmap = val;
    else if (key === '--summary' && val !== null) opts.summary = val;
    else if (key === '--why' && val !== null) opts.why = val;
    else if (key === '--doubts' && val !== null) opts.doubts = val;
    else if (key === '--next' && val !== null) opts.next = val;
    else if ((key === '--harness' || key === '--model') && val !== null) opts.harness = val;
    else if (key === '--out' && val !== null) opts.out = val;
    else if ((key === '--dir' || key === '--workspace') && val !== null) opts.dir = val;
  }

  return opts;
}

function runGit(workspaceRoot, gitArgs) {
  try {
    return execFileSync('git', ['-c', 'safe.directory=*', ...gitArgs], {
      cwd: workspaceRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
      timeout: 3000
    }).trim();
  } catch {
    return null;
  }
}

function analyzeRoadmapFile(absPath, workspaceRoot) {
  const raw = fs.readFileSync(absPath, 'utf8');
  const lines = raw.split(/\r?\n/);
  let done = 0;
  let todo = 0;
  const openTasks = [];

  for (const line of lines) {
    if (/^\s*[-*]\s+\[x\]/i.test(line)) {
      done++;
    } else if (/^\s*[-*]\s+\[\s\]/.test(line)) {
      todo++;
      if (openTasks.length < 10) {
        openTasks.push(line.trim());
      }
    }
  }

  let mtimeMs = 0;
  try {
    mtimeMs = fs.statSync(absPath).mtimeMs;
  } catch {
    mtimeMs = 0;
  }

  const relPath = path.relative(workspaceRoot, absPath).replace(/\\/g, '/');
  return {
    absPath,
    relPath,
    name: path.basename(absPath),
    done,
    todo,
    total: done + todo,
    openTasks,
    mtimeMs
  };
}

function discoverActiveRoadmaps(workspaceRoot, explicitRoadmap) {
  const results = [];
  const seen = new Set();

  if (explicitRoadmap) {
    const resolved = path.resolve(workspaceRoot, explicitRoadmap);
    if (!fs.existsSync(resolved)) {
      console.error(`Erreur : Roadmap introuvable : ${resolved}`);
      process.exit(1);
    }
    const info = analyzeRoadmapFile(resolved, workspaceRoot);
    results.push(info);
    seen.add(resolved);
  }

  const roadmapsDir = path.join(workspaceRoot, 'roadmaps');
  if (fs.existsSync(roadmapsDir)) {
    const entries = fs.readdirSync(roadmapsDir, { withFileTypes: true });
    const discovered = entries
      .filter(
        entry =>
          entry.isFile() &&
          entry.name.endsWith('.md') &&
          !/^(?:readme|.*template.*)\.md$/i.test(entry.name)
      )
      .map(entry => path.join(roadmapsDir, entry.name))
      .filter(absPath => !seen.has(absPath))
      .map(absPath => analyzeRoadmapFile(absPath, workspaceRoot))
      .sort((a, b) => b.mtimeMs - a.mtimeMs);

    results.push(...discovered);
  }

  return results;
}

function formatDateParts(date) {
  const pad = n => String(n).padStart(2, '0');
  const dd = pad(date.getDate());
  const mm = pad(date.getMonth() + 1);
  const yyyy = String(date.getFullYear());
  const hh = pad(date.getHours());
  const min = pad(date.getMinutes());
  return {
    ddmmyyyy: `${dd}${mm}${yyyy}`,
    human: `${dd}/${mm}/${yyyy} ${hh}:${min}`,
    iso: date.toISOString()
  };
}

function detectHarnessLabel(workspaceRoot, explicitHarness) {
  if (explicitHarness && explicitHarness.trim()) {
    return explicitHarness.trim();
  }
  try {
    const modelsFile = path.join(workspaceRoot, '.agents', 'models.json');
    if (fs.existsSync(modelsFile)) {
      const cfg = JSON.parse(fs.readFileSync(modelsFile, 'utf8'));
      const agyOrch = cfg?.agy?.orchestrator || 'gemini-4-argon-high';
      const agyExec = cfg?.agy?.executor || 'gemini-4-hydrogen-xhigh';
      const ocOrch = cfg?.opencode?.orchestrator || 'opencode-go/hy4';
      const ocExec = cfg?.opencode?.executor || 'opencode-go/deepseek-v4-pro';
      return `Dual-Harness (.agents/models.json -> AGY: ${agyOrch} / ${agyExec} | OpenCode: ${ocOrch} / ${ocExec})`;
    }
  } catch {
    // Ignore malformed models.json
  }
  return 'Session sortante (Antigravity / OpenCode V2 — vérifier .agents/models.json)';
}

function buildRoadmapSlug(roadmaps) {
  if (!roadmaps.length) return 'SESSION';
  const base = roadmaps[0].name.replace(/\.md$/i, '');
  const slug = base
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
  return slug || 'SESSION';
}

function formatInventory(roadmaps) {
  if (!roadmaps.length) {
    return '- Aucune roadmap active détectée dans `roadmaps/*.md`.';
  }
  return roadmaps
    .map(rm => {
      const pct = rm.total > 0 ? Math.round((rm.done / rm.total) * 100) : 0;
      const lines = [`- **\`${rm.relPath}\`** : ${rm.done}/${rm.total} coches \`- [x]\` (${pct}%), ${rm.todo} restante(s) \`- [ ]\``];
      if (rm.openTasks.length > 0) {
        lines.push(...rm.openTasks.map(t => `  - ${t}`));
        if (rm.todo > rm.openTasks.length) {
          lines.push(`  - *(... et ${rm.todo - rm.openTasks.length} autre(s) tâche(s) \`- [ ]\` dans le fichier)*`);
        }
      }
      return lines.join('\n');
    })
    .join('\n');
}

function renderFallbackTemplate() {
  return `# TRANSCRIPT DE RELAIS SCEPTIQUE : {{ROADMAP_TITLE}}

> **Date de génération :** {{DATE_DISPLAY}} (\`{{TIMESTAMP_ISO}}\`)  
> **Harnais / Modèle sortant :** {{OUTGOING_HARNESS_MODEL}}  
> **Roadmaps actives associées :** {{ACTIVE_ROADMAPS_LIST}}  
> **Progression constatée (\`- [x]\` / \`- [ ]\`):** {{PROGRESS_SUMMARY}}  
> **État Git courant :** {{GIT_BRANCH_INFO}}

## 1. CE QUI A ÉTÉ ACCOMPLI, COMMENT ET POURQUOI
{{SUMMARY_SECTION}}

{{WHY_SECTION}}

\`\`\`text
{{GIT_STATUS_SHORT}}
\`\`\`

\`\`\`text
{{GIT_LOG_ONELINE}}
\`\`\`

## 2. ZONES DE DOUTE, HYPOTHÈSES FRAGILES & RACCOURCIS POTENTIELS
{{DOUBTS_SECTION}}

## 3. PROTOCOLE DE RELAIS SCEPTIQUE (DOUBT & VERIFY)
Vérifie \`.agents/cache/REPO_MAP.md\`, \`git diff\`, les tests réels et les hypothèses fragiles avant de faire confiance à ce transcript.

## 4. CE QUI RESTE À ACCOMPLIR
{{NEXT_SECTION}}

{{ROADMAPS_INVENTORY}}
`;
}

function main() {
  const opts = parseArgs(process.argv.slice(2));
  if (opts.help) {
    printHelp();
    process.exit(0);
  }

  const workspaceRoot = path.resolve(opts.dir || process.cwd());
  const roadmaps = discoverActiveRoadmaps(workspaceRoot, opts.roadmap);
  const slug = buildRoadmapSlug(roadmaps);
  const dateParts = formatDateParts(new Date());

  const defaultOutRel = path.join(
    'roadmaps',
    'transcripts',
    `TRANSCRIPT_${slug}_${dateParts.ddmmyyyy}.md`
  );
  const outPath = opts.out
    ? path.resolve(workspaceRoot, opts.out)
    : path.resolve(workspaceRoot, defaultOutRel);

  const gitBranch = runGit(workspaceRoot, ['rev-parse', '--abbrev-ref', 'HEAD']) || 'non-git';
  const gitStatusRaw = runGit(workspaceRoot, ['status', '--short']);
  const gitStatusDisplay =
    gitStatusRaw === null
      ? '(Dépôt non-Git ou git indisponible)'
      : gitStatusRaw || '(Working tree clean)';

  const gitLogRaw = runGit(workspaceRoot, ['log', '-n', '5', '--oneline']);
  const gitLogDisplay =
    gitLogRaw === null || gitLogRaw === ''
      ? '(Aucun commit disponible)'
      : gitLogRaw;

  const totalDone = roadmaps.reduce((acc, r) => acc + r.done, 0);
  const totalTodo = roadmaps.reduce((acc, r) => acc + r.todo, 0);
  const totalAll = totalDone + totalTodo;
  const pct = totalAll > 0 ? Math.round((totalDone / totalAll) * 100) : 0;

  const activeList = roadmaps.length
    ? roadmaps.map(r => `\`${r.relPath}\``).join(', ')
    : 'Aucune roadmap active dans `roadmaps/*.md`';

  const progressSummary = roadmaps.length
    ? `${totalDone} \`- [x]\` terminée(s), ${totalTodo} \`- [ ]\` restante(s) (${pct}%)`
    : 'Aucune case détectée';

  const summarySection = opts.summary.trim()
    ? opts.summary.trim()
    : '*(Non renseigné via `--summary` — vérifier `git status` et `git log` ci-dessous avant de conclure.)*';

  const whySection = opts.why.trim()
    ? opts.why.trim()
    : '*(Aucune justification `--why` fournie — auditer le code et les ADRs/roadmaps directement.)*';

  const doubtsSection = opts.doubts.trim()
    ? opts.doubts.trim()
    : '*(Aucune auto-critique `--doubts` déclarée par l\'agent sortant — présumer qu\'il existe des angles morts non testés et auditer les modifications.)*';

  const nextSection = opts.next.trim()
    ? opts.next.trim()
    : '*(Reprendre les tâches `- [ ]` restantes ci-dessous après vérification sceptique du terrain.)*';

  const template = fs.existsSync(TEMPLATE_PATH)
    ? fs.readFileSync(TEMPLATE_PATH, 'utf8')
    : renderFallbackTemplate();

  const replacements = {
    '{{ROADMAP_TITLE}}': roadmaps.length ? roadmaps[0].name : 'RELAIS_SESSION',
    '{{DATE_DISPLAY}}': dateParts.human,
    '{{TIMESTAMP_ISO}}': dateParts.iso,
    '{{OUTGOING_HARNESS_MODEL}}': detectHarnessLabel(workspaceRoot, opts.harness),
    '{{ACTIVE_ROADMAPS_LIST}}': activeList,
    '{{PROGRESS_SUMMARY}}': progressSummary,
    '{{GIT_BRANCH_INFO}}': `branche \`${gitBranch}\``,
    '{{SUMMARY_SECTION}}': summarySection,
    '{{WHY_SECTION}}': whySection,
    '{{GIT_STATUS_SHORT}}': gitStatusDisplay,
    '{{GIT_LOG_ONELINE}}': gitLogDisplay,
    '{{DOUBTS_SECTION}}': doubtsSection,
    '{{NEXT_SECTION}}': nextSection,
    '{{ROADMAPS_INVENTORY}}': formatInventory(roadmaps)
  };

  let rendered = template;
  for (const [token, value] of Object.entries(replacements)) {
    rendered = rendered.split(token).join(value);
  }

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, rendered, 'utf8');

  console.log(outPath);
}

main();
