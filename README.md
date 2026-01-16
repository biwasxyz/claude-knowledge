# Claude Knowledge Base

A shared knowledge repository for AI-assisted development workflows.

## Quick Start

Fork and clone this repo, then symlink to your `~/.claude/` directory:

```bash
# Fork and clone (sets up upstream remote automatically)
gh repo fork whoabuddy/claude-knowledge --clone=true
mv claude-knowledge ~/dev/$USER/claude-knowledge
cd ~/dev/$USER/claude-knowledge

# Symlink agents and skills
ln -sf $(pwd)/claude-config/agents ~/.claude/agents
ln -sf $(pwd)/claude-config/skills ~/.claude/skills

# Copy and customize CLAUDE.md
cp CLAUDE.md ~/.claude/CLAUDE.md
# Edit paths in ~/.claude/CLAUDE.md to match your setup
```

Restart Claude Code to load the new configuration.

## Structure

```
claude-knowledge/
├── CLAUDE.md           # Shared config reference
├── claude-config/      # Shared Claude Code configuration
│   ├── agents/         # Custom agent definitions
│   └── skills/         # Skills (symlinked to ~/.claude/skills)
├── context/            # Reference docs (APIs, specs, standards)
├── decisions/          # Architecture Decision Records
├── nuggets/            # Quick facts by topic
├── patterns/           # Code patterns and gotchas
└── runbook/            # Operational procedures
```

## Skills

| Skill | Purpose |
|-------|---------|
| `/check-code-complete` | Verify no TODOs, stubs, or dead code |
| `/check-docs` | Verify README.md, CLAUDE.md, and docs |
| `/check-production-ready` | Full production readiness check |
| `/daily` | Generate daily work summary across repos |
| `/setup` | Check status, update CLAUDE.md |
| `/sprout-docs` | Generate folder-scoped documentation |
| `/update-after-merge` | Clean up after PR merge |

## Keeping in Sync

Pull updates from upstream without losing your personal additions:

```bash
cd ~/dev/$USER/claude-knowledge
git fetch upstream
git merge upstream/main
git push origin main
```

Your personal skills (committed to your fork) are preserved.

## Adding Personal Skills

Add skills directly to your fork:

```bash
mkdir claude-config/skills/my-skill
# Add SKILL.md with your skill definition
git add -A && git commit -m "feat: add my-skill"
git push origin main
```

To share with everyone, open a PR to `whoabuddy/claude-knowledge`.

## Contributing Knowledge

When you learn something useful:
1. Add to the appropriate `nuggets/<topic>.md` file
2. If it's important, add to shared `CLAUDE.md`
3. Commit and push (or PR if sharing upstream)

## What's Shared vs Personal

| Item | Method | Notes |
|------|--------|-------|
| Agents | Symlink | Auto-updates on git pull |
| Skills | Symlink | Auto-updates on git pull |
| CLAUDE.md | Copy | Personal paths, shared standards |
| Knowledge | Git | Fork workflow for personal + upstream |
