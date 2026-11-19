#!/usr/bin/env node

/**
 * ==============================================================================
 * CLI UNIVERSEL D'INSTALLATION & GOUVERNANCE — SAN AI HARNESS (san_*)
 * Auteur : Alexsan.pro
 * Architecture v3.0 : 4 Couches, 8 Workers, 17 Skills, 3 Hooks, Compaction 120k, Dual-Harness
 * ==============================================================================
 */

import fs from 'node:fs';
import path from 'node:path';
import { parseArgs } from 'node:util';
import readline from 'node:readline/promises';
import { stdin as input, stdout as output } from 'node:process';
import { fileURLToPath } from 'node:url';

import {
  FRAMEWORK_ROOT,
  resolveProjectRoot,
  detectExistingInstallation,
  getAvailableSkills,
  getSkillDescription,
  resolveSkillList,
  installFramework,
  updateFramework,
  runDoctor,
  printDoctorReport,
  readModelsConfig,
  configureModels,
  colors
} from './installer.js';
import { formatWhatsNewTerminal } from './whats_new.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Lecture de la version dynamique depuis package.json
let frameworkVersion = '3.0.0';
try {
  const pkgPath = path.resolve(FRAMEWORK_ROOT, 'package.json');
  if (fs.existsSync(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
    if (pkg.version) frameworkVersion = pkg.version;
  }
} catch {}

/**
 * Affiche la bannière ASCII officielle avec couleurs ANSI vives
 */
export function showBanner() {
  const bannerPath = path.resolve(FRAMEWORK_ROOT, 'logos', 'LOGO_ASCII.txt');
  if (fs.existsSync(bannerPath)) {
    const raw = fs.readFileSync(bannerPath, 'utf8');
    console.log(`${colors.brightCyan}${colors.bold}${raw}${colors.reset}\n`);
  } else {
    console.log(`${colors.brightCyan}${colors.bold}=== SAN AI HARNESS v${frameworkVersion} ===${colors.reset}\n`);
  }
}

/**
 * Affiche le guide d'aide complet
 */
export function showHelp() {
  showBanner();
  const skillCount = getAvailableSkills().length || 17;
  const minorLabel = frameworkVersion.split('.').slice(0, 2).join('.') || '3.0';
  console.log(`${colors.bold}SAN AI HARNESS — DUAL-HARNESS GOOGLE ANTIGRAVITY & OPENCODE V2.3 (san_*)${colors.reset}`);
  console.log(`${colors.gray}Alexsan.pro · Adaptive Orchestration & Compaction 120k · v${frameworkVersion}${colors.reset}\n`);
  console.log(`${colors.bold}UTILISATION :${colors.reset}`);
  console.log(`  npx @alexsan/san-ai-harness <commande> [options]`);
  console.log(`  san-harness <commande> [options]`);
  console.log(`  san-framework <commande> [options]  ${colors.gray}(alias rétrocompatible)${colors.reset}\n`);
  console.log(`${colors.bold}COMMANDES OFFICIELLES :${colors.reset}`);
  console.log(`  ${colors.brightCyan}init${colors.reset}                     Installer san_ai_harness v${minorLabel} (local 4 couches ou global plugin)`);
  console.log(`  ${colors.brightCyan}update${colors.reset}                   Mettre à jour vers v${minorLabel} (Smart Merge, purge cache, 8 workers, opencode.json + plugin)`);
  console.log(`  ${colors.brightCyan}models${colors.reset}                   Configurer les exécuteurs & compaction 120k (.agents/models.json & opencode.json)`);
  console.log(`  ${colors.brightCyan}doctor${colors.reset}                   Contrôler les 6 piliers de santé v${minorLabel} (dont absence de .agents/cache)`);
  console.log(`  ${colors.brightCyan}whats-new${colors.reset}                Afficher les notes de version (What's New on san_ai_harness)`);
  console.log(`  ${colors.brightCyan}list${colors.reset}                     Lister l'ensemble des ${skillCount} skills du catalogue`);
  console.log(`  ${colors.brightCyan}version, -v, --version${colors.reset}   Afficher la version installée`);
  console.log(`  ${colors.brightCyan}help, -h, --help${colors.reset}         Afficher ce guide d'aide\n`);
  console.log(`${colors.bold}OPTIONS GÉNÉRALES :${colors.reset}`);
  console.log(`  ${colors.cyan}--local${colors.reset}                  Installer dans le projet local (.agents/) [Défaut en non-interactif]`);
  console.log(`  ${colors.cyan}--global${colors.reset}                 Installer sous forme de Plugin global Antigravity`);
  console.log(`  ${colors.cyan}--light${colors.reset}                  Mode héritage léger (.agents/skills.json "inherits" sans copier les ${skillCount} skills)`);
  console.log(`  ${colors.cyan}--all${colors.reset}                    Installer l'intégralité des ${skillCount} skills du catalogue`);
  console.log(`  ${colors.cyan}--skills=<liste>${colors.reset}         Sélection granulaire de skills (ex: --skills=san_init,san_planner)`);
  console.log(`  ${colors.cyan}--dry-run${colors.reset}                Mode simulation (zéro écriture sur le disque)`);
  console.log(`  ${colors.cyan}--force${colors.reset}                  Forcer la réécriture des composants existants`);
  console.log(`  ${colors.cyan}--opencode${colors.reset}               Génère/met à jour opencode.json V2.3 + plugin Swarm Board (.agents/opencode)`);
  console.log(`  ${colors.cyan}--dir=<chemin>${colors.reset}           Spécifier manuellement le répertoire cible\n`);
  console.log(`${colors.bold}OPTIONS DE LA COMMANDE models :${colors.reset}`);
  console.log(`  ${colors.cyan}--opencode=<model>${colors.reset}       Définir opencode.executor (ex: opencode-go/deepseek-v4-pro)`);
  console.log(`  ${colors.cyan}--agy=<model>${colors.reset}            Définir agy.executor (ex: gemini-4-hydrogen-xhigh)`);
  console.log(`  ${colors.cyan}--compaction=<tokens>${colors.reset}    Définir compaction.targetTokens (défaut: 120000)`);
  console.log(`  ${colors.cyan}--set=<model>${colors.reset}            Détection automatique ('/' -> OpenCode, sinon Antigravity)`);
  console.log(`  ${colors.cyan}--interactive, -i${colors.reset}        Assistant interactif (TTY uniquement)\n`);
  console.log(`${colors.bold}EXEMPLES D'UTILISATION :${colors.reset}`);
  console.log(`  ${colors.gray}# 1. Déploiement complet des 4 couches v${minorLabel} dans le projet courant${colors.reset}`);
  console.log(`  san-harness init --local --all\n`);
  console.log(`  ${colors.gray}# 2. Déploiement Dual-Harness (Antigravity + OpenCode V2.3 + Swarm Board)${colors.reset}`);
  console.log(`  san-harness init --local --all --opencode\n`);
  console.log(`  ${colors.gray}# 3. Basculer le modèle exécuteur des workers (OpenCode V2.3 & Antigravity)${colors.reset}`);
  console.log(`  san-harness models --opencode=opencode-go/deepseek-v4-pro`);
  console.log(`  san-harness models --agy=gemini-4-hydrogen-xhigh`);
  console.log(`  san-harness models --compaction=120000\n`);
  console.log(`  ${colors.gray}# 4. Déploiement léger (.agents/skills.json) & Doctor${colors.reset}`);
  console.log(`  san-harness init --local --light && san-harness doctor\n`);
  console.log(`  ${colors.gray}# 5. Mise à jour non-destructive et affichage des nouveautés${colors.reset}`);
  console.log(`  san-harness update && san-harness whats-new\n`);
}

/**
 * Affiche la liste des skills disponibles
 */
export function showList() {
  showBanner();
  const availableSkills = getAvailableSkills();
  console.log(`${colors.bold}Catalogue des Skills SAN AI Harness (san_*) — ${availableSkills.length} modules disponibles :${colors.reset}\n`);

  for (const s of availableSkills) {
    const desc = getSkillDescription(s);
    console.log(`  ${colors.brightCyan}•${colors.reset} ${colors.bold}${s.padEnd(24)}${colors.reset} : ${desc || colors.gray + '(Description)' + colors.reset}`);
  }
  console.log('');
  console.log(`${colors.gray}Pour installer ces modules : san-harness init --all${colors.reset}\n`);
}

/**
 * Assistant interactif (TTY sans flags d'automatisation)
 */
async function runInteractivePrompt(availableSkills, initialTargetMode = null) {
  const rl = readline.createInterface({ input, output });

  try {
    const minorLabel = frameworkVersion.split('.').slice(0, 2).join('.') || '3.0';
    console.log(`${colors.brightCyan}${colors.bold}--- Assistant Interactif SAN AI Harness v${minorLabel} ---${colors.reset}\n`);

    let targetMode = initialTargetMode;
    if (!targetMode) {
      console.log(`${colors.bold}1. Cible d'installation :${colors.reset}`);
      console.log(`   [1] Projet local (.agents/ + AGENTS.md souverain) ${colors.green}[Recommandé / Défaut]${colors.reset}`);
      console.log(`   [2] Plugin Global Antigravity CLI (~/.gemini/antigravity-cli/plugins/san-ai-harness/)\n`);

      const targetAnswer = (await rl.question(`${colors.cyan}Votre choix [1-2] (défaut: 1) : ${colors.reset}`)).trim();
      targetMode = targetAnswer === '2' ? 'global' : 'local';
    }

    console.log(`\n${colors.bold}2. Sélection des compétences (Skills) :${colors.reset}`);
    console.log(`   [1] Tous les skills ${colors.green}[Recommandé - ${availableSkills.length} modules du framework v${minorLabel}]${colors.reset}`);
    console.log(`   [2] Socle Onboarding & Cadrage (san_init, san_brainstorming, san_planner)`);
    console.log(`   [3] Sélection manuelle personnalisée\n`);

    const skillsAnswer = (await rl.question(`${colors.cyan}Votre choix [1-3] (défaut: 1) : ${colors.reset}`)).trim();
    let selectedSkills = [];

    if (skillsAnswer === '2') {
      selectedSkills = ['san_init', 'san_brainstorming', 'san_planner'];
    } else if (skillsAnswer === '3') {
      console.log(`\n${colors.bold}Modules disponibles dans le catalogue :${colors.reset}`);
      availableSkills.forEach((s, idx) => {
        const num = String(idx + 1).padStart(2, ' ');
        console.log(`   [${num}] ${s}`);
      });
      console.log('');
      const manualAnswer = await rl.question(`${colors.cyan}Entrez les numéros ou noms séparés par des virgules (ex: 2, 11, 12) : ${colors.reset}`);
      const rawItems = manualAnswer.split(',').map(x => x.trim()).filter(Boolean);
      for (const item of rawItems) {
        const num = parseInt(item, 10);
        if (!isNaN(num) && num >= 1 && num <= availableSkills.length) {
          selectedSkills.push(availableSkills[num - 1]);
        } else if (availableSkills.includes(item)) {
          selectedSkills.push(item);
        } else if (availableSkills.includes(`san_${item}`)) {
          selectedSkills.push(`san_${item}`);
        }
      }
      if (selectedSkills.length === 0) {
        console.log(`${colors.yellow}Aucune sélection valide reconnue, sélection de tous les modules par défaut.${colors.reset}`);
        selectedSkills = availableSkills;
      }
    } else {
      selectedSkills = availableSkills;
    }

    return { targetMode, skills: selectedSkills };
  } finally {
    rl.close();
  }
}

function printModelsQuickExamples() {
  console.log(`${colors.bold}Exemples rapides :${colors.reset}`);
  console.log(`  ${colors.brightCyan}san-harness models --opencode=opencode-go/deepseek-v4-pro${colors.reset}`);
  console.log(`  ${colors.brightCyan}san-harness models --agy=gemini-4-hydrogen-xhigh${colors.reset}`);
  console.log(`  ${colors.brightCyan}san-harness models --compaction=120000${colors.reset}`);
  console.log(`  ${colors.brightCyan}san-harness models --set=opencode-go/glm-5.3-flash${colors.reset}\n`);
}

function validateModelFlag(flagName, value) {
  if (value === undefined) return undefined;
  if (typeof value !== 'string' || !value.trim() || value.trim().startsWith('-')) {
    throw new Error(`L'option --${flagName} requiert un nom de modèle valide (ex: --${flagName}=opencode-go/deepseek-v4-pro).`);
  }
  return value.trim();
}

async function runModelsInteractivePrompt(currentConfig) {
  const rl = readline.createInterface({ input, output });
  try {
    console.log(`${colors.brightCyan}${colors.bold}--- Assistant Interactif san-harness models ---${colors.reset}\n`);
    console.log(`${colors.gray}Note : les orchestrateurs héritent par défaut du /model sélectionné dans AGY ou OpenCode.${colors.reset}\n`);
    const ocExec = (await rl.question(
      `${colors.cyan}Exécuteur OpenCode V2 [${currentConfig.opencode.executor}] : ${colors.reset}`
    )).trim();
    const agyExec = (await rl.question(
      `${colors.cyan}Exécuteur Antigravity [${currentConfig.agy.executor}] : ${colors.reset}`
    )).trim();
    const compRaw = (await rl.question(
      `${colors.cyan}Seuil Compaction Auto (tokens) [${currentConfig.compaction?.targetTokens ?? 120000}] : ${colors.reset}`
    )).trim();

    return {
      opencodeExecutor: ocExec || currentConfig.opencode.executor,
      agyExecutor: agyExec || currentConfig.agy.executor,
      compactionTargetTokens: compRaw ? Number(compRaw) : (currentConfig.compaction?.targetTokens ?? 120000)
    };
  } finally {
    rl.close();
  }
}

async function runExistingProjectMenu(existing, availableSkills, values) {
  const rl = readline.createInterface({ input, output });
  try {
    const modeLabel = existing.mode === 'light'
      ? 'Mode léger (.agents/skills.json)'
      : `${existing.skillsCount}/${availableSkills.length} skills (.agents/skills/)`;
    console.log(`${colors.brightGreen}${colors.bold}✔ SAN AI Harness déjà installé dans ce projet${colors.reset}`);
    console.log(`  ${colors.bold}Racine détectée${colors.reset} : ${existing.projectRoot}`);
    console.log(`  ${colors.bold}Architecture${colors.reset}    : ${modeLabel}`);
    if (existing.hasModelsConfig) {
      const m = readModelsConfig(existing.projectRoot).config;
      console.log(`  ${colors.bold}Modèles${colors.reset}         : AGY=${m.agy.executor} | OpenCode=${m.opencode.executor}`);
    }
    console.log('');
    console.log(`${colors.bold}Action souhaitée :${colors.reset}`);
    console.log(`   [1] Mettre à jour vers v${frameworkVersion} (update) ${colors.green}[Recommandé / Défaut]${colors.reset}`);
    console.log(`   [2] Diagnostic de santé 6 piliers (doctor)`);
    console.log(`   [3] Configurer les modèles Dual-Harness (models)`);
    console.log(`   [4] Réinstaller / Modifier les options (init)`);
    console.log(`   [5] Quitter\n`);

    const choice = (await rl.question(`${colors.cyan}Votre choix [1-5] (défaut: 1) : ${colors.reset}`)).trim();
    return choice || '1';
  } finally {
    rl.close();
  }
}

/**
 * Point d'entrée principal CLI
 */
async function main() {
  const rawArgs = process.argv.slice(2);
  const { values, positionals } = parseArgs({
    args: rawArgs,
    options: {
      help: { type: 'boolean', short: 'h' },
      version: { type: 'boolean', short: 'v' },
      local: { type: 'boolean' },
      global: { type: 'boolean' },
      light: { type: 'boolean' },
      inherit: { type: 'boolean' },
      all: { type: 'boolean' },
      skills: { type: 'string' },
      'dry-run': { type: 'boolean' },
      force: { type: 'boolean' },
      dir: { type: 'string' },
      opencode: { type: 'boolean' }
    },
    allowPositionals: true,
    strict: false
  });

  const command = positionals[0] ? positionals[0].toLowerCase() : null;
  const isLightMode = Boolean(values.light || values.inherit);

  // 1. Commande Version
  if (values.version || command === 'version' || command === '-v' || command === '--version') {
    console.log(`@alexsan/san-ai-harness v${frameworkVersion}`);
    process.exit(0);
  }

  // 2. Commande Help
  if (values.help || command === 'help' || command === '-h' || command === '--help') {
    showHelp();
    process.exit(0);
  }

  // 2B. Commande What's New
  if (command === 'whats-new' || command === 'whatsnew') {
    const requestedVersion = positionals[1] || frameworkVersion;
    console.log(formatWhatsNewTerminal(requestedVersion));
    process.exit(0);
  }

  // 3. Commande List
  if (command === 'list') {
    showList();
    process.exit(0);
  }

  // 3B. Commande Models (.agents/models.json & opencode.json V2.3)
  if (command === 'models') {
    const { values: mValues } = parseArgs({
      args: rawArgs,
      options: {
        help: { type: 'boolean', short: 'h' },
        opencode: { type: 'string' },
        agy: { type: 'string' },
        orchestrator: { type: 'string' },
        'agy-orchestrator': { type: 'string' },
        'opencode-orchestrator': { type: 'string' },
        compaction: { type: 'string' },
        set: { type: 'string' },
        dir: { type: 'string' },
        'dry-run': { type: 'boolean' },
        interactive: { type: 'boolean', short: 'i' }
      },
      allowPositionals: true,
      strict: false
    });

    if (mValues.help) {
      showHelp();
      process.exit(0);
    }

    const opencodeExecutor = validateModelFlag('opencode', mValues.opencode);
    const agyExecutor = validateModelFlag('agy', mValues.agy);
    const orchestrator = validateModelFlag('orchestrator', mValues.orchestrator);
    const agyOrchestrator = validateModelFlag('agy-orchestrator', mValues['agy-orchestrator']);
    const opencodeOrchestrator = validateModelFlag('opencode-orchestrator', mValues['opencode-orchestrator']);
    const compactionTargetTokens = mValues.compaction !== undefined ? Number(mValues.compaction) : undefined;
    const setModel = validateModelFlag('set', mValues.set);
    const targetDir = mValues.dir;
    const dryRun = Boolean(mValues['dry-run']);

    const hasMutationFlags = Boolean(
      opencodeExecutor ||
      agyExecutor ||
      orchestrator ||
      agyOrchestrator ||
      opencodeOrchestrator ||
      (Number.isFinite(compactionTargetTokens) && compactionTargetTokens >= 10000) ||
      setModel
    );

    if (!hasMutationFlags && mValues.interactive && process.stdin.isTTY) {
      const current = readModelsConfig(targetDir).config;
      const answers = await runModelsInteractivePrompt(current);
      configureModels({
        targetDir,
        ...answers,
        dryRun
      });
      process.exit(0);
    }

    configureModels({
      targetDir,
      opencodeExecutor,
      agyExecutor,
      orchestrator,
      agyOrchestrator,
      opencodeOrchestrator,
      compactionTargetTokens,
      setModel,
      dryRun
    });

    if (!hasMutationFlags) {
      printModelsQuickExamples();
    }

    process.exit(0);
  }

  // 4. Commande Doctor (contrôle officiel des 6 piliers de santé v2.2)
  if (command === 'doctor') {
    showBanner();
    const report = runDoctor({ targetDir: values.dir });
    printDoctorReport(report);
    process.exit(report.allPassed ? 0 : 1);
  }

  // 5. Commande Update (migration & mise à jour v2.2 non destructive)
  if (command === 'update') {
    showBanner();
    const availableSkills = getAvailableSkills();
    let skillsToUpdate = null;
    if (values.all) {
      skillsToUpdate = availableSkills;
    } else if (values.skills) {
      skillsToUpdate = resolveSkillList(values.skills, availableSkills);
    } else {
      skillsToUpdate = availableSkills;
    }

    await updateFramework({
      targetDir: values.dir,
      skills: skillsToUpdate,
      dryRun: Boolean(values['dry-run']),
      force: Boolean(values.force),
      opencode: Boolean(values.opencode),
      light: isLightMode
    });

    process.exit(0);
  }

  // 6. Commande Init (ou exécution par défaut en TTY)
  if (command === 'init' || (!command && process.stdin.isTTY)) {
    showBanner();
    const availableSkills = getAvailableSkills();

    let targetMode = values.global ? 'global' : (values.local ? 'local' : null);
    let skillsToInstall = null;

    if (values.all) {
      skillsToInstall = availableSkills;
    } else if (values.skills) {
      skillsToInstall = resolveSkillList(values.skills, availableSkills);
    }

    const isAutomated = Boolean(values.all || values.skills !== undefined || isLightMode || values.force);
    const isInteractive = Boolean(process.stdin.isTTY && !isAutomated);

    // Reconnaissance automatique d'une installation existante (.agents/ dans cwd ou racine du repo)
    if (isInteractive && targetMode !== 'global') {
      const existing = detectExistingInstallation(values.dir);
      if (existing.installed) {
        if (!command) {
          const action = await runExistingProjectMenu(existing, availableSkills, values);
          if (action === '1') {
            await updateFramework({
              targetDir: existing.projectRoot,
              skills: availableSkills,
              dryRun: Boolean(values['dry-run']),
              force: Boolean(values.force),
              opencode: Boolean(values.opencode || existing.hasOpencodeConfig),
              light: existing.mode === 'light'
            });
            process.exit(0);
          } else if (action === '2') {
            const report = runDoctor({ targetDir: existing.projectRoot });
            printDoctorReport(report);
            process.exit(report.allPassed ? 0 : 1);
          } else if (action === '3') {
            const current = readModelsConfig(existing.projectRoot).config;
            const answers = await runModelsInteractivePrompt(current);
            configureModels({ targetDir: existing.projectRoot, ...answers, dryRun: Boolean(values['dry-run']) });
            process.exit(0);
          } else if (action === '5') {
            process.exit(0);
          }
          // action === '4' -> continue vers réinstallation interactive
        } else {
          const rl = readline.createInterface({ input, output });
          let confirmChoice = '1';
          try {
            console.log(`${colors.brightYellow}ℹ SAN AI Harness est déjà installé dans : ${existing.projectRoot}${colors.reset}`);
            console.log(`   [1] Mettre à jour sans rien écraser (update) ${colors.green}[Recommandé / Défaut]${colors.reset}`);
            console.log(`   [2] Continuer la réinstallation (init)`);
            console.log(`   [3] Annuler\n`);
            confirmChoice = (await rl.question(`${colors.cyan}Votre choix [1-3] (défaut: 1) : ${colors.reset}`)).trim() || '1';
          } finally {
            rl.close();
          }
          if (confirmChoice === '1') {
            await updateFramework({
              targetDir: existing.projectRoot,
              skills: availableSkills,
              dryRun: Boolean(values['dry-run']),
              force: false,
              opencode: Boolean(values.opencode || existing.hasOpencodeConfig),
              light: existing.mode === 'light'
            });
            process.exit(0);
          } else if (confirmChoice === '3') {
            process.exit(0);
          }
        }
      }
    }

    if (isInteractive) {
      const answers = await runInteractivePrompt(availableSkills, targetMode);
      targetMode = answers.targetMode;
      skillsToInstall = answers.skills;
    } else {
      // Mode non-interactif : valeurs par défaut souveraines
      if (!targetMode) targetMode = 'local';
      if (!skillsToInstall) skillsToInstall = availableSkills;
    }

    await installFramework({
      targetMode,
      targetDir: values.dir,
      skills: skillsToInstall,
      dryRun: Boolean(values['dry-run']),
      force: Boolean(values.force),
      opencode: Boolean(values.opencode),
      light: isLightMode
    });

    process.exit(0);
  }

  // Commande inexistante ou sans argument en non-TTY
  if (!command) {
    showHelp();
    process.exit(0);
  }

  console.error(`${colors.red}[ERREUR] Commande inconnue : ${command}${colors.reset}`);
  console.log(`Tapez "san-harness --help" pour afficher la liste des commandes disponibles.`);
  process.exit(1);
}

main().catch((err) => {
  console.error(`${colors.red}[ERREUR FATALE] : ${err.message}${colors.reset}`);
  if (process.env.DEBUG) {
    console.error(err.stack);
  }
  process.exit(1);
});
