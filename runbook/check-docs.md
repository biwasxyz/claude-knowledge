# Check Documentation

Verify documentation quality and completeness in a repository.

## Overview

This procedure checks that essential documentation exists, is non-empty, has valid links, and reflects the current state of the code.

## Priority Files

1. **README.md** (required) - Project overview, setup, usage
2. **CLAUDE.md** (if present) - Claude Code instructions for the project
3. **Other .md files** - Lower priority, check if they exist

## Checks

### 1. Existence and Content

```bash
# Check for required files
ls -la README.md CLAUDE.md 2>/dev/null

# Check file sizes (non-empty)
wc -l README.md CLAUDE.md 2>/dev/null
```

**Pass criteria:**
- README.md exists and has content
- CLAUDE.md exists if project uses Claude Code

### 2. Link Validation

Check all markdown links in documentation files:

**Internal links** (relative paths):
- File references exist: `[guide](./docs/guide.md)`
- Anchors resolve: `[section](#installation)`
- Image paths valid: `![logo](./assets/logo.png)`

**External links**:
- URLs are reachable (optional - can be slow)
- No obviously broken patterns (localhost in production docs)

### 3. Up-to-Date Check

Compare documentation against code:

**README.md should reflect:**
- Current installation steps match package.json/requirements
- CLI commands/flags match actual implementation
- API examples use current signatures
- Dependencies listed match actual dependencies

**CLAUDE.md should reflect:**
- Build/test commands that actually work
- File paths that exist
- Quick facts that are still accurate

### 4. Common Issues

| Issue | How to Detect |
|-------|---------------|
| Stale install steps | Compare README commands with package.json scripts |
| Dead links | Grep for `](` and verify targets exist |
| Outdated examples | Code snippets reference old APIs |
| Missing sections | No usage/install/contributing for public repos |

## Output Format

Report as a checklist:

```
## Documentation Check

### README.md
- [x] Exists and non-empty (142 lines)
- [x] Internal links valid (3 checked)
- [ ] Install steps match package.json - OUTDATED
  - README says `npm install` but package.json uses pnpm

### CLAUDE.md
- [x] Exists and non-empty (45 lines)
- [x] Build commands work
- [ ] References stale path: `src/old-module/`

### Other Docs
- docs/api.md - exists (89 lines)
- docs/setup.md - NOT FOUND (referenced in README)

### Summary
2 issues found - see details above
```

## When to Run

- Before creating a PR
- After significant refactoring
- When onboarding to a new project
- Periodically for maintained projects

## Fixing Issues

For each issue found:
1. Verify the issue (false positives happen)
2. Update the documentation OR update the code
3. Re-run check to confirm fix
