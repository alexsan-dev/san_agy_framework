#!/usr/bin/env node
import fs from 'node:fs';

let input = '';
try {
  input = fs.readFileSync(0, 'utf8');
} catch {
  input = '';
}

let data = {};
try {
  if (input && input.trim()) data = JSON.parse(input);
} catch {
  data = {};
}

const toolCall = data.toolCall || {};
const args = toolCall.args || {};

const targetPath = (
  args.TargetFile || args.target_file ||
  args.TargetFilePath || args.target_file_path ||
  args.AbsolutePath || args.absolute_path ||
  args.FilePath || args.file_path ||
  args.Path || args.path || ''
).toString();
const normalizedPath = targetPath.replace(/\\/g, '/');

let textContent = '';
for (const key of ['Content', 'content', 'Replacement', 'replacement', 'CodeEdit', 'code_edit', 'Code', 'code', 'text', 'data']) {
  if (typeof args[key] === 'string') {
    textContent += (textContent ? '\n' : '') + args[key];
  }
}

// Garde 1 : Bloquer l'archivage d'une roadmap contenant des tâches non cochées (- [ ] ou * [ ])
const isArchiveRoadmap = normalizedPath.includes('roadmaps/archives/') || normalizedPath.includes('/roadmaps/archives/');
const hasUncheckedTasks = /(?:^|\n)\s*[-*]\s*\[\s*\]/.test(textContent);

if (isArchiveRoadmap && hasUncheckedTasks) {
  console.log(JSON.stringify({
    decision: 'deny',
    reason: "[SAN HARNESS GUARD] Interdiction absolue d'archiver une roadmap contenant encore des tâches non cochées (- [ ] ou * [ ]). Terminez ou annulez explicitement chaque tâche avant archivage."
  }, null, 2));
  process.exit(0);
}

// Garde 2 : Bloquer l'injection de lorem ipsum dans le code source ou les maquettes design
const isSourceOrDesign =
  /(?:src\/|app\/|components\/|design\/|resources\/)/i.test(normalizedPath) ||
  /\.(?:tsx?|jsx?|html|vue|svelte|php|py|go)(?:$|[?#])/i.test(normalizedPath);

const isTestOrFixture = /(?:^|\/)(?:tests?|specs?|__tests__|fixtures?)\/|(?:\.|\b)(?:test|spec)\.[a-z0-9]+$/i.test(normalizedPath);
const hasLorem = /(?:lorem[\s_]+ipsum|dolor[\s_]+sit[\s_]+amet|consectetur[\s_]+adipiscing|sed[\s_]+do[\s_]+eiusmod|tempor[\s_]+incididunt)/i.test(textContent);

if (isSourceOrDesign && !isTestOrFixture && hasLorem) {
  console.log(JSON.stringify({
    decision: 'deny',
    reason: '[SAN HARNESS GUARD] Tolérance zéro : injection de Lorem Ipsum / faux texte interdite dans le code applicatif et les maquettes design.'
  }, null, 2));
  process.exit(0);
}

console.log(JSON.stringify({
  decision: 'ask',
  reason: '[SAN HARNESS GUARD] Opération conforme soumise à confirmation utilisateur.'
}, null, 2));
process.exit(0);
