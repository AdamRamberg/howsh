# cmdai

Turn English into bash commands with AI-powered suggestions.

cmdai provides **always-on suggestions** that appear as you type, similar to zsh-autosuggestions or Cursor's tab completion. Just describe what you want in plain English, and accept the suggestion with Tab.

## Installation

### Global Install (Recommended)

```bash
npm install -g cmdai
```

### One-time Use

```bash
npx cmdai "list all files larger than 100MB"
```

### Requirements

- Node.js 18+ or Bun

## Quick Start

1. Set your API key:

```bash
cmdai config set api-key YOUR_ANTHROPIC_KEY
```

2. Try it out:

```bash
cmdai "find all python files modified today"
# Output: find . -name "*.py" -mtime 0
```

3. Enable always-on suggestions:

```bash
cmdai setup   # Add to your shell
source ~/.zshrc  # Reload shell config
cmdai on      # Enable suggestions
```

Now just type in plain English and press Tab to accept suggestions!

## Usage

### Direct Translation

```bash
cmdai "find all files larger than 100MB"
# Output: find . -size +100M

cmdai "show disk usage sorted by size"
# Output: du -sh * | sort -h

cmdai "find processes using port 3000"
# Output: lsof -i :3000
```

### Always-On Suggestions

When enabled, cmdai shows grayed-out suggestions as you type:

1. Start typing an English description
2. A suggestion appears in gray after your cursor
3. Press **Tab** or **Right Arrow** to accept
4. Press any other key to continue typing

```bash
# Enable suggestions
cmdai on

# Disable suggestions
cmdai off
```

### Cheat Sheets

Browse built-in bash cheatsheets:

```bash
# List all cheatsheets
cmdai list

# View a specific cheatsheet
cmdai list tar
cmdai list git

# Search across all cheatsheets
cmdai list --search "network"
```

Available cheatsheets:
- `file-operations` - find, copy, move, compress
- `text-processing` - grep, sed, awk, sort
- `networking` - curl, ssh, ports, dns
- `git` - branches, commits, remotes
- `process-management` - ps, kill, jobs, services

### Configuration

```bash
# View current config
cmdai config

# Set provider (anthropic or openai)
cmdai config set provider anthropic

# Set API key
cmdai config set api-key sk-ant-...

# Set model (optional, uses fast default)
cmdai config set model claude-3-haiku-20240307
```

## Providers

cmdai supports multiple LLM providers:

| Provider | Default Model | Env Variable |
|----------|--------------|--------------|
| Anthropic (default) | claude-3-haiku | `ANTHROPIC_API_KEY` |
| OpenAI | gpt-4o-mini | `OPENAI_API_KEY` |

You can set the API key either through the config command or environment variable:

```bash
# Via config (stored securely)
cmdai config set api-key YOUR_KEY

# Via environment variable
export ANTHROPIC_API_KEY=your_key
```

## Shell Integration

cmdai integrates with Zsh to provide always-on suggestions:

```bash
# One-time setup (adds to ~/.zshrc)
cmdai setup

# Reload your shell
source ~/.zshrc

# Enable suggestions
cmdai on
```

The shell integration:
- Monitors your input as you type
- Detects when you're typing English (not bash commands)
- Fetches suggestions in the background
- Shows grayed-out hints that you can accept with Tab

## Examples

```bash
# File operations
cmdai "delete all node_modules folders"
# find . -name "node_modules" -type d -exec rm -rf {} +

cmdai "find duplicate files"
# find . -type f -exec md5sum {} + | sort | uniq -d -w32

# Text processing
cmdai "count lines of code in all javascript files"
# find . -name "*.js" -exec wc -l {} + | tail -1

cmdai "replace foo with bar in all python files"
# find . -name "*.py" -exec sed -i 's/foo/bar/g' {} +

# System administration
cmdai "show largest files in current directory"
# du -sh * | sort -rh | head -10

cmdai "kill all node processes"
# pkill -f node
```

## Development

```bash
# Clone the repo
git clone https://github.com/AdamRamberg/cmdai
cd cmdai

# Install dependencies
bun install

# Run in development
bun run dev "your query here"

# Build for distribution
bun run build
```

## License

MIT
