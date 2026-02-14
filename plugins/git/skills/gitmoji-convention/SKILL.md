---
name: gitmoji-convention
description: Gitmoji + Conventional Commits rules, branch-commit type mapping, diff-based type inference
user-invocable: false
---
# Gitmoji + Conventional Commits Rules
## Gitmoji Type Mapping Table
| Type | Gitmoji | Description |
|------|---------|-------------|
| feat | ✨ | New feature |
| fix | 🐛 | Bug fix |
| docs | 📝 | Documentation update |
| style | 🎨 | Code formatting (no logic change) |
| refactor | ♻️ | Refactoring |
| test | ✅ | Add/update tests |
| chore | 🔧 | Build/config changes |
| perf | ⚡ | Performance improvement |
| ci | 💚 | CI config changes |
| build | 📦 | Build system/dependencies |
| revert | ⏪ | Revert previous commit |
## Conventional Commits Format
```
<gitmoji> <type>(<scope>): <subject>

<body>

<footer>
```
- **subject**: max 50 chars, imperative, lowercase start, no period
- **body**: explain why and diff from previous behavior (add when 3+ files changed)
- **footer**: Breaking Changes, issue references, etc.
## Branch Type → Commit Type Mapping
| Branch Prefix | Commit Type | Gitmoji |
|---------------|-------------|---------|
| feat/* | feat | ✨ |
| fix/* | fix | 🐛 |
| chore/* | chore | 🔧 |
| docs/* | docs | 📝 |
| refactor/* | refactor | ♻️ |
| test/* | test | ✅ |
| perf/* | perf | ⚡ |
## Diff-Based Type Inference Rules (File Patterns)
| File Pattern | Inferred Type |
|-------------|---------------|
| `*.test.*`, `*_test.*`, `*.spec.*`, `**/tests/**`, `**/test/**`, `**/__tests__/**` | test ✅ |
| `*.md`, `docs/**`, `README*`, `LICENSE*`, `CHANGELOG*` | docs 📝 |
| `Dockerfile`, `.github/**`, `*.yml` (CI), `.gitlab-ci.yml`, `Jenkinsfile` | ci 💚 |
| `package.json` only, `pom.xml` only, `build.gradle*` only, `go.mod` only | chore 🔧 |
| `.gitignore`, `.eslintrc*`, `tsconfig.json`, `.prettierrc*` | chore 🔧 |
| New files in `src/**` | feat ✨ |
| Mixed patterns (composite changes) | Ask user to choose |
## Type Decision Priority
1. **Branch name extraction** — use mapped type if branch prefix matches table above
2. **Diff file pattern inference** — use type if changed files converge to a single type
3. **AskUserQuestion** — prompt user when above methods are inconclusive
## Scope Rules (Optional)
- Use common parent directory name of changed files
  - e.g. `src/auth/login.ts`, `src/auth/oauth.ts` → scope=`auth`
- Single file change → scope may be omitted
- Monorepo → use package name
