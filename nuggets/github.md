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
- **Jekyll theme gotcha**: Use `remote_theme: just-the-docs/just-the-docs` NOT `theme: just-the-docs`
  - GitHub's built-in Jekyll builder only supports whitelisted themes via `theme:`
  - Non-whitelisted themes (like just-the-docs) require `remote_theme:` + `jekyll-remote-theme` plugin
  - In `_config.yml`: add `plugins: [jekyll-remote-theme]`
  - In `Gemfile`: add `gem "jekyll-remote-theme"` instead of `gem "just-the-docs"`

