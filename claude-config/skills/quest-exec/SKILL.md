---
name: quest-exec
description: Execute a planned phase with fresh subagent contexts and atomic commits
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task
---

# Quest Exec Skill

Execute a planned phase by spawning fresh executor subagents for each task.

## Usage

```
/quest-exec              Execute the current planned phase
/quest-exec 2            Execute a specific phase by number
```

## Behavior

1. **Validate** prerequisites:
   ```bash
   ~/.claude/scripts/quest/validate-phase.sh exec <phase_num> .
   ```
2. **Read** `phases/NN-name/PLAN.md` for task definitions
3. **Emit** `phase_executing` event:
   ```bash
   ~/.claude/scripts/quest/emit-event.sh phase_executing '"questId":"<id>","phaseId":"<id>","phaseName":"<name>"'
   ```
4. **For each task**, spawn `phase-executor` agent:
   ```
   Task tool with subagent_type: phase-executor
   Prompt includes:
   - The PLAN.md content
   - Task-specific instructions
   - Any diagnosis from previous failed verification (if retrying)
   ```
   Key: Each executor gets a fresh 200k context (prevents context rot)
5. **Collect** results from executors
6. **Update** `PHASES.md` status to `executed`
7. **Update** `STATE.md` with execution results (commits, files changed, issues)

## Orchestrator Rules

The orchestrating skill stays **lean** (under 30% context):
- Only read PLAN.md and executor results
- Never read full source files directly
- Route between executors, don't execute yourself
- Log decisions to STATE.md

## Deviation Handling

Executors follow deviation rules:
- **Auto-fix**: bugs, missing deps, blocking issues
- **Checkpoint**: architectural changes, scope creep — executor stops, reports back

If an executor checkpoints:
1. Present the issue to the user
2. Wait for direction before continuing
3. Log decision to STATE.md

## Prerequisites

- Active quest with planned phase
- Phase status must be `planned` or `retrying`

## Output

```
Executing Phase 2: Add login endpoint

Task 1/3: Create login route handler
  Executor completed: 1 file changed, 45 lines added
  Commit: feat(auth): add POST /login route

Task 2/3: Add JWT token generation
  Executor completed: 2 files changed, 62 lines added
  Commit: feat(auth): implement JWT token generation

Task 3/3: Write login tests
  Executor completed: 1 file created, 89 lines
  Commit: test(auth): add login endpoint tests

Phase 2 executed: 3 commits, 4 files changed

Next: /quest-verify to verify this phase
```

## Retry Mode

When phase status is `retrying` (from failed verification):
- Read diagnosis from `phases/NN-name/VERIFY.md`
- Pass diagnosis to executor as additional context
- Executor focuses on fixing identified gaps
