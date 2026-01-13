# Sprout Docs Runbook

Generate navigable README.md files for every folder in a repository.

## Overview

Sprout Docs creates folder-scoped documentation with breadcrumb navigation, contents tables, and relationship mapping. Works on the current branch (for PRs to upstream) rather than gh-pages.

## State File

`sprout-docs.json` (gitignored) tracks documentation state:

```json
{
  "version": 1,
  "lastRun": "2024-01-06T15:30:00Z",
  "baseBranch": "main",
  "theme": {
    "primary": "#06B6D4",
    "accent": "#3B82F6",
    "source": "fallback-go"
  },
  "folders": {
    "src": { "contentHash": "abc123", "documented": true },
    "src/components": { "contentHash": "def456", "documented": true }
  },
  "stats": {
    "totalFolders": 23,
    "documented": 23,
    "lastFullRun": "2024-01-06T15:30:00Z"
  }
}
```

## First Run Setup

1. Add `sprout-docs.json` to `.gitignore`
2. Commit the .gitignore change
3. Proceed with folder discovery and documentation

## Skip Patterns

Always skip:
- `node_modules/`, `.git/`, `dist/`, `build/`, `out/`
- `coverage/`, `.claude/`, `__pycache__/`
- Anything in `.gitignore`
- Empty directories

## Folder Discovery

For each folder:
1. Calculate content hash: `git rev-parse HEAD:path/to/folder`
2. Compare to stored hash in `sprout-docs.json`
3. If new or changed, add to processing queue

## README Template

```markdown
[← parent](../README.md) · **folder-name**

# Folder Name

> One-line purpose: why this folder exists, not what it contains.

## Contents

| Item | Purpose |
|------|---------|
| [`file.ts`](./file.ts) | Brief description |
| [`subfolder/`](./subfolder/) | Brief description |

## Relationships

Non-obvious connections only:
- **Consumed by**: `../api/routes.ts` uses these utilities
- **Depends on**: Requires `../config/` to be initialized first

---
*[View on main](../../tree/main/path/to/folder) · Updated: 2024-01-06*
```

## Navigation Rules

**Breadcrumb format:**
```
[← parent](../README.md) · **current** · [root](/README.md)
```

- Always link to parent (except root)
- Bold the current folder name
- Link to root from deep folders (depth > 2)
- Use relative paths only

## Theme Detection

Search priority:
1. `tailwind.config.{js,ts}` - theme.extend.colors
2. `src/**/theme.{js,ts,json}`
3. `package.json` - theme config
4. CSS variables in globals.css

**Fallback themes by language:**
- TypeScript/React: Blue (#2563EB), emerald (#10B981)
- Python: Blue (#3B82F6), amber (#F59E0B)
- Rust: Orange (#EA580C), slate (#475569)
- Go: Cyan (#06B6D4), blue (#3B82F6)
- Generic: Slate (#475569), blue (#2563EB)

## Quality Gate

README is complete when:
- [ ] Has breadcrumb navigation (valid links)
- [ ] Has purpose statement (< 100 chars, explains WHY)
- [ ] Contents table matches actual folder contents
- [ ] Relationships section exists
- [ ] All internal links resolve
- [ ] Updated timestamp present

## Iteration Strategy

Each iteration:
1. Check state - Read `sprout-docs.json`, identify pending work
2. Select batch - Pick 5-10 folders to document
3. Complete batch - Finish every README before exiting
4. Commit progress - `docs(sprout): document folder1, folder2, folder3`
5. Update state - Write to `sprout-docs.json`
6. Exit or continue - Promise if all done

**Critical: Always finish what you start**
- Never leave a README half-written
- State file reflects completed work only

## Commit Strategy

- Commit after each completed batch
- Message format: `docs(sprout): document src/api, src/utils, src/hooks`
- Work on current branch (not gh-pages)

## Update Mode

When `sprout-docs.json` exists:
1. Compare folder hashes to find changes
2. Only regenerate changed folders
3. Preserve `<!-- custom -->` sections
4. Update timestamps on touched files

## Completion

Output when ALL conditions met:
```
<promise>DOCUMENTATION COMPLETE</promise>
```

Conditions:
- Every non-skipped folder has README.md
- All READMEs pass quality gate
- `sprout-docs.json` updated
- Changes committed

## Progress Display

```
DOCS PROGRESS: 15/23 folders
━━━━━━━━━━━━━━━━━━━━━░░░░░░░░ 65%

This iteration:
  ✓ src/components/ - complete
  ✓ src/utils/ - complete
  → src/hooks/ - in progress

Queued:
  ○ src/api/
  ○ src/services/
```
