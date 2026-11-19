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

const workspaceRoot =
  Array.isArray(data.workspacePaths) && data.workspacePaths[0]?.trim()
    ? path.resolve(data.workspacePaths[0])
    : typeof data.cwd === 'string' && data.cwd.trim()
      ? path.resolve(data.cwd)
      : process.cwd();

let targetTokens = 120000;
try {
  const modelsFile = path.join(workspaceRoot, '.agents', 'models.json');
  if (fs.existsSync(modelsFile)) {
    const models = JSON.parse(fs.readFileSync(modelsFile, 'utf8'));
    const rawTarget = Number(models?.compaction?.targetTokens);
    if (Number.isFinite(rawTarget) && rawTarget >= 10000) {
      targetTokens = Math.floor(rawTarget);
    }
  }
} catch {}

let estimatedTokens = 0;

if (typeof data.transcriptPath === 'string' && data.transcriptPath.trim()) {
  try {
    const transcriptPath = path.resolve(data.transcriptPath.trim());
    if (fs.existsSync(transcriptPath)) {
      const stat = fs.statSync(transcriptPath);
      const TAIL_LIMIT = 4 * 1024 * 1024;
      let rawChunk = '';
      if (stat.size <= TAIL_LIMIT) {
        rawChunk = fs.readFileSync(transcriptPath, 'utf8');
      } else {
        const fd = fs.openSync(transcriptPath, 'r');
        try {
          const buf = Buffer.alloc(TAIL_LIMIT);
          fs.readSync(fd, buf, 0, TAIL_LIMIT, stat.size - TAIL_LIMIT);
          rawChunk = buf.toString('utf8');
        } finally {
          fs.closeSync(fd);
        }
      }

      const lines = rawChunk.split(/\r?\n/);
      let lastCompactLine = -1;
      let latestPlannerTokens = 0;

      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (!line) continue;
        if (
          line.includes('"CHECKPOINT"') ||
          line.includes('# Resuming from a compaction') ||
          line.includes('<CONTEXT_SUMMARY>')
        ) {
          lastCompactLine = i;
          latestPlannerTokens = 0;
          continue;
        }
        if (line.includes('"PLANNER_RESPONSE"') && line.includes('input_tokens')) {
          try {
            const parsed = JSON.parse(line);
            if (parsed.type === 'PLANNER_RESPONSE') {
              const inTok = Number(parsed.input_tokens) || 0;
              const cacheTok = Number(parsed.cache_read_tokens) || 0;
              if (inTok + cacheTok > 0) latestPlannerTokens = inTok + cacheTok;
            }
          } catch {}
        }
      }

      const activeSlice = lastCompactLine >= 0 ? lines.slice(lastCompactLine + 1).join('\n') : rawChunk;
      const bytesEstimate = Math.round(Buffer.byteLength(activeSlice, 'utf8') / 4);
      estimatedTokens = latestPlannerTokens > 0 ? Math.max(latestPlannerTokens, 0) : bytesEstimate;
    }
  } catch {}
}

const forced = data.forceCompactionCheckForTest === true;
if (forced || estimatedTokens >= targetTokens) {
  const estK = Math.round((forced && estimatedTokens === 0 ? targetTokens : estimatedTokens) / 1000);
  const targetK = Math.round(targetTokens / 1000);
  const reminder =
    `[SAN HARNESS — COMPACTION 120K] Contexte estimé ~${estK}k tokens (>= ${targetK}k). ` +
    'Exécutez /compact (ou synthétisez l\'état courant) pour préserver la précision et limiter le coût tokens.';
  console.log(JSON.stringify({
    injectSteps: [{ systemMessage: { systemMessage: reminder } }]
  }, null, 2));
  process.exit(0);
}

console.log(JSON.stringify({ injectSteps: [] }, null, 2));
process.exit(0);
