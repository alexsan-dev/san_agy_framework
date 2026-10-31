#!/usr/bin/env node

/**
 * ==============================================================================
 * CLI UNIVERSEL D'INSTALLATION & GOUVERNANCE — FRAMEWORK ANTIGRAVITY (san_*)
 * Auteur : Alexsan.pro
 * Architecture v2.0 : 4 Couches, 8 Sous-Agents, 17 Skills, 3 Hooks, Doctor
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
  getAvailableSkills,
  getSkillDescription,
  resolveSkillList,
  installFramework,
  updateFramework,
  runDoctor,
  printDoctorReport,
  colors
} from './installer.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Lecture de la version dynamique depuis package.json
let frameworkVersion = '2.0.0';
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
    console.log(`${colors.brightCyan}${colors.bold}=== ANTIGRAVITY CARTESIAN FRAMEWORK v${frameworkVersion} ===${colors.reset}\n`);
  }
}

/**
 * Affiche le guide d'aide complet
 */
export function showHelp() {
  showBanner();
  console.log(`${colors.bold}FRAMEWORK UNIVERSEL GOOGLE ANTIGRAVITY (san_*)${colors.reset}`);
  console.log(`${colors.gray}Alexsan.pro · Cartesian Engineering & Cognitive Harness · v${frameworkVersion}${colors.reset}\n`);
  console.log(`${colors.bold}UTILISATION :${colors.reset}`);
  console.log(`  npx @alexsan/agy-framework <commande> [options]`);
  console.log(`  agy-framework <commande> [options]`);
  console.log(`  san-framework <commande> [options]\n`);
  console.log(`${colors.bold}COMMANDES OFFICIELLES :${colors.reset}`);
  console.log(`  ${colors.brightCyan}init${colors.reset}                     Installer le framework v2.0 (local 4 couches ou global plugin)`);
  console.log(`  ${colors.brightCyan}update${colors.reset}                   Migrer instantanément v1.0 -> v2.0 (Smart Merge frontmatter, 8 agents, 3 hooks)`);
  console.log(`  ${colors.brightCyan}doctor${colors.reset}                   Contrôler les 6 piliers de santé v2.0 et l'intégrité de l'environnement`);
  console.log(`  ${colors.brightCyan}list${colors.reset}                     Lister l'ensemble des 17 skills du catalogue`);
  console.log(`  ${colors.brightCyan}version, -v, --version${colors.reset}   Afficher la version installée`);
  console.log(`  ${colors.brightCyan}help, -h, --help${colors.reset}         Afficher ce guide d'aide\n`);
  console.log(`${colors.bold}OPTIONS GÉNÉRALES :${colors.reset}`);
  console.log(`  ${colors.cyan}--local${colors.reset}                  Installer dans le projet local (.agents/) [Défaut en non-interactif]`);
  console.log(`  ${colors.cyan}--global${colors.reset}                 Installer sous forme de Plugin global Antigravity`);
  console.log(`  ${colors.cyan}--all${colors.reset}                    Installer l'intégralité des 17 skills du catalogue`);
  console.log(`  ${colors.cyan}--skills=<liste>${colors.reset}         Sélection granulaire de skills (ex: --skills=san_init,san_planner)`);
  console.log(`  ${colors.cyan}--dry-run${colors.reset}                Mode simulation (zéro écriture sur le disque)`);
  console.log(`  ${colors.cyan}--force${colors.reset}                  Forcer la réécriture des composants existants`);
  console.log(`  ${colors.cyan}--opencode${colors.reset}               Génère également le contexte opencode.json`);
  console.log(`  ${colors.cyan}--dir=<chemin>${colors.reset}            Spécifier manuellement le répertoire cible\n`);
  console.log(`${colors.bold}EXEMPLES D'UTILISATION :${colors.reset}`);
  console.log(`  ${colors.gray}# 1. Déploiement complet des 4 couches v2.0 dans le projet courant${colors.reset}`);
  console.log(`  san-framework init --local --all\n`);
  console.log(`  ${colors.gray}# 2. Vérification de santé et conformité des 6 piliers${colors.reset}`);
  console.log(`  san-framework doctor\n`);
  console.log(`  ${colors.gray}# 3. Migration transparente non-destructive d'une v1.0 vers v2.0${colors.reset}`);
  console.log(`  san-framework update\n`);
  console.log(`  ${colors.gray}# 4. Packaging Plugin global Antigravity CLI${colors.reset}`);
  console.log(`  san-framework init --global --all\n`);
}

/**
 * Affiche la liste des skills disponibles
 */
export function showList() {
  showBanner();
  const availableSkills = getAvailableSkills();
  console.log(`${colors.bold}Catalogue des Skills Antigravity (san_*) — ${availableSkills.length} modules disponibles :${colors.reset}\n`);

  for (const s of availableSkills) {
    const desc = getSkillDescription(s);
    console.log(`  ${colors.brightCyan}•${colors.reset} ${colors.bold}${s.padEnd(24)}${colors.reset} : ${desc || colors.gray + '(Description)' + colors.reset}`);
  }
  console.log('');
  console.log(`${colors.gray}Pour installer ces modules : san-framework init --all${colors.reset}\n`);
}

/**
 * Assistant interactif (TTY sans flags d'automatisation)
 */
async function runInteractivePrompt(availableSkills, initialTargetMode = null) {
  const rl = readline.createInterface({ input, output });

  try {
    console.log(`${colors.brightCyan}${colors.bold}--- Assistant Interactif d'Installation Antigravity v2.0 ---${colors.reset}\n`);

    let targetMode = initialTargetMode;
    if (!targetMode) {
      console.log(`${colors.bold}1. Cible d'installation :${colors.reset}`);
      console.log(`   [1] Projet local (.agents/ + AGENTS.md souverain) ${colors.green}[Recommandé / Défaut]${colors.reset}`);
      console.log(`   [2] Plugin Global Antigravity CLI (~/.gemini/antigravity-cli/plugins/san-framework/)\n`);

      const targetAnswer = (await rl.question(`${colors.cyan}Votre choix [1-2] (défaut: 1) : ${colors.reset}`)).trim();
      targetMode = targetAnswer === '2' ? 'global' : 'local';
    }

    console.log(`\n${colors.bold}2. Sélection des compétences (Skills) :${colors.reset}`);
    console.log(`   [1] Tous les skills ${colors.green}[Recommandé - 17 modules du framework v2.0]${colors.reset}`);
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

/**
 * Point d'entrée principal CLI
 */
async function main() {
  const { values, positionals } = parseArgs({
    args: process.argv.slice(2),
    options: {
      help: { type: 'boolean', short: 'h' },
      version: { type: 'boolean', short: 'v' },
      local: { type: 'boolean' },
      global: { type: 'boolean' },
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

  // 1. Commande Version
  if (values.version || command === 'version' || command === '-v' || command === '--version') {
    console.log(`@alexsan/agy-framework v${frameworkVersion}`);
    process.exit(0);
  }

  // 2. Commande Help
  if (values.help || command === 'help' || command === '-h' || command === '--help') {
    showHelp();
    process.exit(0);
  }

  // 3. Commande List
  if (command === 'list') {
    showList();
    process.exit(0);
  }

  // 4. Commande Doctor (contrôle officiel des 6 piliers de santé v2.0)
  if (command === 'doctor') {
    showBanner();
    const report = runDoctor({ targetDir: values.dir });
    printDoctorReport(report);
    process.exit(report.allPassed ? 0 : 1);
  }

  // 5. Commande Update (migration v1.0 -> v2.0 non destructive)
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
      opencode: Boolean(values.opencode)
    });

    process.exit(0);
  }

  // 6. Commande Init (ou exécution par défaut)
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

    const isAutomated = (values.all || values.skills !== undefined);
    const isInteractive = Boolean(process.stdin.isTTY && !isAutomated);

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
      opencode: Boolean(values.opencode)
    });

    process.exit(0);
  }

  // Commande inexistante ou sans argument en non-TTY
  if (!command) {
    showHelp();
    process.exit(0);
  }

  console.error(`${colors.red}[ERREUR] Commande inconnue : ${command}${colors.reset}`);
  console.log(`Tapez "san-framework --help" pour afficher la liste des commandes disponibles.`);
  process.exit(1);
}

main().catch((err) => {
  console.error(`${colors.red}[ERREUR FATALE] : ${err.message}${colors.reset}`);
  if (process.env.DEBUG) {
    console.error(err.stack);
  }
  process.exit(1);
});
