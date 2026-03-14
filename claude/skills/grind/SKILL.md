---
name: grind
description: Verify proposed changes with tech-lead-orchestrator then implement improvements. This skill should be used when the user asks to 'grind', 'verify and implement', 'review then fix', or wants a tech-lead review of proposed changes before implementing them.
allowed-tools: Task, Read, Edit, Write, Glob, Grep, Bash, Agent
---

Verify ALL proposed changes with the tech-lead-orchestrator agent, then implement the improvements.

## Instructions

1. **Gather context:** Summarize all proposed changes from the current conversation — what files are affected, what the goal is, and what approach has been discussed. If there are uncommitted changes in the working tree, include those too.

2. **Verify phase:** Use the `tech-lead-orchestrator` subagent to analyze and verify the proposed changes. Pass it the full context summary. The agent should:
   - Review the approach and architecture
   - Identify risks, edge cases, and potential issues
   - Suggest concrete improvements
   - Return a prioritized task breakdown for implementation

3. **Implement phase:** Based on the tech-lead-orchestrator's findings, implement the recommended improvements. Use the appropriate specialist subagents for the work (e.g., `react-component-expert`, `typescript-expert`, `backend-expert`, etc.) or implement directly for straightforward changes.

4. **Final verification:** After implementation, use the `tech-lead-orchestrator` agent one more time to verify the implemented changes address the original findings. Flag anything still outstanding.
