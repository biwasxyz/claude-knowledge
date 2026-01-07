#!/bin/bash
# Daily Git Summary Script
# Scans all git repos under ~/dev and reports commits for a given date
# Usage: daily-git-summary.sh [YYYY-MM-DD]
#
# Output: Logs saved to ~/logs/YYYY-MM-DDTHH-MM-SS-daily-summary.md

DATE="${1:-$(date +%Y-%m-%d)}"
DEV_DIR="${2:-$HOME/dev}"

# Setup logging
LOG_DIR="${HOME}/logs"
TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
LOG_FILE="${LOG_DIR}/${TIMESTAMP}-daily-github-summary.md"
mkdir -p "$LOG_DIR"

# Use exec to redirect all output to both terminal and log file
exec > >(tee "$LOG_FILE") 2>&1

echo "=== Git Activity for $DATE ==="
echo ""

# Find all git repos and check for commits
find "$DEV_DIR" -type d -name ".git" 2>/dev/null | sort | while read gitdir; do
  repo=$(dirname "$gitdir")
  repo_name=$(echo "$repo" | sed "s|$HOME/dev/||")

  # Get commits for the date
  commits=$(cd "$repo" && git log --oneline --since="$DATE 00:00:00" --until="$DATE 23:59:59" 2>/dev/null)

  if [ -n "$commits" ]; then
    count=$(echo "$commits" | wc -l)
    echo "### $repo_name ($count commits)"
    echo "$commits"
    echo ""
  fi
done

echo "=== GitHub Activity ==="
echo ""

# Check if gh is available
if command -v gh &> /dev/null; then
  # Issues created by me today
  echo "### Issues Created"
  issues_created=$(gh search issues --author=@me --created="$DATE" --limit=20 \
    --json repository,number,title \
    --jq '.[] | "- " + .repository.nameWithOwner + "#" + (.number|tostring) + ": " + .title' 2>/dev/null)
  if [ -n "$issues_created" ]; then
    echo "$issues_created"
  else
    echo "None"
  fi
  echo ""

  # Issues closed today (that involve me)
  echo "### Issues Closed"
  issues_closed=$(gh search issues --involves=@me --closed="$DATE" --limit=20 \
    --json repository,number,title \
    --jq '.[] | "- " + .repository.nameWithOwner + "#" + (.number|tostring) + ": " + .title' 2>/dev/null)
  if [ -n "$issues_closed" ]; then
    echo "$issues_closed"
  else
    echo "None"
  fi
  echo ""

  # PRs opened by me today
  echo "### PRs Opened"
  prs_opened=$(gh search prs --author=@me --created="$DATE" --limit=20 \
    --json repository,number,title \
    --jq '.[] | "- " + .repository.nameWithOwner + "#" + (.number|tostring) + ": " + .title' 2>/dev/null)
  if [ -n "$prs_opened" ]; then
    echo "$prs_opened"
  else
    echo "None"
  fi
  echo ""

  # PRs merged today (that I authored)
  echo "### PRs Merged"
  prs_merged=$(gh search prs --author=@me --merged="$DATE" --limit=20 \
    --json repository,number,title \
    --jq '.[] | "- " + .repository.nameWithOwner + "#" + (.number|tostring) + ": " + .title' 2>/dev/null)
  if [ -n "$prs_merged" ]; then
    echo "$prs_merged"
  else
    echo "None"
  fi
else
  echo "gh CLI not available - skipping GitHub activity"
fi

echo ""
echo "=== End of Summary ==="
echo ""
echo "Log saved: $LOG_FILE"
