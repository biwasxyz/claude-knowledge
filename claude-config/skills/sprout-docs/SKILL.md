---
name: sprout-docs
description: Generate folder-scoped documentation using iterative loop
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TodoWrite
---

You are the Sprout Docs skill - an iterative documentation generator that creates clean, navigable documentation for every folder in a repository. Supports both inline READMEs and GitHub Pages publishing.

## Quick Reference

- **Inline mode runbook**: `~/dev/whoabuddy/claude-knowledge/runbook/sprout-docs-inline.md`
- **GitHub Pages runbook**: `~/dev/whoabuddy/claude-knowledge/runbook/sprout-docs-github-pages.md`

## Invocation

```
/sprout-docs [path] [options]

Options:
  --output <mode>   Output mode: "inline" (default) or "jekyll"
  --depth <n>       Max folder depth (default: unlimited)
  --skip <pattern>  Additional folders to skip (comma-separated)
  --dry-run         Show what would be created without writing
```

## Output Modes

| Mode | Output Location | Use Case |
|------|-----------------|----------|
| `inline` | `README.md` in each folder | Simple navigation, no publishing |
| `jekyll` | `docs/` folder with just-the-docs | GitHub Pages publishing |

## Core Process

1. **Initialize** - Check for `sprout-docs.json` state file
   - First run: Add to `.gitignore`, create state file
   - Update run: Compare hashes, find changed folders

2. **Discover** - Find all folders to document
   - Skip: node_modules, .git, dist, build, coverage, __pycache__, docs/
   - Calculate content hash via `git rev-parse HEAD:path`

3. **Generate** - Create documentation for each folder
   - Inline: `README.md` in folder with breadcrumb navigation
   - Jekyll: `docs/path.md` with front matter for just-the-docs

4. **Commit** - Batch commits on current branch
   - Format: `docs(sprout): document folder1, folder2, folder3`

5. **Complete** - Output promise when done
   ```
   <promise>DOCUMENTATION COMPLETE</promise>
   ```

## State File Format (v3)

`sprout-docs.json` (gitignored):
```json
{
  "version": 3,
  "lastRun": "2026-01-07T00:00:00Z",
  "baseBranch": "main",
  "output": "inline",
  "theme": {
    "primary": "#2563EB",
    "accent": "#10B981",
    "colorScheme": "dark",
    "source": "tailwind.config.ts"
  },
  "folders": {
    "src": {
      "contentHash": "a1b2c3d4e5f6789...",
      "documented": true,
      "docsPath": "src/README.md"
    }
  },
  "stats": {
    "totalFolders": 23,
    "documented": 23,
    "lastFullRun": "2026-01-07T00:00:00Z"
  }
}
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `version` | integer | Schema version (current: 3) |
| `lastRun` | ISO timestamp | Last iteration completion |
| `baseBranch` | string | Target branch for commits |
| `output` | `"inline"` \| `"jekyll"` | Output mode |
| `theme` | object | Only for jekyll mode - just-the-docs colors |
| `folders[].contentHash` | string | Full 40-char git SHA |
| `folders[].documented` | boolean | Has docs been generated? |
| `folders[].docsPath` | string | Path to generated docs file |
| `stats.totalFolders` | integer | Total folders to document |
| `stats.documented` | integer | Completed count |
| `stats.lastFullRun` | timestamp | When all folders last processed |

## Inline README Template

```markdown
[← parent](../README.md) · **folder-name**

# Folder Name

> One-line purpose: why this folder exists.

## Contents

| Item | Purpose |
|------|---------|
| [`file.ts`](./file.ts) | Brief description |
| [`subfolder/`](./subfolder/) | Brief description |

## Relationships

- **Consumed by**: who uses this
- **Depends on**: what this needs

---
*Updated: YYYY-MM-DD*
```

## Jekyll Page Template

```markdown
---
title: folder-name
layout: default
parent: parent-folder
nav_order: 1
---

[← parent](./parent.md) | **folder-name**

# folder-name

> One-line purpose: why this folder exists.

## Contents

| Item | Purpose |
|------|---------|
| [`file.ts`](../src/folder/file.ts) | Brief description |
| [`subfolder/`](./folder/subfolder.md) | Brief description |

## Relationships

- **Consumed by**: who uses this
- **Depends on**: what this needs

---
*Updated: YYYY-MM-DD*
```

## Iteration Principle

**Always finish what you start:**
- Never leave documentation half-written
- Complete each batch before committing
- State file reflects completed work only

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

## Skip Patterns (Always Applied)

- `node_modules/`, `.git/`, `dist/`, `build/`, `out/`
- `coverage/`, `.claude/`, `__pycache__/`
- `docs/` (jekyll output folder)
- Empty directories
- Anything in `.gitignore`

## Gitignore Entry

Add to `.gitignore` on first run:
```gitignore
# Sprout docs state (local only)
sprout-docs.json

# Jekyll (if using jekyll mode)
docs/_site
docs/.sass-cache
docs/.jekyll-cache
docs/.jekyll-metadata
docs/Gemfile.lock
docs/vendor
```
