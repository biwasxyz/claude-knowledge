---
description: Capture knowledge nuggets for future sessions
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion
argument-hint: <category>: <knowledge>
---

You are capturing a knowledge nugget to persist across sessions.

## Input Parsing

Parse the input: `$ARGUMENTS`

Expected formats:
- `category: knowledge statement` - e.g., `cloudflare: use dry run before deploy`
- `knowledge statement` - will prompt for category

## Categories

| Category | Description | Storage |
|----------|-------------|---------|
| `clarity` | Clarity language, contracts, Clarinet | `nuggets/clarity.md` |
| `stacks` | Stacks.js, blockchain, deployment | `nuggets/stacks.md` |
| `cloudflare` | Workers, Pages, deployment | `nuggets/cloudflare.md` |
| `git` | Git workflows, commands, gotchas | `nuggets/git.md` |
| `github` | GitHub API, Actions, PRs | `nuggets/github.md` |
| `node` | Node.js, npm, TypeScript | `nuggets/node.md` |
| `python` | Python, pip, tooling | `nuggets/python.md` |
| `general` | Anything else | `nuggets/general.md` |

## Workflow

1. Parse the input to extract category and knowledge
2. If no category provided, use AskUserQuestion to ask which category fits
3. Read the existing nugget file (or create if doesn't exist)
4. Append the new nugget with timestamp
5. If marked as "critical" or "always", also add to CLAUDE.md Quick Facts

## Nugget File Format

```markdown
# [Category] Knowledge Nuggets

## Entries

### 2024-01-02
- Knowledge statement here
- Another learning from same day

### 2024-01-01
- Earlier knowledge
```

## Storage Location

Base path: `~/dev/whoabuddy/claude-knowledge/nuggets/`

## Response

After saving, confirm:
```
Saved to nuggets/[category].md:
"[knowledge statement]"

[If critical: Also added to CLAUDE.md Quick Facts]
```

## Critical Knowledge Detection

If the knowledge contains patterns like:
- "never", "always", "do not", "must"
- Mentions errors, failures, or gotchas
- Is about deployment or production

Ask if it should also be added to CLAUDE.md Quick Facts for automatic loading.
