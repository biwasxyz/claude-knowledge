# ADR-0001: Workflow Component Design

## Status
Accepted

## Context
Need modular, composable workflow components for development cycles. Two source patterns:
- **Planning flow**: SYNC, GATHER, PLAN, EXECUTE, REPORT, REFLECT
- **Dev cycle**: interview, status, approve, build, pr, preview, ship

## Decision

### Component Classification

| Component   | Type    | Rationale                                           |
|-------------|---------|-----------------------------------------------------|
| `/sync`     | Command | Explicit user action, pulls repos                   |
| `/gather`   | Command | User-initiated context collection                   |
| `/plan`     | Command | Requires user input, spawns Plan agent              |
| `/execute`  | Skill   | Proactive during coding, orchestrates build/test    |
| `/report`   | Command | User-initiated session summary                      |
| `reflect`   | Skill   | Proactive, suggests improvements via claude-code-expert |
| `/interview`| Command | Requirements gathering, interactive                 |
| `/status`   | Command | Quick check, deterministic output                   |
| `/approve`  | Command | Gate, requires explicit user action                 |
| `/build`    | Command | Explicit action, runs build pipeline                |
| `/pr`       | Command | Creates/manages pull request                        |
| `/preview`  | Command | Deploys to preview environment                      |
| `/ship`     | Command | Production deploy, requires confirmation            |

### Composable Workflows

**Planning Session**
```
/sync → /gather → /plan → [work] → /report → reflect
```

**Feature Development**
```
/interview → /plan → /execute → /build → /pr → /preview → /approve → /ship
```

**Quick Fix**
```
/status → [fix] → /build → /pr → /ship
```

## Consequences

### Benefits
- Clear mental model: commands = explicit, skills = proactive
- Composable for different workflow needs
- Skills can trigger commands but not vice versa

### Trade-offs
- More files to maintain
- Users need to learn which is which
