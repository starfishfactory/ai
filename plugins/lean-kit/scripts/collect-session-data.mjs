#!/usr/bin/env node

/**
 * Collect and aggregate Claude CLI session data for a given date.
 *
 * Usage: node collect-session-data.mjs [YYYY-MM-DD]
 *   Default: yesterday (KST)
 *
 * Output: JSON to stdout with structured session statistics.
 * All timestamps are processed in KST (UTC+9).
 */

import { readdirSync, statSync, existsSync, createReadStream } from 'fs';
import { join, basename } from 'path';
import { homedir } from 'os';
import { createInterface } from 'readline';

// ─── Pricing (per 1M tokens) ─────────────────────────────────────────────────
const PRICING = {
  'claude-opus-4-6':   { input: 15.00, output: 75.00, cacheRead: 1.50, cacheCreate: 3.75 },
  'claude-sonnet-4-6': { input: 3.00,  output: 15.00, cacheRead: 0.30, cacheCreate: 3.75 },
  'claude-haiku-4-5':  { input: 0.80,  output: 4.00,  cacheRead: 0.08, cacheCreate: 1.00 },
};

const DEFAULT_PRICING_KEY = 'claude-opus-4-6';

// ─── Date Helpers (KST = UTC+9) ──────────────────────────────────────────────
const KST_OFFSET_MS = 9 * 60 * 60 * 1000;

function toKST(date) {
  return new Date(date.getTime() + KST_OFFSET_MS);
}

function getKSTDateString(date) {
  return toKST(date).toISOString().slice(0, 10);
}

function parseTargetDate(arg) {
  if (arg && /^\d{4}-\d{2}-\d{2}$/.test(arg)) return arg;
  // Default: yesterday KST
  const now = new Date();
  const yesterdayKST = new Date(now.getTime() + KST_OFFSET_MS - 86400000);
  return yesterdayKST.toISOString().slice(0, 10);
}

function getDateRange(dateStr) {
  // KST 00:00:00 = UTC previous day 15:00:00
  // KST 23:59:59.999 = UTC same day 14:59:59.999
  const [y, m, d] = dateStr.split('-').map(Number);
  const kstStart = new Date(Date.UTC(y, m - 1, d, 0, 0, 0) - KST_OFFSET_MS);
  const kstEnd = new Date(Date.UTC(y, m - 1, d, 23, 59, 59, 999) - KST_OFFSET_MS);
  return { start: kstStart, end: kstEnd };
}

// ─── JSONL Parsing ────────────────────────────────────────────────────────────
async function parseSessionFile(filePath) {
  const lines = [];
  const rl = createInterface({
    input: createReadStream(filePath, { encoding: 'utf8' }),
    crlfDelay: Infinity,
  });

  for await (const line of rl) {
    if (!line.trim()) continue;
    try {
      lines.push(JSON.parse(line));
    } catch {
      // skip malformed lines
    }
  }
  return lines;
}

function extractSessionData(events, projectDir) {
  const session = {
    sessionId: null,
    startTime: null,
    endTime: null,
    model: null,
    tokens: { input: 0, output: 0, cacheRead: 0, cacheCreate: 0 },
    tools: {},
    subagentTypes: {},
    prompts: [],
    detectedCommits: [],
    slashCommands: [],
    hasSendMessage: false,
    isEmpty: true,
  };

  let minTs = null;
  let maxTs = null;

  for (const ev of events) {
    const ts = ev.timestamp ? new Date(ev.timestamp) : null;
    if (ts) {
      if (!minTs || ts < minTs) minTs = ts;
      if (!maxTs || ts > maxTs) maxTs = ts;
    }

    if (!session.sessionId && ev.sessionId) {
      session.sessionId = ev.sessionId;
    }

    // Assistant messages: extract model, tokens, tool_use
    if (ev.type === 'assistant' && ev.message) {
      const msg = ev.message;

      if (msg.model && !session.model) {
        session.model = msg.model;
      }

      // Token usage
      if (msg.usage) {
        const u = msg.usage;
        session.tokens.input += (u.input_tokens || 0);
        session.tokens.output += (u.output_tokens || 0);
        session.tokens.cacheRead += (u.cache_read_input_tokens || 0);

        // cache_creation: Claude API has two formats depending on version:
        //   1. Flat: usage.cache_creation_input_tokens (older format)
        //   2. Nested: usage.cache_creation.ephemeral_{ttl}_input_tokens (newer format)
        // The flat field is the total; the nested object breaks down by TTL.
        // We prefer the flat field when present, falling back to summing nested.
        if (u.cache_creation_input_tokens) {
          session.tokens.cacheCreate += u.cache_creation_input_tokens;
        } else if (u.cache_creation) {
          const cc = u.cache_creation;
          session.tokens.cacheCreate += (cc.ephemeral_5m_input_tokens || 0) + (cc.ephemeral_1h_input_tokens || 0);
        }
      }

      // Tool use
      if (Array.isArray(msg.content)) {
        for (const block of msg.content) {
          if (block.type === 'tool_use') {
            const toolName = block.name;
            session.tools[toolName] = (session.tools[toolName] || 0) + 1;
            session.isEmpty = false;

            if (toolName === 'SendMessage') {
              session.hasSendMessage = true;
            }

            // Subagent detection
            if (toolName === 'Task' && block.input?.subagent_type) {
              const sat = block.input.subagent_type;
              session.subagentTypes[sat] = (session.subagentTypes[sat] || 0) + 1;
            }

            // Slash command detection (Skill tool)
            if (toolName === 'Skill' && block.input?.name) {
              session.slashCommands.push(block.input.name);
            }
          }
        }
      }
    }

    // User messages: extract prompts and git commit results
    if (ev.type === 'user' && ev.message) {
      const msg = ev.message;
      const content = msg.content;

      // Text prompts
      if (typeof content === 'string' && content.trim()) {
        session.prompts.push(content.trim());
        session.isEmpty = false;
      } else if (Array.isArray(content)) {
        for (const block of content) {
          if (block.type === 'text' && block.text?.trim()) {
            const text = block.text.trim();
            if (text !== '[Request interrupted by user for tool use]') {
              session.prompts.push(text);
              session.isEmpty = false;
            }
          }

          // Git commit detection in Bash tool results
          if (block.type === 'tool_result') {
            const resultText = typeof block.content === 'string'
              ? block.content
              : Array.isArray(block.content)
                ? block.content.map(c => c.text || '').join('\n')
                : '';
            detectGitCommits(resultText, session.detectedCommits);
          }
        }
      }

      // Slash commands from prompt
      if (typeof content === 'string') {
        const slashMatch = content.match(/^\/([a-z-]+(?::[a-z-]+)?)/);
        if (slashMatch) {
          session.slashCommands.push('/' + slashMatch[1]);
        }
      }
    }
  }

  session.startTime = minTs ? minTs.toISOString() : null;
  session.endTime = maxTs ? maxTs.toISOString() : null;

  return session;
}

function detectGitCommits(text, commits) {
  if (!text) return;

  // Only detect actual git commit output, NOT git log listings.
  // git commit output format: [branch-name hash] commit message
  // Examples:
  //   [main abc1234] feat: add new feature
  //   [feat/daily-report 1e2bec1] refactor: module restructure
  const commitOutputPattern = /\[[\w/.-]+\s+([a-f0-9]{7,40})\]\s+(.+)/g;
  let match;
  while ((match = commitOutputPattern.exec(text)) !== null) {
    const hash = match[1];
    const message = match[2].trim();
    if (!commits.some(c => c.hash === hash)) {
      commits.push({ hash, message });
    }
  }
}

// ─── Project Name Extraction ──────────────────────────────────────────────────
function extractProjectName(dirName) {
  // dirName format: -Users-jinhyung-yoo-IdeaProjects-org-project-subpath
  const parts = dirName.replace(/^-/, '').split('-');

  // Find meaningful segments after known prefixes
  // Skip: Users, username, IdeaProjects
  const ideaIdx = parts.findIndex(p => p === 'IdeaProjects');
  if (ideaIdx >= 0) {
    const meaningful = parts.slice(ideaIdx + 1);
    if (meaningful.length >= 2) {
      // org/project pattern — return last 2 segments as project identity
      return meaningful.slice(-2).join('/');
    }
    if (meaningful.length === 1) return meaningful[0];
  }

  // Fallback: last meaningful segment
  return parts[parts.length - 1] || dirName;
}

// ─── Cost Calculation ─────────────────────────────────────────────────────────
// Claude API usage fields are non-overlapping:
//   input_tokens = non-cached input only (fresh tokens, NOT including cache read/create)
//   cache_read_input_tokens = tokens served from cache
//   cache_creation_input_tokens = tokens written to cache
//   output_tokens = generated output
// Total input tokens = input + cache_read + cache_create (each priced differently)
function calculateCost(tokens, modelKey) {
  const pricing = PRICING[modelKey] || PRICING[DEFAULT_PRICING_KEY];
  const costs = {
    input: (tokens.input / 1_000_000) * pricing.input,
    output: (tokens.output / 1_000_000) * pricing.output,
    cacheRead: (tokens.cacheRead / 1_000_000) * pricing.cacheRead,
    cacheCreate: (tokens.cacheCreate / 1_000_000) * pricing.cacheCreate,
  };
  costs.total = costs.input + costs.output + costs.cacheRead + costs.cacheCreate;
  return costs;
}

// ─── Main ─────────────────────────────────────────────────────────────────────
async function main() {
  const targetDate = parseTargetDate(process.argv[2]);
  const { start, end } = getDateRange(targetDate);

  const projectsDir = join(homedir(), '.claude', 'projects');
  if (!existsSync(projectsDir)) {
    console.log(JSON.stringify({ error: 'No projects directory found', date: targetDate }));
    process.exit(1);
  }

  const projectDirs = readdirSync(projectsDir)
    .map(d => join(projectsDir, d))
    .filter(d => {
      try { return statSync(d).isDirectory(); } catch { return false; }
    });

  const projects = {};
  const allSessions = [];

  for (const projDir of projectDirs) {
    const dirName = basename(projDir);
    const projectName = extractProjectName(dirName);

    const jsonlFiles = readdirSync(projDir)
      .filter(f => f.endsWith('.jsonl'))
      .map(f => join(projDir, f));

    for (const filePath of jsonlFiles) {
      // Skip files not modified within ±2 days of target date (covers carry-over)
      let stat;
      try { stat = statSync(filePath); } catch { continue; }
      if (stat.mtimeMs < start.getTime() - 2 * 86400000) continue;

      const events = await parseSessionFile(filePath);
      if (events.length === 0) continue;

      const session = extractSessionData(events, projDir);
      if (!session.startTime) continue;

      const sessionStart = new Date(session.startTime);
      const sessionEnd = new Date(session.endTime);

      // Date filter: session must overlap with target date range
      // carry-over: started before but ended within range
      const overlaps = sessionStart <= end && sessionEnd >= start;
      if (!overlaps) continue;

      const isCarryOver = sessionStart < start;

      const cost = calculateCost(session.tokens, session.model || DEFAULT_PRICING_KEY);

      const sessionData = {
        sessionId: session.sessionId || basename(filePath, '.jsonl'),
        startTime: session.startTime,
        endTime: session.endTime,
        isCarryOver,
        model: session.model,
        tokens: session.tokens,
        cost,
        tools: session.tools,
        subagentTypes: session.subagentTypes,
        prompts: session.prompts,
        detectedCommits: session.detectedCommits,
        slashCommands: [...new Set(session.slashCommands)],
        sessionType: 'main', // will be classified later
        isEmpty: session.isEmpty,
      };

      if (!projects[projectName]) {
        projects[projectName] = { sessions: [], totals: null };
      }
      projects[projectName].sessions.push(sessionData);
      allSessions.push(sessionData);
    }
  }

  // Classify sessions (main/worker/empty)
  for (const session of allSessions) {
    if (session.isEmpty && session.prompts.length === 0) {
      session.sessionType = 'empty';
    } else if (session.tools['SendMessage']) {
      session.sessionType = 'worker';
    }
  }

  // Compute per-project totals
  for (const [name, proj] of Object.entries(projects)) {
    // Sort sessions by start time
    proj.sessions.sort((a, b) => new Date(a.startTime) - new Date(b.startTime));

    const totals = {
      sessionCount: proj.sessions.length,
      mainSessions: proj.sessions.filter(s => s.sessionType === 'main').length,
      workerSessions: proj.sessions.filter(s => s.sessionType === 'worker').length,
      emptySessions: proj.sessions.filter(s => s.sessionType === 'empty').length,
      tokens: { input: 0, output: 0, cacheRead: 0, cacheCreate: 0 },
      cost: { input: 0, output: 0, cacheRead: 0, cacheCreate: 0, total: 0 },
      toolUsage: {},
      commitCount: 0,
    };

    for (const s of proj.sessions) {
      totals.tokens.input += s.tokens.input;
      totals.tokens.output += s.tokens.output;
      totals.tokens.cacheRead += s.tokens.cacheRead;
      totals.tokens.cacheCreate += s.tokens.cacheCreate;
      totals.cost.input += s.cost.input;
      totals.cost.output += s.cost.output;
      totals.cost.cacheRead += s.cost.cacheRead;
      totals.cost.cacheCreate += s.cost.cacheCreate;
      totals.cost.total += s.cost.total;
      totals.commitCount += s.detectedCommits.length;

      for (const [tool, count] of Object.entries(s.tools)) {
        totals.toolUsage[tool] = (totals.toolUsage[tool] || 0) + count;
      }
    }

    proj.totals = totals;
  }

  // Compute global totals
  const globalTokens = { input: 0, output: 0, cacheRead: 0, cacheCreate: 0 };
  const globalCost = { input: 0, output: 0, cacheRead: 0, cacheCreate: 0, total: 0 };
  const globalTools = {};
  const globalSubagentTypes = {};
  let totalCommits = 0;
  let earliestStart = null;
  let latestEnd = null;
  let earliestNonCarryOver = null;

  for (const s of allSessions) {
    globalTokens.input += s.tokens.input;
    globalTokens.output += s.tokens.output;
    globalTokens.cacheRead += s.tokens.cacheRead;
    globalTokens.cacheCreate += s.tokens.cacheCreate;
    globalCost.input += s.cost.input;
    globalCost.output += s.cost.output;
    globalCost.cacheRead += s.cost.cacheRead;
    globalCost.cacheCreate += s.cost.cacheCreate;
    globalCost.total += s.cost.total;
    totalCommits += s.detectedCommits.length;

    for (const [tool, count] of Object.entries(s.tools)) {
      globalTools[tool] = (globalTools[tool] || 0) + count;
    }
    for (const [sat, count] of Object.entries(s.subagentTypes)) {
      globalSubagentTypes[sat] = (globalSubagentTypes[sat] || 0) + count;
    }

    // For time range: clamp carry-over session starts to target date start
    if (s.startTime) {
      const st = new Date(s.startTime);
      const effectiveStart = s.isCarryOver ? (st < start ? start : st) : st;
      if (!earliestStart || effectiveStart < earliestStart) earliestStart = effectiveStart;
      if (!s.isCarryOver && (!earliestNonCarryOver || st < earliestNonCarryOver)) {
        earliestNonCarryOver = st;
      }
    }
    if (s.endTime) {
      const et = new Date(s.endTime);
      if (!latestEnd || et > latestEnd) latestEnd = et;
    }
  }

  // Total tokens = sum of all billing token categories.
  // Each category (input, output, cacheRead, cacheCreate) is non-overlapping per the Claude API.
  const totalTokenCount = globalTokens.input + globalTokens.output + globalTokens.cacheRead + globalTokens.cacheCreate;

  // Round costs to 2 decimal places
  const round2 = (n) => Math.round(n * 100) / 100;
  globalCost.input = round2(globalCost.input);
  globalCost.output = round2(globalCost.output);
  globalCost.cacheRead = round2(globalCost.cacheRead);
  globalCost.cacheCreate = round2(globalCost.cacheCreate);
  globalCost.total = round2(globalCost.total);

  for (const proj of Object.values(projects)) {
    proj.totals.cost.input = round2(proj.totals.cost.input);
    proj.totals.cost.output = round2(proj.totals.cost.output);
    proj.totals.cost.cacheRead = round2(proj.totals.cost.cacheRead);
    proj.totals.cost.cacheCreate = round2(proj.totals.cost.cacheCreate);
    proj.totals.cost.total = round2(proj.totals.cost.total);
    for (const s of proj.sessions) {
      s.cost.input = round2(s.cost.input);
      s.cost.output = round2(s.cost.output);
      s.cost.cacheRead = round2(s.cost.cacheRead);
      s.cost.cacheCreate = round2(s.cost.cacheCreate);
      s.cost.total = round2(s.cost.total);
    }
  }

  const result = {
    date: targetDate,
    timezone: 'KST',
    projects,
    totals: {
      sessionCount: allSessions.length,
      mainSessions: allSessions.filter(s => s.sessionType === 'main').length,
      workerSessions: allSessions.filter(s => s.sessionType === 'worker').length,
      emptySessions: allSessions.filter(s => s.sessionType === 'empty').length,
      totalTokens: totalTokenCount,
      totalCost: globalCost.total,
      totalCommits,
      tokenBreakdown: globalTokens,
      costBreakdown: globalCost,
      toolUsage: globalTools,
      subagentTypes: globalSubagentTypes,
      timeRange: {
        earliest: earliestStart ? earliestStart.toISOString() : null,
        latest: latestEnd ? latestEnd.toISOString() : null,
        earliestKST: earliestStart ? toKST(earliestStart).toISOString().slice(11, 16) : null,
        latestKST: latestEnd ? toKST(latestEnd).toISOString().slice(11, 16) : null,
        earliestNonCarryOverKST: earliestNonCarryOver ? toKST(earliestNonCarryOver).toISOString().slice(11, 16) : null,
      },
      projectCount: Object.keys(projects).length,
    },
    pricing: Object.fromEntries(
      Object.entries(PRICING).map(([k, v]) => [k, {
        model: k,
        inputPerM: v.input,
        outputPerM: v.output,
        cacheReadPerM: v.cacheRead,
        cacheCreatePerM: v.cacheCreate,
      }])
    ),
  };

  console.log(JSON.stringify(result, null, 2));
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
