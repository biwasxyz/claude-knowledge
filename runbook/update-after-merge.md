# Update After Merge

Clean up local repository after a PR is merged.

## Overview

After a PR is merged on GitHub, this procedure updates your local repository: switches to the default branch, deletes the merged feature branch, and pulls the latest changes.

## Procedure

### 1. Detect Current State

```bash
# Get current branch
git branch --show-current

# Get default branch (usually main or master)
git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs
```

### 2. Check for Uncommitted Changes

```bash
git status --porcelain
```

If there are uncommitted changes:
- Stash them: `git stash push -m "WIP before branch cleanup"`
- Or commit them if intentional
- Or discard if not needed: `git checkout -- .`

### 3. Switch to Default Branch

```bash
# Switch to main (or master)
git checkout main
# or
git checkout master
```

### 4. Pull Latest Changes

```bash
git pull origin main
# or with rebase
git pull --rebase origin main
```

### 5. Delete Feature Branch

```bash
# Get the feature branch name (stored before switching)
FEATURE_BRANCH="feature/your-branch-name"

# Delete local branch
git branch -d $FEATURE_BRANCH

# Delete remote branch (if not auto-deleted by GitHub)
git push origin --delete $FEATURE_BRANCH
```

**Note:** Use `-d` (safe delete) not `-D` (force delete). Safe delete prevents deleting unmerged branches.

### 6. Clean Up Remote References

```bash
# Prune deleted remote branches
git fetch --prune
```

## Quick One-Liner

For a branch already merged:

```bash
git checkout main && git pull && git branch -d feature-branch && git fetch --prune
```

## Output Format

```
## Update After Merge

Previous branch: feature/add-auth
Default branch: main

- [x] Switched to main
- [x] Pulled latest (3 new commits)
- [x] Deleted local branch: feature/add-auth
- [x] Remote branch already deleted by GitHub
- [x] Pruned stale remote references

Ready to start new work.
```

## Edge Cases

### Branch Not Merged

If the branch wasn't actually merged:
```
error: The branch 'feature/thing' is not fully merged.
If you are sure you want to delete it, run 'git branch -D feature/thing'.
```

**Resolution:** Verify the PR was merged on GitHub before forcing delete.

### Working on Wrong Branch

If currently on a different feature branch:
```
You're on 'feature/other-thing', not the merged branch.
Switch to the merged branch first, or specify which branch to delete.
```

### Remote Branch Still Exists

If GitHub didn't auto-delete:
```bash
git push origin --delete feature/your-branch
```

## When to Run

- After a PR is merged on GitHub
- After completing a feature and merging locally
- When cleaning up stale branches
