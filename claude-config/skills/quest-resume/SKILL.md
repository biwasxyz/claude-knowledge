---
name: quest-resume
description: Resume a paused quest
allowed-tools: Bash, Read, Write, Edit
---

# Quest Resume Skill

Resume a paused quest from where it left off.

## Usage

```
/quest-resume
```

## Behavior

1. Verify quest is paused:
   - Read `QUEST.md` status
   - If active or completed, show appropriate message
2. Read current state from `STATE.md`:
   - Current phase number
   - Phase status (pending, planned, executed, etc.)
3. Update `QUEST.md`:
   - Set Status to `active`
   - Add resume timestamp
4. Update `STATE.md`:
   - Add resume entry to decisions log
5. Emit `quest_resumed` event:
   ```bash
   ~/.claude/scripts/quest/emit-event.sh quest_resumed '"questId":"<id>","name":"<name>","currentPhase":<n>'
   ```
6. Display resume summary with suggested next action

## Output

```
Quest Resumed: Implement User Authentication

Picking up from:
- Phase: 3 of 5 - Add session management
- Status: executed

Suggested next step: /quest-verify
(Phase 3 was executed but not yet verified)
```

## Prerequisites

- Active quest (`.planning/` directory exists)
- Quest status is `paused`

## Next Action Logic

Based on current phase status, suggest:
- `pending` → `/quest-plan` or `/quest-run`
- `planned` → `/quest-exec` or `/quest-run`
- `executed` → `/quest-verify` or `/quest-run`
- `retrying` → `/quest-exec` or `/quest-run`
