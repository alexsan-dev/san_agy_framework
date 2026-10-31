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
const shouldEnforce = /(?:d[eé]velopp|impl[eé]ment|cr[eé][eé]|architect|plan|design|cod|audit|refactor|fix|bug|test|build|feature|ex[eé]cut|optimis|ajoute|modifi)/i.test(userInput);

if (!shouldEnforce) {
  console.log(JSON.stringify({ injectSteps: [] }, null, 2));
  process.exit(0);
}

const reminderText = "[SAN.AGY ENFORCER] (1) Never solo-code features inline: delegate exploration to san-researcher, architecture pre-mortem to san-architect, atomic implementation to san-coder-* / san-designer-worker. (2) Reject mediocre first drafts: challenge assumptions with san-qa-auditor (and visual PNG inspection for UI) + fail-closed gate scripts before checking [x].";

const response = {
  injectSteps: [
    {
      ephemeralMessage: reminderText
    }
  ]
};

console.log(JSON.stringify(response, null, 2));
process.exit(0);
