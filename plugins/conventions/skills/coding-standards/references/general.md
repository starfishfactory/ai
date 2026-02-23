# General Coding Conventions

## Git Workflow

### Branch Naming
- `feat/{issue}-{description}` — new feature
- `fix/{issue}-{description}` — bug fix
- `chore/{description}` — maintenance
- `docs/{description}` — documentation

### Commit Messages
- Follow Gitmoji + Conventional Commits (use `/git:commit`)
- Subject line: max 70 characters, imperative mood
- Body: explain "why", not "what"

### Pull Requests
- One PR per logical change
- PR title matches the main commit message
- Include test plan in PR description
- Request review from at least 1 team member

## Code Review

### Reviewer Responsibilities
- Check correctness, readability, maintainability
- Use severity prefixes: [BLOCKING], [MAJOR], [MINOR], [NIT], [PRAISE]
- Provide concrete suggestions with code examples
- Approve when all [BLOCKING] items are resolved

### Author Responsibilities
- Keep PRs small (< 400 lines preferred)
- Respond to all comments
- Don't force-push after review starts

## Documentation

### Language Rules
- Code comments: English
- User-facing docs (README, guides): Korean
- API docs: English
- Internal design docs: Korean or English (team preference)

### Comment Rules
- Explain "why", not "what" (code should be self-explanatory)
- No commented-out code — use version control
- TODO format: `// TODO(owner): description (#issue)`
- Update comments when changing the code they describe

## Dependencies

- Pin exact versions in production (`1.2.3`, not `^1.2.3`)
- Evaluate security advisories before adding new deps
- Prefer well-maintained libraries with active communities
- Document why each major dependency was chosen

## Security

- Never commit secrets (use `.env` + `.gitignore`)
- Validate all external input at system boundaries
- Use parameterized queries for database access
- Apply principle of least privilege for service accounts
- Enable HTTPS everywhere, TLS 1.2+
