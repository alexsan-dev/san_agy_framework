#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

// Read all stdin synchronously
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

// Determine workspace root
const workspaceRoot = (Array.isArray(data.workspacePaths) && data.workspacePaths.length > 0 && data.workspacePaths[0])
  ? data.workspacePaths[0]
  : process.cwd();

// Detect active roadmap in roadmaps/*.md (excluding archives/, ideas/, templates, readme)
let activeRoadmap = null;
try {
  const roadmapsDir = path.join(workspaceRoot, 'roadmaps');
  if (fs.existsSync(roadmapsDir)) {
    const entries = fs.readdirSync(roadmapsDir, { withFileTypes: true });
    const candidates = entries
      .filter(entry => entry.isFile() && entry.name.endsWith('.md') && !/^(?:readme|template|.*_template)\.md$/i.test(entry.name))
      .map(entry => {
        const fullPath = path.join(roadmapsDir, entry.name);
        let mtime = 0;
        try {
          mtime = fs.statSync(fullPath).mtimeMs;
        } catch {
          mtime = 0;
        }
        return { name: entry.name, mtime };
      })
      .sort((a, b) => b.mtime - a.mtime);

    if (candidates.length > 0) {
      activeRoadmap = candidates[0].name;
    }
  }
} catch {
  activeRoadmap = null;
}

// Detect project profile in .agents/rules/PROJECT.md or template
let projectProfile = null;
const candidateProfiles = [
  path.join(workspaceRoot, '.agents', 'rules', 'PROJECT.md'),
  path.join(workspaceRoot, 'src', 'skills', 'san_init', 'templates', 'rules', 'PROJECT_TEMPLATE.md')
];

for (const profileFile of candidateProfiles) {
  try {
    if (fs.existsSync(profileFile)) {
      const content = fs.readFileSync(profileFile, 'utf8');
      const profileMatch = content.match(/PROJECT_PROFILE:\s*["']?([a-zA-Z0-9_-]+)["']?/i);
      if (profileMatch && profileMatch[1] && !profileMatch[1].startsWith('[')) {
        projectProfile = profileMatch[1];
        break;
      }
    }
  } catch {
    // Continue checking other candidates
  }
}

const roadmapDisplay = activeRoadmap || 'none';
const profileDisplay = projectProfile ? ` (Profile: ${projectProfile})` : '';

const message = `[SAN.AGY CONSTITUTION v2.0] Active Harness: 8 native subagents (san-*), mandatory pre-mortem & adversarial QA inquisition, zero solo-coding policy. Roadmap: ${roadmapDisplay}${profileDisplay}.`;

const response = {
  injectSteps: [
    {
      systemMessage: {
        systemMessage: message
      }
    }
  ]
};

console.log(JSON.stringify(response, null, 2));
process.exit(0);
