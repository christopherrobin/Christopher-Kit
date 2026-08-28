# Claude Code Agents

A collection of specialized AI agents for [Claude Code](https://claude.com/claude-code) CLI. Each agent is an expert in a specific framework, language, or development task.

## Getting Started

1. **Install the agents** (see [Setup](#setup) below) so they live at `~/.claude/agents`.
2. **Configure your project once.** From your project root, run the team-configurator to detect the stack and write an agent assignment table into your project's CLAUDE.md:

   ```bash
   claude "Use team-configurator to set up my AI development team"
   ```

   If you use the bundled [.zshrc](../../zsh/), the `claudeInit` function runs this exact command.
3. **Work normally.** Claude auto-delegates to the right specialists based on the assignment table. Use the `/scaffold` or `/grind` [skills](../skills/) when you want the tech-lead-orchestrator to drive a feature end-to-end.

## Setup

> If `~/.claude/agents` already exists as a real directory, move it aside first (`mv ~/.claude/agents ~/.claude/agents.bak`) - otherwise the symlink nests inside it instead of replacing it.

From the repo root:

```bash
# Copy
cp -r claude/agents ~/.claude/agents

# Or symlink to keep it linked to the repo
ln -sfn "$(pwd)/claude/agents" ~/.claude/agents
```

## Usage

Ask for an agent in plain English and Claude routes the work to it:

```bash
claude "use the tech-lead-orchestrator to plan a user auth system"
claude "use the code-reviewer to review my changes"
claude "have the react-nextjs-expert add a server component for product listing"
```

Tip: in an interactive session you can also @-mention an agent directly (e.g. `@agent-code-reviewer`). A mention that doesn't resolve is dropped silently with no error, so plain English is the safer habit and works everywhere.

## Naming Conventions

Agent names follow a consistent suffix pattern:

| Suffix | Role | Examples |
|---|---|---|
| **expert** | Domain specialist - implements and advises within a specific technology | typescript-expert, react-nextjs-expert, aws-expert |
| **architect** | Design-only - produces specs and plans, never implements | api-architect, scraper-architect |
| **orchestrator / analyst / configurator** | Coordination - plans tasks, routes to specialists, never implements directly | tech-lead-orchestrator, project-analyst, team-configurator |
| **Unique names** | Earned exceptions where the name better describes the role | code-reviewer, code-archaeologist, performance-optimizer |

## Coding Philosophy

Code produced by these agents in your projects should follow these principles. The team-configurator writes them into each project's CLAUDE.md when it sets up the AI team, so every session and specialist working in that project inherits them:

- **DRY** - Don't repeat yourself. Extract reusable utilities instead of copy-pasting. But don't abstract prematurely - wait until a pattern is clear before extracting.
- **Functional over imperative** - Prefer pure functions over side effects. Use `map`/`filter`/`reduce` over imperative loops. Compose small functions over writing monolithic ones.
- **Immutable by default** - Use `const`, `readonly`, and immutable data structures. Mutate only when there's a clear performance reason.
- **Composable and reusable** - Design functions and components for reuse from the start. Small, focused units that compose together.
- **Scalable patterns** - Write code that works for 10 items and 10,000 items. Consider data growth, not just current state.

## Agents Included

### Core Specialists
Meta-development activities that apply across any project:
- **code-reviewer** - Code review and security auditing
- **performance-optimizer** - Performance profiling and optimization
- **playwright-expert** - E2E testing and browser automation
- **scraper-architect** - Web scraping architecture and data pipelines
- **documentation-expert** - READMEs, API docs, architecture guides
- **code-archaeologist** - Codebase exploration and documentation
- **skill-expert** - Create, review, and update Claude Code skills
- **agent-expert** - Create, review, and update Claude Code agent definitions

### Orchestrators (3)
High-level planning and coordination:
- **project-analyst** - Detect tech stacks and route to specialists
- **team-configurator** - Auto-configure AI team for your project
- **tech-lead-orchestrator** - Plan and coordinate multi-step tasks

### Framework Specialists
- **Python**: python-expert, testing-expert, performance-expert, python-security-expert, web-scraping-expert, devops-cicd-expert
- **React**: react-component-expert, react-nextjs-expert, material-ui-expert, jest-react-testing-expert
- **React Native**: react-native-expert, expo-expert
- **Node.js**: express-tsoa-expert, fastify-expert, vitest-expert
- **Database**: prisma-database-expert, mysql-prisma-expert, postgresql-prisma-expert
- **Firebase**: firebase-expert

### Universal Specialists
Cross-framework tools:
- **api-architect** - REST/GraphQL design
- **openapi-contract-expert** - Contract-first API development and client generation
- **auth-integration-expert** - Authentication/authorization (NextAuth, Auth.js, OAuth)
- **backend-expert** - Framework-agnostic backend
- **frontend-expert** - Framework-agnostic frontend
- **tailwind-css-expert** - Tailwind CSS styling
- **typescript-expert** - TypeScript patterns and best practices
- **aws-expert** - AWS services integration
- **node-security-expert** - Node.js security (JWT/jose, bcryptjs, OWASP, rate limiting)

## Adding a New Agent

Use the tech-lead-orchestrator to add agents that follow the established patterns:

```bash
claude "use the tech-lead-orchestrator to add a new 'svelte-expert' agent to ~/.claude/agents/

The agent should be:
- Category: Framework specialist (specialized/svelte/)
- Purpose: Svelte and SvelteKit development expert

Tasks needed:
1. Analyze existing framework specialist patterns (react, python)
2. Create svelte-expert.md following the standard format
3. Update orchestrators to know about the new agent
4. Review the integration"
```
