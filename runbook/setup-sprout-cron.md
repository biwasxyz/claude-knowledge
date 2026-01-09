# Setup Sprout Documentation Cron Job

Automate documentation updates across all your repositories using sprout-update-all.sh with cron.

## Prerequisites

- Claude Code CLI installed and authenticated
- Repositories initialized with `/sprout-docs` (creates `sprout-docs.json`)
- `jq` installed for JSON parsing: `sudo apt install jq`

## Quick Setup

### 1. Symlink the Script (Optional)

Add the script to your PATH for easy access:

```bash
ln -s ~/.claude/skills/sprout-docs/sprout-update-all.sh \
      ~/.local/bin/sprout-update-all
```

### 2. Test the Script

Run a dry run first to see which repos would be updated:

```bash
DRY_RUN=true sprout-update-all ~/dev
```

Run for real:

```bash
sprout-update-all ~/dev
```

### 3. Add to Crontab

Edit your crontab:

```bash
crontab -e
```

Add one of these schedules:

```cron
# Daily at 2 AM
0 2 * * * ~/.claude/skills/sprout-docs/sprout-update-all.sh ~/dev

# Weekly on Sunday at 3 AM
0 3 * * 0 ~/.claude/skills/sprout-docs/sprout-update-all.sh ~/dev

# Monthly on the 1st at 4 AM
0 4 1 * * ~/.claude/skills/sprout-docs/sprout-update-all.sh ~/dev
```

### 4. Verify Cron Entry

```bash
crontab -l | grep sprout
```

## How It Works

1. **Scans** `target_dir` (default: `~/dev`) for `sprout-docs.json` files
2. **Filters** to only opted-in repositories (those with the config file)
3. **Runs** Claude Code with `/sprout-docs` skill on each repo
4. **Logs** results to `~/logs/TIMESTAMP-sprout-update-all.json`

### Opting In a Repository

To include a repo in automated updates, run the skill once manually:

```bash
cd ~/dev/org/my-repo
claude
> /sprout-docs
```

This creates `sprout-docs.json` which marks the repo as opted-in.

### Opting Out

Remove the config file to exclude a repo:

```bash
rm ~/dev/org/my-repo/sprout-docs.json
```

## Cost Control

The script is designed to minimize API usage:

- **Opt-in only**: Skips repos without `sprout-docs.json`
- **Incremental updates**: The skill uses content hashing to only update changed folders
- **Dry run mode**: Preview which repos would be processed without API calls

## Logs

Logs are saved to `~/logs/` as JSON files with timestamp prefixes:

```bash
# View latest log
ls -lt ~/logs/*sprout* | head -5

# Pretty-print the latest log
jq . "$(ls -t ~/logs/*-sprout-update-all.json | head -1)"

# Check summary of latest run
jq '.summary' "$(ls -t ~/logs/*-sprout-update-all.json | head -1)"

# List failed repos
jq '.repos[] | select(.status == "failed")' ~/logs/2026-01-07T02-00-00-sprout-update-all.json
```

Log filename format: `YYYY-MM-DDTHH-MM-SS-sprout-update-all.json`

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

0 2 * * * /path/to/sprout-update-all.sh ~/dev
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

Verify repos have `sprout-docs.json`:

```bash
find ~/dev -name "sprout-docs.json" -type f
```

If empty, initialize repos manually with `/sprout-docs`.

## Advanced Usage

### Custom Target Directory

```bash
# Update only a specific org's repos
sprout-update-all ~/dev/my-org

# Update a different dev folder
sprout-update-all ~/projects
```

### Environment Variables

```bash
# Dry run (no changes)
DRY_RUN=true sprout-update-all ~/dev
```

### Manual Log Rotation

Logs accumulate over time. Clean up old logs:

```bash
# Remove sprout logs older than 30 days
find ~/logs -name "*-sprout-update-all.json" -mtime +30 -delete
```

Or add to cron:

```cron
# Clean old sprout logs weekly
0 0 * * 0 find ~/logs -name "*-sprout-update-all.json" -mtime +30 -delete
```
