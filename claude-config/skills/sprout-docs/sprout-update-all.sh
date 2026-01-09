#!/bin/bash
# Sprout Update All - Batch documentation updater
# Scans for repos with sprout-docs.json and runs /sprout-docs on each
#
# Usage: sprout-update-all.sh [target_dir]
#
# Arguments:
#   target_dir    Root directory to scan (default: ~/dev)
#
# Expected directory structure:
#   ~/dev/
#   ├── org1/
#   │   ├── repo-a/           # Has sprout-docs.json -> will update
#   │   └── repo-b/           # No sprout-docs.json -> skipped
#   ├── org2/
#   │   └── repo-c/           # Has sprout-docs.json -> will update
#   └── personal-project/     # Has sprout-docs.json -> will update
#
# Opt-in mechanism:
#   Only repos containing sprout-docs.json are processed.
#   Run /sprout-docs manually once to initialize a repo.
#
# Cost control:
#   - Only processes opted-in repos (those with sprout-docs.json)
#   - Skips repos where docs are already up to date
#   - Use --dry-run to preview without making changes

set -euo pipefail

# Configuration
TARGET_DIR="${1:-$HOME/dev}"
LOG_DIR="${HOME}/logs"
TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
LOG_FILE="${LOG_DIR}/${TIMESTAMP}-sprout-update-all.json"
DRY_RUN="${DRY_RUN:-false}"
START_TIME=$(date -Iseconds)

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Terminal logging (no file writes until end)
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# JSON result collection
declare -a RESULTS=()

add_result() {
    local repo="$1"
    local status="$2"
    local message="$3"
    RESULTS+=("{\"repo\":\"$repo\",\"status\":\"$status\",\"message\":\"$message\"}")
}

# Ensure log directory exists
mkdir -p "$LOG_DIR"

log_info "=== Sprout Update All ==="
log_info "Target: $TARGET_DIR"
log_info "Log: $LOG_FILE"
log_info "Started: $START_TIME"
echo ""

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Find all sprout-docs.json files (opted-in repos)
log_info "Scanning for sprout-docs.json files..."
SPROUT_CONFIGS=$(find "$TARGET_DIR" -name "sprout-docs.json" -type f 2>/dev/null | sort)

if [ -z "$SPROUT_CONFIGS" ]; then
    log_warn "No sprout-docs.json files found in $TARGET_DIR"
    log_info "Run /sprout-docs manually in a repo to initialize it."
    exit 0
fi

# Count repos
TOTAL=$(echo "$SPROUT_CONFIGS" | wc -l)
log_info "Found $TOTAL opted-in repos"
echo ""

# Track results
UPDATED=0
SKIPPED=0
FAILED=0

# Process each repo
for config in $SPROUT_CONFIGS; do
    REPO_DIR=$(dirname "$config")
    REPO_NAME=$(echo "$REPO_DIR" | sed "s|$TARGET_DIR/||")

    log_info "Processing: $REPO_NAME"

    # Check if it's a git repo
    if [ ! -d "$REPO_DIR/.git" ]; then
        log_warn "  Skipping: not a git repository"
        add_result "$REPO_NAME" "skipped" "not a git repository"
        ((SKIPPED++))
        continue
    fi

    # Dry run mode
    if [ "$DRY_RUN" = "true" ]; then
        log_info "  [DRY RUN] Would update documentation"
        add_result "$REPO_NAME" "dry_run" "would update"
        continue
    fi

    # Run claude with sprout-docs skill
    cd "$REPO_DIR"

    # Capture output and exit code
    if output=$(claude -p "Run /sprout-docs to update documentation" \
        --allowedTools "Bash,Read,Write,Edit,Glob,Grep" \
        --output-format json 2>&1); then

        # Check if docs were updated
        result=$(echo "$output" | jq -r '.result // "No result"' 2>/dev/null || echo "$output")

        if echo "$result" | grep -q "DOCUMENTATION COMPLETE\|up to date\|No changes"; then
            log_success "  Complete"
            add_result "$REPO_NAME" "complete" "documentation up to date"
            ((UPDATED++))
        else
            log_success "  Updated"
            add_result "$REPO_NAME" "updated" "documentation updated"
            ((UPDATED++))
        fi
    else
        log_error "  Failed to update"
        add_result "$REPO_NAME" "failed" "update failed"
        ((FAILED++))
    fi

    echo ""
done

# Summary
END_TIME=$(date -Iseconds)
log_info "=== Summary ==="
log_info "Total repos: $TOTAL"
log_success "Updated: $UPDATED"
[ $SKIPPED -gt 0 ] && log_warn "Skipped: $SKIPPED"
[ $FAILED -gt 0 ] && log_error "Failed: $FAILED"
log_info "Completed: $END_TIME"

# Write JSON log file
{
    echo "{"
    echo "  \"startTime\": \"$START_TIME\","
    echo "  \"endTime\": \"$END_TIME\","
    echo "  \"targetDir\": \"$TARGET_DIR\","
    echo "  \"dryRun\": $DRY_RUN,"
    echo "  \"summary\": {"
    echo "    \"total\": $TOTAL,"
    echo "    \"updated\": $UPDATED,"
    echo "    \"skipped\": $SKIPPED,"
    echo "    \"failed\": $FAILED"
    echo "  },"
    echo "  \"repos\": ["
    # Join results with commas
    first=true
    for r in "${RESULTS[@]}"; do
        if [ "$first" = true ]; then
            echo "    $r"
            first=false
        else
            echo "    ,$r"
        fi
    done
    echo "  ]"
    echo "}"
} > "$LOG_FILE"

log_info "Log saved: $LOG_FILE"
