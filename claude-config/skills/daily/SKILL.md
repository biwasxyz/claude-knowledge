---
name: daily
description: Generate daily summary of git activity across all repositories
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TodoWrite
---

# Daily Summary Skill

Generates and publishes a team-friendly daily summary of work across all git repositories.

## Usage

```bash
/daily           # Uses today's date
/daily 2026-01-05  # Specific date
```

## Configuration

Set these in your environment or `~/.claude/CLAUDE.md`:
- `DAILY_LOGS_REPO` - GitHub repo for publishing summaries (e.g., `myorg/dev-logs`)
- Default dev directory: `~/dev/` (all `org/repo` subdirectories are scanned)

## Workflow

Follow the runbook: `runbook/daily-summary.md` in your knowledge base.

1. **Collect** - Run `daily-git-summary.sh` to gather raw data
2. **Interpret** - Create/update team summary using TEMPLATE.md
3. **Sync** - Copy to your configured logs repo `_posts/` directory
4. **Push** - Commit and push to trigger GitHub Pages build

## Files

| File | Purpose |
|------|---------|
| `daily-git-summary.sh` | Bash helper for raw data collection |
| `extract-deployments.ts` | Bun script to extract deployment URLs from wrangler.jsonc |
| `TEMPLATE.md` | Summary format template |

## Deployment URLs

For repos with Cloudflare Workers (wrangler.jsonc), extract deployment links:

```bash
bun ~/.claude/skills/daily/extract-deployments.ts --from-repos org/repo1,org/repo2
```

This outputs a markdown table with staging/production URLs extracted from wrangler.jsonc routes.
