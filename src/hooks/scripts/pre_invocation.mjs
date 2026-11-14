#!/usr/bin/env node
import fs from 'node:fs';

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

const userInput = (typeof data.lastUserInput === 'string') ? data.lastUserInput : '';
const shouldEnforce = /(?:d[eé]velopp|impl[eé]ment|cr[eé]e?|architect|plan|design|cod|audit|refactor|fix|bug|test|build|feature|ex[eé]cut|optimis|ajoute|modifi|corrig|d[eé]ploi)/i.test(userInput);

if (!shouldEnforce) {
  console.log(JSON.stringify({ injectSteps: [] }, null, 2));
  process.exit(0);
}

const reminderText =
  '[SAN.AGY ENFORCER] [SAN.AGY DISCIPLINE REMINDER] ' +
  '(1) Map-First: read .agents/cache/REPO_MAP.md and active roadmap first. ' +
  '(2) Never solo-code features inline: follow san_brainstorming -> san_planner -> san_executer -> san_qa_security_expert -> san_git_whisperer, and delegate parallel work via swarm(action: "add", model: "gemini-4-hydrogen-xhigh") (forbid Model: "inherit" on Argon) across san-researcher, san-architect, san-coder-*, san-designer-worker. ' +
  '(3) Reject mediocre first drafts: challenge with san-qa-auditor + fail-closed gates before checking [x].';

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
