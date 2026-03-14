---
name: scaffold
description: Plan and scaffold a new feature using tech-lead-orchestrator to design the approach, then delegate to specialists to build it. This skill should be used when the user asks to 'scaffold', 'create a new feature', 'build something new', 'set up a new page/component/endpoint', or wants a planned, multi-step feature implementation from scratch.
allowed-tools: Task, Read, Write, Edit, Glob, Grep, Bash, Agent
---

Plan a new feature with the tech-lead-orchestrator, then delegate to specialists to build it.

## Instructions

1. **Gather requirements:** Clarify what the user wants to build. Identify:
   - What the feature does
   - Which parts of the stack it touches (frontend, backend, database, etc.)
   - Any specific patterns or libraries to use
   - Acceptance criteria if provided

2. **Detect stack:** Scan the project for `package.json`, `tsconfig.json`, `prisma/schema.prisma`, and other config files to understand the tech stack and existing patterns.

3. **Plan phase:** Use the `tech-lead-orchestrator` subagent to:
   - Analyze the requirements against the existing codebase
   - Design the implementation approach
   - Break the work into tasks assigned to specific specialist agents
   - Define execution order (what can run in parallel vs sequential)

4. **Build phase:** Execute the plan by delegating each task to the assigned specialist agent. Follow the execution order from the plan.

5. **Verify phase:** After implementation:
   - Run the test suite if one exists
   - Use `code-reviewer` to review the new code
   - Flag any issues back to the user

6. **Report:** Summarize what was built, files created/modified, and any remaining work.
