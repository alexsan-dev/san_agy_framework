#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

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

const workspaceRoot = (Array.isArray(data.workspacePaths) && data.workspacePaths[0])
  ? data.workspacePaths[0]
  : (typeof data.cwd === 'string' && data.cwd.trim() ? data.cwd : process.cwd());

let activeRoadmap = 'none';
try {
  const roadmapsDir = path.join(workspaceRoot, 'roadmaps');
  if (fs.existsSync(roadmapsDir)) {
    const latest = fs.readdirSync(roadmapsDir, { withFileTypes: true })
      .filter((e) => e.isFile() && e.name.endsWith('.md') && !/^(?:readme|template|.*_template)\.md$/i.test(e.name))
      .map((e) => ({ name: e.name, mtime: fs.statSync(path.join(roadmapsDir, e.name)).mtimeMs }))
      .sort((a, b) => b.mtime - a.mtime)[0];
    if (latest) activeRoadmap = latest.name;
  }
} catch {}

let projectProfile = null;
const profileFiles = [
  path.join(workspaceRoot, '.agents', 'rules', 'PROJECT.md'),
  path.join(workspaceRoot, 'src', 'skills', 'san_init', 'templates', 'rules', 'PROJECT_TEMPLATE.md')
];
for (const file of profileFiles) {
  try {
    if (!fs.existsSync(file)) continue;
    const m = fs.readFileSync(file, 'utf8').match(/PROJECT_PROFILE:\s*["']?([a-zA-Z0-9_-]+)["']?/i);
    if (m && m[1] && !m[1].startsWith('[')) {
      projectProfile = m[1];
      break;
    }
  } catch {}
}

const profilePart = projectProfile ? ` (Profile: ${projectProfile})` : '';
const message =
  `[SAN AI HARNESS v3.0] Active Harness: 8 workers (san-*), adaptive Plan->Execute / Swarm delegation via .agents/models.json, 120k auto-compaction hygiene. Roadmap: ${activeRoadmap}${profilePart}.`;

console.log(JSON.stringify({
  injectSteps: [{ systemMessage: { systemMessage: message } }]
}, null, 2));
process.exit(0);
