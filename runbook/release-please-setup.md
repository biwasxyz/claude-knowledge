# Release Please Setup

Automate semver and changelog generation for production repositories.

## When to Use

- Production repos with protected main branch
- Projects requiring PR-only workflow
- Any repo that needs automated releases and changelogs

## Prerequisites

- Repository uses conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- GitHub Actions enabled
- Main branch exists

## Setup

### 1. Create Workflow File

Create `.github/workflows/release-please.yml`:

```yaml
name: Release Please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
```

For non-Node projects, change `release-type`:
- `node` - package.json
- `python` - setup.py, pyproject.toml
- `rust` - Cargo.toml
- `go` - version.go
- `simple` - just changelog + tags

### 2. Enable GitHub Permissions

**Settings → Actions → General → Workflow permissions**

Check: "Allow GitHub Actions to create and approve pull requests"

### 3. Commit and Push

```bash
git add .github/workflows/release-please.yml
git commit -m "ci: add release-please for automated releases"
git push
```

## How It Works

### Commit Types → Version Bumps

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `fix:` | Patch (0.1.0 → 0.1.1) | Bug fixes |
| `feat:` | Minor (0.1.0 → 0.2.0) | New features |
| `feat!:` or `BREAKING CHANGE:` | Major (0.1.0 → 1.0.0) | Breaking changes |
| `docs:`, `chore:`, `ci:` | No bump | Non-code changes |

### Workflow

1. Merge PRs to main with conventional commits
2. Release Please creates/updates a "Release PR" automatically
3. Release PR shows pending changelog + proposed version
4. Merge Release PR when ready to ship
5. Action bumps version, generates CHANGELOG.md, creates GitHub Release

### Release PR Branch

Release Please uses a long-lived branch: `release-please--branches--main--components--{name}`

**Leave this branch alone** - it's reused for future release PRs.

## Files Created/Modified

| File | Purpose |
|------|---------|
| `CHANGELOG.md` | Generated changelog |
| `package.json` | Version bumped (Node) |
| `.release-please-manifest.json` | Version tracking (optional) |

## Advanced Configuration

For monorepos or custom config, create `release-please-config.json`:

```json
{
  "packages": {
    ".": {
      "release-type": "node",
      "changelog-path": "CHANGELOG.md"
    }
  }
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not permitted to create pull requests" | Enable workflow permissions in repo settings |
| Wrong version detected | Check for existing tags with `git tag -l` |
| No release PR created | Ensure commits use conventional format |
| PR not updating | Check workflow runs in Actions tab |

## References

- [Release Please Action](https://github.com/googleapis/release-please-action)
- [Release Please](https://github.com/googleapis/release-please)
- [Conventional Commits](https://www.conventionalcommits.org/)
