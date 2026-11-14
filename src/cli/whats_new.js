/**
 * ==============================================================================
 * NOTES DE RELEASE & "WHAT'S NEW ON SAN-AGY" — FRAMEWORK ANTIGRAVITY (san_*)
 * ==============================================================================
 */

export const LATEST_WHATS_NEW_VERSION = '2.1.0';

export const WHATS_NEW = {
  '2.1.0': {
    version: '2.1.0',
    date: '2026-11-14',
    title: 'Hydrogen Swarm & Studio Engineering',
    summary:
      'Orchestrateur autonome Argon -> Swarm gemini-4-hydrogen-xhigh, Hook Stop anti-boucle, Mode --light, Workflows Python & Studio Duel UI.',
    highlights: [
      "What's New on san-agy : encart post-update dans le terminal, commande `whats-new` et injection unique au 1er SessionStart.",
      'Orchestrateur Autonome (Argon/Carbon) -> Swarm 100% gemini-4-hydrogen-xhigh (interdiction de Model: "inherit", suppression de 3.1-pro / 3.8-flash).',
      'Hook Stop (stop_guard.mjs) avec Circuit Breaker anti-boucle (max 2 relances) + Hooks API v2 (systemMessage dans pre_invocation.mjs).',
      'Mode Héritage Léger (--light) : génère .agents/skills.json ("inherits") sans dupliquer les 18 dossiers de skills + support san-framework doctor.',
      'Workflows Python déterministes (run_workflow + JSON Schema) : autonomous_slice_workflow.py et parallel_inquisition_workflow.py.',
      'Architecture Contract-First (OpenAPI 3.1 / Zod / TypeBox) & Architectural Fitness Functions vérifiées au Quality Gate.',
      'export_png.mjs v2 : capture Multi-Viewports (mobile 390x844, tablet 820x1180, desktop 1440x900) sur Chromium unique + Linter Géométrique DOM (--audit-dom).',
      'Mode Studio Duel UI (option-a vs option-b en parallèle) + Standard UI 5 États non-destructifs & Motion System (cubic-bezier, reduced-motion, >=44px).',
      'Continuité Map-First : san_cartographer & .agents/cache/REPO_MAP.md synchronisés en temps réel.'
    ]
  }
};

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
 * Formate l'encart terminal "What's New on san-agy" pour `update` et `whats-new`.
 */
export function formatWhatsNewTerminal(version = LATEST_WHATS_NEW_VERSION, { useColors = true } = {}) {
  const entry = getWhatsNewEntry(version);
  const c = useColors
    ? ANSI
    : { reset: '', bold: '', cyan: '', brightCyan: '', green: '', yellow: '', gray: '' };

  const lines = [
    `${c.cyan}------------------------------------------------------------${c.reset}`,
    `${c.brightCyan}${c.bold}What's New on san-agy v${entry.version}${c.reset} ${c.gray}(${entry.date} · ${entry.title})${c.reset}`,
    `${c.gray}${entry.summary}${c.reset}`,
    ''
  ];

  entry.highlights.forEach((item, idx) => {
    lines.push(`  ${c.green}${idx + 1}.${c.reset} ${item}`);
  });

  lines.push(`${c.cyan}------------------------------------------------------------${c.reset}`);
  return lines.join('\n');
}

/**
 * Formate la bannière compacte injectée dans systemMessage au 1er SessionStart post-update.
 */
export function formatWhatsNewSessionBanner(version = LATEST_WHATS_NEW_VERSION, pendingOverride = null) {
  const entry = getWhatsNewEntry(version);
  const effectiveVersion = (pendingOverride && pendingOverride.version) || entry.version;
  const highlights =
    pendingOverride && Array.isArray(pendingOverride.highlights) && pendingOverride.highlights.length > 0
      ? pendingOverride.highlights
      : entry.highlights;

  const bullets = highlights.map(item => `- ${item}`).join('\n');
  return `[WHAT'S NEW ON SAN.AGY v${effectiveVersion}] (${entry.date} — ${entry.title})\n${bullets}`;
}

export default {
  LATEST_WHATS_NEW_VERSION,
  WHATS_NEW,
  getWhatsNewEntry,
  formatWhatsNewTerminal,
  formatWhatsNewSessionBanner
};
