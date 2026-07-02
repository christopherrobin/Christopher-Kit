---
name: handoff
description: "This skill should be used when the user says '/handoff', 'before I compact', 'save my context', 'save context', 'context handoff', 'hand this off', 'hand off to a new session', 'preserve context', 'snapshot my session', 'I need to compact', 'pre-compact', 'context is getting long', or wants to capture working state before a /compact or when handing work off to a fresh Claude session or a teammate."
disable-model-invocation: true
allowed-tools: Read, Write, Bash(git:*), Bash(pwd:*), Bash(date:*)
---

# Generate Session Handoff Document

Produce a high-fidelity handoff document that captures the full working state of this session. Write it to a file so it survives a `/compact` or session boundary. The document is optimized for a Claude reader (not a human status report) — it must contain everything a fresh instance needs to resume at full speed with zero warm-up.

## CRITICAL RULES

1. **Write to a file — never just print.** The whole point is persistence across a compact. Default path: `./.claude/handoff.md` (project root). If the user specifies a path, use that instead.
2. **Overwrite silently.** If the file already exists, overwrite it without asking.
3. **Be ruthlessly specific.** File paths, line numbers, symbol names, exact error messages, exact command invocations. Vague prose defeats the purpose.
4. **Capture the "why" and the "why not".** Decisions made AND approaches that were tried and rejected — with reasons. This is what default compact drops.
5. **Write in second person addressed to Claude**, not a human. "You are in the middle of...", "The approach you tried was X — it failed because Y."

---

## Step 1: Orient Yourself

Run these commands to anchor the document:

```bash
pwd
date -u +"%Y-%m-%dT%H:%M:%SZ"
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(not a git repo)"
git status --short 2>/dev/null || true
git log --oneline -5 2>/dev/null || true
```

---

## Step 2: Determine Output Path

- Default: `<project-root>/.claude/handoff.md`
- If the user passed an argument (e.g., `/handoff ./notes/handoff.md`), use that path exactly.
- If `.claude/` does not exist at the project root, create it.

---

## Step 3: Synthesize the Document

Read the full conversation and your working knowledge of the codebase, then write the document using the template below. Every section is required. If a section has nothing to say, write "Nothing to capture." — do not omit it.

**Template:**

```markdown
# Session Handoff
Generated: <ISO 8601 timestamp>
Branch: <branch name or "(not a git repo)">
Working directory: <absolute path>

---

## Active Task
<!-- One paragraph. What is the user trying to accomplish? What is the end goal?
     Write this as: "You are working on..." -->


## Current State
<!-- Where exactly did you leave off? What is the immediate next thing to do?
     Be precise: "You were in the middle of X. You had just finished Y. The next
     concrete action is Z." -->


## What Is Done
<!-- Bulleted list. Each item: what was completed + relevant file:line if applicable. -->
- 


## What Is In Progress
<!-- Bulleted list. Partially done work, open PRs/MRs, uncommitted changes. -->
- 


## What Is Not Started
<!-- Bulleted list. Known remaining work that hasn't been touched yet. -->
- 


## Key Files and Locations
<!-- The specific files, functions, classes, and line numbers that are central to this work.
     Format: `path/to/file.ts:42` — `FunctionName` — one-line description of why it matters. -->
- 


## Decisions Made
<!-- Each decision that shaped the implementation. Format:
     **Decision:** what was decided
     **Rationale:** why
     **Alternatives considered:** what else was on the table and why it was rejected -->


## Dead Ends and Gotchas
<!-- Approaches that were tried and failed, surprising behaviors, footguns, environment
     quirks. This is the highest-value section — it prevents re-doing failed work.
     Format: what was tried → what happened → why it doesn't work / what to do instead. -->


## Environment and Commands
<!-- How to run, build, test, and validate. Exact commands, not descriptions.
     Include any non-obvious setup, env vars, or flags that were needed. -->
```bash
# Run dev server
<command>

# Run tests
<command>

# Validate / lint
<command>
```


## Open Questions
<!-- Unresolved questions, things to verify, or decisions deferred. -->
- 


## Explicit Next Steps
<!-- Numbered, ordered list. The very next action is #1. Be specific enough that
     a fresh Claude can execute step 1 without asking any clarifying questions. -->
1. 
```

---

## Step 4: Write the File

Write the completed document to the output path. Then confirm in chat:

```
Handoff written to <absolute path>

To resume: open a new session, read that file, and say "resume from handoff".
```

Print nothing else — no preamble, no summary of what you wrote. Just the one-line confirmation.
