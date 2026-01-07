---
description: Check status of build, PRs, deployments, and CI
allowed-tools: Bash, Read
---

Check the current status of the project:

1. **Git status**
   ```bash
   git status --short
   git log -3 --oneline
   ```

2. **Branch info**
   ```bash
   git branch -vv
   ```

3. **CI/CD status** (if GitHub)
   ```bash
   gh run list --limit 5
   gh pr status
   ```

4. **Open PRs**
   ```bash
   gh pr list --state open
   ```

5. **Build status** (if applicable)
   - Check for build artifacts
   - Check recent test runs

6. **Report format**
   ```
   STATUS: [repo name]
   ═══════════════════════════════════════

   Git:     [branch] | [ahead/behind] | [clean/dirty]
   Commits: [recent commits]

   CI/CD:   [last run status]
   PRs:     [open count] open, [draft count] draft

   Recent Runs:
   ├── [workflow] [status] [time]
   └── [workflow] [status] [time]

   ═══════════════════════════════════════
   ```

Quick, read-only status check. Use /sync to actually pull changes.
