#!/bin/bash
# Validate claude-config for sharing
# Run before committing to catch hardcoded paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "=== Validating claude-config ==="
echo ""

ERRORS=0

# Check for hardcoded username (ignore github.com URLs which are intentional)
echo "Checking for hardcoded usernames..."
FOUND=$(grep -r "whoabuddy" "$CONFIG_DIR" --include="*.md" --include="*.sh" 2>/dev/null | grep -v "github.com/whoabuddy" | grep -v "validate-config.sh")
if [ -n "$FOUND" ]; then
  echo "⚠️  Found hardcoded username in:"
  echo "$FOUND"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ No hardcoded usernames (github URLs excluded)"
fi
echo ""

# Check for hardcoded home paths
echo "Checking for hardcoded home paths..."
if grep -rqE "/home/[a-z]+" "$CONFIG_DIR" --include="*.md" --include="*.sh" 2>/dev/null; then
  echo "⚠️  Found hardcoded /home/ paths in:"
  grep -rlE "/home/[a-z]+" "$CONFIG_DIR" --include="*.md" --include="*.sh" 2>/dev/null
  ERRORS=$((ERRORS + 1))
else
  echo "✓ No hardcoded home paths"
fi
echo ""

# Check for potential secrets
echo "Checking for potential secrets..."
if grep -rqEi "(api[_-]?key|secret|password|token)[\s]*[=:][\s]*['\"][^'\"]+['\"]" "$CONFIG_DIR" --include="*.md" --include="*.sh" 2>/dev/null; then
  echo "⚠️  Potential secrets found - review carefully"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ No obvious secrets"
fi
echo ""

# Summary
echo "=== Validation Complete ==="
if [ $ERRORS -eq 0 ]; then
  echo "✓ All checks passed - safe to commit"
  exit 0
else
  echo "⚠️  $ERRORS issue(s) found - review before committing"
  exit 1
fi
