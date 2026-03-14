---
name: review-me
description: Compare current branch to its base branch and run code review
allowed-tools: Bash(git:*), Agent
---

# Review My Changes

Compare the current branch against its base branch and run a thorough code review.

## Steps

1. Detect the default/base branch:
   - Try `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null` and extract the branch name
   - If that fails, check which of `main`, `master`, or `develop` exists locally or on the remote
   - Fall back to `main` if nothing is found

2. Get the current branch with `git branch --show-current`
   - If on the base branch itself, inform the user there's nothing to compare

3. Use the **code-reviewer** agent to review all changes between the base branch and the current branch
