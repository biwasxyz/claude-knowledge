---
description: Create implementation plan for a feature or task
allowed-tools: Task, Read, Glob, Grep, AskUserQuestion, TodoWrite
argument-hint: [feature or task to plan]
---

Create a detailed implementation plan for: $ARGUMENTS

1. **Understand requirements**
   - Parse the task description
   - Ask clarifying questions if ambiguous
   - Identify success criteria

2. **Explore codebase**
   - Use Explore agent to understand current architecture
   - Identify files that will need changes
   - Find existing patterns to follow

3. **Design approach**
   - Break into discrete, testable steps
   - Identify dependencies between steps
   - Note potential risks or blockers

4. **Create plan document**
   Save to `$CLAUDE_KNOWLEDGE_PATH/notes/plan-[timestamp].md`:
   ```markdown
   # Plan: [Task Title]

   ## Summary
   [1-2 sentence overview]

   ## Requirements
   - [requirement 1]
   - [requirement 2]

   ## Approach
   [High-level strategy]

   ## Steps
   1. [ ] Step 1 - [description]
   2. [ ] Step 2 - [description]
   ...

   ## Files to Modify
   - `path/to/file.ts` - [changes needed]

   ## Risks & Considerations
   - [risk 1]

   ## Success Criteria
   - [ ] [criterion 1]
   ```

5. **Populate TodoWrite**
   - Add plan steps to todo list for tracking

Use the Plan agent for complex architectural decisions.
