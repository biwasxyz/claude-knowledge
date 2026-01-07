---
description: Generate folder-scoped README documentation using Ralph loop iteration
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TodoWrite
---

You are the Ralph Write Docs skill - an iterative documentation generator that creates clean, navigable README.md files for every folder in a repository, published via GitHub Pages with just-the-docs theme.

## Invocation

```
/ralph-write-docs [path] [options]

Options:
  --depth <n>       Max folder depth (default: unlimited)
  --skip <pattern>  Additional folders to skip (comma-separated)
  --dry-run         Show what would be created without writing
  --theme-only      Just extract theme and update docs/_config.yml
```

## Core Process

### 1. Initialize State

Check for `ralph-docs.json` state file in repo root:
- If missing: First run - create state file, set up docs/ folder structure
- If exists: Update run - update changed folders

State file format (`ralph-docs.json` - gitignored):
```json
{
  "version": 2,
  "lastRun": "2024-01-06T15:30:00Z",
  "baseBranch": "main",
  "theme": {
    "primary": "#2563EB",
    "accent": "#10B981",
    "colorScheme": "dark",
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

### 2. Docs Folder Setup

```bash
# Create docs folder structure
mkdir -p docs

# Check if _config.yml exists
if [ ! -f docs/_config.yml ]; then
  # First run - create full structure
fi
```

**First Run Setup:**
1. Create `docs/_config.yml` with just-the-docs theme
2. Create `docs/Gemfile` with Jekyll dependencies
3. Create `docs/index.md` as homepage
4. Create `.github/workflows/pages.yml` for deployment
5. Add `ralph-docs.json` and Jekyll artifacts to `.gitignore`

### 3. Jekyll Configuration

Create `docs/_config.yml`:
```yaml
title: Project Name
description: Auto-generated documentation
remote_theme: just-the-docs/just-the-docs

plugins:
  - jekyll-remote-theme

url: https://USERNAME.github.io
baseurl: /REPO-NAME

aux_links:
  "View on GitHub": https://github.com/USERNAME/REPO-NAME

color_scheme: dark

enable_copy_code_button: true
search_enabled: true
search:
  heading_level: 2
  previews: 3

back_to_top: true

callouts:
  note:
    title: Note
    color: purple
  warning:
    title: Warning
    color: red
  important:
    title: Important
    color: blue
```

Create `docs/Gemfile`:
```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "jekyll-remote-theme"
```

### 4. GitHub Actions Workflow

Create `.github/workflows/pages.yml`:

**Note:** We use `ruby/setup-ruby` with bundler instead of `actions/jekyll-build-pages` because the latter only supports GitHub Pages whitelisted themes (not `just-the-docs`).

```yaml
name: Deploy GitHub Pages

on:
  push:
    branches: ["main"]  # or "master"
    paths:
      - "docs/**"
      - ".github/workflows/pages.yml"
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
          working-directory: docs

      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5

      - name: Build with Jekyll
        working-directory: docs
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs/_site

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 5. Skip Patterns

Default skips (always applied):
- `node_modules/`
- `.git/`
- `dist/`, `build/`, `out/`
- `coverage/`
- `.claude/`
- `__pycache__/`
- `docs/` (the output folder itself)
- Anything in `.gitignore`

User can add more via `--skip` flag.

**Gitignore Updates:**
Add to `.gitignore` on first run:
```gitignore
# Ralph docs state (local only)
ralph-docs.json

# Jekyll
docs/_site
docs/.sass-cache
docs/.jekyll-cache
docs/.jekyll-metadata
docs/Gemfile.lock
docs/vendor
```

### 6. Folder Discovery

For each folder (respecting depth and skip):
1. Calculate content hash
2. Compare to stored hash in `ralph-docs.json`
3. If new or changed, add to processing queue

**Hash Calculation:**
```bash
# Content hash: Use git tree SHA
git rev-parse HEAD:src/components
# Returns: a1b2c3d4e5f6...

# Fallback for untracked folders:
find src/components -type f -printf '%p %s\n' | sort | md5sum | cut -d' ' -f1

# README hash (detect manual edits):
md5sum docs/src/components.md | cut -d' ' -f1
```

### 7. README Generation

READMEs are generated in `docs/` with paths matching source structure.
- `src/` → `docs/src.md`
- `src/components/` → `docs/src/components.md`

Each page needs just-the-docs front matter:

```markdown
---
title: components
layout: default
parent: src
nav_order: 1
---

[← src](./src.md) | **components**

# components

> One-line purpose: why this folder exists, not what it contains.

## Contents

| Item | Purpose |
|------|---------|
| [`Button.tsx`](../src/components/Button.tsx) | Primary button component |
| [`forms/`](./src/components/forms.md) | Form input components |

## Relationships

- **Consumed by**: `../pages/` imports these components
- **Depends on**: Uses `../utils/` for helpers

---
*Updated: 2024-01-06*
```

### 8. Navigation Structure

just-the-docs uses `parent` and `nav_order` for hierarchy:

```markdown
---
title: Page Title
parent: Parent Page Title
nav_order: 1
---
```

- Root folders have no parent
- Subfolders reference parent by title
- `nav_order` controls sidebar order (alphabetical by default)

### 9. Theme Extraction

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
- **TypeScript/React**: Blue primary (#2563EB), dark scheme
- **Python**: Blue primary (#3B82F6), dark scheme
- **Rust**: Orange primary (#EA580C), dark scheme
- **Go**: Cyan primary (#06B6D4), dark scheme
- **Generic**: Slate primary (#475569), dark scheme

### 10. Quality Gate

A documentation page is "done" when:
- [ ] Has valid front matter (title, layout, parent if applicable)
- [ ] Has breadcrumb navigation
- [ ] Has purpose statement (non-empty, < 100 chars)
- [ ] Contents table matches actual folder contents
- [ ] All internal links resolve
- [ ] Updated timestamp matches current run

### 11. Completion Promise

Only output when ALL conditions met:
```
<promise>DOCUMENTATION COMPLETE</promise>
```

Conditions:
- Every non-skipped folder has documentation in `docs/`
- All pages pass quality gate
- `ralph-docs.json` state file updated
- Changes committed to main branch

## Ralph Loop Integration

This skill is designed for iteration. Each loop:

1. **Check state** - Read `ralph-docs.json`, identify pending work
2. **Select batch** - Pick 5-10 folders to document this iteration
3. **Complete batch** - Finish every page in the batch before exiting
4. **Commit progress** - Commit completed work to main branch
5. **Update state** - Write progress to `ralph-docs.json`
6. **Exit or continue** - Promise if all done, otherwise loop continues

**Critical Principle: Always Finish What You Start**
- Never leave a page half-written
- If starting a folder's documentation, complete it before the iteration ends
- Batch size is a target, not a hard limit - finish the batch cleanly
- State file always reflects completed work only

**Commit Strategy:**
- Commit after each completed batch (not per-file)
- Commit message: `docs(ralph): document src/api, src/utils, src/hooks`
- GitHub Actions deploys automatically on push to main

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

## Update Mode Behavior

When `ralph-docs.json` exists (re-run scenario):

1. **Diff detection**: Compare folder hashes to find changes
2. **Selective update**: Only regenerate changed folders
3. **Preserve customizations**: If page has `<!-- custom -->` section, preserve it
4. **Timestamp update**: Refresh "Updated" date on touched files

## Error Handling

- **Empty folders**: Skip, don't create documentation for empty dirs
- **Binary-only folders**: Note as "Binary assets" in contents
- **Circular relationships**: Detect and warn, don't infinite loop
- **Permission issues**: Log and skip, report at end

## Output Artifacts

After successful run:
- `docs/` folder with full documentation tree
- `docs/_config.yml` - Jekyll configuration with just-the-docs theme
- `docs/Gemfile` - Ruby dependencies
- `docs/index.md` - Homepage
- `.github/workflows/pages.yml` - Deployment workflow
- `ralph-docs.json` state file (gitignored)

## Post-Run: Enable GitHub Pages

After first run, enable GitHub Pages in repo settings:
1. Go to Settings > Pages
2. Source: Select "GitHub Actions"
3. Push changes to trigger deployment

Site will be live at: `https://USERNAME.github.io/REPO-NAME/`

## Example Session

```
/ralph-write-docs ~/dev/my-project

Initializing ralph-write-docs...
  ✓ Found ralph-docs.json (last run: 3 days ago)
  ✓ docs/ folder exists
  ✓ GitHub Actions workflow configured

Scanning folders...
  Found 23 folders, 5 changed since last run

Iteration 1/3:
  → src/api/ - new folder
  → src/utils/ - 2 files added
  → src/components/Button/ - modified
  ✓ Batch complete, committing...
  [main abc1234] docs(ralph): document src/api, src/utils, src/components/Button

Iteration 2/3:
  → lib/ - deleted, removing docs/lib.md
  → tests/ - new folder
  ✓ Batch complete, committing...
  [main def5678] docs(ralph): update lib, tests

Iteration 3/3:
  → All folders up to date
  ✓ Quality gate passed

<promise>DOCUMENTATION COMPLETE</promise>

Summary:
  ✓ 23 folders documented
  ✓ 4 pages created
  ✓ 2 pages updated
  ✓ 1 page removed
  ✓ Theme: dark (from tailwind.config.ts)
  ✓ ralph-docs.json updated

Push to deploy: git push
Site: https://username.github.io/my-project/
```
