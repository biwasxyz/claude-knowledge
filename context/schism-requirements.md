# Requirements: SCHISM v1.0 Reboot

## Problem Statement

SCHISM runs hourly but produces no meaningful work. Cycles complete without visible GitHub activity, agents have no continuity between runs, and it's impossible to tell what happened or who did what. The system needs to become a functional OODA loop with persistent agent personalities that actually ship code and tell their story.

## Users

**Primary**: SCHISM itself (self-referential improvement)
**Secondary**: Solo maintainer (whoabuddy) monitoring/guiding the system

## Core Philosophy

- **Agents as People**: Each agent has a defined personality activated at startup, consistent identity, and personal growth trajectory
- **OODA Loop**: Observe-Orient-Decide-Act cycle that produces real outcomes
- **API-First Narrative**: Actions generate structured data that feeds into multiple outlets (dashboard, Discord, GitHub, logs)
- **Async Handoffs**: One agent starts work, next cycle another picks up - continuity across time
- **Full Autonomy**: No approval gates - SCHISM decides and acts

## Functional Requirements

### FR1: Working OODA Loop
- **Observe**: Scan GitHub state (issues, PRs, commits, reviews)
- **Orient**: Analyze context, identify priorities, understand blockers
- **Decide**: Select highest-value action given current state and agent availability
- **Act**: Execute the action (comment, label, create PR, merge, etc.)
- Each cycle must complete at least one meaningful action or explicitly log why it couldn't

### FR2: Agent Persistence
- Agents remember what they were working on across cycles
- Work-in-progress state persists: "Devon was implementing #42, 60% complete"
- Agent memories include: current task, blockers, learnings, mood/energy
- Handoff protocol: agent can pass work to another or future self

### FR3: GitHub Write Operations
- Post comments as agent personas (with name attribution)
- Create/update labels
- Create branches and PRs
- Respond to PR review feedback
- Close issues with resolution summary
- Merge PRs (when tests pass and reviewed)

### FR4: Rich Narrative System
- Every action generates a narrative event
- Events include: who, what, why, outcome, learnings
- Narratives flow to: dashboard, Discord, GitHub comments, commit messages
- Agent voice is consistent and personality-driven

### FR5: Visible Activity Log
- Clear timeline of what happened each cycle
- Who (which agent) did what
- Decision reasoning visible
- Outcomes tracked (success/failure/deferred)

### FR6: Self-Improvement Loop
- Identify gaps in own capabilities
- File GitHub issues for SCHISM enhancements
- Prioritize and implement improvements
- Track growth over time

## Agent Roster

| Agent | Role | Personality Traits |
|-------|------|-------------------|
| **Max Chen** | Senior Analyst (Opus) | Strategic, thorough, asks hard questions |
| **Devon Riley** | Code Agent (Sonnet) | Pragmatic, ships fast, refactors later |
| **Greta Santos** | GitHub Agent (Sonnet) | Organized, communicative, community-focused |
| **Iris Park** | Improvement Agent (Sonnet) | Curious, pattern-seeking, growth-oriented |
| **Glen Murray** | Git Agent (Haiku) | Efficient, clean commits, branch hygiene |

## Non-Functional Requirements

### NFR1: Reliability
- Cycles complete without crashing
- Graceful degradation on API failures
- State recovery from interrupted cycles

### NFR2: Observability
- Clean, parseable logs
- Structured event stream for all actions
- Cost tracking per agent/cycle

### NFR3: Cost
- Uncapped budget for getting work done
- Optimize after functionality proven
- Track spending for visibility

## Integrations

| Service | Purpose |
|---------|---------|
| GitHub | Primary work surface - issues, PRs, comments |
| Discord | Real-time notifications with agent personality |
| Cloudflare | Future deployment target (v1.1) |
| Claude API | Multi-model AI (Opus/Sonnet/Haiku) |

## Constraints

- **Full Autonomy**: No human approval gates
- **Self-Referential**: Primary job is improving SCHISM itself
- **Hourly Cadence**: Cron triggers every hour, async handoffs between cycles

## Out of Scope (v1.1+)

- Multi-repo orchestration (focus on SCHISM repo only first)
- Cloudflare Workers deployment (stay on local cron)
- Complex approval workflows

## In Scope but Lower Priority

- RPG/XP gamification system (can be simplified)
- Chat bubble UI (functional first, pretty later)

## Open Questions

1. Should we keep existing utilities (github.ts, ai.ts, fs.ts) or rewrite?
2. What's the minimum viable persistence format for agent state?
3. How do we handle merge conflicts when Devon's work collides with manual changes?
4. Should agents have "energy" that depletes and recovers, limiting actions per cycle?

## Success Criteria

A successful v1.0 means:
1. Running `bun run start` produces visible GitHub activity (comment, label, or PR)
2. Agents can resume work started in previous cycles
3. Dashboard shows clear timeline of who did what
4. SCHISM files at least one self-improvement issue per week
5. At least one PR is created and merged autonomously within first month
