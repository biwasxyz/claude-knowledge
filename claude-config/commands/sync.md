---
description: Sync development environment - pull repos, check git status, verify dependencies
allowed-tools: Bash, Glob, Read
---

Synchronize the development environment by:

1. **Check current directory**
   - Run `git status` to see current state
   - Check for uncommitted changes

2. **Pull latest changes**
   - If clean, run `git pull --rebase`
   - If dirty, warn user about uncommitted changes

3. **Check related repos** (if in ~/dev/)
   - Look for common dependency repos
   - Report which repos have updates available

4. **Verify dependencies**
   - If package.json exists: check if node_modules is current
   - If requirements.txt exists: note Python dependencies
   - If Clarinet.toml exists: note Clarity project

5. **Report summary**
   Format:
   ```
   SYNC COMPLETE
   ├── Current repo: [status]
   ├── Branch: [branch]
   ├── Last commit: [hash] [message]
   ├── Dependencies: [status]
   └── Related repos: [count] checked
   ```

$ARGUMENTS can specify a specific repo path to sync instead of current directory.
