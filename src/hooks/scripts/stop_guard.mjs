#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const MAX_RETRIES = 2;
const GATE_MAX_AGE_MS = 30 * 60 * 1000;
const NORMAL_TERMINATION_REASONS = new Set([
  'CONVERSATION_TURN_COMPLETE',
  'NO_TOOL_CALL'
]);

function allowStop() {
  console.log(JSON.stringify({}));
  process.exit(0);
}

function readStdinJson() {
  let raw = '';
  try {
    raw = fs.readFileSync(0, 'utf8');
  } catch {
    return {};
  }
  if (!raw || !raw.trim()) return {};
  try {
    const parsed = JSON.parse(raw);
    return parsed && typeof parsed === 'object' ? parsed : {};
  } catch {
    return {};
  }
}

function resolveWorkspaceRoot(data) {
  if (
    Array.isArray(data.workspacePaths) &&
    data.workspacePaths.length > 0 &&
    typeof data.workspacePaths[0] === 'string' &&
    data.workspacePaths[0].trim()
  ) {
    return path.resolve(data.workspacePaths[0]);
  }
  if (typeof data.cwd === 'string' && data.cwd.trim()) {
    return path.resolve(data.cwd);
  }
  return process.cwd();
}

function readRetryCount(stateFile, conversationId) {
  try {
    if (!fs.existsSync(stateFile)) return 0;
    const raw = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
    if (!raw || typeof raw !== 'object') return 0;
    if (
      conversationId &&
      typeof raw.conversationId === 'string' &&
      raw.conversationId &&
      raw.conversationId !== conversationId
    ) {
      return 0;
    }
    const count = Number(raw.retryCount);
    return Number.isFinite(count) && count > 0 ? Math.floor(count) : 0;
  } catch {
    return 0;
  }
}

function writeStopState(stateFile, payload) {
  try {
    fs.mkdirSync(path.dirname(stateFile), { recursive: true });
    const content = {
      retryCount: 0,
      ...payload,
      updatedAt: new Date().toISOString()
    };
    fs.writeFileSync(stateFile, JSON.stringify(content, null, 2) + '\n', 'utf8');
  } catch {
    // Best-effort state persistence; never crash hook on IO failure
  }
}

function resetStateIfPresent(stateFile, conversationId, reason) {
  try {
    if (fs.existsSync(stateFile)) {
      writeStopState(stateFile, {
        retryCount: 0,
        conversationId: conversationId || null,
        lastResetReason: reason
      });
    }
  } catch {
    // Ignore cleanup errors
  }
}

function triggerStopBlock(stateFile, currentRetryCount, conversationId) {
  const nextRetry = currentRetryCount + 1;
  writeStopState(stateFile, {
    retryCount: nextRetry,
    conversationId: conversationId || null
  });
  console.log(
    JSON.stringify({
      decision: 'continue',
      reason: `[SAN.AGY STOP GUARD] Code applicatif modifié sans Quality Gate validé (.agents/cache/last-gate-status.json). Exécute les tests / Quality Gate avant de clore la tâche (Relance ${nextRetry}/${MAX_RETRIES}).`
    })
  );
  process.exit(0);
}

function getModifiedPaths(workspaceRoot) {
  let output = '';
  try {
    output = execFileSync(
      'git',
      ['-c', 'safe.directory=*', 'status', '--porcelain', '-uall'],
      {
        cwd: workspaceRoot,
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'pipe'],
        timeout: 2000
      }
    );
  } catch {
    return null;
  }

  if (!output || !output.trim()) {
    return [];
  }

  const paths = [];
  for (const line of output.split(/\r?\n/)) {
    if (!line || line.length < 4) continue;
    let filePart = line.slice(3).trim();
    if (!filePart) continue;
    if (filePart.includes(' -> ')) {
      filePart = filePart.split(' -> ').pop().trim();
    }
    if (filePart.startsWith('"') && filePart.endsWith('"') && filePart.length >= 2) {
      filePart = filePart.slice(1, -1);
    }
    const normalized = filePart.replace(/\\/g, '/').replace(/^\.\//, '');
    if (normalized) {
      paths.push(normalized);
    }
  }
  return paths;
}

function isDocOrConfigExempt(relPath) {
  const p = relPath.replace(/\\/g, '/').replace(/^\.\//, '');
  if (!p) return true;
  if (/\.(?:md|mdx)$/i.test(p)) return true;
  if (/^roadmaps(?:\/|$)/i.test(p)) return true;
  if (/^docs(?:\/|$)/i.test(p)) return true;
  if (/(?:^|\/)\.agents(?:\/|$)/i.test(p)) return true;
  return false;
}

function parseTimestampMs(rawTs) {
  if (typeof rawTs === 'number' && Number.isFinite(rawTs)) {
    return rawTs > 0 && rawTs < 1e12 ? rawTs * 1000 : rawTs;
  }
  if (typeof rawTs === 'string' && rawTs.trim()) {
    const trimmed = rawTs.trim();
    if (/^\d+(?:\.\d+)?$/.test(trimmed)) {
      const num = Number(trimmed);
      if (Number.isFinite(num)) {
        return num > 0 && num < 1e12 ? num * 1000 : num;
      }
    }
    const parsed = Date.parse(trimmed);
    return Number.isNaN(parsed) ? null : parsed;
  }
  return null;
}

function hasValidRecentQualityGate(gateStatusFile) {
  try {
    if (!fs.existsSync(gateStatusFile)) return false;
    const gate = JSON.parse(fs.readFileSync(gateStatusFile, 'utf8'));
    if (!gate || gate.passed !== true) return false;
    const tsMs = parseTimestampMs(gate.timestamp);
    if (tsMs === null) return false;
    const ageMs = Date.now() - tsMs;
    return ageMs >= -60_000 && ageMs < GATE_MAX_AGE_MS;
  } catch {
    return false;
  }
}

try {
  const data = readStdinJson();
  const workspaceRoot = resolveWorkspaceRoot(data);
  const cacheDir = path.join(workspaceRoot, '.agents', 'cache');
  const stateFile = path.join(cacheDir, 'stop-guard-state.json');
  const gateStatusFile = path.join(cacheDir, 'last-gate-status.json');
  const conversationId =
    typeof data.conversationId === 'string' && data.conversationId.trim()
      ? data.conversationId.trim()
      : null;

  // 1. Allow stop immediately on non-normal termination reasons (cancel, error, budget limit, etc.)
  if (typeof data.terminationReason === 'string' && data.terminationReason.trim() !== '') {
    const reason = data.terminationReason.trim();
    if (!NORMAL_TERMINATION_REASONS.has(reason)) {
      resetStateIfPresent(stateFile, conversationId, `termination:${reason}`);
      allowStop();
    }
  }

  // 2. Native Antigravity continuation guard: allow stop and reset retry counter
  if (data.continuationActive === true) {
    writeStopState(stateFile, {
      retryCount: 0,
      conversationId,
      lastResetReason: 'continuationActive'
    });
    allowStop();
  }

  // 3. Circuit Breaker: max 2 forced continuations per turn
  const currentRetryCount = readRetryCount(stateFile, conversationId);
  if (currentRetryCount >= MAX_RETRIES) {
    writeStopState(stateFile, {
      retryCount: 0,
      conversationId,
      lastResetReason: 'circuit_breaker_max_retries'
    });
    allowStop();
  }

  // 4. Unit test deterministic trigger
  if (data.forceBlockForTest === true) {
    triggerStopBlock(stateFile, currentRetryCount, conversationId);
  }

  // 5. Inspect workspace changes: exempt greenfield / non-git / clean / DOC_ONLY sessions
  const modifiedPaths = getModifiedPaths(workspaceRoot);
  if (modifiedPaths === null || modifiedPaths.length === 0) {
    if (currentRetryCount > 0) {
      resetStateIfPresent(stateFile, conversationId, 'no_app_changes');
    }
    allowStop();
  }

  const hasAppCodeChanges = modifiedPaths.some(p => !isDocOrConfigExempt(p));
  if (!hasAppCodeChanges) {
    if (currentRetryCount > 0) {
      resetStateIfPresent(stateFile, conversationId, 'doc_only');
    }
    allowStop();
  }

  // 6. Verify fresh passing Quality Gate proof (.agents/cache/last-gate-status.json)
  if (hasValidRecentQualityGate(gateStatusFile)) {
    if (currentRetryCount > 0) {
      resetStateIfPresent(stateFile, conversationId, 'quality_gate_passed');
    }
    allowStop();
  }

  triggerStopBlock(stateFile, currentRetryCount, conversationId);
} catch {
  allowStop();
}
