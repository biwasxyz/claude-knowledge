# Claude Knowledge Base

A structured knowledge repository for AI-assisted development workflows.

## Structure

```
claude-knowledge/
├── decisions/      # Architecture Decision Records (ADRs)
├── notes/          # Working notes and discoveries
├── runbook/        # Operational procedures and guides
├── context/        # Project context and background
├── patterns/       # Recurring patterns and solutions
├── logs/           # Session logs (gitignored raw, curated committed)
└── retrospectives/ # Post-mortems and reflections
```

## Usage

This knowledge base integrates with Claude Code workflows:
- `/gather` - Pull relevant context before work
- `/report` - Generate session summaries
- `reflect` skill - Review and improve workflows

## Logs Policy

- `logs/*.raw.md` - Gitignored, ephemeral session data
- `logs/*.summary.md` - Curated, worth committing
- HTML viewer available at `logs/index.html`
