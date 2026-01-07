# Claude Code Configuration

Shareable Claude Code configuration files. Symlink these to your `~/.claude/` directory.

## Setup

```bash
# Clone the repo
git clone https://github.com/whoabuddy/claude-knowledge.git ~/dev/whoabuddy/claude-knowledge

# Create symlinks (backup existing first if needed)
ln -s ~/dev/whoabuddy/claude-knowledge/claude-config/commands ~/.claude/commands
ln -s ~/dev/whoabuddy/claude-knowledge/claude-config/skills ~/.claude/skills
ln -s ~/dev/whoabuddy/claude-knowledge/claude-config/agents ~/.claude/agents

# Copy and customize CLAUDE.md
cp ~/dev/whoabuddy/claude-knowledge/claude-config/CLAUDE.md.example ~/.claude/CLAUDE.md
# Edit ~/.claude/CLAUDE.md with your paths
```

## Contents

- `commands/` - Slash commands (`/daily`, `/learn`, `/plan`, etc.)
- `skills/` - Supporting scripts and skill definitions
- `agents/` - Agent configurations
- `CLAUDE.md.example` - Template for global instructions

## Key Commands

| Command | Description |
|---------|-------------|
| `/daily` | Generate daily work summary from all git repos |
| `/learn` | Capture knowledge nuggets during sessions |
| `/plan` | Create implementation plans |
| `/build` | Run build pipeline |
| `/pr` | Create pull requests |

## Keeping in Sync

With symlinks, any edits to commands/skills/agents are automatically tracked in this repo. Just commit and push when you make changes.
