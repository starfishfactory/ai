#!/usr/bin/env node

/**
 * UserPromptSubmit hook: Detect keywords and suggest relevant skills.
 * Protocol: Read JSON from stdin, output { continue, [message] } to stdout.
 */

import { readFileSync } from 'fs';

let input = '';
try {
  input = readFileSync('/dev/stdin', 'utf8');
} catch {
  console.log(JSON.stringify({ continue: true }));
  process.exit(0);
}

let prompt = '';
try {
  const data = JSON.parse(input);
  prompt = (data.prompt || data.message || '').toLowerCase();
} catch {
  console.log(JSON.stringify({ continue: true }));
  process.exit(0);
}

if (!prompt) {
  console.log(JSON.stringify({ continue: true }));
  process.exit(0);
}

/**
 * Keyword → skill mapping table.
 * Each entry: { keywords: string[], skill: string, description: string }
 */
const mappings = [
  {
    keywords: ['커밋', 'commit', '커밋해', '커밋 해'],
    skill: '/git:commit',
    description: 'Gitmoji smart commit'
  },
  {
    keywords: ['pr', '풀리퀘', 'pull request', '풀 리퀘스트', 'pr 만들', 'pr 생성', 'pr 리뷰'],
    skill: '/git:pr',
    description: 'PR creation/review'
  },
  {
    keywords: ['브랜치', 'branch', '브랜치 생성', '브랜치 정리'],
    skill: '/git:branch',
    description: 'Branch management'
  },
  {
    keywords: ['스펙', 'spec', '기술명세', '기술 명세', 'tech spec'],
    skill: '/sdd-tech-spec:write-spec',
    description: 'Write Tech Spec (SDD)'
  },
  {
    keywords: ['스펙 리뷰', 'spec review', '명세 리뷰', '명세 검토'],
    skill: '/sdd-tech-spec:review-spec',
    description: 'Review Tech Spec'
  },
  {
    keywords: ['msa', '온보딩', '마이크로서비스', 'microservice', 'msa 분석'],
    skill: '/msa-onboard-team:msa-analysis',
    description: 'MSA analysis with Agent Teams'
  },
  {
    keywords: ['셋업', 'setup', '설치', '플러그인 확인', 'plugin check'],
    skill: '/lean-kit:setup',
    description: 'Plugin setup & diagnostics'
  }
];

// Find matching skill
const matches = [];
for (const mapping of mappings) {
  for (const keyword of mapping.keywords) {
    if (prompt.includes(keyword)) {
      matches.push(mapping);
      break;
    }
  }
}

if (matches.length === 0) {
  console.log(JSON.stringify({ continue: true }));
  process.exit(0);
}

// Build suggestion message
const suggestions = matches
  .map(m => `\`${m.skill}\` — ${m.description}`)
  .join('\n');

const message = `**Tip**: Related skill available:\n${suggestions}`;

console.log(JSON.stringify({
  continue: true,
  message
}));
