# Setup Claude Code from Knowledge Base

Configure Claude Code to use a shared knowledge base with team standards, agents, and skills.

## Overview

This procedure sets up your `~/.claude/` directory to use shared configuration from a cloned knowledge base repo. Both agents and skills are symlinked (auto-update on git pull).

## Prerequisites

- Claude Code CLI installed
- Knowledge base repo cloned (e.g., `~/dev/yourorg/claude-knowledge`)

## Procedure

### 1. Detect Knowledge Base Location

Search for the knowledge base repo:

```bash
find ~/dev -maxdepth 3 -name "claude-knowledge" -type d 2>/dev/null
```

If not found, clone it:
```bash
git clone https://github.com/yourorg/claude-knowledge.git ~/dev/yourorg/claude-knowledge
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

To sync changes from the knowledge base:

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

### Sync New Skills

1. Compare `$KNOWLEDGE_BASE/claude-config/skills/` with `~/.claude/skills/`
2. List new skills available in knowledge base
3. Offer to copy new skills (won't overwrite existing)
4. User can decline to keep their setup as-is

## Personal vs Shared

| Item | Method | Why |
|------|--------|-----|
| Agents | Symlink | Auto-updates on git pull |
| Skills | Symlink | Auto-updates on git pull |
| CLAUDE.md | Generate | Paths differ per user |

## Adding Personal Skills

Add skills directly to the knowledge base repo:

```bash
mkdir $KNOWLEDGE_BASE/claude-config/skills/my-skill
# Add SKILL.md with your skill definition
git add -A && git commit -m "feat: add my-skill"
```

Skills are available immediately since the directory is symlinked.

## Troubleshooting

**Symlinks not working**: Verify the knowledge base path exists and contains `claude-config/`.

**Skills not loading**: Restart Claude Code after setup to reload configuration.

**CLAUDE.md not loading**: Ensure it's at `~/.claude/CLAUDE.md` (not in a subdirectory).
