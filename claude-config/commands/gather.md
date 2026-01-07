---
description: Gather context from knowledge base and codebase for current task
allowed-tools: Glob, Grep, Read, Task
argument-hint: [topic or task description]
---

Gather relevant context for the task: $ARGUMENTS

1. **Search knowledge base** at `~/dev/whoabuddy/claude-knowledge/`
   - Check `decisions/` for relevant ADRs
   - Check `patterns/` for applicable patterns
   - Check `runbook/` for related procedures
   - Check `context/` for background info

2. **Search current codebase**
   - Find files related to the topic
   - Identify existing implementations
   - Note test files and coverage

3. **Check recent activity**
   - Recent commits touching related files
   - Open issues/PRs if in a git repo with remote

4. **Compile context summary**
   Format:
   ```
   CONTEXT GATHERED: [topic]

   ## Knowledge Base
   - [relevant files and summaries]

   ## Codebase
   - [relevant files and patterns]

   ## Recent Activity
   - [commits, issues, PRs]

   ## Suggested Starting Points
   - [files to read first]
   - [decisions to consider]
   ```

Use the Explore agent for deep codebase searches if needed.
