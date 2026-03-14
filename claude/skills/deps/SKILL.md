---
name: deps
description: Check for outdated, vulnerable, or unused dependencies and suggest updates. This skill should be used when the user asks to 'check deps', 'update dependencies', 'audit packages', 'find vulnerabilities', or wants to know which packages are outdated or insecure.
allowed-tools: Bash, Read, Glob, Grep
---

Audit project dependencies for outdated versions, known vulnerabilities, and unused packages.

## Instructions

1. **Detect package manager:** Check for `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun), `requirements.txt` / `pyproject.toml` (Python), or `Gemfile.lock` (Ruby).

2. **Check outdated packages:**
   - Node.js: Run `npm outdated` or equivalent
   - Python: Run `pip list --outdated` or `uv pip list --outdated`
   - Report current version, wanted version, and latest version for each

3. **Check for vulnerabilities:**
   - Node.js: Run `npm audit` (or `yarn audit`, `pnpm audit`)
   - Python: Run `pip-audit` if available
   - Report severity (critical, high, medium, low) and affected package

4. **Check for unused dependencies:**
   - Search the codebase for import/require statements
   - Compare against dependencies listed in package.json or requirements.txt
   - Flag packages that are installed but never imported

5. **Report:** Present findings in a structured format:

   ```markdown
   ## Dependency Audit

   ### Vulnerabilities
   | Package | Severity | Description | Fix |
   |---------|----------|-------------|-----|

   ### Outdated (Major)
   | Package | Current | Latest | Breaking Changes? |
   |---------|---------|--------|-------------------|

   ### Outdated (Minor/Patch)
   | Package | Current | Latest |
   |---------|---------|--------|

   ### Potentially Unused
   - [package]: No imports found in codebase

   ### Recommendations
   - [Prioritized list of what to update and in what order]
   ```

6. **Safe updates:** If the user asks to update, prefer minor/patch updates first. For major version bumps, check changelogs for breaking changes and flag them before proceeding.
