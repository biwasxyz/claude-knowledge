# Skill Organization Pattern

How to structure Claude Code skills, runbooks, and bash helpers for maintainability.

## The Three-Layer Pattern

```
┌─────────────────────────────────────────────────────────┐
│  SKILL (invocation)                                     │
│  ~/.claude/skills/{name}/SKILL.md                       │
│  - User-facing entry point                              │
│  - Usage examples and arguments                         │
│  - Points to runbook for workflow                       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  RUNBOOK (workflow)                                     │
│  ~/dev/whoabuddy/claude-knowledge/runbook/{name}.md     │
│  - Complete operational procedure                       │
│  - Step-by-step instructions                            │
│  - Troubleshooting and edge cases                       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  BASH HELPERS (data collection)                         │
│  ~/.claude/skills/{name}/*.sh                           │
│  - Collect information as context                       │
│  - Output consistent, parseable format                  │
│  - Idempotent and safe to run repeatedly                │
└─────────────────────────────────────────────────────────┘
```

## Why This Pattern?

| Layer | Purpose | Changes When |
|-------|---------|--------------|
| Skill | Entry point | Command syntax changes |
| Runbook | Procedure | Workflow steps change |
| Bash | Data format | Output structure changes |

**Benefits:**
- Skills stay lean and focused on invocation
- Runbooks document the full procedure for manual or automated use
- Bash scripts are reusable helpers, not the workflow itself
- Each layer can be updated independently

## Guidelines

### Skills (`SKILL.md`)

- Keep under 30 lines
- Show usage examples
- Reference the runbook for workflow details
- List helper files with one-line descriptions

### Runbooks

- Include prerequisites
- Number the steps
- Show exact commands
- Document troubleshooting

### Bash Helpers

- Collect and format data only
- Accept date/arguments for flexibility
- Output to predictable locations
- Exit with meaningful codes

## Example: Daily Summary

```
~/.claude/skills/daily/
├── SKILL.md              # "/daily" invocation docs
├── TEMPLATE.md           # Output format template
└── daily-git-summary.sh  # Collects git/GitHub data

~/dev/whoabuddy/claude-knowledge/runbook/
└── daily-summary.md      # Full 4-step workflow
```

The skill invokes the workflow. The runbook orchestrates the steps. The bash script collects raw data.

## Anti-Patterns

- **Monolithic skill**: Don't put the entire procedure in SKILL.md
- **Smart scripts**: Don't make bash scripts do interpretation or decision-making
- **Orphaned helpers**: Always document bash scripts in both skill and runbook
- **Duplicated docs**: Reference, don't copy, between skill and runbook
