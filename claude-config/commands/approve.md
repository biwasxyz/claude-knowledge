---
description: Approval gate - confirm readiness to proceed
allowed-tools: AskUserQuestion, Bash, Read
argument-hint: [pr|deploy|ship]
---

Approval checkpoint for: $ARGUMENTS

This is a gate command that requires explicit user confirmation before proceeding.

1. **Gather context**
   - Current branch and status
   - Recent changes summary
   - Test/build status

2. **Show approval checklist**
   ```
   APPROVAL CHECKPOINT: [context]
   ═══════════════════════════════════════

   □ Code reviewed
   □ Tests passing
   □ Build successful
   □ Preview tested (if applicable)
   □ Documentation updated (if needed)

   Changes to approve:
   - [file1]: [change summary]
   - [file2]: [change summary]

   ═══════════════════════════════════════
   ```

3. **Ask for confirmation**
   Use AskUserQuestion with options:
   - "Approve and proceed"
   - "View diff first"
   - "Run tests again"
   - "Cancel"

4. **On approval**
   - Log approval to knowledge base
   - Proceed with requested action
   - Suggest next command (/ship, /pr merge, etc.)

5. **On rejection**
   - Ask what needs to be addressed
   - Suggest relevant commands to fix issues

Context: $ARGUMENTS (pr, deploy, or ship)
