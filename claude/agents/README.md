# Claude Code Agents

A collection of specialized AI agents for [Claude Code](https://claude.com/claude-code) CLI. Each agent is an expert in a specific framework, language, or development task.

## Setup

Copy or symlink the agents directory into your Claude config:

```bash
# Copy
cp -r agents/ ~/.claude/agents/

# Or symlink
ln -sf "$(pwd)/agents" ~/.claude/agents
```

## Configure Your Project

Run the team configurator to auto-detect your project's tech stack and set up agent routing in your CLAUDE.md:

```bash
claude "use @agent-team-configurator and optimize my project to best use the available subagents"
```

## Usage

Invoke agents by name with `@agent-name`:

```bash
claude "use @agent-tech-lead-orchestrator to plan a user auth system"
claude "use @agent-code-reviewer to review my changes"
claude "@react-nextjs-expert add a server component for product listing"
```

## Naming Conventions

Agent names follow a consistent suffix pattern:

| Suffix | Role | Examples |
|---|---|---|
| **expert** | Domain specialist — implements and advises within a specific technology | typescript-expert, react-nextjs-expert, aws-expert |
| **architect** | Design-only — produces specs and plans, never implements | api-architect, scraper-architect |
| **orchestrator / analyst / configurator** | Coordination — plans tasks, routes to specialists, never implements directly | tech-lead-orchestrator, project-analyst, team-configurator |
| **Unique names** | Earned exceptions where the name better describes the role | code-reviewer, code-archaeologist, performance-optimizer |

## Agents Included

### Core Specialists
Meta-development activities that apply across any project:
- **code-reviewer** — Code review and security auditing
- **performance-optimizer** — Performance profiling and optimization
- **playwright-expert** — E2E testing and browser automation
- **scraper-architect** — Web scraping architecture and data pipelines
- **documentation-expert** — READMEs, API docs, architecture guides
- **code-archaeologist** — Codebase exploration and documentation
- **skill-expert** — Create, review, and update Claude Code skills
- **agent-expert** — Create, review, and update Claude Code agent definitions

### Orchestrators (3)
High-level planning and coordination:
- **project-analyst** — Detect tech stacks and route to specialists
- **team-configurator** — Auto-configure AI team for your project
- **tech-lead-orchestrator** — Plan and coordinate multi-step tasks

### Framework Specialists
- **Python**: python-expert, testing-expert, performance-expert, security-expert, web-scraping-expert, devops-cicd-expert
- **React**: react-component-expert, react-nextjs-expert, material-ui-expert, jest-react-testing-expert
- **React Native**: react-native-expert, expo-expert
- **Node.js**: express-tsoa-expert
- **Database**: prisma-database-expert, mysql-prisma-expert, postgresql-prisma-expert
- **Firebase**: firebase-expert

### Universal Specialists
Cross-framework tools:
- **api-architect** — REST/GraphQL design
- **openapi-contract-expert** — Contract-first API development and client generation
- **auth-integration-expert** — Authentication/authorization (NextAuth, Auth.js, OAuth)
- **backend-expert** — Framework-agnostic backend
- **frontend-expert** — Framework-agnostic frontend
- **tailwind-css-expert** — Tailwind CSS styling
- **typescript-expert** — TypeScript patterns and best practices
- **aws-expert** — AWS services integration

## Adding a New Agent

Use the tech-lead-orchestrator to add agents that follow the established patterns:

```bash
claude "use @agent-tech-lead-orchestrator to add a new 'svelte-expert' agent to ~/.claude/agents/

The agent should be:
- Category: Framework specialist (specialized/svelte/)
- Purpose: Svelte and SvelteKit development expert

Tasks needed:
1. Analyze existing framework specialist patterns (react, python)
2. Create svelte-expert.md following the standard format
3. Update orchestrators to know about the new agent
4. Review the integration"
```
