# Setup Ralph Documentation Cron Job

Automate documentation updates across all your repositories using ralph-update-all.sh with cron.

## Prerequisites

- Claude Code CLI installed and authenticated
- Repositories initialized with `/ralph-write-docs` (creates `ralph-docs.json`)
- `jq` installed for JSON parsing: `sudo apt install jq`

## Quick Setup

### 1. Symlink the Script (Optional)

Add the script to your PATH for easy access:

```bash
ln -s ~/dev/whoabuddy/claude-knowledge/claude-config/skills/ralph-write-docs/ralph-update-all.sh \
      ~/.local/bin/ralph-update-all
```

### 2. Test the Script

Run a dry run first to see which repos would be updated:

```bash
DRY_RUN=true ralph-update-all ~/dev
```

Run for real:

```bash
ralph-update-all ~/dev
```

### 3. Add to Crontab

Edit your crontab:

```bash
crontab -e
```

Add one of these schedules:

```cron
# Daily at 2 AM
0 2 * * * /home/whoabuddy/dev/whoabuddy/claude-knowledge/claude-config/skills/ralph-write-docs/ralph-update-all.sh ~/dev

# Weekly on Sunday at 3 AM
0 3 * * 0 /home/whoabuddy/dev/whoabuddy/claude-knowledge/claude-config/skills/ralph-write-docs/ralph-update-all.sh ~/dev

# Monthly on the 1st at 4 AM
0 4 1 * * /home/whoabuddy/dev/whoabuddy/claude-knowledge/claude-config/skills/ralph-write-docs/ralph-update-all.sh ~/dev
```

### 4. Verify Cron Entry

```bash
crontab -l | grep ralph
```

## How It Works

1. **Scans** `target_dir` (default: `~/dev`) for `ralph-docs.json` files
2. **Filters** to only opted-in repositories (those with the config file)
3. **Runs** Claude Code with `/ralph-write-docs` skill on each repo
4. **Logs** results to `~/.local/log/ralph/update-TIMESTAMP.log`

### Opting In a Repository

To include a repo in automated updates, run the skill once manually:

```bash
cd ~/dev/org/my-repo
claude
> /ralph-write-docs
```

This creates `ralph-docs.json` which marks the repo as opted-in.

### Opting Out

Remove the config file to exclude a repo:

```bash
rm ~/dev/org/my-repo/ralph-docs.json
```

## Cost Control

The script is designed to minimize API usage:

- **Opt-in only**: Skips repos without `ralph-docs.json`
- **Incremental updates**: The skill uses content hashing to only update changed folders
- **Dry run mode**: Preview which repos would be processed without API calls

## Logs

Logs are saved to `~/logs/` as JSON files with timestamp prefixes:

```bash
# View latest log
ls -lt ~/logs/*ralph* | head -5

# Pretty-print the latest log
jq . "$(ls -t ~/logs/*-ralph-update-all.json | head -1)"

# Check summary of latest run
jq '.summary' "$(ls -t ~/logs/*-ralph-update-all.json | head -1)"

# List failed repos
jq '.repos[] | select(.status == "failed")' ~/logs/2026-01-07T02-00-00-ralph-update-all.json
```

Log filename format: `YYYY-MM-DDTHH-MM-SS-ralph-update-all.json`

Log structure:
```json
{
  "startTime": "2026-01-07T02:00:00-07:00",
  "endTime": "2026-01-07T02:05:30-07:00",
  "targetDir": "/home/whoabuddy/dev",
  "dryRun": false,
  "summary": {
    "total": 3,
    "updated": 2,
    "skipped": 0,
    "failed": 1
  },
  "repos": [
    {"repo": "org/repo-a", "status": "updated", "message": "documentation updated"},
    {"repo": "org/repo-b", "status": "complete", "message": "documentation up to date"},
    {"repo": "org/repo-c", "status": "failed", "message": "update failed"}
  ]
}
```

## Troubleshooting

### Script Not Running in Cron

Cron has a minimal environment. Ensure Claude is in the PATH:

```cron
PATH=/home/whoabuddy/.local/bin:/usr/local/bin:/usr/bin:/bin

0 2 * * * /path/to/ralph-update-all.sh ~/dev
```

Or use full path to claude:

```bash
# Find claude location
which claude
# e.g., /home/whoabuddy/.local/bin/claude
```

### Authentication Issues

Claude Code needs to be authenticated. Run interactively first:

```bash
claude --auth
```

### No Repos Found

Verify repos have `ralph-docs.json`:

```bash
find ~/dev -name "ralph-docs.json" -type f
```

If empty, initialize repos manually with `/ralph-write-docs`.

## Advanced Usage

### Custom Target Directory

```bash
# Update only a specific org's repos
ralph-update-all ~/dev/my-org

# Update a different dev folder
ralph-update-all ~/projects
```

### Environment Variables

```bash
# Dry run (no changes)
DRY_RUN=true ralph-update-all ~/dev
```

### Manual Log Rotation

Logs accumulate over time. Clean up old logs:

```bash
# Remove ralph logs older than 30 days
find ~/logs -name "*-ralph-update-all.json" -mtime +30 -delete
```

Or add to cron:

```cron
# Clean old ralph logs weekly
0 0 * * 0 find ~/logs -name "*-ralph-update-all.json" -mtime +30 -delete
```
