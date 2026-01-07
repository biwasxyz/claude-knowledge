# Daily Summary Skill

Generates and publishes a team-friendly daily summary of work across all git repositories.

## Usage

```bash
/daily           # Uses today's date
/daily 2026-01-05  # Specific date
```

## Workflow

Follow the runbook: `~/dev/whoabuddy/claude-knowledge/runbook/daily-summary.md`

1. **Collect** - Run `daily-git-summary.sh` to gather raw data
2. **Interpret** - Create/update team summary using TEMPLATE.md
3. **Sync** - Copy to `~/dev/whoabuddy/claude-logs/_posts/`
4. **Push** - Commit and push to trigger GitHub Pages build

## Files

| File | Purpose |
|------|---------|
| `daily-git-summary.sh` | Bash helper for raw data collection |
| `TEMPLATE.md` | Summary format template |
