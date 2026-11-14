import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { WHATS_NEW, formatWhatsNewTerminal } from './whats_new.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const FRAMEWORK_ROOT = path.resolve(__dirname, '../..');
export const SKILLS_SRC_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'skills');
export const AGENTS_SRC_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'agents');
export const HOOKS_SRC_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'hooks');
export const PLUGIN_SRC_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'plugin');
export const TEMPLATES_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'skills', 'san_init', 'templates');
export const RULES_TEMPLATES_DIR = path.resolve(TEMPLATES_DIR, 'rules');

export const CANONICAL_RULES = [
  { template: 'BRAND_TEMPLATE.md', target: 'BRAND.md' },
  { template: 'PRODUCT_TEMPLATE.md', target: 'PRODUCT.md' },
  { template: 'PROJECT_TEMPLATE.md', target: 'PROJECT.md' },
  { template: 'API_TEMPLATE.md', target: 'API.md' },
  { template: 'LOGO_TEMPLATE.md', target: 'LOGO.md' }
];

export const CANONICAL_AGENTS = [
  'san-researcher.md',
  'san-architect.md',
  'san-designer-worker.md',
  'san-coder-back.md',
  'san-coder-front.md',
  'san-qa-auditor.md',
  'san-ops-devops.md',
  'san-growth-legal.md'
];

export const CANONICAL_HOOK_SCRIPTS = [
  'session_start.mjs',
  'pre_invocation.mjs',
  'pre_tool_guard.mjs',
  'post_tool_indexer.mjs',
  'stop_guard.mjs'
];

export function getFrameworkVersion() {
  try {
    const pkgPath = path.resolve(FRAMEWORK_ROOT, 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if (pkg.version) return pkg.version;
    }
  } catch {}
  return '2.1.0';
}

function normalizeTargetOptions(targetDirOrOptions, maybeOptions = {}) {
  if (typeof targetDirOrOptions === 'string') {
    return { ...(maybeOptions || {}), targetDir: targetDirOrOptions };
  }
  return targetDirOrOptions || {};
}

export const colors = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  cyan: '\x1b[36m',
  brightCyan: '\x1b[96m',
  green: '\x1b[32m',
  brightGreen: '\x1b[92m',
  yellow: '\x1b[33m',
  brightYellow: '\x1b[93m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  gray: '\x1b[90m'
};

/**
 * Récupère la liste de tous les modules disponibles dans src/skills/
 */
export function getAvailableSkills(frameworkRoot = FRAMEWORK_ROOT) {
  const srcDir = path.join(frameworkRoot, 'src', 'skills');
  if (!fs.existsSync(srcDir)) return [];
  return fs.readdirSync(srcDir, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory() && dirent.name.startsWith('san_'))
    .map(dirent => dirent.name)
    .sort();
}

/**
 * Extrait la description d'un skill depuis son fichier SKILL.md
 */
export function getSkillDescription(skillName, frameworkRoot = FRAMEWORK_ROOT) {
  const skillFile = path.join(frameworkRoot, 'src', 'skills', skillName, 'SKILL.md');
  if (fs.existsSync(skillFile)) {
    try {
      const content = fs.readFileSync(skillFile, 'utf8');
      const match = content.match(/description:\s*([^\n\r]+)/);
      if (match) return match[1].trim();
    } catch {}
  }
  return '';
}

/**
 * Résout une liste de skills utilisateur (gère le préfixe 'san_' optionnel)
 */
export function resolveSkillList(skillsInput, availableSkills = getAvailableSkills()) {
  if (!skillsInput || skillsInput.length === 0) return availableSkills;
  const list = Array.isArray(skillsInput)
    ? skillsInput
    : String(skillsInput).split(',');
  const resolved = [];
  for (const raw of list) {
    const s = raw.trim();
    if (!s) continue;
    if (availableSkills.includes(s)) {
      resolved.push(s);
    } else if (availableSkills.includes(`san_${s}`)) {
      resolved.push(`san_${s}`);
    } else {
      console.warn(`${colors.yellow}[!] Attention : Skill "${s}" introuvable dans le catalogue.${colors.reset}`);
    }
  }
  return [...new Set(resolved)];
}

/**
 * Extrait le frontmatter YAML complet (délimité par --- et ---) d'un texte Markdown
 */
export function extractFrontmatter(content) {
  if (!content || typeof content !== 'string') return null;
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  return match ? match[0] : null;
}

/**
 * Détecte si un contenu Markdown possède un frontmatter YAML officiel Antigravity valide avec un trigger:
 */
export function hasTriggerFrontmatter(content) {
  if (!content || typeof content !== 'string') return false;
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return false;
  return /^\s*trigger\s*:/m.test(match[1]);
}

/**
 * Exécute l'hygiène Git souveraine et l'isolation hermétique réversible.
 * Remplace tout rm -rf par un déplacement réversible dans .agents/backups/legacy-ai-configs/<timestamp>/
 * Préserve scrupuleusement <root>/AGENTS.md.
 */
export function executeGitHygiene(projectDir, { dryRun = false, preserveOpencode = false } = {}) {
  const report = {
    isGit: false,
    gitRoot: null,
    purgedFiles: [],
    purgedDirs: [],
    backupDir: null,
    untrackedCount: 0,
    gitignoreUpdated: false,
    excludeUpdated: false
  };

  try {
    const isInside = execSync('git rev-parse --is-inside-work-tree', {
      cwd: projectDir,
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8'
    }).trim();
    if (isInside === 'true') {
      report.isGit = true;
      report.gitRoot = execSync('git rev-parse --show-toplevel', {
        cwd: projectDir,
        encoding: 'utf8'
      }).trim();
    }
  } catch {
    report.isGit = false;
  }

  const OBSOLETE_FILES = [
    'CLAUDE.md',
    '.cursorrules',
    '.windsurfrules',
    '.poolside',
    '.github/copilot-instructions.md',
    ...(preserveOpencode ? [] : ['.opencode'])
  ];

  const OBSOLETE_DIRS = [
    '.claude',
    '.cursor',
    '.windsurf',
    '.copilot'
  ];

  const rootTarget = report.isGit && report.gitRoot ? report.gitRoot : projectDir;
  const searchRoots = report.isGit && report.gitRoot
    ? [report.gitRoot, ...(projectDir !== report.gitRoot ? [projectDir] : [])]
    : [projectDir];

  const now = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const timestamp = `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}_${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;
  const backupBaseDir = path.join(rootTarget, '.agents', 'backups', 'legacy-ai-configs', timestamp);

  let hasBackedUp = false;

  for (const root of searchRoots) {
    for (const file of OBSOLETE_FILES) {
      if (file === 'AGENTS.md') continue; // Sanctuaire absolu
      const filePath = path.join(root, file);
      if (fs.existsSync(filePath)) {
        if (!dryRun) {
          try {
            const destPath = path.join(backupBaseDir, file);
            fs.mkdirSync(path.dirname(destPath), { recursive: true });
            fs.renameSync(filePath, destPath);
            hasBackedUp = true;
          } catch {
            try {
              const destPath = path.join(backupBaseDir, file);
              fs.mkdirSync(path.dirname(destPath), { recursive: true });
              fs.copyFileSync(filePath, destPath);
              fs.rmSync(filePath, { force: true });
              hasBackedUp = true;
            } catch {}
          }
        }
        report.purgedFiles.push(file);
      }
    }

    for (const dir of OBSOLETE_DIRS) {
      const dirPath = path.join(root, dir);
      if (fs.existsSync(dirPath)) {
        if (!dryRun) {
          try {
            const destDir = path.join(backupBaseDir, dir);
            fs.mkdirSync(path.dirname(destDir), { recursive: true });
            fs.cpSync(dirPath, destDir, { recursive: true });
            fs.rmSync(dirPath, { recursive: true, force: true });
            hasBackedUp = true;
          } catch {}
        }
        report.purgedDirs.push(dir);
      }
    }
  }

  if (hasBackedUp) {
    report.backupDir = backupBaseDir;
  }

  report.purgedFiles = [...new Set(report.purgedFiles)];
  report.purgedDirs = [...new Set(report.purgedDirs)];

  const GITIGNORE_MARKER = '# --- ANTIGRAVITY AI ISOLATION (san_*) ---';
  const GITIGNORE_BLOCK = `\n# --- ANTIGRAVITY AI ISOLATION (san_*) ---
# Espace souverain local Antigravity (Zéro fuite Git)
/.agents/
/GEMINI.md

# Résidus tiers archivés
/.claude/
/CLAUDE.md
/.opencode/
/.poolside/
/.cursor/
/.cursorrules/
/.windsurf/
/.windsurfrules/
/.copilot/
# ----------------------------------------\n`;

  // 1. .gitignore (Toujours créé ou mis à jour à la racine de projectDir, même hors dépôt Git initialisé)
  const gitignorePath = path.join(projectDir, '.gitignore');
  let gitignoreContent = '';
  if (fs.existsSync(gitignorePath)) {
    gitignoreContent = fs.readFileSync(gitignorePath, 'utf8');
  }
  if (!gitignoreContent.includes(GITIGNORE_MARKER)) {
    if (!dryRun) {
      fs.appendFileSync(gitignorePath, GITIGNORE_BLOCK, 'utf8');
    }
    report.gitignoreUpdated = true;
  }

  // Si le dépôt Git a sa racine au-dessus de projectDir, isoler également le .gitignore racine
  if (report.isGit && report.gitRoot && report.gitRoot !== projectDir) {
    const rootGitignore = path.join(report.gitRoot, '.gitignore');
    let rootContent = fs.existsSync(rootGitignore) ? fs.readFileSync(rootGitignore, 'utf8') : '';
    if (!rootContent.includes(GITIGNORE_MARKER)) {
      if (!dryRun) {
        fs.appendFileSync(rootGitignore, GITIGNORE_BLOCK, 'utf8');
      }
      report.gitignoreUpdated = true;
    }
  }

  if (report.isGit && report.gitRoot) {
    // AGENTS.md en est formellement exclu afin de rester committable
    const AI_CACHE_TARGETS = [
      '.agents',
      '.agents/',
      'GEMINI.md',
      '.claude',
      '.claude/',
      'CLAUDE.md',
      '.cursor',
      '.cursorrules',
      '.windsurf',
      '.windsurfrules',
      '.copilot',
      '.github/copilot-instructions.md',
      '.poolside',
      ...(preserveOpencode ? [] : ['.opencode'])
    ];

    if (!dryRun) {
      try {
        execSync(`git rm -r --cached --ignore-unmatch ${AI_CACHE_TARGETS.join(' ')}`, {
          cwd: report.gitRoot,
          stdio: 'ignore'
        });
      } catch {}
    }

    // 2. .git/info/exclude
    let excludePath;
    try {
      const p = execSync('git rev-parse --git-path info/exclude', {
        cwd: report.gitRoot,
        encoding: 'utf8'
      }).trim();
      excludePath = path.isAbsolute(p) ? p : path.join(report.gitRoot, p);
    } catch {
      excludePath = path.join(report.gitRoot, '.git', 'info', 'exclude');
    }

    let excludeContent = '';
    if (fs.existsSync(excludePath)) {
      excludeContent = fs.readFileSync(excludePath, 'utf8');
    }
    if (!excludeContent.includes(GITIGNORE_MARKER)) {
      if (!dryRun) {
        try {
          fs.mkdirSync(path.dirname(excludePath), { recursive: true });
          fs.appendFileSync(excludePath, GITIGNORE_BLOCK, 'utf8');
          report.excludeUpdated = true;
        } catch {}
      }
    }
  }

  return report;
}

/**
 * Marqueur interne inséré dans les fichiers de contexte générés.
 */
const CONTEXT_MARKER = '<!-- san_* context (generated) -->';

/**
 * Génère le fichier de constitution souveraine `AGENTS.md` à la racine du projet.
 * Smart Merge : un AGENTS.md existant sans marqueur (rédigé par l'utilisateur)
 * n'est jamais écrasé, sauf en cas de `--force`.
 */
export function generateAgentsContext(projectRoot, { skills = [], dryRun = false, force = false } = {}) {
  const dest = path.join(projectRoot, 'AGENTS.md');
  const templatePath = path.join(TEMPLATES_DIR, 'AGENTS_INDEX_TEMPLATE.md');

  if (fs.existsSync(dest) && !force) {
    const existing = fs.readFileSync(dest, 'utf8');
    if (!existing.includes(CONTEXT_MARKER) && !existing.includes('<!-- san_* opencode context (generated) -->')) {
      return { file: 'AGENTS.md', status: 'preserved' };
    }
  }

  let content = '';
  if (fs.existsSync(templatePath)) {
    content = fs.readFileSync(templatePath, 'utf8');
  } else {
    content = `${CONTEXT_MARKER}\n# Contexte et Constitution — Framework Antigravity (san_*)\n`;
  }

  const SHORT_DESCRIPTIONS = {
    san_backend_expert: 'API, transactions DB et idempotence.',
    san_brainstorming: 'Idéation produit et scoring matriciel.',
    san_cartographer: 'Carte hybride du repo et cache AST/IA.',
    san_copywriter: 'Rédaction UX et micro-copies 5 états.',
    san_design_tokens: 'Tokens BRAND vers CSS, Tailwind et TS.',
    san_designer: 'Design UI 100% code et canvas stores.',
    san_devops_expert: 'Docker, CI/CD, Nginx et backups testés.',
    san_doc_keeper: 'SemVer, CHANGELOG et intégrité doc.',
    san_executer: 'Delivery full-stack et Quality Gate.',
    san_exporter: 'Capture Playwright et export PNG/PDF.',
    san_growth_expert: 'SEO local, acquisition et tracking.',
    san_init: 'Cadrage initial, règles et isolation Git.',
    san_planner: 'Découpage cartésien et gouvernance roadmaps.',
    san_qa_security_expert: 'Audit OWASP, tests E2E et validation.',
    san_searcher: 'Documentation officielle et Context Shielding.',
    san_store_legal_expert: 'Conformité stores App/Play et RGPD.',
    san_subagent_manager: 'Calibrage des sous-agents hermétiques.',
    san_ux_ui_expert: 'Composants front/mobile, 5 états et 60 fps.'
  };

  const skillLines = (skills.length ? skills : getAvailableSkills())
    .map((s) => `* **${s}** — ${SHORT_DESCRIPTIONS[s] || getSkillDescription(s) || 'Compétence du framework san_*.'}`)
    .join('\n');
  content = content.replace('{{SKILLS_LIST}}', skillLines || '* (aucune compétence)');

  if (!dryRun) {
    fs.writeFileSync(dest, content, 'utf8');
  }

  return { file: 'AGENTS.md', status: 'created' };
}

/**
 * Fusionne la configuration opencode.json sans écraser les champs utilisateur.
 */
export function mergeOpencodeConfig(projectRoot, { dryRun = false } = {}) {
  const configPath = path.join(projectRoot, 'opencode.json');
  let config = { $schema: 'https://opencode.ai/config.json' };
  let existed = false;

  if (fs.existsSync(configPath)) {
    existed = true;
    try {
      const parsed = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) config = parsed;
    } catch {
      return { file: 'opencode.json', status: 'skipped-invalid' };
    }
  }

  const desiredSkillPath = '.agents/skills';
  const existingPaths = Array.isArray(config.skills?.paths) ? config.skills.paths : [];
  if (!existingPaths.includes(desiredSkillPath)) existingPaths.push(desiredSkillPath);
  config.skills = { ...(config.skills ?? {}), paths: existingPaths };

  const instructions = Array.isArray(config.instructions) ? config.instructions : [];
  for (const target of ['.agents/GEMINI.md']) {
    if (!instructions.includes(target)) instructions.push(target);
  }
  if (instructions.length) config.instructions = instructions;

  if (!config.$schema) config.$schema = 'https://opencode.ai/config.json';

  const next = JSON.stringify(config, null, 2) + '\n';
  if (!dryRun) fs.writeFileSync(configPath, next, 'utf8');

  return { file: 'opencode.json', status: existed ? 'merged' : 'created' };
}

/**
 * Déploie les compétences (Skills) dans le dossier cible et rend leurs scripts exécutables.
 */
export function deploySkills(skillsDestDir, selectedSkills = getAvailableSkills(), { dryRun = false, force = false } = {}) {
  const installedSkills = [];
  for (const skillName of selectedSkills) {
    const src = path.join(SKILLS_SRC_DIR, skillName);
    const dest = path.join(skillsDestDir, skillName);

    if (!fs.existsSync(src)) continue;

    if (!dryRun) {
      fs.mkdirSync(skillsDestDir, { recursive: true });
      if (fs.existsSync(dest) && force) {
        fs.rmSync(dest, { recursive: true, force: true });
      }
      fs.cpSync(src, dest, { recursive: true });

      const scriptsPath = path.join(dest, 'scripts');
      if (fs.existsSync(scriptsPath)) {
        try {
          for (const f of fs.readdirSync(scriptsPath)) {
            try { fs.chmodSync(path.join(scriptsPath, f), 0o755); } catch {}
          }
        } catch {}
      }
    }
    installedSkills.push(skillName);
  }
  return installedSkills;
}

/**
 * Déploie les compétences en mode héritage léger (--light) via .agents/skills.json.
 */
export function deploySkillsLight(agentsDir, { dryRun = false } = {}) {
  const skillsJsonPath = path.join(agentsDir, 'skills.json');
  const payload = {
    version: 1,
    inherits: [SKILLS_SRC_DIR]
  };

  if (!dryRun) {
    fs.mkdirSync(agentsDir, { recursive: true });
    fs.writeFileSync(skillsJsonPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  }

  return {
    file: 'skills.json',
    status: dryRun ? 'dry-run' : 'created',
    config: payload
  };
}

/**
 * Écrit le marqueur .agents/cache/whats_new_pending.json pour notification unique au 1er SessionStart.
 */
export function writeWhatsNewPendingCache(agentsDir, { dryRun = false, version = getFrameworkVersion() } = {}) {
  const entry = WHATS_NEW[version] || WHATS_NEW['2.1.0'];
  const pendingPayload = {
    version: entry ? entry.version : version,
    updatedAt: new Date().toISOString(),
    seen: false,
    highlights: entry ? entry.highlights : []
  };

  if (!dryRun) {
    const cacheDir = path.join(agentsDir, 'cache');
    fs.mkdirSync(cacheDir, { recursive: true });
    fs.writeFileSync(
      path.join(cacheDir, 'whats_new_pending.json'),
      JSON.stringify(pendingPayload, null, 2) + '\n',
      'utf8'
    );
  }

  return pendingPayload;
}

/**
 * Déploie les 8 sous-agents natifs dans .agents/agents/
 */
export function deployAgents(agentsDestDir, { dryRun = false, force = false } = {}) {
  const statusList = [];
  if (!dryRun) {
    fs.mkdirSync(agentsDestDir, { recursive: true });
  }

  for (const agentFile of CANONICAL_AGENTS) {
    const src = path.join(AGENTS_SRC_DIR, agentFile);
    const dest = path.join(agentsDestDir, agentFile);

    if (!fs.existsSync(src)) continue;

    const exists = fs.existsSync(dest);
    if (!dryRun) {
      if (!exists || force) {
        fs.copyFileSync(src, dest);
      }
    }
    statusList.push({ file: agentFile, status: exists ? (force ? 'overwritten' : 'preserved') : 'created' });
  }

  return statusList;
}

/**
 * Migre chirurgicalement la section de routage des modèles v2.0 (invoke_subagent / 3.8 Flash / 3.1 Pro)
 * dans un fichier PROJECT.md personnalisé tout en préservant 100% de la stack métier du projet.
 */
export function migrateLegacyModelRoutingInProjectRule(content) {
  if (!content || typeof content !== 'string') return { content, migrated: false };
  const hasLegacySection =
    /ROUTAGE STRICT DES MOD[ÈE]LES ANTIGRAVITY\s*\(`?invoke_subagent`?\)/i.test(content) ||
    /Gemini 3\.8 Flash|gemini-3\.8-flash-high|gemini-3\.1-pro-high/i.test(content);

  if (!hasLegacySection) {
    return { content, migrated: false };
  }

  const v21RoutingSection = `## 2. DOCTRINE D'ORCHESTRATION SOUVERAINE (\`Argon\` -> \`Swarm Hydrogen XHigh\`)

Pour maximiser la puissance d'ingénierie tout en sanctuarisant le quota hebdomadaire de l'Orchestrateur, la délégation suit la vérité technique Antigravity CLI v1.5.8+ :

- **Interdiction absolue de \`invoke_subagent\` :** \`invoke_subagent(Model: "inherit")\` brûle le quota hebdomadaire \`Argon\`/\`Carbon\`, et \`invoke_subagent(Model: "pro" | "flash")\` subit un fallback serveur vers \`gemini-3.8-flash-tiered\`.
- **Délégation exclusive via \`swarm\` :** Toute tâche de recherche, d'architecture, de code, d'UI ou d'audit est déléguée via **\`swarm(action: "add", model: "gemini-4-hydrogen-xhigh", ...)\`** (ou \`agy -p --model gemini-4-hydrogen-xhigh\`).

| Rôle dans le Projet | Outil & Paramètre \`model\` | Modèle Réel Actif | Périmètre & Responsabilité |
| :--- | :--- | :--- | :--- |
| **Session Principale (Orchestrateur)** | Thread principal (\`coordinator\`) | \`Gemini 4 Argon (High)\` | Architecture, arbitrage, découpage sans conflit de fichiers et pilotage du board \`swarm\`. |
| **Workers d'Architecture & Code (\`san-architect\`, \`san-coder-*\`, \`san-designer-worker\`, \`san-ops-devops\`)** | \`swarm(action: "add", model: "gemini-4-hydrogen-xhigh")\` | \`Gemini 4 Hydrogen (XHigh)\` | Pre-Mortem, contrats OpenAPI/Zod, code Backend/Frontend atomique, Studio Duel UI, scripts & infra. |
| **Workers de Recherche & Audit QA (\`san-researcher\`, \`san-qa-auditor\`)** | \`swarm(action: "add", model: "gemini-4-hydrogen-xhigh")\` | \`Gemini 4 Hydrogen (XHigh)\` | Exploration Map-First (\`REPO_MAP.md\`), audit contradictoire OWASP/Substance/DOM, validation des tests. |`;

  let next = content;
  const sectionRegex = /##\s*2\.\s*ROUTAGE STRICT DES MOD[ÈE]LES ANTIGRAVITY[\s\S]*?(?=\r?\n---\r?\n|\r?\n##\s*3\.|$)/i;
  if (sectionRegex.test(next)) {
    next = next.replace(sectionRegex, v21RoutingSection + '\n');
  } else {
    next = next
      .replace(/gemini-3\.1-pro-high|gemini-3\.8-flash-high|Gemini 3\.8 Flash/g, 'gemini-4-hydrogen-xhigh')
      .replace(/invoke_subagent/g, 'swarm(action: "add", model: "gemini-4-hydrogen-xhigh")');
  }

  return { content: next, migrated: next !== content };
}

/**
 * Déploie les règles avec Smart Merge Frontmatter :
 * Si une règle existe sans frontmatter YAML valide (trigger:), le frontmatter officiel
 * est injecté en tête de fichier tout en conservant 100% du contenu rédigé par le développeur.
 * Migre également toute table de routage legacy v2.0 (3.8-flash / invoke_subagent) dans PROJECT.md.
 * Supprime également l'ancien fichier obsolète rules.json.
 */
export function deployRulesWithSmartMerge(rulesDestDir, { dryRun = false, force = false } = {}) {
  const statusList = [];
  if (!dryRun) {
    fs.mkdirSync(rulesDestDir, { recursive: true });
    // Supprimer l'ancien rules.json s'il existe
    const obsoleteRulesJson = path.join(path.dirname(rulesDestDir), 'rules.json');
    if (fs.existsSync(obsoleteRulesJson)) {
      try { fs.rmSync(obsoleteRulesJson, { force: true }); } catch {}
    }
  }

  for (const rule of CANONICAL_RULES) {
    const targetPath = path.join(rulesDestDir, rule.target);
    const templatePath = path.join(RULES_TEMPLATES_DIR, rule.template);

    if (!fs.existsSync(templatePath)) continue;

    if (fs.existsSync(targetPath)) {
      if (force) {
        if (!dryRun) fs.copyFileSync(templatePath, targetPath);
        statusList.push({ file: rule.target, status: 'overwritten' });
        continue;
      }

      let existingContent = fs.readFileSync(targetPath, 'utf8');
      let migratedRouting = false;
      if (rule.target === 'PROJECT.md') {
        const mig = migrateLegacyModelRoutingInProjectRule(existingContent);
        if (mig.migrated) {
          existingContent = mig.content;
          migratedRouting = true;
        }
      }

      if (hasTriggerFrontmatter(existingContent)) {
        if (migratedRouting && !dryRun) {
          fs.writeFileSync(targetPath, existingContent, 'utf8');
        }
        statusList.push({ file: rule.target, status: migratedRouting ? 'migrated-v2.1' : 'preserved' });
      } else {
        // Smart Merge Frontmatter : injecter le frontmatter officiel en préservant le texte client
        const templateContent = fs.readFileSync(templatePath, 'utf8');
        const officialFm = extractFrontmatter(templateContent);
        const existingFm = extractFrontmatter(existingContent);
        const userBody = existingFm ? existingContent.slice(existingFm.length) : existingContent;
        const mergedContent = (officialFm ? officialFm.trimEnd() + '\n' : '') + userBody.trimStart();

        if (!dryRun) {
          fs.writeFileSync(targetPath, mergedContent, 'utf8');
        }
        statusList.push({ file: rule.target, status: 'merged-frontmatter' });
      }
    } else {
      if (!dryRun) {
        fs.copyFileSync(templatePath, targetPath);
      }
      statusList.push({ file: rule.target, status: 'created' });
    }
  }

  return statusList;
}

/**
 * Déploie .agents/hooks.json et les scripts sous .agents/hooks/scripts/ (avec chmod +x)
 */
export function deployHooks(agentsDir, { dryRun = false, force = false } = {}) {
  const statusList = [];
  const hooksJsonDest = path.join(agentsDir, 'hooks.json');
  const hooksScriptsDestDir = path.join(agentsDir, 'hooks', 'scripts');
  const hooksJsonSrc = path.join(HOOKS_SRC_DIR, 'hooks.json');

  if (!dryRun) {
    fs.mkdirSync(hooksScriptsDestDir, { recursive: true });
    if (fs.existsSync(hooksJsonSrc)) {
      fs.copyFileSync(hooksJsonSrc, hooksJsonDest);
      statusList.push({ file: 'hooks.json', status: 'installed' });
    }

    for (const script of CANONICAL_HOOK_SCRIPTS) {
      const src = path.join(HOOKS_SRC_DIR, 'scripts', script);
      const dest = path.join(hooksScriptsDestDir, script);
      if (fs.existsSync(src)) {
        fs.copyFileSync(src, dest);
        try { fs.chmodSync(dest, 0o755); } catch {}
        statusList.push({ file: `hooks/scripts/${script}`, status: 'installed' });
      }
    }
  } else {
    statusList.push({ file: 'hooks.json', status: 'dry-run' });
    for (const script of CANONICAL_HOOK_SCRIPTS) {
      statusList.push({ file: `hooks/scripts/${script}`, status: 'dry-run' });
    }
  }

  return statusList;
}

/**
 * Assemble et déploie le Plugin complet Antigravity dans un dossier cible (init --global)
 */
export function packageGlobalPlugin(targetDir, { dryRun = false, force = false } = {}) {
  const report = {
    targetDir,
    manifest: false,
    logo: false,
    skillsCount: 0,
    agentsCount: 0,
    rulesCount: 0,
    hooksInstalled: false
  };

  if (!dryRun) {
    fs.mkdirSync(targetDir, { recursive: true });
    fs.mkdirSync(path.join(targetDir, 'assets'), { recursive: true });
    fs.mkdirSync(path.join(targetDir, 'rules'), { recursive: true });
    fs.mkdirSync(path.join(targetDir, 'agents'), { recursive: true });
    fs.mkdirSync(path.join(targetDir, 'skills'), { recursive: true });
    fs.mkdirSync(path.join(targetDir, 'hooks', 'scripts'), { recursive: true });

    // 1. plugin.json (avec au plus 3 suggestedPrompts pour conformité strict mode)
    const pluginJsonSrc = path.join(PLUGIN_SRC_DIR, 'plugin.json');
    if (fs.existsSync(pluginJsonSrc)) {
      try {
        const manifest = JSON.parse(fs.readFileSync(pluginJsonSrc, 'utf8'));
        if (Array.isArray(manifest.suggestedPrompts) && manifest.suggestedPrompts.length > 3) {
          manifest.suggestedPrompts = manifest.suggestedPrompts.slice(0, 3);
        }
        fs.writeFileSync(path.join(targetDir, 'plugin.json'), JSON.stringify(manifest, null, 2) + '\n', 'utf8');
        report.manifest = true;
      } catch {
        fs.copyFileSync(pluginJsonSrc, path.join(targetDir, 'plugin.json'));
        report.manifest = true;
      }
    }

    // 2. assets/logo.svg
    const logoSrc = path.join(PLUGIN_SRC_DIR, 'assets', 'logo.svg');
    const fallbackLogo = path.join(FRAMEWORK_ROOT, 'logos', 'san_framework_icon.svg');
    const logoDest = path.join(targetDir, 'assets', 'logo.svg');
    if (fs.existsSync(logoSrc)) {
      fs.copyFileSync(logoSrc, logoDest);
      report.logo = true;
    } else if (fs.existsSync(fallbackLogo)) {
      fs.copyFileSync(fallbackLogo, logoDest);
      report.logo = true;
    }

    // 3. hooks.json + hooks/scripts/
    const hooksJsonSrc = path.join(HOOKS_SRC_DIR, 'hooks.json');
    if (fs.existsSync(hooksJsonSrc)) {
      fs.copyFileSync(hooksJsonSrc, path.join(targetDir, 'hooks.json'));
      report.hooksInstalled = true;
    }
    for (const script of CANONICAL_HOOK_SCRIPTS) {
      const sSrc = path.join(HOOKS_SRC_DIR, 'scripts', script);
      const sDest = path.join(targetDir, 'hooks', 'scripts', script);
      if (fs.existsSync(sSrc)) {
        fs.copyFileSync(sSrc, sDest);
        try { fs.chmodSync(sDest, 0o755); } catch {}
      }
    }

    // 4. agents/
    for (const agentFile of CANONICAL_AGENTS) {
      const aSrc = path.join(AGENTS_SRC_DIR, agentFile);
      const aDest = path.join(targetDir, 'agents', agentFile);
      if (fs.existsSync(aSrc)) {
        fs.copyFileSync(aSrc, aDest);
        report.agentsCount++;
      }
    }

    // 5. rules/ (avec frontmatters YAML officiels)
    for (const rule of CANONICAL_RULES) {
      const rSrc = path.join(RULES_TEMPLATES_DIR, rule.template);
      const rDest = path.join(targetDir, 'rules', rule.target);
      if (fs.existsSync(rSrc)) {
        fs.copyFileSync(rSrc, rDest);
        report.rulesCount++;
      }
    }

    // 6. skills/
    const allSkills = getAvailableSkills();
    deploySkills(path.join(targetDir, 'skills'), allSkills, { dryRun: false, force: true });
    report.skillsCount = allSkills.length;
  } else {
    report.manifest = true;
    report.logo = true;
    report.agentsCount = CANONICAL_AGENTS.length;
    report.rulesCount = CANONICAL_RULES.length;
    report.skillsCount = getAvailableSkills().length;
    report.hooksInstalled = true;
  }

  return report;
}

/**
 * Diagnostic de santé officiel (doctor) : contrôle les 6 piliers v2.1
 */
export function runDoctor(targetDirOrOptions = {}, maybeOptions = {}) {
  const options = normalizeTargetOptions(targetDirOrOptions, maybeOptions);
  const projectRoot = options.targetDir ? path.resolve(options.targetDir) : process.cwd();
  const agentsDir = path.join(projectRoot, '.agents');

  const report = {
    projectRoot,
    allPassed: false,
    pillars: {
      governance: { title: '1. Gouvernance souveraine (<root>/AGENTS.md)', passed: false, checks: [] },
      rules: { title: '2. Règles normatives (.agents/rules/*.md)', passed: false, checks: [] },
      agents: { title: '3. Sous-agents natifs (.agents/agents/*.md)', passed: false, checks: [] },
      hooks: { title: '4. Garde-fous mécaniques (.agents/hooks.json & scripts)', passed: false, checks: [] },
      skills: { title: '5. Catalogue des 18 skills (.agents/skills/ | skills.json <= 130 lignes)', passed: false, checks: [] },
      gitHygiene: { title: '6. Étanchéité Git (.gitignore ou .git/info/exclude)', passed: false, checks: [] }
    }
  };

  // Pilier 1 : Gouvernance souveraine (<root>/AGENTS.md)
  const agentsMdPath = path.join(projectRoot, 'AGENTS.md');
  if (!fs.existsSync(agentsMdPath)) {
    report.pillars.governance.checks.push({ ok: false, msg: 'Fichier AGENTS.md absent à la racine du projet' });
  } else {
    try {
      const content = fs.readFileSync(agentsMdPath, 'utf8');
      const size = Buffer.byteLength(content, 'utf8');
      const startsWithYaml = content.trimStart().startsWith('---');

      if (startsWithYaml) {
        report.pillars.governance.checks.push({ ok: false, msg: 'AGENTS.md ne doit PAS posséder de frontmatter YAML (always_on natif)' });
      } else {
        report.pillars.governance.checks.push({ ok: true, msg: 'AGENTS.md sans frontmatter YAML (always_on natif)' });
      }

      if (size >= 4096) {
        report.pillars.governance.checks.push({ ok: false, msg: `AGENTS.md taille excessive : ${size} octets (doit être < 4096 octets)` });
      } else {
        report.pillars.governance.checks.push({ ok: true, msg: `AGENTS.md taille compacte : ${size} octets (< 4096 octets)` });
      }
    } catch (e) {
      report.pillars.governance.checks.push({ ok: false, msg: `Erreur lecture AGENTS.md : ${e.message}` });
    }
  }
  report.pillars.governance.passed = report.pillars.governance.checks.length > 0 && report.pillars.governance.checks.every(c => c.ok);

  // Pilier 2 : Règles normatives (.agents/rules/*.md)
  const rulesDir = path.join(agentsDir, 'rules');
  const obsoleteRulesJson = path.join(agentsDir, 'rules.json');
  if (fs.existsSync(obsoleteRulesJson)) {
    report.pillars.rules.checks.push({ ok: false, msg: 'Fichier obsolète .agents/rules.json détecté (doit être supprimé)' });
  }

  const expectedRules = CANONICAL_RULES.map(r => r.target);
  if (!fs.existsSync(rulesDir)) {
    report.pillars.rules.checks.push({ ok: false, msg: 'Répertoire .agents/rules/ absent' });
  } else {
    for (const r of expectedRules) {
      const rPath = path.join(rulesDir, r);
      if (!fs.existsSync(rPath)) {
        report.pillars.rules.checks.push({ ok: false, msg: `Règle obligatoire manquante : ${r}` });
      } else {
        try {
          const content = fs.readFileSync(rPath, 'utf8');
          if (!hasTriggerFrontmatter(content)) {
            report.pillars.rules.checks.push({ ok: false, msg: `Règle ${r} sans frontmatter YAML valide (trigger:)` });
          } else if (
            r === 'PROJECT.md' &&
            (/ROUTAGE STRICT DES MOD[ÈE]LES ANTIGRAVITY\s*\(`?invoke_subagent`?\)/i.test(content) ||
              /Gemini 3\.8 Flash|gemini-3\.8-flash-high|gemini-3\.1-pro-high/i.test(content))
          ) {
            report.pillars.rules.checks.push({
              ok: false,
              msg: 'Règle PROJECT.md contient encore le routage legacy v2.0 (3.8-flash / invoke_subagent) — exécutez "san-framework update"'
            });
          } else {
            report.pillars.rules.checks.push({ ok: true, msg: `Règle ${r} avec frontmatter YAML valide (trigger:)` });
          }
        } catch (e) {
          report.pillars.rules.checks.push({ ok: false, msg: `Erreur lecture ${r} : ${e.message}` });
        }
      }
    }
  }
  report.pillars.rules.passed = report.pillars.rules.checks.length >= expectedRules.length && report.pillars.rules.checks.every(c => c.ok);

  // Pilier 3 : Sous-agents natifs (.agents/agents/*.md)
  const agentsSubDir = path.join(agentsDir, 'agents');
  const expectedAgents = CANONICAL_AGENTS;
  if (!fs.existsSync(agentsSubDir)) {
    report.pillars.agents.checks.push({ ok: false, msg: 'Répertoire .agents/agents/ absent' });
  } else {
    for (const a of expectedAgents) {
      const aPath = path.join(agentsSubDir, a);
      if (!fs.existsSync(aPath)) {
        report.pillars.agents.checks.push({ ok: false, msg: `Sous-agent manquant : ${a}` });
      } else {
        try {
          const content = fs.readFileSync(aPath, 'utf8');
          if (!content.trimStart().startsWith('---') || !content.includes('name:')) {
            report.pillars.agents.checks.push({ ok: false, msg: `Sous-agent ${a} invalide (frontmatter YAML manquant)` });
          } else if (
            /gemini-3\.8-flash-high|gemini-3\.1-pro-high/i.test(content) ||
            !content.includes('gemini-4-hydrogen-xhigh')
          ) {
            report.pillars.agents.checks.push({
              ok: false,
              msg: `Sous-agent ${a} en version v2.0 obsolète (manque gemini-4-hydrogen-xhigh) — exécutez "san-framework update"`
            });
          } else {
            report.pillars.agents.checks.push({ ok: true, msg: `Sous-agent ${a} présent et valide (v2.1 Hydrogen XHigh)` });
          }
        } catch (e) {
          report.pillars.agents.checks.push({ ok: false, msg: `Erreur lecture ${a} : ${e.message}` });
        }
      }
    }
  }
  report.pillars.agents.passed = report.pillars.agents.checks.length >= expectedAgents.length && report.pillars.agents.checks.every(c => c.ok);

  // Pilier 4 : Garde-fous mécaniques (.agents/hooks.json & scripts)
  const hooksJsonPath = path.join(agentsDir, 'hooks.json');
  const hooksScriptsDir = path.join(agentsDir, 'hooks', 'scripts');
  if (!fs.existsSync(hooksJsonPath)) {
    report.pillars.hooks.checks.push({ ok: false, msg: 'Fichier .agents/hooks.json absent' });
  } else {
    try {
      JSON.parse(fs.readFileSync(hooksJsonPath, 'utf8'));
      report.pillars.hooks.checks.push({ ok: true, msg: '.agents/hooks.json présent et syntaxiquement valide' });
    } catch (e) {
      report.pillars.hooks.checks.push({ ok: false, msg: `.agents/hooks.json JSON invalide : ${e.message}` });
    }
  }

  const expectedScripts = CANONICAL_HOOK_SCRIPTS;
  for (const s of expectedScripts) {
    const sPath = path.join(hooksScriptsDir, s);
    if (!fs.existsSync(sPath)) {
      report.pillars.hooks.checks.push({ ok: false, msg: `Script de hook manquant : ${s}` });
    } else {
      let isExec = false;
      try {
        const stats = fs.statSync(sPath);
        isExec = (stats.mode & 0o111) !== 0;
      } catch {}
      if (!isExec) {
        report.pillars.hooks.checks.push({ ok: false, msg: `Script ${s} non exécutable (chmod +x requis)` });
      } else {
        report.pillars.hooks.checks.push({ ok: true, msg: `Script ${s} présent et exécutable` });
      }
    }
  }
  report.pillars.hooks.passed = report.pillars.hooks.checks.length >= (1 + expectedScripts.length) && report.pillars.hooks.checks.every(c => c.ok);

  // Pilier 5 : Catalogue des 18 skills (.agents/skills/ ou .agents/skills.json <= 130 lignes)
  const skillsSubDir = path.join(agentsDir, 'skills');
  const skillsJsonPath = path.join(agentsDir, 'skills.json');
  const expectedSkills = getAvailableSkills();

  const validateSkillInDir = (baseDir, skillName, sourceLabel) => {
    const skMd = path.join(baseDir, skillName, 'SKILL.md');
    if (!fs.existsSync(skMd)) {
      return { ok: false, msg: `Skill manquant ou sans SKILL.md (${sourceLabel}) : ${skillName}` };
    }
    try {
      const content = fs.readFileSync(skMd, 'utf8');
      const lineCount = content.split('\n').length;
      if (lineCount > 130) {
        return { ok: false, msg: `Skill ${skillName}/SKILL.md trop long : ${lineCount} lignes (max: 130)` };
      }
      return { ok: true, msg: `Skill ${skillName} valide (${lineCount} lignes <= 130 via ${sourceLabel})` };
    } catch (e) {
      return { ok: false, msg: `Erreur lecture ${skillName} : ${e.message}` };
    }
  };

  if (fs.existsSync(skillsJsonPath)) {
    try {
      const parsed = JSON.parse(fs.readFileSync(skillsJsonPath, 'utf8'));
      const rawInherits = Array.isArray(parsed?.inherits) ? parsed.inherits : [];
      if (rawInherits.length === 0) {
        report.pillars.skills.checks.push({ ok: false, msg: '.agents/skills.json ne déclare aucun chemin dans "inherits"' });
      } else {
        const validInheritedDirs = [];
        for (const entry of rawInherits) {
          const rawPath = typeof entry === 'string' ? entry : entry?.path;
          if (!rawPath || typeof rawPath !== 'string') {
            report.pillars.skills.checks.push({ ok: false, msg: 'Entrée "inherits" invalide dans .agents/skills.json' });
            continue;
          }
          const expanded = rawPath.startsWith('~/')
            ? path.join(os.homedir(), rawPath.slice(2))
            : rawPath;
          const resolvedDir = path.isAbsolute(expanded)
            ? expanded
            : path.resolve(projectRoot, expanded);
          if (!fs.existsSync(resolvedDir)) {
            report.pillars.skills.checks.push({ ok: false, msg: `Chemin hérité introuvable dans .agents/skills.json : ${resolvedDir}` });
          } else {
            validInheritedDirs.push(resolvedDir);
            report.pillars.skills.checks.push({ ok: true, msg: `Mode léger (.agents/skills.json) : héritage valide depuis ${resolvedDir}` });
          }
        }

        if (validInheritedDirs.length > 0) {
          for (const sk of expectedSkills) {
            let foundDir = null;
            if (fs.existsSync(path.join(skillsSubDir, sk, 'SKILL.md'))) {
              foundDir = skillsSubDir;
            } else {
              for (const inhDir of validInheritedDirs) {
                if (fs.existsSync(path.join(inhDir, sk, 'SKILL.md'))) {
                  foundDir = inhDir;
                  break;
                }
              }
            }
            if (!foundDir) {
              report.pillars.skills.checks.push({ ok: false, msg: `Skill manquant dans les chemins hérités (.agents/skills.json) : ${sk}` });
            } else {
              report.pillars.skills.checks.push(validateSkillInDir(foundDir, sk, foundDir === skillsSubDir ? '.agents/skills' : 'inherits'));
            }
          }
        }
      }
    } catch (e) {
      report.pillars.skills.checks.push({ ok: false, msg: `.agents/skills.json JSON invalide : ${e.message}` });
    }
  } else if (!fs.existsSync(skillsSubDir)) {
    report.pillars.skills.checks.push({ ok: false, msg: 'Répertoire .agents/skills/ (et .agents/skills.json) absent' });
  } else {
    for (const sk of expectedSkills) {
      report.pillars.skills.checks.push(validateSkillInDir(skillsSubDir, sk, '.agents/skills'));
    }
  }
  report.pillars.skills.passed = report.pillars.skills.checks.length >= expectedSkills.length && report.pillars.skills.checks.every(c => c.ok);

  // Pilier 6 : Étanchéité Git (.gitignore ou .git/info/exclude)
  const gitignorePath = path.join(projectRoot, '.gitignore');
  let excludePath = null;
  try {
    const p = execSync('git rev-parse --git-path info/exclude', { cwd: projectRoot, stdio: ['ignore', 'pipe', 'ignore'], encoding: 'utf8' }).trim();
    excludePath = path.isAbsolute(p) ? p : path.join(projectRoot, p);
  } catch {
    excludePath = path.join(projectRoot, '.git', 'info', 'exclude');
  }

  let gitignoreHasAgents = false;
  if (fs.existsSync(gitignorePath)) {
    const c = fs.readFileSync(gitignorePath, 'utf8');
    if (c.includes('/.agents/') || c.includes('.agents/') || c.includes('.agents')) {
      gitignoreHasAgents = true;
    }
  }

  let excludeHasAgents = false;
  if (fs.existsSync(excludePath)) {
    const c = fs.readFileSync(excludePath, 'utf8');
    if (c.includes('/.agents/') || c.includes('.agents/') || c.includes('.agents')) {
      excludeHasAgents = true;
    }
  }

  if (gitignoreHasAgents || excludeHasAgents) {
    report.pillars.gitHygiene.checks.push({
      ok: true,
      msg: `Isolation Git active (${gitignoreHasAgents ? '.gitignore' : ''}${gitignoreHasAgents && excludeHasAgents ? ' & ' : ''}${excludeHasAgents ? '.git/info/exclude' : ''})`
    });
    report.pillars.gitHygiene.passed = true;
  } else {
    report.pillars.gitHygiene.checks.push({
      ok: false,
      msg: "Ni .gitignore ni .git/info/exclude ne contient d'isolation hermétique pour /.agents/"
    });
    report.pillars.gitHygiene.passed = false;
  }

  report.allPassed = Object.values(report.pillars).every(p => p.passed);
  return report;
}

/**
 * Affiche le bilan du diagnostic doctor dans la console
 */
export function printDoctorReport(report) {
  const version = getFrameworkVersion();
  console.log('');
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.brightCyan}  DIAGNOSTIC DE SANTÉ DU FRAMEWORK ANTIGRAVITY v${version} (DOCTOR)${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`  ${colors.bold}Cible${colors.reset}   : ${report.projectRoot}`);
  console.log(`  ${colors.bold}Verdict${colors.reset} : ${report.allPassed ? `${colors.green}${colors.bold}CONFORME (6/6 PILIERS AU VERT)${colors.reset}` : `${colors.red}${colors.bold}NON CONFORME (DÉFAUTS DÉTECTÉS)${colors.reset}`}`);
  console.log('');

  for (const [, pillar] of Object.entries(report.pillars)) {
    const icon = pillar.passed ? `${colors.green}✔${colors.reset}` : `${colors.red}✘${colors.reset}`;
    const titleColor = pillar.passed ? colors.green : colors.red;
    console.log(`  ${icon} ${titleColor}${colors.bold}${pillar.title}${colors.reset}`);
    for (const chk of pillar.checks) {
      if (!chk.ok) {
        console.log(`     ${colors.red}↳ ✘ ${chk.msg}${colors.reset}`);
      }
    }
  }

  console.log('');
  if (report.allPassed) {
    console.log(`${colors.brightGreen}${colors.bold}✔ Félicitations ! Votre environnement respecte à 100% l'architecture souveraine v${version}.${colors.reset}`);
  } else {
    console.log(`${colors.brightYellow}ℹ Conseil : Exécutez "san-framework update" ou "san-framework init --local --all" pour réparer automatiquement les piliers défaillants.${colors.reset}`);
  }
  console.log(`${colors.cyan}============================================================${colors.reset}\n`);
}

/**
 * Moteur de la commande `update` : migration & mise à jour non destructive vers v2.1
 */
export async function updateFramework(targetDirOrOptions = {}, maybeOptions = {}) {
  const options = normalizeTargetOptions(targetDirOrOptions, maybeOptions);
  const dryRun = Boolean(options.dryRun);
  const force = Boolean(options.force);
  const light = Boolean(options.light);
  const currentVersion = getFrameworkVersion();
  const projectRoot = options.targetDir ? path.resolve(options.targetDir) : process.cwd();

  const agentsDir = path.join(projectRoot, '.agents');
  const skillsDestDir = path.join(agentsDir, 'skills');
  const agentsDestDir = path.join(agentsDir, 'agents');
  const rulesDestDir = path.join(agentsDir, 'rules');
  const geminiMdDest = path.join(agentsDir, 'GEMINI.md');

  const availableSkills = getAvailableSkills();
  const selectedSkills = resolveSkillList(options.skills, availableSkills);

  // 1. Déploiement / Resynchronisation des skills (Couche 1 : standard ou --light)
  let skillsInstalled = [];
  let lightSkillsConfig = null;
  if (light) {
    lightSkillsConfig = deploySkillsLight(agentsDir, { dryRun });
    skillsInstalled = selectedSkills;
  } else {
    skillsInstalled = deploySkills(skillsDestDir, selectedSkills, { dryRun, force });
  }

  // 2. Déploiement des 8 sous-agents natifs (Couche 2 : toujours resynchronisés lors d'un update)
  const agentsStatus = deployAgents(agentsDestDir, { dryRun, force: true });

  // 3. Déploiement des règles avec Smart Merge Frontmatter & migration routage v2.1 (Couche 3)
  const rulesStatus = deployRulesWithSmartMerge(rulesDestDir, { dryRun, force });

  // 4. Déploiement des hooks mécaniques (Couche 4)
  const hooksStatus = deployHooks(agentsDir, { dryRun, force });

  // 5. Index maître GEMINI.md
  let geminiStatus = 'preserved';
  const geminiTemplate = path.join(TEMPLATES_DIR, 'GEMINI_INDEX_TEMPLATE.md');
  if (!fs.existsSync(geminiMdDest) || force) {
    if (!dryRun && fs.existsSync(geminiTemplate)) {
      fs.copyFileSync(geminiTemplate, geminiMdDest);
    }
    geminiStatus = fs.existsSync(geminiMdDest) ? 'updated' : 'created';
  } else if (!dryRun && fs.existsSync(geminiMdDest)) {
    try {
      const existingGemini = fs.readFileSync(geminiMdDest, 'utf8');
      const migratedGemini = existingGemini
        .replace(/routage des mod[èe]les LLM\s*\(`?flash`?\s*vs\s*`?inherit`?\)/gi, 'routage Swarm autonome (`Argon` -> `gemini-4-hydrogen-xhigh`)')
        .replace(/via\s+`?\.agents\/rules\.json`?/gi, 'via `.agents/cache/REPO_MAP.md` (Map-First)');
      if (migratedGemini !== existingGemini) {
        fs.writeFileSync(geminiMdDest, migratedGemini, 'utf8');
        geminiStatus = 'migrated-v2.1';
      }
    } catch {}
  }

  // 6. Gouvernance souveraine AGENTS.md racine
  const agentsContext = generateAgentsContext(projectRoot, {
    skills: selectedSkills,
    dryRun,
    force
  });

  // 7. opencode.json si existant ou si flag --opencode
  const hasOpencodeConfig = fs.existsSync(path.join(projectRoot, 'opencode.json'));
  let opencodeMerge = null;
  if (hasOpencodeConfig || options.opencode) {
    opencodeMerge = mergeOpencodeConfig(projectRoot, { dryRun });
  }

  // 8. Hygiène Git réversible
  const hygiene = executeGitHygiene(projectRoot, {
    dryRun,
    preserveOpencode: Boolean(options.opencode || hasOpencodeConfig)
  });

  // 9. Initialisation / Resynchronisation du cache cartographique & What's New (.agents/cache/)
  let whatsNewPending = null;
  if (!dryRun) {
    const cacheDir = path.join(agentsDir, 'cache');
    try { fs.mkdirSync(cacheDir, { recursive: true }); } catch {}

    const localMapperScript = path.join(skillsDestDir, 'san_cartographer', 'scripts', 'repo_mapper.mjs');
    const srcMapperScript = path.join(SKILLS_SRC_DIR, 'san_cartographer', 'scripts', 'repo_mapper.mjs');
    const mapperScript = fs.existsSync(localMapperScript)
      ? localMapperScript
      : (fs.existsSync(srcMapperScript) ? srcMapperScript : null);

    if (mapperScript) {
      try {
        execSync(`node "${mapperScript}" --root "${projectRoot}"`, {
          cwd: projectRoot,
          stdio: ['ignore', 'ignore', 'ignore']
        });
      } catch {}
    }

    whatsNewPending = writeWhatsNewPendingCache(agentsDir, { dryRun: false, version: currentVersion });
  } else {
    whatsNewPending = writeWhatsNewPendingCache(agentsDir, { dryRun: true, version: currentVersion });
  }

  // Bilan récapitulatif
  console.log('');
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.brightCyan}  MIGRATION & MISE À JOUR v${currentVersion} — FRAMEWORK ANTIGRAVITY${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`  ${colors.bold}Projet${colors.reset}        : ${projectRoot}`);
  const hasAgents = fs.existsSync(agentsDir);
  console.log(`  ${colors.bold}Déploiement${colors.reset}   : ${hasAgents ? `${colors.green}Détecté (.agents/)${colors.reset}` : `${colors.yellow}Absent (aucun .agents/)${colors.reset}`}`);
  if (light) {
    console.log(`  ${colors.bold}Skills (--light)${colors.reset}: .agents/skills.json (héritage -> ${SKILLS_SRC_DIR})`);
  } else {
    console.log(`  ${colors.bold}Skills resync${colors.reset} : ${skillsInstalled.length}/${availableSkills.length}`);
  }
  console.log(`  ${colors.bold}Sous-agents${colors.reset}   : ${agentsStatus.length} installés (.agents/agents/)`);
  console.log(`  ${colors.bold}Hooks natifs${colors.reset}  : ${hooksStatus.length} fichiers (.agents/hooks.json & scripts/)`);
  if (dryRun) {
    console.log(`  ${colors.yellow}${colors.bold}[DRY-RUN]${colors.reset} Mode simulation actif — aucun octet écrit.`);
  }

  console.log('');
  console.log(`${colors.bold}🛡️ Smart Merge Frontmatter (Règles normatives) :${colors.reset}`);
  for (const r of rulesStatus) {
    const badge = r.status === 'merged-frontmatter'
      ? `${colors.green}[MERGED FRONTMATTER]${colors.reset} (Frontmatter officiel injecté, texte client 100% préservé)`
      : r.status === 'preserved'
        ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Règle avec frontmatter valide conservée)`
        : `${colors.green}[CRÉÉ]${colors.reset} (Instancié depuis gabarit v${currentVersion})`;
    console.log(`  • ${r.file.padEnd(14)} : ${badge}`);
  }

  console.log('');
  console.log(`${colors.bold}📜 Gouvernance & Constitution racine :${colors.reset}`);
  console.log(`  • ${'AGENTS.md'.padEnd(14)} : ${agentsContext.status === 'preserved' ? `${colors.yellow}[PRÉSERVÉ]${colors.reset}` : `${colors.green}[SYNCHRONISÉ]${colors.reset}`}`);
  console.log(`  • ${'GEMINI.md'.padEnd(14)} : ${geminiStatus === 'preserved' ? `${colors.yellow}[PRÉSERVÉ]${colors.reset}` : `${colors.green}[SYNCHRONISÉ]${colors.reset}`}`);

  if (hygiene.backupDir) {
    console.log('');
    console.log(`${colors.bold}📦 Hygiène réversible :${colors.reset}`);
    console.log(`  ${colors.green}✔${colors.reset} Anciennes configurations sauvegardées dans : ${hygiene.backupDir}`);
  }

  console.log('');
  console.log(formatWhatsNewTerminal(currentVersion));

  console.log('');
  console.log(`${colors.brightCyan}✔ Codebase migrée en v${currentVersion}. Tapez "san-framework doctor" pour valider l'intégrité.${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}\n`);

  return {
    success: true,
    version: currentVersion,
    light,
    lightSkillsConfig,
    whatsNewPending,
    projectRoot,
    skillsInstalled,
    agentsStatus,
    rulesStatus,
    hooksStatus,
    agentsContext,
    opencodeMerge,
    hygiene
  };
}

/**
 * Moteur principal d'installation du framework Antigravity (init)
 */
export async function installFramework(options = {}) {
  const targetMode = options.targetMode || 'local';
  const dryRun = Boolean(options.dryRun);
  const force = Boolean(options.force);
  const opencode = Boolean(options.opencode);
  const light = Boolean(options.light);
  const currentVersion = getFrameworkVersion();

  const availableSkills = getAvailableSkills();
  const selectedSkills = resolveSkillList(options.skills, availableSkills);

  if (targetMode === 'global') {
    const targetDirs = [];
    if (options.targetDir) {
      targetDirs.push(path.resolve(options.targetDir));
    } else {
      const defaultCliPlugin = path.join(os.homedir(), '.gemini', 'antigravity-cli', 'plugins', 'san-framework');
      targetDirs.push(defaultCliPlugin);

      const geminiConfigDir = path.join(os.homedir(), '.gemini', 'config');
      if (fs.existsSync(geminiConfigDir)) {
        targetDirs.push(path.join(geminiConfigDir, 'plugins', 'san-framework'));
      }
    }

    const pluginReports = [];
    for (const pDir of targetDirs) {
      const r = packageGlobalPlugin(pDir, { dryRun, force });
      pluginReports.push(r);
    }

    console.log('');
    console.log(`${colors.cyan}============================================================${colors.reset}`);
    console.log(`${colors.bold}${colors.brightCyan}  PACKAGING PLUGIN GLOBAL DU FRAMEWORK ANTIGRAVITY (v${currentVersion})${colors.reset}`);
    console.log(`${colors.cyan}============================================================${colors.reset}`);
    for (const r of pluginReports) {
      console.log(`  ${colors.green}✔${colors.reset} Plugin assemblé dans : ${r.targetDir}`);
      console.log(`    ↳ Manifeste  : plugin.json (avec assets/logo.svg)`);
      console.log(`    ↳ Sous-agents: ${r.agentsCount} agents natifs (.md)`);
      console.log(`    ↳ Skills     : ${r.skillsCount} skills canoniques`);
      console.log(`    ↳ Règles     : ${r.rulesCount} règles avec frontmatter YAML`);
      console.log(`    ↳ Hooks      : hooks.json + ${CANONICAL_HOOK_SCRIPTS.length} scripts exécutables`);
    }
    if (dryRun) {
      console.log(`\n  ${colors.yellow}${colors.bold}[DRY-RUN]${colors.reset} Mode simulation actif.`);
    }
    console.log(`${colors.cyan}============================================================${colors.reset}\n`);

    return {
      success: true,
      targetMode: 'global',
      pluginReports
    };
  }

  // Mode Local (.agents/)
  const projectRoot = options.targetDir ? path.resolve(options.targetDir) : process.cwd();
  const agentsDir = path.join(projectRoot, '.agents');
  const skillsDestDir = path.join(agentsDir, 'skills');
  const agentsDestDir = path.join(agentsDir, 'agents');
  const rulesDestDir = path.join(agentsDir, 'rules');
  const geminiMdDest = path.join(agentsDir, 'GEMINI.md');

  // 1. Couche 1 : Skills (standard ou mode léger --light via .agents/skills.json)
  let installedSkills = [];
  let lightSkillsConfig = null;
  if (light) {
    lightSkillsConfig = deploySkillsLight(agentsDir, { dryRun });
    installedSkills = selectedSkills;
  } else {
    installedSkills = deploySkills(skillsDestDir, selectedSkills, { dryRun, force });
  }

  // 2. Couche 2 : Sous-agents natifs (8 agents)
  const agentsStatus = deployAgents(agentsDestDir, { dryRun, force });

  // 3. Couche 3 : Règles normatives avec Smart Merge Frontmatter (5 règles)
  const rulesStatus = deployRulesWithSmartMerge(rulesDestDir, { dryRun, force });

  // 4. Couche 4 : Garde-fous mécaniques (hooks.json + scripts)
  const hooksStatus = deployHooks(agentsDir, { dryRun, force });

  // 5. Index maître GEMINI.md
  let geminiStatus = 'preserved';
  const geminiTemplate = path.join(TEMPLATES_DIR, 'GEMINI_INDEX_TEMPLATE.md');
  if (fs.existsSync(geminiMdDest) && !force) {
    geminiStatus = 'preserved';
  } else if (fs.existsSync(geminiTemplate)) {
    if (!dryRun) {
      fs.copyFileSync(geminiTemplate, geminiMdDest);
    }
    geminiStatus = 'created';
  }

  // 6. Gouvernance souveraine AGENTS.md racine
  const agentsContext = generateAgentsContext(projectRoot, {
    skills: selectedSkills,
    dryRun,
    force
  });

  // 7. Hygiène Git réversible
  const hygiene = executeGitHygiene(projectRoot, { dryRun, preserveOpencode: opencode });

  // 8. Couche opencode optionnelle
  const opencodeContext = opencode
    ? [agentsContext, mergeOpencodeConfig(projectRoot, { dryRun })].filter(Boolean)
    : [];

  // 9. Initialisation du cache cartographique (.agents/cache/)
  if (!dryRun) {
    const cacheDir = path.join(agentsDir, 'cache');
    try { fs.mkdirSync(cacheDir, { recursive: true }); } catch {}

    const localMapperScript = path.join(skillsDestDir, 'san_cartographer', 'scripts', 'repo_mapper.mjs');
    const srcMapperScript = path.join(SKILLS_SRC_DIR, 'san_cartographer', 'scripts', 'repo_mapper.mjs');
    const mapperScript = fs.existsSync(localMapperScript)
      ? localMapperScript
      : (fs.existsSync(srcMapperScript) ? srcMapperScript : null);

    if (mapperScript) {
      try {
        execSync(`node "${mapperScript}" --root "${projectRoot}"`, {
          cwd: projectRoot,
          stdio: ['ignore', 'ignore', 'ignore']
        });
      } catch {}
    }
  }

  // Bilan récapitulatif
  console.log('');
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.brightCyan}  INSTALLATION DU FRAMEWORK ANTIGRAVITY (san_*) RÉUSSIE !${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`  ${colors.bold}Mode${colors.reset}        : ${light ? 'Local léger (.agents/ + skills.json inherits)' : 'Local (.agents/)'}`);
  console.log(`  ${colors.bold}Destination${colors.reset} : ${agentsDir}`);
  console.log(`  ${colors.bold}Couche 1${colors.reset}    : ${light ? `${installedSkills.length}/${availableSkills.length} skills hérités (.agents/skills.json)` : `${installedSkills.length}/${availableSkills.length} skills configurés (.agents/skills/)`}`);
  console.log(`  ${colors.bold}Couche 2${colors.reset}    : ${agentsStatus.length} sous-agents déployés (.agents/agents/)`);
  console.log(`  ${colors.bold}Couche 3${colors.reset}    : ${rulesStatus.length} règles normatives YAML (.agents/rules/)`);
  console.log(`  ${colors.bold}Couche 4${colors.reset}    : ${hooksStatus.length} fichiers de cycle de vie (.agents/hooks.json & scripts/)`);
  if (dryRun) {
    console.log(`  ${colors.yellow}${colors.bold}[DRY-RUN]${colors.reset} Mode simulation actif — aucun octet écrit sur le disque.`);
  }

  console.log('');
  if (light) {
    console.log(`${colors.bold}📦 Skills hérités via .agents/skills.json (${installedSkills.length}) :${colors.reset}`);
    console.log(`  ${colors.green}✔${colors.reset} inherits -> ${colors.cyan}${SKILLS_SRC_DIR}${colors.reset}`);
  } else {
    console.log(`${colors.bold}📦 Skills installés (${installedSkills.length}) :${colors.reset}`);
    for (const s of installedSkills) {
      console.log(`  ${colors.green}✔${colors.reset} ${colors.cyan}${s}${colors.reset}`);
    }
  }

  console.log('');
  console.log(`${colors.bold}🛡️ Smart Merge Frontmatter (Règles normatives & Table de routage) :${colors.reset}`);
  for (const r of rulesStatus) {
    const badge = r.status === 'preserved'
      ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Fichier existant avec frontmatter valide conservé)`
      : r.status === 'merged-frontmatter'
        ? `${colors.green}[MERGED FRONTMATTER]${colors.reset} (Frontmatter officiel injecté, texte client 100% préservé)`
        : `${colors.green}[CRÉÉ]${colors.reset} (Instancié depuis gabarit officiel)`;
    console.log(`  • ${r.file.padEnd(14)} : ${badge}`);
  }
  const geminiBadge = geminiStatus === 'preserved'
    ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Index maître existant)`
    : `${colors.green}[CRÉÉ]${colors.reset} (Index maître .agents/GEMINI.md déployé)`;
  console.log(`  • ${'GEMINI.md'.padEnd(14)} : ${geminiBadge}`);

  if (agentsContext) {
    const agentsBadge = agentsContext.status === 'preserved'
      ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Index souverain AGENTS.md scrupuleusement conservé)`
      : `${colors.green}[CRÉÉ]${colors.reset} (Index souverain AGENTS.md déployé à la racine)`;
    console.log(`  • ${'AGENTS.md'.padEnd(14)} : ${agentsBadge}`);
  }

  console.log('');
  console.log(`${colors.bold}🧹 Hygiène & Isolation Git Réversible :${colors.reset}`);
  if (hygiene.isGit) {
    if (hygiene.backupDir) {
      console.log(`  ${colors.green}✔${colors.reset} Anciennes configurations sauvegardées dans : ${hygiene.backupDir}`);
    }
    if (hygiene.purgedFiles.length > 0 || hygiene.purgedDirs.length > 0) {
      console.log(`  ${colors.green}✔${colors.reset} Résidus tiers archivés : ${[...hygiene.purgedFiles, ...hygiene.purgedDirs].join(', ')}`);
    } else {
      console.log(`  ${colors.green}✔${colors.reset} Aucun résidu tiers détecté sur le disque`);
    }
    console.log(`  ${colors.green}✔${colors.reset} Cache Git désindexé pour .agents/ et résidus`);
    console.log(`  ${colors.green}✔${colors.reset} Isolation hermétique vérifiée (.gitignore & .git/info/exclude)`);
  } else {
    if (hygiene.backupDir) {
      console.log(`  ${colors.green}✔${colors.reset} Anciennes configurations sauvegardées dans : ${hygiene.backupDir}`);
    }
    if (hygiene.purgedFiles.length > 0 || hygiene.purgedDirs.length > 0) {
      console.log(`  ${colors.green}✔${colors.reset} Résidus tiers archivés : ${[...hygiene.purgedFiles, ...hygiene.purgedDirs].join(', ')}`);
    }
    console.log(`  ${colors.green}✔${colors.reset} Isolation hermétique appliquée (.gitignore configuré)`);
  }

  console.log('');
  console.log(`${colors.bold}🚀 Prochaines étapes recommandées :${colors.reset}`);
  console.log(`  ${colors.brightCyan}1.${colors.reset} ${colors.bold}san-framework doctor${colors.reset}   : Contrôler les 6 piliers de santé v${currentVersion}`);
  console.log(`  ${colors.brightCyan}2.${colors.reset} ${colors.bold}san_init${colors.reset}               : Initialiser et cadrer chirurgicalement le projet`);
  console.log(`  ${colors.brightCyan}3.${colors.reset} ${colors.bold}san_brainstorming${colors.reset}      : Cadrer les idées produit et valider la proposition de valeur`);
  console.log(`  ${colors.brightCyan}4.${colors.reset} ${colors.bold}san_planner${colors.reset}            : Planifier les phases d'ingénierie et roadmaps d'exécution`);
  console.log(`${colors.cyan}============================================================${colors.reset}\n`);

  return {
    success: true,
    version: currentVersion,
    light,
    lightSkillsConfig,
    targetMode,
    targetDir: agentsDir,
    installedSkills,
    agentsStatus,
    rulesStatus,
    hooksStatus,
    geminiStatus,
    agentsContext,
    hygiene,
    opencodeContext
  };
}

/**
 * Alias programmatique compatible (targetDir, options) pour installFramework.
 */
export async function initProject(targetDir, options = {}) {
  return installFramework({ ...(options || {}), targetDir });
}
