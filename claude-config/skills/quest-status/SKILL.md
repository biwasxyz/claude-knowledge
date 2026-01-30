---
name: quest-status
description: Show current quest progress and state
allowed-tools: Bash, Read, Glob
---

# Quest Status Skill

Display the current quest progress, phase status, and any retry information.

## Usage

```
/quest-status
```

## Behavior

1. Run the status script:
   ```bash
   ~/.claude/scripts/quest/quest-status.sh .
   ```
2. Read additional details from `.planning/` files:
   - `QUEST.md` for quest description
   - `PHASES.md` for phase details
   - `STATE.md` for decisions log and retry info
3. Display formatted output showing:
   - Quest name and overall status
   - Progress (N/total phases completed)
   - Current phase name and status
   - Retry count if in verification loop
   - Recent decisions from STATE.md

## Output Format

```
Quest: Implement User Authentication
Status: active
Progress: 2/5 phases completed

Current Phase: 3 - Add session management
Status: executed (awaiting verification)
Retries: 0

Recent Activity:
- Phase 2 completed with 3 commits
- Started phase 3 planning
```

## Prerequisites

- Active quest (`.planning/` directory exists)

## Related Commands

- `/quest-plan` - Plan the next phase
- `/quest-exec` - Execute current phase
- `/quest-verify` - Verify execution
- `/quest-run` - Run full automation loop
