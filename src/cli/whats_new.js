/**
 * ==============================================================================
 * NOTES DE RELEASE & "WHAT'S NEW ON SAN AI HARNESS" — san_ai_harness
 * ==============================================================================
 */

export const LATEST_WHATS_NEW_VERSION = '3.0.0';

export const WHATS_NEW = {
  '3.0.0': {
    version: '3.0.0',
    date: '2026-11-19',
    title: "What's New on san_ai_harness v3.0.0 — Decoupled Dual-Harness, OpenCode Swarm Board & 120k Compaction",
    summary:
      'Renommage san_ai_harness (CLI san-harness), orchestration libre (/model), plugin natif OpenCode v2.3 avec Swarm Board, suppression complète du cache/map et compaction 120k.',
    highlights: [
      'Identité & CLI : renommage vers `san_ai_harness` (`@alexsan/san-ai-harness`), binaire `san-harness` (alias `san-framework` / `agy-framework`) et logo SVG adaptatif Dark/Light.',
      'Orchestration dé-couplée : l’orchestrateur suit le `/model` choisi par l’utilisateur (`inherit-user-model`) et les workers sont pilotés exclusivement via `.agents/models.json`.',
      'Doctrine assouplie : cycle natif `Plan → Execute` autorisé sur tâches simples/mono-couche ; `swarm` / `san_swarm` réservé au parallélisme multi-couches, Studio Duel UI et audit `san-qa-auditor`.',
      'Plugin natif OpenCode v2.3 (`./.agents/opencode`) : outil `san_swarm` parallèle avec vue tableau Markdown Swarm Board, `/san-board` et agent primaire `san-orchestrator`.',
      'Zéro `.agents/cache/` & zéro bloat : suppression de `san_cartographer`, `san_transcriber`, `post_tool_indexer.mjs` et `stop_guard.mjs`, remplacés par la compaction auto 120k tokens.'
    ]
  },
  '2.2.0': {
    version: '2.2.0',
    date: '2026-11-14',
    title: 'Dual-Harness (Antigravity + OpenCode V2), Models CLI & Alignement Socratique',
    summary:
      'Support OpenCode V2, commande models (.agents/models.json + opencode.json), alignement socratique et capture Playwright --url.',
    highlights: [
      'Dual-Harness natif Google Antigravity & OpenCode V2 (8 sous-agents san-*).',
      'Commande CLI `models` pilotant `.agents/models.json` et resynchronisant `opencode.json`.',
      'Alignement socratique préalable et capture web live `export_png.mjs --url` (Desktop/Mobile).'
    ]
  },
  '2.1.0': {
    version: '2.1.0',
    date: '2026-11-14',
    title: 'Swarm & Studio Engineering',
    summary:
      'Orchestrateur autonome, Mode --light, Workflows Python & Studio Duel UI.',
    highlights: [
      'Mode Héritage Léger (--light) via `.agents/skills.json`.',
      'Workflows Python déterministes (`run_workflow`) & Studio Duel UI (`option-a` vs `option-b`).',
      'export_png.mjs v2 : capture Multi-Viewports + Linter Géométrique DOM (`--audit-dom`).'
    ]
  }
};

export const WHATS_NEW_DATA = WHATS_NEW['3.0.0'];

const ANSI = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  cyan: '\x1b[36m',
  brightCyan: '\x1b[96m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m'
};

/**
 * Résout l'entrée What's New pour une version donnée (normalisée sans préfixe 'v').
 */
export function getWhatsNewEntry(version = LATEST_WHATS_NEW_VERSION) {
  const normalized = String(version || LATEST_WHATS_NEW_VERSION).replace(/^v/i, '').trim();
  if (WHATS_NEW[normalized]) {
    return WHATS_NEW[normalized];
  }
  return WHATS_NEW[LATEST_WHATS_NEW_VERSION];
}

/**
 * Formate l'encart terminal "What's New" pour `update` et `whats-new`.
 */
export function formatWhatsNewTerminal(version = LATEST_WHATS_NEW_VERSION, { useColors = true } = {}) {
  const entry = getWhatsNewEntry(version);
  const c = useColors
    ? ANSI
    : { reset: '', bold: '', cyan: '', brightCyan: '', green: '', yellow: '', gray: '' };

  const headerLine = entry.title.startsWith("What's New")
    ? `${c.brightCyan}${c.bold}${entry.title}${c.reset} ${c.gray}(${entry.date})${c.reset}`
    : `${c.brightCyan}${c.bold}What's New on san_ai_harness v${entry.version}${c.reset} ${c.gray}(${entry.date} · ${entry.title})${c.reset}`;

  const lines = [
    `${c.cyan}------------------------------------------------------------${c.reset}`,
    headerLine,
    `${c.gray}${entry.summary}${c.reset}`,
    ''
  ];

  entry.highlights.forEach((item, idx) => {
    lines.push(`  ${c.green}${idx + 1}.${c.reset} ${item}`);
  });

  lines.push(`${c.cyan}------------------------------------------------------------${c.reset}`);
  return lines.join('\n');
}

export default {
  LATEST_WHATS_NEW_VERSION,
  WHATS_NEW,
  WHATS_NEW_DATA,
  getWhatsNewEntry,
  formatWhatsNewTerminal
};
