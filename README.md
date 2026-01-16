# Claude Knowledge Base

A shared knowledge repository for AI-assisted development workflows.

## First-Time Setup

If you're reading this in Claude Code and the user wants to set up their environment, follow these steps:

### 1. Detect this repo's location

Find where this repo was cloned by checking the path of this README file. Store as `$KNOWLEDGE_BASE`.

### 2. Set up agents (symlink)

These are shared and auto-update when the user pulls the repo:

```bash
ln -sf $KNOWLEDGE_BASE/claude-config/agents ~/.claude/agents
```

### 3. Set up skills (copy if not exists)

Skills are copied so users can add personal skills without affecting the team repo:

```bash
# Only copy if ~/.claude/skills doesn't exist
if [ ! -d ~/.claude/skills ]; then
  cp -r $KNOWLEDGE_BASE/claude-config/skills ~/.claude/skills
fi
```

### 4. Generate personal CLAUDE.md

Read the shared `CLAUDE.md` in this repo and generate a personalized version at `~/.claude/CLAUDE.md`:

- Replace `<your-org>` with the user's org/username from the repo path
- Update paths to point to this knowledge base location
- Ask the user if they have local repos to add to "Local Resources"

### 5. Report completion

```
SETUP COMPLETE
├── Knowledge base: $KNOWLEDGE_BASE
├── Agents: symlinked
├── Skills: copied
├── CLAUDE.md: generated
└── Action: restart Claude Code to load new config
```

After restart, `/setup` and other skills will be available.

---

## Structure

```
claude-knowledge/
├── CLAUDE.md           # Shared config reference
├── claude-config/      # Shared Claude Code configuration
│   ├── agents/         # Custom agent definitions
│   └── skills/         # Skills (daily, setup, sprout-docs)
├── context/            # Reference docs (APIs, specs, standards)
├── decisions/          # Architecture Decision Records
├── nuggets/            # Quick facts by topic
├── patterns/           # Code patterns and gotchas
└── runbook/            # Operational procedures
```

## After Setup

| Skill | Purpose |
|-------|---------|
| `/setup` | Check status, update CLAUDE.md, sync new skills |
| `/daily` | Generate daily work summary across all repos |
| `/sprout-docs` | Generate folder-scoped documentation |

## Adding Personal Skills

Create skills directly in `~/.claude/skills/`:

```bash
mkdir ~/.claude/skills/my-skill
# Add SKILL.md with your skill definition
```

To share a skill with the team, copy it to `$KNOWLEDGE_BASE/claude-config/skills/` and commit.

## Contributing Knowledge

When you learn something useful:
1. Add to the appropriate `nuggets/<topic>.md` file
2. If it's important, add to shared `CLAUDE.md`
3. Commit and push so the team benefits

## What's Shared vs Personal

| Item | Location | Shared? |
|------|----------|---------|
| Agents | Symlinked | Yes (auto-updates) |
| Skills | Copied | Team skills copied, can add personal |
| CLAUDE.md | Generated | Personal paths, shared standards |
| Knowledge | This repo | Yes (via git) |
