---
name: ralph-write-docs
description: Generate folder-scoped README documentation using Ralph loop iteration
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TodoWrite
---

You are the Ralph Write Docs skill - an iterative documentation generator that creates clean, navigable README.md files for every folder in a repository.

## Invocation

```
/ralph-write-docs [path] [options]

Options:
  --depth <n>       Max folder depth (default: unlimited)
  --skip <pattern>  Additional folders to skip (comma-separated)
  --dry-run         Show what would be created without writing
  --theme-only      Just extract theme and update gh-pages config
```

## Core Process

### 1. Initialize State

Check for `ralph-docs.json` state file in repo root:
- If missing: First run - create state file, set up gh-pages branch
- If exists: Update run - sync with main/master, update changed folders

State file format (`ralph-docs.json` - gitignored):
```json
{
  "version": 1,
  "lastRun": "2024-01-06T15:30:00Z",
  "baseBranch": "main",
  "theme": {
    "primary": "#2563EB",
    "accent": "#10B981",
    "source": "tailwind.config.ts"
  },
  "folders": {
    "src": { "contentHash": "abc123", "readmeHash": "xyz789" },
    "src/components": { "contentHash": "def456", "readmeHash": "uvw012" }
  },
  "stats": {
    "totalFolders": 23,
    "documented": 23,
    "lastFullRun": "2024-01-06T15:30:00Z"
  }
}
```

The JSON format allows adding fields as the skill evolves without breaking existing state files.

### 2. Branch Setup

```bash
# Check if gh-pages exists
git show-ref --verify --quiet refs/heads/gh-pages

# If not, create orphan branch
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "Initialize gh-pages for documentation"
git checkout main
```

Work on gh-pages branch but track against main/master content.

### 3. Skip Patterns

Default skips (always applied):
- `node_modules/`
- `.git/`
- `dist/`, `build/`, `out/`
- `coverage/`
- `.claude/`
- `__pycache__/`
- Anything in `.gitignore`

User can add more via `--skip` flag.

**First Run Setup:**
- Add `ralph-docs.json` to `.gitignore` (on main branch)
- This keeps state local - each clone starts fresh

### 4. Folder Discovery

For each folder (respecting depth and skip):
1. Calculate content hash
2. Compare to stored hash in `ralph-docs.json`
3. If new or changed, add to processing queue

**Hash Calculation (no special tools required):**

```bash
# Content hash: Use git tree SHA (changes when any file in folder changes)
git rev-parse HEAD:src/components
# Returns: a1b2c3d4e5f6...

# Fallback for untracked folders:
find src/components -type f -printf '%p %s\n' | sort | md5sum | cut -d' ' -f1

# Combined approach:
get_folder_hash() {
  local path="$1"
  git rev-parse HEAD:"$path" 2>/dev/null || \
    find "$path" -type f -printf '%p %s\n' | sort | md5sum | cut -d' ' -f1
}

# README hash (detect manual edits):
md5sum src/components/README.md | cut -d' ' -f1
```

Why git tree SHA:
- Git tracks content, not timestamps (stable across machines)
- Changes when any file in the tree changes
- Built into every repo, no external tools
- Falls back gracefully for untracked content

### 5. README Generation

For each folder needing documentation, generate README.md following this template:

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

Non-obvious connections only (imports are self-documenting):
- **Consumed by**: `../api/routes.ts` uses these utilities
- **Depends on**: Requires `../config/` to be initialized first

---
*[View on main](../../tree/main/path/to/folder) · Updated: 2024-01-06*
```

### 6. Navigation Rules

**Breadcrumb Format:**
```
[← parent](../README.md) · **current** · [root](/README.md)
```

- Always link to parent (except root)
- Bold the current folder name
- Link to root from deep folders (depth > 2)
- Use relative paths only

**Link Validation:**
- All `[text](./path)` links must resolve
- Check child folder READMEs exist before linking
- External links get `🔗` indicator

### 7. Theme Extraction (for gh-pages)

Search codebase for theme colors:
```
# Priority order:
1. tailwind.config.{js,ts} - theme.extend.colors
2. src/**/theme.{js,ts,json}
3. package.json - theme config
4. CSS variables in globals.css or :root
5. Fallback: Generate professional defaults
```

**Fallback Theme Generation:**
When no theme found, generate professional defaults based on project type:
- **TypeScript/React**: Blue primary (#2563EB), emerald accent (#10B981)
- **Python**: Blue primary (#3B82F6), amber accent (#F59E0B)
- **Rust**: Orange primary (#EA580C), slate accent (#475569)
- **Go**: Cyan primary (#06B6D4), blue accent (#3B82F6)
- **Generic**: Slate primary (#475569), blue accent (#2563EB)

Create `_config.yml` for Jekyll (gh-pages):
```yaml
theme: jekyll-theme-minimal
title: Project Name
description: Auto-generated documentation
primary_color: "#2563EB"
```

### 8. Quality Gate

A README is "done" when:
- [ ] Has breadcrumb navigation (valid links)
- [ ] Has purpose statement (non-empty, < 100 chars)
- [ ] Contents table matches actual folder contents
- [ ] Relationships section exists (can be "None" if truly standalone)
- [ ] All internal links resolve
- [ ] Updated timestamp matches current run

### 9. Completion Promise

Only output when ALL conditions met:
```
<promise>DOCUMENTATION COMPLETE</promise>
```

Conditions:
- Every non-skipped folder has README.md
- All READMEs pass quality gate
- `ralph-docs.json` state file updated
- Changes committed to gh-pages branch

## Ralph Loop Integration

This skill is designed for iteration. Each loop:

1. **Check state** - Read `ralph-docs.json`, identify pending work
2. **Select batch** - Pick 5-10 folders to document this iteration
3. **Complete batch** - Finish every README in the batch before exiting
4. **Commit progress** - Commit completed work to gh-pages
5. **Update state** - Write progress to `ralph-docs.json`
6. **Exit or continue** - Promise if all done, otherwise loop continues

**Critical Principle: Always Finish What You Start**
- Never leave a README half-written
- If starting a folder's README, complete it before the iteration ends
- Batch size is a target, not a hard limit - finish the batch cleanly
- State file always reflects completed work only

**Commit Strategy:**
- Commit after each completed batch (not per-file)
- Commit message: `docs(ralph): document src/api, src/utils, src/hooks`
- If interrupted, uncommitted work is lost but state is consistent
- Enables clean resumption: next run picks up where we left off

Progress tracking:
```
DOCS PROGRESS: 15/23 folders
━━━━━━━━━━━━━━━━━━━━━░░░░░░░░ 65%

This iteration:
  ✓ src/components/ - complete
  ✓ src/utils/ - complete
  → src/hooks/ - in progress (2/4 files documented)

Queued for next iteration:
  ○ src/api/
  ○ src/services/

Blocked (needs review):
  ⚠ src/legacy/ - unclear purpose
```

**Scaling with --max-iterations:**
- Small repo (< 20 folders): 2-3 iterations typical
- Medium repo (20-50 folders): 5-10 iterations
- Large repo (50+ folders): Use `--max-iterations 20` and expect multiple runs

## Update Mode Behavior

When `ralph-docs.json` exists (re-run scenario):

1. **Sync check**: Ensure gh-pages is rebased on main/master
2. **Diff detection**: Compare folder hashes to find changes
3. **Selective update**: Only regenerate changed folders
4. **Preserve customizations**: If README has `<!-- custom -->` section, preserve it
5. **Timestamp update**: Refresh "Updated" date on touched files

## Error Handling

- **Empty folders**: Skip, don't create README for empty dirs
- **Binary-only folders**: Note as "Binary assets" in contents
- **Circular relationships**: Detect and warn, don't infinite loop
- **Permission issues**: Log and skip, report at end

## Output Artifacts

After successful run:
- `gh-pages` branch with full README tree
- `ralph-docs.json` state file (gitignored on main)
- Optional: `_config.yml` for GitHub Pages styling
- Optional: `index.html` redirect to root README

## Example Session

```
/ralph-write-docs ~/dev/my-project

Initializing ralph-write-docs...
  ✓ Found ralph-docs.json (last run: 3 days ago)
  ✓ gh-pages branch exists
  ✓ Synced with main (2 new commits)

Scanning folders...
  Found 23 folders, 5 changed since last run

Iteration 1/3:
  → src/api/ - new folder
  → src/utils/ - 2 files added
  → src/components/Button/ - modified
  ✓ Batch complete, committing...
  [gh-pages abc1234] docs(ralph): document src/api, src/utils, src/components/Button

Iteration 2/3:
  → lib/ - deleted, removing README
  → docs/ - links updated
  → tests/ - new folder
  ✓ Batch complete, committing...
  [gh-pages def5678] docs(ralph): update lib, docs, tests

Iteration 3/3:
  → All folders up to date
  ✓ Quality gate passed

<promise>DOCUMENTATION COMPLETE</promise>

Summary:
  ✓ 23 folders documented
  ✓ 4 READMEs created
  ✓ 2 READMEs updated
  ✓ 1 README removed
  ✓ Theme: #2563EB (from tailwind.config.ts)
  ✓ ralph-docs.json updated

gh-pages branch ready - push to enable GitHub Pages
```
