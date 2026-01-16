# Claude Code Configuration

Shareable Claude Code configuration files. These work together with the [claude-knowledge](../) repository structure.

## Overview

This folder contains:
- `agents/` - Specialized agent configurations
- `skills/` - Skills with supporting scripts
- `CLAUDE.md.example` - Template for global instructions

## Setup

### 1. Fork and Clone

Fork the repository on GitHub, then clone your fork:

```bash
gh repo fork whoabuddy/claude-knowledge --clone=true
# This clones to ./claude-knowledge and sets up upstream remote

# Move to standard location
mv claude-knowledge ~/dev/$USER/claude-knowledge
cd ~/dev/$USER/claude-knowledge

# Verify remotes
git remote -v
# origin    -> your fork
# upstream  -> whoabuddy/claude-knowledge
```

Or manually:
```bash
# Fork on GitHub first, then:
git clone https://github.com/$USER/claude-knowledge.git ~/dev/$USER/claude-knowledge
cd ~/dev/$USER/claude-knowledge
git remote add upstream https://github.com/whoabuddy/claude-knowledge.git
```

### 2. Create Symlinks

```bash
# Backup existing directories if needed
mv ~/.claude/skills ~/.claude/skills.bak
mv ~/.claude/agents ~/.claude/agents.bak

# Symlink both (auto-updates on git pull)
ln -s ~/dev/$USER/claude-knowledge/claude-config/agents ~/.claude/agents
ln -s ~/dev/$USER/claude-knowledge/claude-config/skills ~/.claude/skills
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

The agents reference `$CLAUDE_KNOWLEDGE_PATH`. Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export CLAUDE_KNOWLEDGE_PATH="$HOME/dev/$USER/claude-knowledge"
```

## Skills

| Skill | Description |
|-------|-------------|
| `/check-code-complete` | Verify no TODOs, stubs, or dead code before merge |
| `/check-docs` | Verify README.md, CLAUDE.md, and docs are complete |
| `/check-production-ready` | Full production readiness check (build, tests, security) |
| `/daily [date]` | Generate daily work summary from all git repos |
| `/setup` | Set up or update Claude Code configuration |
| `/sprout-docs` | Generate folder documentation for codebase exploration |
| `/update-after-merge` | Clean up after PR merge (switch branch, delete, pull) |

## Agents

| Agent | Use Case |
|-------|----------|
| `clarity-expert` | Clarity smart contract development |
| `stacks-expert` | Stacks blockchain and Stacks.js |
| `git-expert` | Git workflows, branching, conflicts |
| `github-expert` | GitHub CLI, issues, PRs, actions |
| `claude-code-expert` | Claude Code configuration itself |

## Customization

### Adding Your Own Skills

Create a new directory in `~/.claude/skills/`:

```bash
mkdir ~/.claude/skills/my-skill
```

Add a `SKILL.md` file:

```markdown
---
name: my-skill
description: What the skill does
allowed-tools: Bash, Read, Write
---

Skill instructions here.
```

To share with the team, copy to the knowledge base and commit.

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

### Pull Updates from Upstream

Get new skills and updates from the main repo without losing your personal additions:

```bash
cd ~/dev/$USER/claude-knowledge
git fetch upstream
git merge upstream/main
# Resolve any conflicts if your changes overlap with upstream
git push origin main
```

Your personal skills (committed to your fork) are preserved. New upstream skills merge in cleanly since they're in different files.

### Contributing Back

To share a skill with everyone:

1. Create the skill in your fork
2. Push to your fork: `git push origin main`
3. Open a PR from your fork to `whoabuddy/claude-knowledge`

## Directory Structure

```
claude-knowledge/
├── claude-config/       # This folder
│   ├── agents/          # Symlinked to ~/.claude/agents
│   ├── skills/          # Symlinked to ~/.claude/skills
│   └── CLAUDE.md.example
├── context/             # API references, specs
├── decisions/           # Architecture Decision Records
├── nuggets/             # Quick facts by category
├── patterns/            # Code patterns and solutions
└── runbook/             # Operational procedures
```

The knowledge base structure is designed to work with the agents - they reference paths like `$CLAUDE_KNOWLEDGE_PATH/patterns/` and `$CLAUDE_KNOWLEDGE_PATH/runbook/`.
