# Setup GitHub Pages with just-the-docs

A step-by-step guide for setting up GitHub Pages documentation using the just-the-docs Jekyll theme.

## When to Use

- API documentation for Cloudflare Workers or serverless functions
- Project documentation that needs search, navigation, and dark mode
- Simple sites that don't need a full static site generator build step

## Prerequisites

- GitHub repository
- Repository settings access (to enable Pages)

## Step 1: Create docs folder structure

```bash
mkdir -p docs
```

## Step 2: Create Jekyll config

Create `docs/_config.yml`:

```yaml
title: Your Project Name
description: Brief project description
theme: just-the-docs

url: https://USERNAME.github.io
baseurl: /REPO-NAME

# Repository link
aux_links:
  "View on GitHub": https://github.com/USERNAME/REPO-NAME

# Footer
footer_content: "Powered by <a href=\"https://example.com\">Your Link</a>"

# Theme
color_scheme: dark  # or light

# Features
enable_copy_code_button: true
search_enabled: true
search:
  heading_level: 2
  previews: 3
  preview_words_before: 5
  preview_words_after: 10

back_to_top: true
back_to_top_text: "Back to top"

# Callouts (for notes, warnings, etc.)
callouts:
  highlight:
    color: yellow
  important:
    title: Important
    color: blue
  note:
    title: Note
    color: purple
  warning:
    title: Warning
    color: red
```

## Step 3: Create Gemfile

Create `docs/Gemfile`:

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "just-the-docs", "~> 0.10"
```

## Step 4: Create homepage

Create `docs/index.md`:

```markdown
---
title: Home
layout: home
nav_order: 1
---

# Project Name

Your project description here.

---

## Quick Start

Basic usage examples...

---

## Features

- Feature 1
- Feature 2
```

## Step 5: Add additional pages

Each page needs front matter:

```markdown
---
title: Page Title
layout: default
nav_order: 2
---

# Page Title

Content...
```

### Callout syntax

```markdown
{: .note }
This is a note callout.

{: .warning }
This is a warning callout.

{: .important }
This is an important callout.
```

## Step 6: Create GitHub Actions workflow

Create `.github/workflows/pages.yml`:

```yaml
name: Deploy GitHub Pages

on:
  push:
    branches: ["master"]  # or "main"
    paths:
      - "docs/**"
      - ".github/workflows/pages.yml"
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Build with Jekyll
        uses: actions/jekyll-build-pages@v1
        with:
          source: ./docs
          destination: ./_site

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## Step 7: Update .gitignore

Add to `.gitignore`:

```gitignore
# Jekyll
docs/_site
docs/.sass-cache
docs/.jekyll-cache
docs/.jekyll-metadata
docs/Gemfile.lock
docs/vendor
```

## Step 8: Enable GitHub Pages

1. Go to repository Settings > Pages
2. Source: Select "GitHub Actions"
3. Push changes to trigger first deployment

## Step 9: Verify deployment

After push:
1. Check Actions tab for workflow status
2. Visit `https://USERNAME.github.io/REPO-NAME/`

## Navigation Structure

Pages are ordered by `nav_order` in front matter. Create nested navigation with `parent`:

```markdown
---
title: Sub Page
parent: Parent Page
nav_order: 1
---
```

## Common Issues

### Build fails with theme not found
- Ensure `docs/Gemfile` includes `just-the-docs` gem
- Check `_config.yml` has `theme: just-the-docs`

### Styles not loading
- Verify `baseurl` matches your repo name exactly
- Include leading slash: `/repo-name` not `repo-name`

### Search not working
- Ensure `search_enabled: true` in config
- May take a few minutes after first deploy to index

## Reference

- [just-the-docs documentation](https://just-the-docs.github.io/just-the-docs/)
- [GitHub Pages documentation](https://docs.github.com/en/pages)
