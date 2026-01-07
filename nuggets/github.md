# GitHub Knowledge Nuggets

Quick facts and learnings about GitHub API, Actions, PRs, and workflows.

## Entries

### GitHub Pages Documentation
- Use `/ralph-write-docs` skill to generate documentation sites
- Creates `docs/` folder with just-the-docs Jekyll theme
- Deploys via GitHub Actions (not gh-pages branch)
- Enable Pages via Settings > Pages > Source: "GitHub Actions"
- Full runbook: `~/dev/whoabuddy/claude-knowledge/runbook/setup-github-pages-just-the-docs.md`

### 2026-01-07
- Docs generation requires: `.github/workflows/pages.yml`, `docs/Gemfile`, `docs/_config.yml`
- Update `.gitignore` with `ralph-docs.json` and Jekyll artifacts (`docs/_site`, `docs/.jekyll-cache`, etc.)
- CRITICAL: Verify repo owner URLs in `_config.yml` and doc links before PR (especially on forks)
- For forks: check `url`, `aux_links`, and any GitHub links in markdown files

