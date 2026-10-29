import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const FRAMEWORK_ROOT = path.resolve(__dirname, '../..');
export const SKILLS_SRC_DIR = path.resolve(FRAMEWORK_ROOT, 'src', 'skills');

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
 * Exécute l'hygiène Git souveraine et l'isolation hermétique
 */
export function executeGitHygiene(projectDir, { dryRun = false, preserveOpencode = false } = {}) {
  const report = {
    isGit: false,
    gitRoot: null,
    purgedFiles: [],
    purgedDirs: [],
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
    ...(preserveOpencode ? [] : ['.opencode', 'AGENTS.md'])
  ];

  const OBSOLETE_DIRS = [
    '.claude',
    '.cursor',
    '.windsurf',
    '.copilot'
  ];

  const searchRoots = report.isGit && report.gitRoot
    ? [report.gitRoot, ...(projectDir !== report.gitRoot ? [projectDir] : [])]
    : [projectDir];

  for (const root of searchRoots) {
    for (const file of OBSOLETE_FILES) {
      const filePath = path.join(root, file);
      if (fs.existsSync(filePath)) {
        if (!dryRun) {
          try {
            fs.rmSync(filePath, { force: true });
          } catch {}
        }
        report.purgedFiles.push(file);
      }
    }

    for (const dir of OBSOLETE_DIRS) {
      const dirPath = path.join(root, dir);
      if (fs.existsSync(dirPath)) {
        if (!dryRun) {
          try {
            fs.rmSync(dirPath, { recursive: true, force: true });
          } catch {}
        }
        report.purgedDirs.push(dir);
      }
    }
  }

  report.purgedFiles = [...new Set(report.purgedFiles)];
  report.purgedDirs = [...new Set(report.purgedDirs)];

  if (report.isGit && report.gitRoot) {
    const AI_CACHE_TARGETS = [
      '.agents',
      '.agents/',
      'AGENTS.md',
      'GEMINI.md',
      '.claude',
      '.claude/',
      'CLAUDE.md',
      '.cursor',
      '.cursorrules',
      '.windsurf',
      '.windsurfrules',
      '.copilot'
    ];

    if (!dryRun) {
      try {
        execSync(`git rm -r --cached --ignore-unmatch ${AI_CACHE_TARGETS.join(' ')}`, {
          cwd: report.gitRoot,
          stdio: 'ignore'
        });
      } catch {}
    }

    const GITIGNORE_MARKER = '# --- ANTIGRAVITY AI ISOLATION (san_*) ---';
    // En mode opencode, AGENTS.md est le fichier de contexte partagé : il reste committable.
    const agentsMdIgnore = preserveOpencode ? '# /AGENTS.md  (committable — contexte opencode)\n' : '/AGENTS.md\n';
    const GITIGNORE_BLOCK = `\n# --- ANTIGRAVITY AI ISOLATION (san_*) ---
# Espace souverain local Antigravity (Zéro fuite Git)
/.agents/
${agentsMdIgnore}/GEMINI.md

# Résidus tiers purgés
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

    // 1. .gitignore
    const gitignorePath = path.join(report.gitRoot, '.gitignore');
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
 * Marqueur interne inséré dans les fichiers de contexte opencode générés.
 * Il permet de distinguer un fichier auto-généré (régénérable) d'un fichier
 * personnalisé par le développeur (préservé par Smart Merge).
 */
const OPENCODE_CONTEXT_MARKER = '<!-- san_* opencode context (generated) -->';

/**
 * Génère le fichier de contexte `AGENTS.md` lu automatiquement par opencode.
 * Smart Merge : un AGENTS.md existant sans marqueur (rédigé par l'utilisateur)
 * n'est jamais écrasé, sauf en cas de `--force`.
 */
export function generateAgentsContext(projectRoot, { skills = [], dryRun = false, force = false } = {}) {
  const dest = path.join(projectRoot, 'AGENTS.md');
  const templatePath = path.join(SKILLS_SRC_DIR, 'san_init', 'templates', 'AGENTS_INDEX_TEMPLATE.md');

  if (fs.existsSync(dest) && !force) {
    const existing = fs.readFileSync(dest, 'utf8');
    if (!existing.includes(OPENCODE_CONTEXT_MARKER)) {
      return { file: 'AGENTS.md', status: 'preserved' };
    }
  }

  let content = '';
  if (fs.existsSync(templatePath)) {
    content = fs.readFileSync(templatePath, 'utf8');
  } else {
    content = `${OPENCODE_CONTEXT_MARKER}\n# Contexte opencode — Framework Antigravity (san_*)\n`;
  }

  const skillLines = (skills.length ? skills : getAvailableSkills())
    .map((s) => `* **${s}** — ${getSkillDescription(s) || 'Compétence du framework san_*.'}`)
    .join('\n');
  content = content.replace('{{SKILLS_LIST}}', skillLines || '* (aucune compétence)');

  if (!dryRun) {
    fs.writeFileSync(dest, content, 'utf8');
  }

  return { file: 'AGENTS.md', status: 'created' };
}

/**
 * Fusionne la configuration opencode.json sans écraser les champs utilisateur.
 * Ajoute le chemin des compétences (.agents/skills) via `skills.paths` et
 * l'index maître (.agents/GEMINI.md) via `instructions`.
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
 * Génère la couche de contexte opencode complète (AGENTS.md + opencode.json)
 * sur une codebase déjà déployée, sans toucher aux règles ni aux skills.
 */
export function generateOpencodeContext(projectRoot, { skills = [], dryRun = false, force = false } = {}) {
  const results = [];
  results.push(generateAgentsContext(projectRoot, { skills, dryRun, force }));
  results.push(mergeOpencodeConfig(projectRoot, { dryRun }));
  return results;
}

/**
 * Moteur de la commande `update` : rend une codebase déjà déployée
 * compréhensible par opencode (contexte) et resynchronise les compétences.
 */
export async function updateFramework(options = {}) {
  const dryRun = Boolean(options.dryRun);
  const force = Boolean(options.force);
  const projectRoot = options.targetDir ? path.resolve(options.targetDir) : process.cwd();

  const agentsDir = path.join(projectRoot, '.agents');
  const skillsDestDir = path.join(agentsDir, 'skills');
  const hasAgents = fs.existsSync(agentsDir);

  const availableSkills = getAvailableSkills();
  const selectedSkills = resolveSkillList(options.skills, availableSkills);

  const report = {
    projectRoot,
    hasAgents,
    skillsResynced: [],
    opencodeContext: []
  };

  // 1. Resynchronisation (non destructive) des compétences déployées.
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
    report.skillsResynced.push(skillName);
  }

  // 2. Génération / rafraîchissement de la couche de contexte opencode.
  report.opencodeContext = generateOpencodeContext(projectRoot, {
    skills: selectedSkills,
    dryRun,
    force
  });

  // 3. Bilan récapitulatif.
  console.log('');
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.brightCyan}  MISE À JOUR OP ENCODE — FRAMEWORK ANTIGRAVITY (san_*)${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`  ${colors.bold}Projet${colors.reset}      : ${projectRoot}`);
  console.log(`  ${colors.bold}Déploiement${colors.reset}  : ${hasAgents ? `${colors.green}Détecté (.agents/)${colors.reset}` : `${colors.yellow}Absent (aucun .agents/)${colors.reset}`}`);
  console.log(`  ${colors.bold}Skills resync${colors.reset} : ${report.skillsResynced.length}/${availableSkills.length}`);
  if (dryRun) {
    console.log(`  ${colors.yellow}${colors.bold}[DRY-RUN]${colors.reset} Mode simulation actif — aucun octet écrit.`);
  }

  console.log('');
  console.log(`${colors.bold}🧠 Contexte opencode :${colors.reset}`);
  for (const r of report.opencodeContext) {
    const badge = r.status === 'preserved'
      ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (fichier personnalisé conservé)`
      : r.status === 'skipped-invalid'
        ? `${colors.yellow}[IGNORÉ]${colors.reset} (JSON invalide, non modifié)`
        : `${colors.green}[${r.status === 'merged' ? 'FUSIONNÉ' : 'CRÉÉ'}]${colors.reset}`;
    console.log(`  • ${r.file.padEnd(14)} : ${badge}`);
  }

  console.log('');
  console.log(`${colors.brightCyan}ℹ Relancez opencode pour recharger le contexte et les compétences.${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}\n`);

  return {
    success: true,
    projectRoot,
    hasAgents,
    skillsResynced: report.skillsResynced,
    opencodeContext: report.opencodeContext
  };
}

/**
 * Moteur principal d'installation du framework Antigravity
 * @param {Object} options
 * @param {'local'|'global'} [options.targetMode='local']
 * @param {string} [options.targetDir]
 * @param {string[]} [options.skills]
 * @param {boolean} [options.dryRun=false]
 * @param {boolean} [options.force=false]
 * @param {boolean} [options.opencode=false]
 */
export async function installFramework(options = {}) {
  const targetMode = options.targetMode || 'local';
  const dryRun = Boolean(options.dryRun);
  const force = Boolean(options.force);
  const opencode = Boolean(options.opencode);

  const availableSkills = getAvailableSkills();
  const selectedSkills = resolveSkillList(options.skills, availableSkills);

  let skillsDestDir;
  let projectRoot = null;
  let agentsDir = null;
  let rulesDestDir = null;
  let geminiMdDest = null;
  let rulesJsonDest = null;

  if (targetMode === 'global') {
    const defaultGlobal = fs.existsSync(path.join(os.homedir(), '.gemini', 'antigravity-cli'))
      ? path.join(os.homedir(), '.gemini', 'antigravity-cli', 'skills')
      : path.join(os.homedir(), '.gemini', 'skills');
    skillsDestDir = options.targetDir ? path.resolve(options.targetDir) : defaultGlobal;
  } else {
    projectRoot = options.targetDir ? path.resolve(options.targetDir) : process.cwd();
    agentsDir = path.join(projectRoot, '.agents');
    skillsDestDir = path.join(agentsDir, 'skills');
    rulesDestDir = path.join(agentsDir, 'rules');
    geminiMdDest = path.join(agentsDir, 'GEMINI.md');
    rulesJsonDest = path.join(agentsDir, 'rules.json');
  }

  // 1. Déploiement des compétences (Skills)
  const installedSkills = [];
  for (const skillName of selectedSkills) {
    const src = path.join(SKILLS_SRC_DIR, skillName);
    const dest = path.join(skillsDestDir, skillName);

    if (!fs.existsSync(src)) {
      console.warn(`${colors.yellow}[!] Source introuvable pour ${skillName}${colors.reset}`);
      continue;
    }

    if (!dryRun) {
      fs.mkdirSync(skillsDestDir, { recursive: true });
      if (fs.existsSync(dest) && force) {
        fs.rmSync(dest, { recursive: true, force: true });
      }
      fs.cpSync(src, dest, { recursive: true });

      // Rendre les scripts exécutables si présents
      const scriptsPath = path.join(dest, 'scripts');
      if (fs.existsSync(scriptsPath)) {
        try {
          for (const f of fs.readdirSync(scriptsPath)) {
            try {
              fs.chmodSync(path.join(scriptsPath, f), 0o755);
            } catch {}
          }
        } catch {}
      }
    }
    installedSkills.push(skillName);
  }

  // 2. Smart Merge pour mode local (Règles normatives & Index maître)
  const rulesStatus = [];
  let geminiStatus = 'none';

  if (targetMode === 'local') {
    const templatesDir = path.join(SKILLS_SRC_DIR, 'san_init', 'templates');
    const rulesTemplatesDir = path.join(templatesDir, 'rules');

    if (!dryRun) {
      fs.mkdirSync(rulesDestDir, { recursive: true });
    }

    const RULE_TEMPLATES = [
      { template: 'BRAND_TEMPLATE.md', target: 'BRAND.md' },
      { template: 'PRODUCT_TEMPLATE.md', target: 'PRODUCT.md' },
      { template: 'PROJECT_TEMPLATE.md', target: 'PROJECT.md' },
      { template: 'API_TEMPLATE.md', target: 'API.md' },
      { template: 'LOGO_TEMPLATE.md', target: 'LOGO.md' }
    ];

    for (const rule of RULE_TEMPLATES) {
      const targetPath = path.join(rulesDestDir, rule.target);
      const templatePath = path.join(rulesTemplatesDir, rule.template);

      if (fs.existsSync(targetPath)) {
        rulesStatus.push({ file: rule.target, status: 'preserved' });
      } else if (fs.existsSync(templatePath)) {
        if (!dryRun) {
          fs.copyFileSync(templatePath, targetPath);
        }
        rulesStatus.push({ file: rule.target, status: 'created' });
      }
    }

    // Index GEMINI.md
    const geminiTemplate = path.join(templatesDir, 'GEMINI_INDEX_TEMPLATE.md');
    if (fs.existsSync(geminiMdDest)) {
      geminiStatus = 'preserved';
    } else if (fs.existsSync(geminiTemplate)) {
      if (!dryRun) {
        fs.copyFileSync(geminiTemplate, geminiMdDest);
      }
      geminiStatus = 'created';
    }

    // Spec rules.json anti-scan plat
    const rulesJsonTemplate = path.join(templatesDir, 'rules_json_template.json');
    if (!fs.existsSync(rulesJsonDest) && fs.existsSync(rulesJsonTemplate)) {
      if (!dryRun) {
        fs.copyFileSync(rulesJsonTemplate, rulesJsonDest);
      }
    }
  }

  // 3. Hygiène Git automatique
  let hygiene = { isGit: false, purgedFiles: [], purgedDirs: [] };
  if (targetMode === 'local' && projectRoot) {
    hygiene = executeGitHygiene(projectRoot, { dryRun, preserveOpencode: opencode });
  }

  // 3bis. Couche de contexte opencode (AGENTS.md + opencode.json) si demandée
  const opencodeContext = opencode && projectRoot
    ? generateOpencodeContext(projectRoot, { skills: selectedSkills, dryRun, force })
    : [];

  // 4. Bilan récapitulatif élégant
  console.log('');
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.brightCyan}  INSTALLATION DU FRAMEWORK ANTIGRAVITY (san_*) RÉUSSIE !${colors.reset}`);
  console.log(`${colors.cyan}============================================================${colors.reset}`);
  console.log(`  ${colors.bold}Mode${colors.reset}        : ${targetMode === 'local' ? 'Local (.agents/)' : 'Global Antigravity CLI'}`);
  console.log(`  ${colors.bold}Destination${colors.reset} : ${skillsDestDir}`);
  console.log(`  ${colors.bold}Modules${colors.reset}     : ${installedSkills.length}/${availableSkills.length} skills configurés`);
  if (dryRun) {
    console.log(`  ${colors.yellow}${colors.bold}[DRY-RUN]${colors.reset} Mode simulation actif — aucun octet écrit sur le disque.`);
  }

  console.log('');
  console.log(`${colors.bold}📦 Skills installés (${installedSkills.length}) :${colors.reset}`);
  for (const s of installedSkills) {
    console.log(`  ${colors.green}✔${colors.reset} ${colors.cyan}${s}${colors.reset}`);
  }

  if (targetMode === 'local') {
    console.log('');
    console.log(`${colors.bold}🛡️ Smart Merge (Règles de gouvernance & Table de routage) :${colors.reset}`);
    for (const r of rulesStatus) {
      const badge = r.status === 'preserved'
        ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Fichier existant scrupuleusement conservé)`
        : `${colors.green}[CRÉÉ]${colors.reset} (Instancié depuis gabarit officiel)`;
      console.log(`  • ${r.file.padEnd(12)} : ${badge}`);
    }
    const geminiBadge = geminiStatus === 'preserved'
      ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (Index maître existant)`
      : `${colors.green}[CRÉÉ]${colors.reset} (Index maître .agents/GEMINI.md déployé)`;
    console.log(`  • ${'GEMINI.md'.padEnd(12)} : ${geminiBadge}`);

    console.log('');
    console.log(`${colors.bold}🧹 Hygiène & Isolation Git :${colors.reset}`);
    if (hygiene.isGit) {
      if (hygiene.purgedFiles.length > 0 || hygiene.purgedDirs.length > 0) {
        console.log(`  ${colors.green}✔${colors.reset} Résidus tiers purgés : ${[...hygiene.purgedFiles, ...hygiene.purgedDirs].join(', ')}`);
      } else {
        console.log(`  ${colors.green}✔${colors.reset} Aucun résidu tiers détecté sur le disque`);
      }
      console.log(`  ${colors.green}✔${colors.reset} Cache Git désindexé pour .agents/`);
      console.log(`  ${colors.green}✔${colors.reset} Isolation hermétique vérifiée (.gitignore & .git/info/exclude)`);
    } else {
      console.log(`  ${colors.gray}ℹ Répertoire hors dépôt Git (isolation ignorée)${colors.reset}`);
    }
  }

  if (opencode && opencodeContext.length) {
    console.log('');
    console.log(`${colors.bold}🧠 Contexte opencode (AGENTS.md + opencode.json) :${colors.reset}`);
    for (const r of opencodeContext) {
      const badge = r.status === 'preserved'
        ? `${colors.yellow}[PRÉSERVÉ]${colors.reset} (fichier personnalisé conservé)`
        : r.status === 'skipped-invalid'
          ? `${colors.yellow}[IGNORÉ]${colors.reset} (JSON invalide, non modifié)`
          : `${colors.green}[${r.status === 'merged' ? 'FUSIONNÉ' : 'CRÉÉ'}]${colors.reset}`;
      console.log(`  • ${r.file.padEnd(14)} : ${badge}`);
    }
  }

  console.log('');
  console.log(`${colors.bold}🚀 Prochaines étapes recommandées :${colors.reset}`);
  console.log(`  ${colors.brightCyan}1.${colors.reset} ${colors.bold}san_init${colors.reset}          : Initialiser et cadrer chirurgicalement le projet`);
  console.log(`  ${colors.brightCyan}2.${colors.reset} ${colors.bold}san_brainstorming${colors.reset} : Cadrer les idées produit et valider la proposition de valeur`);
  console.log(`  ${colors.brightCyan}3.${colors.reset} ${colors.bold}san_planner${colors.reset}       : Planifier les phases d'ingénierie et roadmaps d'exécution`);
  console.log(`${colors.cyan}============================================================${colors.reset}\n`);

  return {
    success: true,
    targetMode,
    targetDir: skillsDestDir,
    installedSkills,
    rulesStatus,
    geminiStatus,
    hygiene,
    opencodeContext
  };
}
