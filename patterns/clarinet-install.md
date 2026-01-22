# Clarinet Installation & Updates

Clarinet is the development environment for Clarity smart contracts on Stacks.

## Repository

**Source:** https://github.com/stx-labs/clarinet

> Note: Clarinet moved from `hirosystems/clarinet` to `stx-labs/clarinet`. The old `get.clarinet.dev` installer may not work.

## Install from GitHub Releases

### Linux (x64)

```bash
# Get latest version
LATEST=$(curl -fsSL https://api.github.com/repos/stx-labs/clarinet/releases/latest | grep '"tag_name"' | cut -d'"' -f4)

# Download and extract
curl -fsSL "https://github.com/stx-labs/clarinet/releases/download/${LATEST}/clarinet-linux-x64-glibc.tar.gz" -o /tmp/clarinet.tar.gz
tar -xzf /tmp/clarinet.tar.gz -C ~/.local/bin
rm /tmp/clarinet.tar.gz

# Verify
clarinet --version
```

### macOS

```bash
# Apple Silicon (M1/M2/M3)
curl -fsSL "https://github.com/stx-labs/clarinet/releases/download/${LATEST}/clarinet-darwin-arm64.tar.gz" -o /tmp/clarinet.tar.gz

# Intel
curl -fsSL "https://github.com/stx-labs/clarinet/releases/download/${LATEST}/clarinet-darwin-x64.tar.gz" -o /tmp/clarinet.tar.gz

tar -xzf /tmp/clarinet.tar.gz -C ~/.local/bin
```

## Update Script

Team VMs have `~/update-clarinet.sh` which automates the update:

```bash
~/update-clarinet.sh
```

## Release Assets

Each release includes:
- `clarinet-linux-x64-glibc.tar.gz` - Linux (standard)
- `clarinet-linux-x64-musl.tar.gz` - Linux (Alpine/musl)
- `clarinet-darwin-arm64.tar.gz` - macOS Apple Silicon
- `clarinet-darwin-x64.tar.gz` - macOS Intel
- `clarinet-windows-x64.zip` - Windows

## Common Commands

```bash
# Check version
clarinet --version

# Create new project
clarinet new my-project

# Check contracts for errors
clarinet check

# Format contracts
clarinet format

# Run tests
clarinet test

# Start local devnet
clarinet devnet start
```

## PATH Setup

Ensure `~/.local/bin` is in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
