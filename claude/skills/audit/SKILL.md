---
name: audit
description: Run a full codebase health check using code-archaeologist and code-reviewer. This skill should be used when the user asks to 'audit', 'health check', 'analyze the codebase', 'check code quality', or wants a comprehensive review of the entire project rather than just recent changes.
allowed-tools: Bash(git:*), Read, Glob, Grep, Agent
---

Run a full codebase health check combining architecture analysis and code quality review.

## Instructions

1. **Scope check:** Determine the target directory. Default to the current working directory. If the user specified a path or subdirectory, use that instead.

2. **Architecture analysis:** Use the `code-archaeologist` subagent to explore the codebase and produce a full report covering:
   - Tech stack and framework detection
   - Architecture patterns and module structure
   - Code metrics (complexity, duplication, test coverage)
   - Risks, dead code, and technical debt
   - Dependency health

3. **Quality review:** Use the `code-reviewer` subagent to review the codebase for:
   - Security vulnerabilities (OWASP Top 10)
   - Performance bottlenecks
   - DRY violations and code duplication
   - Imperative code that should be functional
   - Unnecessary mutation
   - Missing error handling
   - Test coverage gaps

4. **Synthesize:** Combine findings into a single prioritized action plan:
   - Critical issues (security, data loss risk)
   - High-priority improvements (performance, architecture)
   - Medium-priority cleanup (DRY, refactoring)
   - Low-priority polish (style, naming, docs)
