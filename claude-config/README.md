# Claude Code Configuration

Shareable Claude Code configuration files. These work together with the [claude-knowledge](../) repository structure.

## Overview

This folder contains:
- `commands/` - Slash commands (`/daily`, `/learn`, `/plan`, etc.)
- `skills/` - Supporting scripts and skill definitions
- `agents/` - Specialized agent configurations
- `CLAUDE.md.example` - Template for global instructions

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/whoabuddy/claude-knowledge.git ~/dev/$USER/claude-knowledge
```

### 2. Create Symlinks

Symlink these directories to your `~/.claude/` folder:

```bash
# Backup existing directories if needed
mv ~/.claude/commands ~/.claude/commands.bak
mv ~/.claude/skills ~/.claude/skills.bak
mv ~/.claude/agents ~/.claude/agents.bak

# Create symlinks
ln -s ~/dev/$USER/claude-knowledge/claude-config/commands ~/.claude/commands
ln -s ~/dev/$USER/claude-knowledge/claude-config/skills ~/.claude/skills
ln -s ~/dev/$USER/claude-knowledge/claude-config/agents ~/.claude/agents
```

### 3. Configure CLAUDE.md

Copy and customize the example file:

```bash
cp ~/dev/$USER/claude-knowledge/claude-config/CLAUDE.md.example ~/.claude/CLAUDE.md
```

Edit `~/.claude/CLAUDE.md` to set your paths:
- Replace `$USERNAME` with your GitHub username
- Update knowledge base path to match your setup
- Customize quick facts for your workflow

### 4. Set Knowledge Base Path

The agents and commands reference `$CLAUDE_KNOWLEDGE_PATH`. You can either:

**Option A:** Add to your shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
export CLAUDE_KNOWLEDGE_PATH="$HOME/dev/$USER/claude-knowledge"
```

**Option B:** Update paths directly in the agent/command files after symlinking.

## Key Commands

| Command | Description |
|---------|-------------|
| `/daily [date]` | Generate daily work summary from all git repos |
| `/learn <category>: <fact>` | Capture knowledge nuggets during sessions |
| `/plan <task>` | Create implementation plans |
| `/gather <topic>` | Search knowledge base for context |
| `/build` | Run build pipeline for current project |
| `/pr` | Create pull requests |
| `/status` | Check git/CI status |

## Agents

| Agent | Use Case |
|-------|----------|
| `clarity-expert` | Clarity smart contract development |
| `stacks-expert` | Stacks blockchain and Stacks.js |
| `git-expert` | Git workflows, branching, conflicts |
| `github-expert` | GitHub CLI, issues, PRs, actions |
| `claude-code-expert` | Claude Code configuration itself |

## Customization

### Adding Your Own Commands

Create a new file in `commands/`:

```markdown
---
description: What the command does
allowed-tools: Bash, Read, Write
argument-hint: [optional args]
---

Command instructions here. Use $ARGUMENTS for user input.
```

### Adding Your Own Agents

Create a new file in `agents/`:

```markdown
---
name: agent-name
description: When to use this agent
model: opus | sonnet | haiku
---

System prompt for the agent.
```

## Keeping in Sync

With symlinks, any edits to commands/skills/agents are automatically tracked in this repo. Just commit and push when you make changes:

```bash
cd ~/dev/$USER/claude-knowledge
git add claude-config/
git commit -m "Update Claude Code configuration"
git push
```

## Directory Structure

```
claude-knowledge/
├── claude-config/       # This folder - symlinked to ~/.claude/
│   ├── agents/
│   ├── commands/
│   ├── skills/
│   └── CLAUDE.md.example
├── context/             # Project background, API references
├── decisions/           # Architecture Decision Records
├── nuggets/             # Quick facts by category
├── patterns/            # Code patterns and solutions
└── runbook/             # Operational procedures
```

The knowledge base structure is designed to work with the agents and commands - they reference paths like `$CLAUDE_KNOWLEDGE_PATH/patterns/` and `$CLAUDE_KNOWLEDGE_PATH/nuggets/`.
