# Claude Knowledge Base

A shared knowledge repository for AI-assisted development workflows. Clone this repo and run `/setup` to configure your personal Claude Code environment.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/whoabuddy/claude-knowledge ~/dev/<your-org>/claude-knowledge

# Symlink shared config
ln -sf ~/dev/<your-org>/claude-knowledge/claude-config/agents ~/.claude/agents
ln -sf ~/dev/<your-org>/claude-knowledge/claude-config/commands ~/.claude/commands
ln -sf ~/dev/<your-org>/claude-knowledge/claude-config/skills ~/.claude/skills

# Restart Claude Code, then run setup
/setup
```

## Structure

```
claude-knowledge/
├── CLAUDE.md           # Shared config reference (use /sync to personalize)
├── claude-config/      # Shared Claude Code configuration
│   ├── agents/         # Custom agent definitions
│   ├── commands/       # Slash commands
│   └── skills/         # Skills (daily, sprout-docs, sync)
├── context/            # Reference docs (APIs, specs, standards)
├── decisions/          # Architecture Decision Records
├── nuggets/            # Quick facts by topic
├── patterns/           # Code patterns and gotchas
└── runbook/            # Operational procedures
```

## How It Works

1. **Shared config** lives in `claude-config/` - symlinked to `~/.claude/`
2. **Personal CLAUDE.md** is generated from the shared reference
3. **Knowledge** is organized by type and referenced from CLAUDE.md

## Key Skills

| Skill | Purpose |
|-------|---------|
| `/setup` | Set up and update personal config from shared reference |
| `/daily` | Generate daily work summary across all repos |
| `/sprout-docs` | Generate folder-scoped documentation |
| `/learn` | Capture knowledge nuggets during sessions |
| `/sync` | Sync dev environment (git pull, check status, dependencies) |

## Contributing

When you learn something useful:
1. Use `/learn topic: what you learned` to capture it
2. The nugget goes to `nuggets/<topic>.md`
3. If it's important enough, add to shared `CLAUDE.md`
4. Commit and push so the team benefits

## Team Members

Each team member has their own:
- `~/.claude/CLAUDE.md` (personal paths, preferences)
- Local repo clones in `~/dev/`

But shares:
- Agents, commands, skills (via symlinks)
- Quick facts and standards (via /sync)
- Knowledge base content (via git)
