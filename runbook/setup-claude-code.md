# Setup Claude Code from Knowledge Base

Configure Claude Code to use a shared knowledge base with team standards, agents, and skills.

## Overview

This procedure sets up your `~/.claude/` directory to use shared configuration from a cloned knowledge base repo. Both agents and skills are symlinked (auto-update on git pull).

## Prerequisites

- Claude Code CLI installed
- GitHub CLI (`gh`) installed and authenticated

## Procedure

### 1. Fork and Clone Knowledge Base

Check if knowledge base exists:

```bash
find ~/dev -maxdepth 3 -name "claude-knowledge" -type d 2>/dev/null
```

If not found, fork and clone:

```bash
cd ~/dev/$USER
gh repo fork whoabuddy/claude-knowledge --clone=true
# Sets up origin (your fork) and upstream (whoabuddy/claude-knowledge)
```

Or manually:
```bash
# Fork on GitHub first, then:
git clone https://github.com/$USER/claude-knowledge.git ~/dev/$USER/claude-knowledge
cd ~/dev/$USER/claude-knowledge
git remote add upstream https://github.com/whoabuddy/claude-knowledge.git
```

Store the path as `$KNOWLEDGE_BASE` for remaining steps.

### 2. Set Up Shared Config

**Symlink agents and skills** (auto-update on pull):

```bash
ln -sf $KNOWLEDGE_BASE/claude-config/agents ~/.claude/agents
ln -sf $KNOWLEDGE_BASE/claude-config/skills ~/.claude/skills
```

### 3. Generate Personal CLAUDE.md

Read the shared `CLAUDE.md` from the knowledge base and generate a personalized version at `~/.claude/CLAUDE.md`.

**Prompt for customizations:**
- Knowledge base path (detected or manual)
- GitHub username/org (for path substitution)
- Local repo paths (optional)

**Replace placeholders:**
- `$CLAUDE_KNOWLEDGE_PATH` → actual knowledge base path
- `$USER` or `$USERNAME` → GitHub username
- Update "Local Resources" section with user's cloned repos

### 4. Report Status

```
SETUP COMPLETE
├── Knowledge base: ~/dev/<org>/claude-knowledge
├── Agents: symlinked ✓
├── Skills: symlinked ✓
├── CLAUDE.md: generated ✓
└── Next: restart Claude Code to load config
```

## Status Check

If already configured, verify current status:

```bash
# Check symlinks
ls -la ~/.claude/agents

# Check skills directory
ls ~/.claude/skills/

# Check CLAUDE.md exists
ls -la ~/.claude/CLAUDE.md
```

Report:
- Knowledge base location
- Symlink status (agents)
- Skills directory (copied vs symlinked)
- CLAUDE.md last modified
- New skills available in knowledge base (if any)

## Update Procedure

To sync changes from the upstream knowledge base:

### Pull Upstream Updates

```bash
cd $KNOWLEDGE_BASE
git fetch upstream
git merge upstream/main
# Resolve conflicts if your changes overlap with upstream
git push origin main
```

Your personal skills (committed to your fork) are preserved. New upstream skills merge in cleanly since they're in different files.

### Update CLAUDE.md

1. Read shared `CLAUDE.md` from knowledge base
2. Read current personal `~/.claude/CLAUDE.md`
3. **Preserve personal sections:**
   - Knowledge Base Location (path)
   - Local Resources (repo paths)
   - Any custom sections
4. **Update shared sections:**
   - Quick Facts (all subsections)
   - Adding Knowledge
   - External APIs
5. Show diff and confirm before applying

## Personal vs Shared

| Item | Method | Why |
|------|--------|-----|
| Agents | Symlink | Auto-updates on git pull |
| Skills | Symlink | Auto-updates on git pull |
| CLAUDE.md | Generate | Paths differ per user |

## Adding Personal Skills

Add skills directly to your fork:

```bash
mkdir $KNOWLEDGE_BASE/claude-config/skills/my-skill
# Add SKILL.md with your skill definition
git add -A && git commit -m "feat: add my-skill"
git push origin main
```

Skills are available immediately since the directory is symlinked.

To share with everyone, open a PR from your fork to `whoabuddy/claude-knowledge`.

## Troubleshooting

**Symlinks not working**: Verify the knowledge base path exists and contains `claude-config/`.

**Skills not loading**: Restart Claude Code after setup to reload configuration.

**CLAUDE.md not loading**: Ensure it's at `~/.claude/CLAUDE.md` (not in a subdirectory).
