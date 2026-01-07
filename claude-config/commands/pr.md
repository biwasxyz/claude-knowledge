---
description: Create or manage pull requests
allowed-tools: Bash, Read, Write, AskUserQuestion
argument-hint: [create|view|merge] [PR number]
---

Manage pull requests. Usage: /pr [action] [args]

**Actions:**

## /pr create (default)
1. Check branch status
   ```bash
   git status
   git log origin/main..HEAD --oneline
   ```

2. Gather PR info
   - Ask for title if not obvious from commits
   - Generate description from commits and changes
   - Detect linked issues

3. Create PR
   ```bash
   gh pr create --title "Title" --body "$(cat <<'EOF'
   ## Summary
   [description]

   ## Changes
   - [change 1]

   ## Testing
   [how to test]

   ## Related Issues
   Closes #[number]
   EOF
   )"
   ```

## /pr view [number]
```bash
gh pr view [number]
gh pr diff [number]
gh pr checks [number]
```

## /pr merge [number]
1. Check PR status
   ```bash
   gh pr checks [number]
   gh pr view [number] --json reviews
   ```

2. If approved and checks pass:
   ```bash
   gh pr merge [number] --squash
   ```

## /pr list
```bash
gh pr list --state open
```

Arguments: $ARGUMENTS
