# Setup Skill

Set up and maintain your personal Claude Code configuration from the team knowledge base.

## Usage

```bash
/setup             # First-time setup or status check
/setup update      # Update CLAUDE.md and sync new skills from reference
```

## Workflow

### First-Time Setup (`/setup`)

1. **Detect knowledge base location**
   - Search `~/dev/` for `*/claude-knowledge` repos
   - If not found, show clone instructions and exit

2. **Set up shared config**

   **Symlink** agents and commands (shared, rarely need personal customization):
   ```bash
   ln -sf $KNOWLEDGE_BASE/claude-config/agents ~/.claude/agents
   ln -sf $KNOWLEDGE_BASE/claude-config/commands ~/.claude/commands
   ```

   **Copy** skills (allows personal skills without affecting team repo):
   ```bash
   # Only if ~/.claude/skills doesn't exist
   cp -r $KNOWLEDGE_BASE/claude-config/skills ~/.claude/skills
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
   ├── Agents: symlinked ✓
   ├── Commands: symlinked ✓
   ├── Skills: copied ✓ (add personal skills here)
   ├── CLAUDE.md: generated ✓
   └── Next: restart Claude Code to load config
   ```

### Status Check (existing setup)

If already configured, show current status:
- Knowledge base location
- Symlink status (agents, commands)
- Skills directory (copied vs symlinked)
- CLAUDE.md last modified
- New skills available in knowledge base (if any)

### Update (`/setup update`)

1. **Update CLAUDE.md**
   - Read shared CLAUDE.md from knowledge base
   - Read current personal CLAUDE.md
   - **Preserve personal sections:**
     - Knowledge Base Location (path)
     - Local Resources (repo paths)
     - Any custom sections
   - **Update shared sections:**
     - Quick Facts (all subsections)
     - Adding Knowledge
     - External APIs
   - Show diff and confirm before applying

2. **Sync new skills** (optional)
   - Compare `$KNOWLEDGE_BASE/claude-config/skills/` with `~/.claude/skills/`
   - List new skills available in knowledge base
   - Offer to copy new skills (won't overwrite existing)
   - User can decline to keep their setup as-is

## Personal vs Shared

| Item | Method | Why |
|------|--------|-----|
| Agents | Symlink | Rarely need personal agents |
| Commands | Symlink | Shared team commands |
| Skills | Copy | Allows adding personal skills |
| CLAUDE.md | Generate | Paths differ per user |

## Adding Personal Skills

After setup, create personal skills directly in `~/.claude/skills/`:

```bash
mkdir ~/.claude/skills/my-skill
# Add SKILL.md with your skill definition
```

Personal skills won't affect the team repo. To share a skill with the team, copy it to the knowledge base and commit.

## Files

| File | Location | Purpose |
|------|----------|---------|
| `SKILL.md` | This file | Skill documentation |
| `CLAUDE.md` | Knowledge base root | Shared reference (source of truth) |
| `CLAUDE.md` | `~/.claude/` | Personal config (generated) |
| `skills/` | `~/.claude/` | Personal copy (can add custom skills) |
