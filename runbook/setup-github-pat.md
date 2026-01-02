# Setup GitHub Personal Access Token

## Prerequisites
- GitHub account
- GitHub CLI (`gh`) installed

## Step 1: Install GitHub CLI

**Ubuntu/Debian:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

**macOS:**
```bash
brew install gh
```

## Step 2: Authenticate with GitHub

```bash
gh auth login
```

Follow prompts to authenticate via browser or token.

## Step 3: Create Personal Access Token (for MCP)

1. Go to https://github.com/settings/tokens?type=beta
2. Click "Generate new token (fine-grained)"
3. Name: `claude-code-mcp`
4. Expiration: 90 days (or custom)
5. Repository access: All repositories (or select specific)
6. Permissions needed:
   - **Repository:**
     - Contents: Read and write
     - Issues: Read and write
     - Pull requests: Read and write
     - Actions: Read and write
   - **Account:**
     - (optional) Profile: Read

7. Generate and copy token

## Step 4: Set Environment Variable

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxxxxxxxxxx"
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Step 5: Verify Setup

```bash
# Test gh CLI
gh auth status

# Test PAT
echo $GITHUB_PERSONAL_ACCESS_TOKEN | head -c 10
```

## Using with Claude Code

The GitHub Expert agent and workflow commands will use:
- `gh` CLI for most operations (uses gh auth)
- `GITHUB_PERSONAL_ACCESS_TOKEN` for MCP server (if enabled)

## Security Notes

- Never commit tokens to git
- Use fine-grained tokens with minimum permissions
- Rotate tokens every 90 days
- Consider using `gh auth token` instead of PAT where possible
