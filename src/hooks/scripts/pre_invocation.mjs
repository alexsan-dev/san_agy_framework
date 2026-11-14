#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

// Read stdin synchronously
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

const userInput = typeof data.lastUserInput === 'string' ? data.lastUserInput : '';
const shouldEnforce = /(?:d[eé]velopp|impl[eé]ment|cr[eé]e?|architect|plan|design|cod|audit|refactor|fix|bug|test|build|feature|ex[eé]cut|optimis|ajoute|modifi|corrig|d[eé]ploi|refond|vid[eé]o|[eé]cran|page|composant|api|route|script|lanc|fais|faire|chang|remplac|supprim|mets?|mettre|veux|voulais|doit|dois)/i.test(userInput);

if (!shouldEnforce) {
  console.log(JSON.stringify({ injectSteps: [] }, null, 2));
  process.exit(0);
}

const workspaceRoot =
  Array.isArray(data.workspacePaths) &&
  data.workspacePaths.length > 0 &&
  typeof data.workspacePaths[0] === 'string' &&
  data.workspacePaths[0].trim()
    ? path.resolve(data.workspacePaths[0])
    : typeof data.cwd === 'string' && data.cwd.trim()
      ? path.resolve(data.cwd)
      : process.cwd();

let agyExecutor = 'gemini-4-hydrogen-xhigh';
let opencodeExecutor = 'opencode-go/deepseek-v4-pro';

try {
  const modelsFile = path.join(workspaceRoot, '.agents', 'models.json');
  if (fs.existsSync(modelsFile)) {
    const models = JSON.parse(fs.readFileSync(modelsFile, 'utf8'));
    if (typeof models?.agy?.executor === 'string' && models.agy.executor.trim()) {
      agyExecutor = models.agy.executor.trim();
    }
    if (typeof models?.opencode?.executor === 'string' && models.opencode.executor.trim()) {
      opencodeExecutor = models.opencode.executor.trim();
    }
  }
} catch {
  // Fail-safe: keep default Dual-Harness executors
}

const reminderText =
  '[SAN.AGY ENFORCER] [SAN.AGY DISCIPLINE REMINDER] ' +
  '(1) Map-First: read .agents/cache/REPO_MAP.md first. ' +
  '(2) Cognitive Alignment: before delegating roadmap/UI, ask user (ask_question/question) & capture visual URLs (export_png.mjs --url --viewports=desktop,mobile). ' +
  `(3) Dual-Harness: NEVER solo-code or invoke_subagent(Model:"inherit"); Antigravity -> swarm(${agyExecutor}) | OpenCode V2 -> subagent(${opencodeExecutor}) [san-framework models]. ` +
  '(4) Challenge with san-qa-auditor + tests before [x].';

const output = {
  systemMessage: {
    systemMessage: reminderText
  }
};

const response = {
  injectSteps: [output]
};

console.log(JSON.stringify(response, null, 2));
process.exit(0);
