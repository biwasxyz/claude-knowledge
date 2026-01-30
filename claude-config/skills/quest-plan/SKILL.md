---
name: quest-plan
description: Research and plan a specific phase of the active quest
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, WebSearch, WebFetch
---

# Quest Plan Skill

Research and create an executable plan for a quest phase.

## Usage

```
/quest-plan              Plan the current (next pending) phase
/quest-plan 2            Plan a specific phase by number
/quest-plan --force      Re-plan even if already planned
```

## Behavior

1. **Validate** prerequisites:
   ```bash
   ~/.claude/scripts/quest/validate-phase.sh plan <phase_num> .
   ```
2. **Read** context from `.planning/`:
   - `QUEST.md` for overall goal
   - `PHASES.md` for phase goal
   - Previous phase plans for patterns
3. **Spawn** `quest-planner` agent in phase planning mode:
   ```
   Task tool with subagent_type: quest-planner
   Prompt includes:
   - Phase goal from PHASES.md
   - Quest context from QUEST.md
   - Relevant codebase patterns (from exploration)
   ```
4. **Write** plan to `phases/NN-name/PLAN.md` using structured XML task format
5. **Update** `PHASES.md` phase status to `planned`
6. **Update** `STATE.md` with planning decisions
7. **Emit** `phase_planned` event:
   ```bash
   ~/.claude/scripts/quest/emit-event.sh phase_planned '"questId":"<id>","phaseId":"<id>","phaseName":"<name>","taskCount":<n>'
   ```

## Plan Format

Plans use structured XML tasks (targeting 2-3 tasks to stay under 50% context budget):

```xml
<plan>
  <goal>Phase goal statement</goal>
  <context>Relevant codebase context discovered during research</context>

  <task id="1">
    <name>Task name</name>
    <files>file1.ts, file2.ts</files>
    <action>Detailed implementation instructions</action>
    <verify>Concrete verification commands</verify>
    <done>Completion criteria</done>
  </task>

  <task id="2">
    <name>Second task name</name>
    <files>file3.ts</files>
    <action>Implementation instructions</action>
    <verify>Verification commands</verify>
    <done>Completion criteria</done>
  </task>
</plan>
```

## Research Phase

The planner agent may:
- Explore the codebase to understand existing patterns
- Search the web for best practices or library documentation
- Read relevant files to inform task design
- Check for existing implementations to build upon

## Prerequisites

- Active quest (`.planning/` directory exists)
- Phase must be in `pending` status (or use `--force`)

## Output

```
Phase 2: Add login endpoint

Researched:
- Existing auth patterns in src/middleware/
- Express route conventions
- JWT best practices

Plan created with 3 tasks:
1. Create login route handler
2. Add JWT token generation
3. Write login tests

Written to: .planning/phases/02-add-login-endpoint/PLAN.md

Next: /quest-exec to execute this phase
```
