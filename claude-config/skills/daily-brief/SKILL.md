---
name: daily-brief
description: Review logs from ~/logs to provide orientation and context for the day. Use when starting a work session, checking what happened recently, or needing context on recent activity. Reads daily summaries, meeting notes, test runs, and other logged data.
allowed-tools: Bash, Read, Glob, Grep, Task
---

# Daily Brief Skill

Reads and synthesizes logs from `~/logs` to orient you for work.

## Usage

```bash
/daily-brief                  # Yesterday + today (default)
/daily-brief today            # Just today
/daily-brief week             # Last 7 days
/daily-brief 2026-01-15       # Specific date
/daily-brief 2026-01-10 2026-01-15  # Date range
/daily-brief --deep           # More informed analysis
/daily-brief week --deep      # Weekly retrospective
```

## Modes

### Quick Mode (default)
Fast direct reads for daily orientation.

### Deep Mode (`--deep`)
Same compact output, but more informed:
- Verify PR/issue status with `gh` before reporting
- Cross-reference test failures against recent commits
- Richer context from meeting notes and patterns

Deep mode means **better accuracy**, not more verbosity.

## Logs Directory Structure

```
~/logs/
├── daily/                    # Daily summaries (YYYY-MM-DD-daily-summary.md)
│   └── raw/                  # Raw git data from daily skill
├── meetings/                 # Meeting notes and agendas
├── archive/                  # Archived logs
├── aibtc-x402-test-runs/     # Symlinked test logs
└── stx402-test-runs/         # Symlinked test logs
```

## Workflow

1. **Parse arguments** - Date range and `--deep` flag
2. **Read daily summaries** - Primary source (already synthesized)
3. **Check open threads** - From logs, then verify with `gh` if `--deep`
4. **Scan test logs** - Only flag failures not fixed by subsequent commits
5. **Present brief** - Compact output focused on action

### Deep Mode Additions

When `--deep` is specified:
- Run `gh pr list` and `gh issue list` to verify actual status
- Cross-reference test failures against commits after the test date
- Include meeting context if relevant to current work

## Output Format

Keep it compact. One format for both modes (deep just means more accurate).

```markdown
# Daily Brief - [date range]

## What Got Done
**[Date]** - [commit count] commits
- [Accomplishment 1]
- [Accomplishment 2]

**[Date]** - [commit count] commits
- [Accomplishment 1]

## Open Threads
| Item | Status | Context |
|------|--------|---------|
| [org/repo#N](url) | Awaiting review | Brief description |

## Focus Areas
- [Priority 1 based on momentum and open work]
- [Priority 2]

## Notes
[Only if relevant meeting context or important observations]
```

## Verifying Open Threads (Deep Mode)

Use `gh` to check actual PR/issue status:

```bash
# Check PR status
gh pr view org/repo#N --json state,mergedAt

# List open PRs for user
gh pr list --author @me --state open

# Check issue status
gh issue view org/repo#N --json state
```

Only report items that are actually still open. PRs listed in logs may have been merged since.

## Test Log Handling

Parse test logs for pass/fail, but before flagging failures:
1. Note the test date
2. Check if commits after that date mention fixing the issue
3. Only flag if failure appears unresolved

Example: A test failure from Jan 14 shouldn't be flagged as a blocker if Jan 15+ commits show "fix: registry delete endpoint".

## Date Matching

Match files with dates in their names:
- `2026-01-19-daily-summary.md` - Daily summary
- `2026-01-19T*.md` - Timestamped raw logs
- `2026-01-19-*.md` - Any dated file

Use glob patterns like `*2026-01-19*` to find all files for a given date.

## Deep Mode Agent Prompt

When using Task tool for deep analysis:

```
Analyze logs from ~/logs for [DATE RANGE]. The user makes consistent daily progress.

Provide a COMPACT brief with:
1. **What Got Done** - Key accomplishments by date
2. **Open Threads** - Only items still actually open (verify with gh if uncertain)
3. **Focus Areas** - 2-3 suggested priorities based on momentum

Do NOT:
- Flag old test failures without checking for fixes in later commits
- Report PRs/issues as open without verification
- Duplicate information across sections
- Be verbose - keep it scannable

Logs:
[CONTENT]
```

## Tips

- Daily summaries are pre-synthesized - use them as primary source
- Assume progress is being made - frame positively
- Old test failures may already be fixed - check before flagging
- Keep output scannable - busy people need quick orientation
- `--deep` = more accurate, not more words
