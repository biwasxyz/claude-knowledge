# Updating Claude Knowledge Repository

Checklist for maintaining clean, shareable configuration.

## Before Committing

### 1. Check for Hardcoded Paths

```bash
# Search for personal paths in claude-config
grep -r "whoabuddy" claude-config/
grep -r "/home/whoabuddy" claude-config/

# Should use these instead:
# - $CLAUDE_KNOWLEDGE_PATH for knowledge base references
# - $USER or $USERNAME for username placeholders
# - ~/dev/$USER/ for generic dev paths
```

### 2. Check for Project-Specific Code

Review these files for project-specific references that should be generalized:
- `claude-config/skills/daily/daily-git-summary.sh` - No hardcoded repo names
- `claude-config/commands/*.md` - No specific project references
- `claude-config/agents/*.md` - Local resources should be generic or have GitHub links

### 3. Verify CLAUDE.md.example is Updated

If you added new sections to `~/.claude/CLAUDE.md`:
1. Check if it should be shared
2. If yes, add sanitized version to `claude-config/CLAUDE.md.example`
3. Use placeholders: `$USERNAME`, `$CLAUDE_KNOWLEDGE_PATH`

### 4. Check Sensitive Data

Never commit:
- API keys or tokens
- Personal email addresses
- Private repository URLs
- Credentials of any kind

```bash
# Quick check for common patterns
grep -rE "(api[_-]?key|token|secret|password|credential)" claude-config/
```

## Update Workflow

```bash
cd ~/dev/$USER/claude-knowledge  # or your knowledge base path

# 1. Check what changed
git status
git diff claude-config/

# 2. Run validation
grep -r "whoabuddy" claude-config/ && echo "⚠️  Found hardcoded username"
grep -r "/home/" claude-config/ && echo "⚠️  Found hardcoded home path"

# 3. Stage and commit
git add -A
git commit -m "type(scope): description"

# 4. Push
git push
```

## Directory Responsibilities

| Directory | Content | Sharing |
|-----------|---------|---------|
| `claude-config/` | Commands, skills, agents | Public - sanitize paths |
| `context/` | API docs, references | Public - no secrets |
| `patterns/` | Code patterns | Public |
| `runbook/` | Procedures | Public |
| `decisions/` | ADRs | Public |
| `nuggets/` | Quick facts | Public - review for personal info |
| `downloads/` | API specs, downloaded refs | Public - no secrets |

## Common Placeholders

| Placeholder | Use For |
|-------------|---------|
| `$CLAUDE_KNOWLEDGE_PATH` | Knowledge base root path |
| `$USER` or `$USERNAME` | GitHub/system username |
| `~/dev/$USER/` | Generic dev directory |
| `example.com` | Example URLs |
| `your-org` | Organization placeholders |
