---
description: Gather requirements through structured questions
allowed-tools: AskUserQuestion, Write, Read
argument-hint: [feature or project name]
---

Conduct a requirements interview for: $ARGUMENTS

1. **Initial scoping**
   Ask about:
   - What problem are we solving?
   - Who is the target user?
   - What does success look like?

2. **Technical requirements**
   Ask about:
   - Technology constraints or preferences
   - Integration points with existing systems
   - Performance requirements
   - Security considerations

3. **User experience**
   Ask about:
   - User workflow
   - Edge cases to handle
   - Error scenarios

4. **Constraints**
   Ask about:
   - Must-have vs nice-to-have features
   - Known limitations
   - Dependencies on other work

5. **Document requirements**
   Save to `~/dev/whoabuddy/claude-knowledge/context/[project]-requirements.md`:
   ```markdown
   # Requirements: [Project Name]

   ## Problem Statement
   [what we're solving]

   ## Users
   [who will use this]

   ## Functional Requirements
   - FR1: [requirement]
   - FR2: [requirement]

   ## Non-Functional Requirements
   - NFR1: [requirement]

   ## Constraints
   - [constraint 1]

   ## Out of Scope
   - [item 1]

   ## Open Questions
   - [question 1]
   ```

Use AskUserQuestion to gather information interactively, presenting 2-4 options when applicable.
