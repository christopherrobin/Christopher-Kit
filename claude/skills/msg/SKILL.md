---
name: msg
description: Generate a git commit message following Conventional Commits format, auto-detecting project conventions
allowed-tools: Bash(git:*), Read, Glob
---

# Generate Git Commit Message

Generate a single-line git commit message for modified/uncommitted changes following Conventional Commits, adapted to the project's specific conventions when detected.

---

## CRITICAL RULES (DO NOT VIOLATE)

1. **NO period at the end** - message must NOT end with `.`
2. **Start message with lowercase** - first char after scope must be `[a-z0-9]`
3. **Imperative mood** - "add X" not "added X" or "adds X"
4. **Be concise** - one line, under 72 characters total when possible

---

## Step 1: Detect Project Conventions

Before generating the message, check for project-specific commit conventions:

1. Look for config files (check in order, stop at first match):
   - `commitlint.config.{js,cjs,mjs,ts}` or `.commitlintrc.*`
   - `.czrc` or `cz.json`
   - `pyproject.toml` — look for `[tool.commitizen]` section
   - `package.json` — look for `"commitizen"` or `"commitlint"` keys
   - `.changeset/config.json`
   - `CLAUDE.md` or `.claude/settings.json` for any commit message guidance

2. If conventions are found, adapt the format below to match (custom types, scopes, prefixes, etc.)
3. If no config is found, use standard Conventional Commits as described below.

## Step 2: Gather Context

1. Run `git diff --staged --name-status` to check staged changes first
2. If nothing is staged, run `git diff --name-status` to identify modified files (ignore untracked)
3. Run `git diff --staged` (or `git diff` if nothing staged) to understand actual changes
4. Run `git branch --show-current` to get the current branch name — extract any issue/ticket ID if present (e.g., `feat/PROJ-123-description` → `PROJ-123`)
5. Run `git log --oneline -5` to see recent commit style for consistency

## Step 3: Determine Message Components

### Format

```
<type>[optional scope]: [optional ticket] <description>
```

### Standard Types (use unless project config overrides):

- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `style` — formatting, no code change
- `refactor` — neither fix nor feature
- `perf` — performance improvement
- `test` — adding/updating tests
- `build` — build system or dependencies
- `ci` — CI configuration
- `chore` — maintenance, tooling, other

### Scope (optional):

- Derive from the primary directory or module affected by the changes
- Use the most specific meaningful scope (e.g., `auth`, `api`, `cli`, `db`)
- If changes span many areas, omit the scope

### Ticket/Issue ID (optional):

- Extract from branch name if present (any pattern like `PROJ-123`, `#123`, `GH-45`)
- Or from recent commits on the same branch
- Place in brackets after the colon: `feat(api): [PROJ-123] add endpoint`
- If no ticket is found, omit it entirely

### Description:

- Start with lowercase letter or digit
- Use imperative form ("add", "fix", "update", not "added", "fixes", "updated")
- Must NOT end with a period
- Keep concise but descriptive

## Step 4: Output

Output ONLY the commit message, nothing else. No explanation, no alternatives.

## Examples

```
feat(auth): [PROJ-123] add OAuth2 token refresh flow
fix: handle null values in search query parser
docs(api): update rate limiting section in README
refactor(db): extract connection pooling into shared module
test: add integration tests for payment webhook
chore: update dependency lockfile
```

## Important Notes

- Output ONLY the commit message — no commentary
- Match the style of recent commits in the repo when possible
- If project has custom types or scopes defined in config, prefer those over the defaults
- When in doubt about type, `fix` for corrections, `feat` for additions, `refactor` for restructuring
