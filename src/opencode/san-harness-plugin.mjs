import fs from 'node:fs';
import path from 'node:path';

const DEFAULT_EXECUTOR = 'opencode-go/qwen3.8-flash';
const DEFAULT_TARGET_TOKENS = 120000;
const READONLY_AGENTS = new Set(['san-researcher', 'san-architect', 'san-qa-auditor']);

const sessionBoards = new Map();
const sessionTokenEstimates = new Map();

function readModelsConfig(directory) {
  const result = {
    executor: DEFAULT_EXECUTOR,
    targetTokens: DEFAULT_TARGET_TOKENS
  };
  try {
    const modelsPath = path.join(directory, '.agents', 'models.json');
    if (fs.existsSync(modelsPath)) {
      const parsed = JSON.parse(fs.readFileSync(modelsPath, 'utf8'));
      if (typeof parsed?.opencode?.executor === 'string' && parsed.opencode.executor.trim()) {
        result.executor = parsed.opencode.executor.trim();
      }
      const rawTarget = Number(parsed?.compaction?.targetTokens);
      if (Number.isFinite(rawTarget) && rawTarget >= 10000) {
        result.targetTokens = Math.floor(rawTarget);
      }
    }
  } catch {}
  return result;
}

function getActiveRoadmapName(directory) {
  try {
    const roadmapsDir = path.join(directory, 'roadmaps');
    if (!fs.existsSync(roadmapsDir)) return 'none';
    const latest = fs.readdirSync(roadmapsDir, { withFileTypes: true })
      .filter((e) => e.isFile() && e.name.endsWith('.md') && !/^(?:readme|template|.*_template)\.md$/i.test(e.name))
      .map((e) => ({ name: e.name, mtime: fs.statSync(path.join(roadmapsDir, e.name)).mtimeMs }))
      .sort((a, b) => b.mtime - a.mtime)[0];
    return latest ? latest.name : 'none';
  } catch {
    return 'none';
  }
}

function loadAgentSpec(directory, agentName) {
  const safeName = String(agentName || 'san-coder-back').replace(/[^a-zA-Z0-9_-]/g, '');
  const agentPath = path.join(directory, '.agents', 'agents', `${safeName}.md`);
  if (!fs.existsSync(agentPath)) return null;
  try {
    const raw = fs.readFileSync(agentPath, 'utf8');
    const fm = raw.match(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/);
    return (fm ? raw.slice(fm[0].length) : raw).trim();
  } catch {
    return null;
  }
}

function parseModelRef(modelString) {
  if (typeof modelString !== 'string' || !modelString.includes('/')) return undefined;
  const slashIdx = modelString.indexOf('/');
  const providerID = modelString.slice(0, slashIdx).trim();
  let modelID = modelString.slice(slashIdx + 1).trim();
  const hashIdx = modelID.indexOf('#');
  if (hashIdx > 0) modelID = modelID.slice(0, hashIdx).trim();
  if (!providerID || !modelID) return undefined;
  return { providerID, id: modelID };
}

function formatModelName(modelObjOrStr, fallback) {
  if (typeof modelObjOrStr === 'string' && modelObjOrStr.trim()) return modelObjOrStr.trim();
  if (modelObjOrStr && typeof modelObjOrStr === 'object') {
    const p = modelObjOrStr.providerID || modelObjOrStr.providerId;
    const id = modelObjOrStr.id || modelObjOrStr.modelID || modelObjOrStr.modelId;
    if (p && id) return `${p}/${id}`;
    if (id) return String(id);
  }
  return fallback;
}

function estimateContextTokens(event) {
  let chars = 0;
  try {
    if (Array.isArray(event?.messages)) {
      for (const msg of event.messages) {
        if (!msg || typeof msg !== 'object') continue;
        if (typeof msg.content === 'string') {
          chars += msg.content.length;
        } else if (Array.isArray(msg.content)) {
          for (const part of msg.content) {
            if (part && typeof part.text === 'string') chars += part.text.length;
            else if (part && typeof part.content === 'string') chars += part.content.length;
          }
        } else if (Array.isArray(msg.parts)) {
          for (const part of msg.parts) {
            if (part && typeof part.text === 'string') chars += part.text.length;
          }
        }
      }
    }
    if (Array.isArray(event?.system)) {
      for (const part of event.system) {
        if (part && typeof part.text === 'string') chars += part.text.length;
      }
    }
  } catch {}
  return Math.round(chars / 4);
}

function extractLastAssistantText(entries) {
  if (!Array.isArray(entries)) return '';
  const texts = [];
  let lastUserIdx = -1;
  for (let i = 0; i < entries.length; i++) {
    const e = entries[i];
    if (e && (e.role === 'user' || (typeof e.type === 'string' && e.type.includes('user')))) {
      lastUserIdx = i;
    }
  }
  const tail = entries.slice(lastUserIdx + 1);
  for (const e of tail) {
    if (!e || typeof e !== 'object') continue;
    const isAssistant = e.role === 'assistant' || (typeof e.type === 'string' && e.type.includes('assistant'));
    if (!isAssistant) continue;
    if (typeof e.text === 'string') texts.push(e.text);
    const parts = Array.isArray(e.content) ? e.content : (Array.isArray(e.parts) ? e.parts : null);
    if (parts) {
      for (const p of parts) {
        if (p && p.type === 'text' && typeof p.text === 'string') texts.push(p.text);
      }
    }
  }
  return texts.join('\n').trim();
}

function summarizeText(text) {
  if (!text) return 'Aucune sortie textuelle';
  const clean = text.replace(/\s+/g, ' ').replace(/\|/g, '/').trim();
  return clean.length > 140 ? `${clean.slice(0, 137)}...` : clean;
}

function formatDuration(ms) {
  if (!Number.isFinite(ms) || ms < 0) return '0ms';
  if (ms < 1000) return `${Math.round(ms)}ms`;
  return `${(ms / 1000).toFixed(1)}s`;
}

function getOrCreateBoard(sessionID) {
  const key = sessionID || 'default';
  if (!sessionBoards.has(key)) sessionBoards.set(key, []);
  return sessionBoards.get(key);
}

function renderWaveMarkdown(wave, tokenEstimate, targetTokens) {
  const doneCount = wave.rows.filter((r) => r.ok).length;
  const estK = Math.round((tokenEstimate || 0) / 1000);
  const targetK = Math.round(targetTokens / 1000);
  const lines = [
    `### ⚡ SAN AI Harness — Swarm Board (Wave #${wave.index} : ${wave.title})`,
    '',
    '| Worker | Agent | Modèle | Statut | Durée | Résumé |',
    '| :--- | :--- | :--- | :--- | :--- | :--- |'
  ];
  for (const r of wave.rows) {
    lines.push(`| ${r.name} | \`${r.agent}\` | \`${r.model}\` | ${r.status} | ${r.duration} | ${r.summary} |`);
  }
  lines.push('');
  lines.push(`**Workflow Summary :** ${doneCount}/${wave.rows.length} terminés · Contexte estimé : ~${estK}k / ${targetK}k tokens`);
  return lines.join('\n');
}

function mapNativeChildStatus(rawStatus) {
  const statusStr = typeof rawStatus === 'string'
    ? rawStatus.toLowerCase()
    : (typeof rawStatus?.type === 'string' ? rawStatus.type.toLowerCase() : '');

  if (statusStr.includes('busy') || statusStr.includes('running') || statusStr.includes('pending') || statusStr.includes('active')) {
    return { ok: false, label: '⏳ RUNNING' };
  }
  if (statusStr.includes('err') || statusStr.includes('fail') || statusStr.includes('abort')) {
    return { ok: false, label: '❌ ERROR' };
  }
  return { ok: true, label: '✅ DONE' };
}

async function listNativeChildSessions(ctx, parentSessionID, fallbackModel) {
  if (!parentSessionID || parentSessionID === 'default' || typeof ctx?.session?.list !== 'function') {
    return [];
  }
  try {
    const raw = await ctx.session.list();
    const entries = Array.isArray(raw)
      ? raw
      : (Array.isArray(raw?.sessions) ? raw.sessions : (Array.isArray(raw?.data) ? raw.data : []));

    const children = [];
    for (const s of entries) {
      if (!s || typeof s !== 'object') continue;
      const pId = s.parentID || s.parentId;
      if (pId !== parentSessionID) continue;

      const mapped = mapNativeChildStatus(s.status || s.state);
      const createdAt = Number(s.time?.created || s.createdAt || 0);
      const updatedAt = Number(s.time?.updated || s.updatedAt || 0);
      const durationMs = createdAt > 0
        ? (mapped.label === '⏳ RUNNING' ? Date.now() - createdAt : Math.max(0, (updatedAt || Date.now()) - createdAt))
        : 0;

      const agent = String(s.agent || s.agentID || s.agentName || 'subagent');
      const title = summarizeText(s.title || s.slug || s.id || agent);
      children.push({
        sessionID: s.id,
        name: title,
        agent,
        model: formatModelName(s.model, fallbackModel),
        ok: mapped.ok,
        status: mapped.label,
        duration: formatDuration(durationMs),
        summary: s.title ? summarizeText(s.title) : `Session ${s.id || agent}`
      });
    }
    return children;
  } catch {
    return [];
  }
}

async function runWorkerTask(ctx, directory, parentSessionID, task, executorModel) {
  const started = Date.now();
  const modelObj = parseModelRef(executorModel);
  const systemPrompt = loadAgentSpec(directory, task.agent);
  const permissions = READONLY_AGENTS.has(task.agent)
    ? [{ action: 'edit', resource: '*', effect: 'deny' }]
    : undefined;

  let subSessionID = null;
  let contextSub = null;
  try {
    const created = await ctx.session.create({
      ...(parentSessionID ? { parentID: parentSessionID } : {}),
      title: `[SAN Swarm] ${task.name} (${task.agent})`,
      agent: task.agent,
      ...(modelObj ? { model: modelObj } : {}),
      location: { directory },
      ...(permissions ? { permissions } : {})
    });
    subSessionID = created?.id || null;
    if (!subSessionID) throw new Error('session.create did not return an id');

    if (systemPrompt && typeof ctx.session.hook === 'function') {
      contextSub = await ctx.session.hook('context', async (event) => {
        if (!event || event.sessionID !== subSessionID) return;
        if (Array.isArray(event.system)) {
          event.system.push({ type: 'text', text: systemPrompt });
        }
      });
    }

    await ctx.session.prompt({ sessionID: subSessionID, text: task.prompt });
    await ctx.session.wait({ sessionID: subSessionID });
    const entries = await ctx.session.context({ sessionID: subSessionID });
    const rawOutput = extractLastAssistantText(entries);

    return {
      sessionID: subSessionID,
      name: task.name,
      agent: task.agent,
      model: executorModel,
      ok: true,
      status: '✅ DONE',
      duration: formatDuration(Date.now() - started),
      summary: summarizeText(rawOutput),
      rawOutput
    };
  } catch (err) {
    return {
      sessionID: subSessionID,
      name: task.name,
      agent: task.agent,
      model: executorModel,
      ok: false,
      status: '❌ ERROR',
      duration: formatDuration(Date.now() - started),
      summary: summarizeText(err instanceof Error ? err.message : String(err)),
      rawOutput: ''
    };
  } finally {
    if (contextSub && typeof contextSub.dispose === 'function') {
      await contextSub.dispose().catch(() => {});
    }
  }
}

export default {
  id: 'san-ai-harness',
  async setup(ctx) {
    const directory = ctx?.location?.directory || process.cwd();
    const registrations = [];

    if (ctx?.tool && typeof ctx.tool.transform === 'function') {
      const toolReg = await ctx.tool.transform((editor) => {
        editor.add({
          name: 'san_swarm',
          description: 'SAN AI Harness Swarm orchestrator: dispatches parallel san-* workers with a live Swarm Board table and workflow summary, or inspects board/compaction status (including native OpenCode subagent sessions).',
          input: {
            type: 'object',
            properties: {
              action: { type: 'string', enum: ['dispatch', 'board', 'status'] },
              waveTitle: { type: 'string' },
              tasks: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    name: { type: 'string' },
                    agent: { type: 'string' },
                    prompt: { type: 'string' }
                  },
                  required: ['name', 'agent', 'prompt']
                }
              }
            },
            required: ['action']
          },
          execute: async (input, context) => {
            const models = readModelsConfig(directory);
            const parentSessionID = context?.sessionID || 'default';
            const board = getOrCreateBoard(parentSessionID);
            const tokEst = sessionTokenEstimates.get(parentSessionID) || 0;

            const trackedIds = new Set();
            for (const wave of board) {
              for (const row of wave.rows || []) {
                if (row.sessionID) trackedIds.add(row.sessionID);
              }
            }

            if (input.action === 'status') {
              const roadmap = getActiveRoadmapName(directory);
              const estK = Math.round(tokEst / 1000);
              const targetK = Math.round(models.targetTokens / 1000);
              const nativeAll = await listNativeChildSessions(ctx, parentSessionID, models.executor);
              const untrackedNative = nativeAll.filter((c) => !c.sessionID || !trackedIds.has(c.sessionID));
              return {
                content: [
                  '### 🧭 SAN AI Harness — Status',
                  `- **Executor (\`opencode.executor\`) :** \`${models.executor}\``,
                  `- **Roadmap active :** \`${roadmap}\``,
                  `- **Vagues \`san_swarm\` :** ${board.length}`,
                  `- **Sous-agents natifs (\`subagent\`) détectés :** ${untrackedNative.length}`,
                  `- **Compaction Auto :** ~${estK}k / ${targetK}k tokens`
                ].join('\n')
              };
            }

            if (input.action === 'board') {
              const nativeAll = await listNativeChildSessions(ctx, parentSessionID, models.executor);
              const nativeChildren = nativeAll.filter((c) => !c.sessionID || !trackedIds.has(c.sessionID));

              if (board.length === 0 && nativeChildren.length === 0) {
                const estK = Math.round(tokEst / 1000);
                const targetK = Math.round(models.targetTokens / 1000);
                return {
                  content: `### ⚡ SAN AI Harness — Swarm Board\nAucun worker dispatché dans cette session.\n\n**Contexte estimé :** ~${estK}k / ${targetK}k tokens`
                };
              }

              const sections = board.map((w) => renderWaveMarkdown(w, tokEst, models.targetTokens));
              if (nativeChildren.length > 0) {
                sections.push(
                  renderWaveMarkdown(
                    {
                      index: board.length + 1,
                      title: 'Sessions Subagent Natives (OpenCode)',
                      rows: nativeChildren
                    },
                    tokEst,
                    models.targetTokens
                  )
                );
              }

              return {
                content: sections.join('\n\n---\n\n')
              };
            }

            const tasks = Array.isArray(input.tasks) ? input.tasks : [];
            if (tasks.length === 0) {
              return { content: '⚠️ `san_swarm(action: "dispatch")` requiert au moins 1 tâche dans `tasks`.' };
            }

            const waveTitle = input.waveTitle || `Parallel Execution (${tasks.length} workers)`;
            let completed = 0;
            const notifyProgress = () => {
              try {
                if (typeof context?.progress === 'function') {
                  context.progress({
                    title: `⚡ SAN Swarm [${completed}/${tasks.length}] ${waveTitle}`,
                    done: completed,
                    total: tasks.length
                  });
                }
              } catch {}
            };

            notifyProgress();
            const settled = await Promise.allSettled(
              tasks.map(async (t) => {
                const res = await runWorkerTask(ctx, directory, parentSessionID, t, models.executor);
                completed += 1;
                notifyProgress();
                return res;
              })
            );

            const rows = settled.map((item, idx) =>
              item.status === 'fulfilled'
                ? item.value
                : {
                    sessionID: null,
                    name: tasks[idx]?.name || `worker-${idx + 1}`,
                    agent: tasks[idx]?.agent || 'unknown',
                    model: models.executor,
                    ok: false,
                    status: '❌ ERROR',
                    duration: '0ms',
                    summary: summarizeText(String(item.reason)),
                    rawOutput: ''
                  }
            );

            const wave = { index: board.length + 1, title: waveTitle, rows };
            board.push(wave);

            const boardMd = renderWaveMarkdown(wave, tokEst, models.targetTokens);
            const details = rows
              .filter((r) => r.rawOutput)
              .map((r) => `#### Résultat \`${r.name}\` (\`${r.agent}\`)\n${r.rawOutput}`)
              .join('\n\n');

            return {
              content: details ? `${boardMd}\n\n---\n\n${details}` : boardMd
            };
          }
        });
      });
      registrations.push(toolReg);
    }

    if (ctx?.command && typeof ctx.command.transform === 'function') {
      const cmdReg = await ctx.command.transform((editor) => {
        editor.add({
          name: 'san-board',
          description: 'Afficher le tableau de bord SAN Swarm et le résumé du workflow',
          execute: async (invocation) => {
            if (typeof ctx?.session?.prompt === 'function' && invocation?.sessionID) {
              await ctx.session.prompt({
                sessionID: invocation.sessionID,
                text: 'Appelle san_swarm(action: "board") et affiche uniquement le Swarm Board et son Workflow Summary.'
              });
            }
          }
        });
      });
      registrations.push(cmdReg);
    }

    if (ctx?.session && typeof ctx.session.hook === 'function') {
      const ctxHook = await ctx.session.hook('context', async (event) => {
        if (!event?.sessionID) return;
        const models = readModelsConfig(directory);
        const est = estimateContextTokens(event);
        sessionTokenEstimates.set(event.sessionID, est);
        if (est >= models.targetTokens && Array.isArray(event.system)) {
          const estK = Math.round(est / 1000);
          const targetK = Math.round(models.targetTokens / 1000);
          event.system.push({
            type: 'text',
            text: `[SAN AI HARNESS — COMPACTION ${targetK}K] Contexte estimé ~${estK}k tokens (>= ${targetK}k). Lance /compact ou synthétise l'état avant dérive.`
          });
        }
      });
      registrations.push(ctxHook);

      const cmpHook = await ctx.session.hook('compaction', async (event) => {
        if (event?.sessionID) sessionTokenEstimates.set(event.sessionID, 0);
        const roadmap = getActiveRoadmapName(directory);
        if (Array.isArray(event?.system)) {
          event.system.push({
            type: 'text',
            text: `Préserver strictement les règles .agents/rules/*.md et la roadmap active (${roadmap}).`
          });
        }
      });
      registrations.push(cmpHook);
    }

    return async () => {
      for (const reg of registrations) {
        if (reg && typeof reg.dispose === 'function') {
          await reg.dispose().catch(() => {});
        }
      }
    };
  }
};
