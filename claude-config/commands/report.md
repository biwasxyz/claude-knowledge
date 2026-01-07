---
description: Generate session report summarizing work done
allowed-tools: Bash, Read, Write, Glob
argument-hint: [optional: report title]
---

Generate a session report summarizing the work completed.

1. **Gather session context**
   - Check git log for commits made this session
   - Review files modified
   - Check todo list completion status

2. **Analyze changes**
   - Summarize what was built/fixed/changed
   - Note any decisions made
   - Identify follow-up items

3. **Generate report**
   Save to `~/dev/whoabuddy/claude-knowledge/logs/[date]-[title].summary.md`:
   ```markdown
   # Session Report: [Title or Date]

   ## Summary
   [2-3 sentence overview of what was accomplished]

   ## Work Completed
   - [item 1]
   - [item 2]

   ## Changes Made
   - `file1.ts` - [description]
   - `file2.ts` - [description]

   ## Commits
   - [hash] [message]

   ## Decisions Made
   - [decision 1]

   ## Follow-up Items
   - [ ] [item 1]
   - [ ] [item 2]

   ## Notes
   [any additional context worth preserving]
   ```

4. **Suggest knowledge updates**
   - Recommend patterns to document
   - Suggest decisions to record as ADRs
   - Identify runbook entries needed

Title: $ARGUMENTS (defaults to current date)
