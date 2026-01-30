---
name: quest-pause
description: Pause the active quest
allowed-tools: Bash, Read, Write, Edit
---

# Quest Pause Skill

Pause the active quest, preserving state for later resumption.

## Usage

```
/quest-pause
```

## Behavior

1. Verify quest is active:
   - Read `QUEST.md` status
   - If already paused or completed, show error
2. Update `QUEST.md`:
   - Set Status to `paused`
   - Add pause timestamp
3. Update `STATE.md`:
   - Add pause entry to decisions log
   - Record current position
4. Emit `quest_paused` event:
   ```bash
   ~/.claude/scripts/quest/emit-event.sh quest_paused '"questId":"<id>","name":"<name>","currentPhase":<n>,"phaseStatus":"<status>"'
   ```
5. Display pause confirmation

## Output

```
Quest Paused: Implement User Authentication

Current position saved:
- Phase: 3 of 5
- Status: executed (awaiting verification)

Use /quest-resume to continue.
```

## Prerequisites

- Active quest (`.planning/` directory exists)
- Quest status is `active`

## When to Pause

- Switching to higher priority work
- Need to gather more information before continuing
- Waiting for external dependencies
- End of work session
