#!/usr/bin/env node

/**
 * SessionStart hook: Scan SF plugins and output catalog message.
 * Protocol: Read JSON from stdin, output { continue, [message] } to stdout.
 */

import { readFileSync, readdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Read stdin (hook protocol)
let input = '';
try {
  input = readFileSync('/dev/stdin', 'utf8');
} catch {
  // stdin may be empty
}

/**
 * Find repository root by walking up from plugin location.
 * Looks for .claude-plugin/marketplace.json as the marker.
 */
function findRepoRoot() {
  // Plugin is at plugins/lean-kit/scripts/ → go up 3 levels
  let dir = join(__dirname, '..', '..', '..');
  const marker = join(dir, '.claude-plugin', 'marketplace.json');
  if (existsSync(marker)) return dir;
  return null;
}

/**
 * Parse YAML-like frontmatter from a markdown file.
 * Returns an object with key-value pairs.
 */
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  const fm = {};
  for (const line of match[1].split('\n')) {
    const idx = line.indexOf(':');
    if (idx > 0) {
      const key = line.slice(0, idx).trim();
      const val = line.slice(idx + 1).trim();
      fm[key] = val;
    }
  }
  return fm;
}

/**
 * Scan skills directory for user-invocable skills.
 */
function scanSkills(skillsDir) {
  const skills = [];
  if (!existsSync(skillsDir)) return skills;
  for (const entry of readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const skillFile = join(skillsDir, entry.name, 'SKILL.md');
    if (!existsSync(skillFile)) continue;
    try {
      const content = readFileSync(skillFile, 'utf8');
      const fm = parseFrontmatter(content);
      // Skip non-user-invocable skills
      if (fm['user-invocable'] === 'false') continue;
      skills.push(fm.name || entry.name);
    } catch {
      // skip unreadable files
    }
  }
  return skills;
}

/**
 * Scan agents directory for agent metadata.
 */
function scanAgents(agentsDir) {
  const agents = [];
  if (!existsSync(agentsDir)) return agents;
  for (const entry of readdirSync(agentsDir, { withFileTypes: true })) {
    if (!entry.isFile() || !entry.name.endsWith('.md')) continue;
    try {
      const content = readFileSync(join(agentsDir, entry.name), 'utf8');
      const fm = parseFrontmatter(content);
      if (fm.name) {
        agents.push({ name: fm.name, model: fm.model || 'default' });
      }
    } catch {
      // skip
    }
  }
  return agents;
}

function main() {
  const root = findRepoRoot();
  if (!root) {
    console.log(JSON.stringify({ continue: true }));
    return;
  }

  let marketplace;
  try {
    marketplace = JSON.parse(readFileSync(join(root, '.claude-plugin', 'marketplace.json'), 'utf8'));
  } catch {
    console.log(JSON.stringify({ continue: true }));
    return;
  }

  const plugins = marketplace.plugins || [];
  if (plugins.length === 0) {
    console.log(JSON.stringify({ continue: true }));
    return;
  }

  const lines = ['**SF Plugins loaded:**'];

  for (const plugin of plugins) {
    const pluginDir = join(root, plugin.source.replace(/^\.\//, ''));
    const skills = scanSkills(join(pluginDir, 'skills'));
    const agents = scanAgents(join(pluginDir, 'agents'));

    const skillList = skills.length > 0
      ? skills.map(s => `/${plugin.name}:${s}`).join(', ')
      : '(none)';

    lines.push(`- **${plugin.name}**: ${skillList}`);

    if (agents.length > 0) {
      const agentList = agents.map(a => `${a.name}(${a.model})`).join(', ');
      lines.push(`  Agents: ${agentList}`);
    }
  }

  // Scan core/advanced agents
  const coreAgents = scanAgents(join(root, 'agents', 'core'));
  const advAgents = scanAgents(join(root, 'agents', 'advanced'));

  if (coreAgents.length > 0 || advAgents.length > 0) {
    lines.push('- **Core agents**: ' + coreAgents.map(a => `${a.name}(${a.model})`).join(', '));
    lines.push('- **Advanced agents**: ' + advAgents.map(a => `${a.name}(${a.model})`).join(', '));
  }

  console.log(JSON.stringify({
    continue: true,
    message: lines.join('\n')
  }));
}

main();
