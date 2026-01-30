---
name: quest-verify
description: Verify phase execution and loop until complete or checkpoint to human
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task
---

# Quest Verify Skill

Verify that a phase was executed correctly using goal-backward verification.

## Usage

```
/quest-verify            Verify the current executed phase
/quest-verify 2          Verify a specific phase by number
/quest-verify --skip     Skip verification and mark phase complete
```

## Behavior

1. **Validate** prerequisites:
   ```bash
   ~/.claude/scripts/quest/validate-phase.sh verify <phase_num> .
   ```
2. **Read** phase context:
   - Phase goal from `PHASES.md`
   - Task definitions from `PLAN.md`
3. **Spawn** `phase-verifier` agent:
   ```
   Task tool with subagent_type: phase-verifier
   Prompt includes:
   - Phase goal
   - PLAN.md task definitions
   - Access to codebase for verification
   ```
4. **Receive** verification result: `VERIFICATION PASSED` or `GAPS FOUND`

### On PASS

1. Write results to `phases/NN-name/VERIFY.md`
2. Update `PHASES.md` phase status to `completed`
3. Update `STATE.md` with verification results
4. Emit `phase_verified` event:
   ```bash
   ~/.claude/scripts/quest/emit-event.sh phase_verified '"questId":"<id>","phaseId":"<id>","result":"pass","retryCount":0'
   ```
5. If all phases complete, suggest `/quest-complete`
6. Otherwise, advance `STATE.md` to next phase

### On FAIL

1. Write diagnosis to `phases/NN-name/VERIFY.md`
2. Read `config.json` for maxRetries (default 3)
3. If retryCount < maxRetries:
   a. Update `PHASES.md` status to `retrying`
   b. Increment retryCount in `STATE.md`
   c. Emit `phase_retrying` event:
      ```bash
      ~/.claude/scripts/quest/emit-event.sh phase_retrying '"questId":"<id>","phaseId":"<id>","retryCount":<n>,"diagnosis":"<summary>"'
      ```
   d. Invoke `/quest-exec` with diagnosis context
   e. Re-invoke `/quest-verify` after execution
4. If retryCount >= maxRetries:
   a. Emit `phase_verified` event (result: fail)
   b. Present full diagnosis to user
   c. Wait for human intervention

## Loop-Until-Complete

```
execute → verify → [PASS] → next phase
                → [FAIL] → re-execute with diagnosis → verify again
                → [FAIL x3] → checkpoint to human
```

## Prerequisites

- Active quest with executed phase
- Phase status must be `executed` or `retrying`

## Output on Pass

```
Verifying Phase 2: Add login endpoint

Checking task completions:
✓ Task 1: Login route handler exists at src/routes/auth.ts
✓ Task 2: JWT generation working (tested with curl)
✓ Task 3: Tests passing (npm test)

VERIFICATION PASSED

Phase 2 complete. Advancing to Phase 3.
```

## Output on Fail

```
Verifying Phase 2: Add login endpoint

Checking task completions:
✓ Task 1: Login route handler exists
✗ Task 2: JWT generation missing error handling
✓ Task 3: Tests exist but 1 failing

GAPS FOUND:
1. No error handling for invalid credentials
2. Test "should reject empty password" failing

Retry 1/3: Re-executing with diagnosis...
```

## Skip Mode

When using `--skip`:
- Mark phase as `completed` without verification
- Log skip reason to STATE.md
- Emit event with `result: "skipped"`
