# Daily Summary Skill

Generates a team-friendly daily summary of work across all git repositories.

## Files

- `daily-git-summary.sh` - Bash script that collects raw git/GitHub data
- `TEMPLATE.md` - Template for the team summary format

## Usage

```bash
/daily           # Uses today's date
/daily 2026-01-05  # Specific date
```

## Output Files

Two files are generated per run:

| File | Purpose |
|------|---------|
| `~/logs/DATETIME-daily-github-summary.md` | Raw script output (one per run) |
| `~/logs/YYYY-MM-DD-daily-summary.md` | Team summary (one per day, updated in place) |

## Summary Format

The team summary includes:

- **Highlights** - 2-4 sentences on main accomplishments
- **Commits table** - Repos with commit counts and summaries
- **GitHub Activity** - Issues and PRs in table format
- **Notes** - Optional blockers or follow-ups

## Update Behavior

When run multiple times on the same day:
- Raw data files accumulate (timestamped)
- Team summary updates in place (preserves manual notes)
- "Last updated" timestamp refreshes
