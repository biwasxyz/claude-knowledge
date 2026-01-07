---
description: Generate daily work summary from all git repos in ~/dev
allowed-tools: Bash, Read, Write, Edit, Glob
argument-hint: [optional: date as YYYY-MM-DD, defaults to today]
---

Generate a team-friendly daily summary of work across all git repositories.

## Process

### 1. Run the GitHub summary script

```bash
~/.claude/skills/daily/daily-git-summary.sh $ARGUMENTS
```

This saves raw git/GitHub data to `~/logs/DATETIME-daily-github-summary.md`.

### 2. Read the template

```bash
cat ~/.claude/skills/daily/TEMPLATE.md
```

### 3. Check for existing daily summary

Look for today's summary file: `~/logs/YYYY-MM-DD-daily-summary.md`

If it exists, read it as context. You'll be updating it in place, not starting fresh.

### 4. Generate the summary

Using the raw GitHub data and template, create/update the daily summary:

**Highlights section:**
- 2-4 sentences summarizing main accomplishments
- Written in first person plural ("We added...", "We fixed...")
- Focus on outcomes, not technical details
- Suitable for sharing with non-technical stakeholders

**Commits table:**
- One row per repo with activity
- Count column shows number of commits
- Summary column: brief description of what changed (not individual commits)

**GitHub Activity tables:**
- Issues table: Created and Closed actions with issue references
- PRs table: Opened and Merged actions with PR references
- Use format `org/repo#N` for references

**Notes section:**
- Include only if there are blockers, follow-ups, or important context
- Remove the section entirely if empty

### 5. Save the summary

Save to `~/logs/YYYY-MM-DD-daily-summary.md` (one file per day, updated in place).

If updating an existing file:
- Preserve any manual notes or context added
- Update the "Last updated" timestamp
- Refresh data sections with latest information

### 6. Display the summary

Output the final summary so the user can see it.

## Output Files

- `~/logs/DATETIME-daily-github-summary.md` - Raw script output (one per run)
- `~/logs/YYYY-MM-DD-daily-summary.md` - Team summary (one per day, updated)

Date: $ARGUMENTS (defaults to today's date)
