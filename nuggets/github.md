# GitHub Knowledge Nuggets

Quick facts and learnings about GitHub API, Actions, PRs, and workflows.

## Entries

### GitHub Pages with just-the-docs
- Use `docs/` folder approach with Jekyll and GitHub Actions (not gh-pages branch)
- Theme: `just-the-docs` supports dark mode, search, callouts, copy buttons
- Workflow: `actions/jekyll-build-pages@v1` with `source: ./docs`
- Enable Pages via Settings > Pages > Source: "GitHub Actions"
- Full runbook: `~/dev/whoabuddy/claude-knowledge/runbook/setup-github-pages-just-the-docs.md`

### GitHub Actions Pages Workflow
- Use `actions/configure-pages@v5`, `actions/jekyll-build-pages@v1`, `actions/upload-pages-artifact@v3`, `actions/deploy-pages@v4`
- Permissions needed: `contents: read`, `pages: write`, `id-token: write`
- Concurrency group prevents parallel deployments: `group: "pages"`

