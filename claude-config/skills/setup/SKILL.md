# Setup Skill

Set up and maintain your personal Claude Code configuration from the team knowledge base.

## Usage

```bash
/setup             # First-time setup or status check
/setup update      # Update personal CLAUDE.md from shared reference
```

## Workflow

### First-Time Setup (`/setup`)

1. **Detect knowledge base location**
   - Search `~/dev/` for `*/claude-knowledge` repos
   - If not found, show clone instructions

2. **Check/create symlinks** for shared config:
   ```bash
   ln -sf $KNOWLEDGE_BASE/claude-config/agents ~/.claude/agents
   ln -sf $KNOWLEDGE_BASE/claude-config/commands ~/.claude/commands
   ln -sf $KNOWLEDGE_BASE/claude-config/skills ~/.claude/skills
   ```

3. **Generate personal CLAUDE.md**
   - Read shared CLAUDE.md from knowledge base
   - Prompt for personal customizations:
     - Knowledge base path (detected or manual)
     - GitHub username/org (for path substitution)
     - Local repo paths (optional)
   - Write personalized `~/.claude/CLAUDE.md`

4. **Report status**
   ```
   SETUP COMPLETE
   ├── Knowledge base: ~/dev/<org>/claude-knowledge
   ├── Symlinks: agents ✓ commands ✓ skills ✓
   ├── CLAUDE.md: generated
   └── Next: restart Claude Code to load config
   ```

### Status Check (existing setup)

If symlinks already exist, show current status:
- Symlink targets and validity
- CLAUDE.md last modified
- Differences from shared reference (if any)

### Update (`/setup update`)

1. Read shared CLAUDE.md from knowledge base
2. Read current personal CLAUDE.md
3. **Preserve personal sections:**
   - Knowledge Base Location (path)
   - Local Resources (repo paths)
   - Any `## Personal` sections
4. **Update shared sections:**
   - Quick Facts (all subsections)
   - Adding Knowledge
   - External APIs
5. Show diff and confirm before applying

## Personal vs Shared Sections

| Section | Type | Behavior |
|---------|------|----------|
| Knowledge Base Location | Personal | Preserved, path customized |
| Quick Facts | Shared | Updated from reference |
| Adding Knowledge | Shared | Updated from reference |
| External APIs | Shared | Updated from reference |
| Local Resources | Personal | Preserved |
| Custom sections | Personal | Preserved |

## Files

| File | Location | Purpose |
|------|----------|---------|
| `SKILL.md` | This file | Skill documentation |
| `CLAUDE.md` | Knowledge base root | Shared reference (source of truth) |
| `CLAUDE.md` | `~/.claude/` | Personal config (generated) |
