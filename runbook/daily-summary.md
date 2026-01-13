# Daily Summary Workflow

Generate and publish daily work summaries across all git repositories.

## Overview

This workflow produces a team-friendly summary of commits, issues, and PRs, then publishes it to a Jekyll blog hosted on GitHub Pages.

## Prerequisites

- GitHub CLI (`gh`) authenticated
- Access to `~/dev/` repositories (organized as `org/repo-name`)
- A GitHub repo for publishing summaries (e.g., `yourorg/dev-logs`)
- Set `DAILY_LOGS_REPO` environment variable or note your logs repo path

## Workflow Steps

### 1. Collect Raw Data

Run the bash script to gather git and GitHub activity:

```bash
~/.claude/skills/daily/daily-git-summary.sh [DATE]
```

**Outputs:**
- `~/logs/DATETIME-daily-github-summary.md` - Raw data (timestamped, accumulates)
- Console output with commits, issues, PRs

### 2. Interpret and Format

Review the raw output and create/update the team summary:

- **Location**: `~/logs/YYYY-MM-DD-daily-summary.md`
- **Template**: `~/.claude/skills/daily/TEMPLATE.md`

Summary sections:
| Section | Content |
|---------|---------|
| Highlights | 2-4 sentences on main accomplishments |
| Repository Changes | Repos added/removed (if any) |
| Commits | Table with repo, count, summary |
| GitHub Activity | Issues and PRs in table format |
| Notes | Optional blockers or follow-ups |

### 3. Sync to Logs Repo

Copy the formatted summary to your blog repo:

```bash
# Replace with your logs repo path
cp ~/logs/YYYY-MM-DD-daily-summary.md ~/dev/$DAILY_LOGS_REPO/_posts/
```

Add Jekyll front matter if creating new post:
```yaml
---
title: "Daily Summary - YYYY-MM-DD"
date: YYYY-MM-DD
categories: [daily-summary]
tags: [commits, github]
---
```

### 4. Commit and Push

```bash
cd ~/dev/$DAILY_LOGS_REPO
git add _posts/YYYY-MM-DD-daily-summary.md
git commit -m "docs: add daily summary for YYYY-MM-DD"
git push
```

GitHub Pages builds automatically on push.

## Running Multiple Times

- Raw data files accumulate (timestamped)
- Team summary updates in place
- "Last updated" timestamp refreshes
- Manual notes in existing summaries are preserved

## Files Reference

| File | Purpose |
|------|---------|
| `~/.claude/skills/daily/daily-git-summary.sh` | Bash script for raw data collection |
| `~/.claude/skills/daily/TEMPLATE.md` | Summary format template |
| `~/logs/*-daily-github-summary.md` | Raw script outputs |
| `~/logs/YYYY-MM-DD-daily-summary.md` | Formatted summaries |
| `~/dev/$DAILY_LOGS_REPO/_posts/` | Published blog posts |

## Troubleshooting

**No commits found**: Check if the date is correct and repos have activity.

**GitHub API errors**: Verify `gh auth status` and rate limits.

**Push rejected**: Pull latest changes first with `git pull --rebase`.
