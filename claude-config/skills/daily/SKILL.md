# Daily Git Summary Skill

Scans all git repositories under `~/dev` and generates a summary of commits for a specified date.

## Files

- `daily-git-summary.sh` - Bash script that finds all `.git` directories and runs `git log` for the date

## Usage

The `/daily` command invokes this skill with an optional date argument.

```bash
# Run directly
~/.claude/skills/daily/daily-git-summary.sh 2026-01-06

# Or via Claude command
/daily           # Uses today's date
/daily 2026-01-05  # Specific date
```

## Output

Returns commits grouped by repository with commit counts:
```
### org/repo-name (N commits)
abc1234 commit message
def5678 another message
```
