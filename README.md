# howsh

Turn English into bash commands with AI-powered suggestions.

howsh provides **always-on suggestions** that appear as you type, similar to zsh-autosuggestions or Cursor's tab completion. Just describe what you want in plain English, and accept the suggestion with Tab.

## Installation

### Global Install (Recommended)

```bash
npm install -g howsh
```

### One-time Use

```bash
npx howsh "list all files larger than 100MB"
```

### Requirements

- Node.js 18+ or Bun

## Quick Start

1. Set your API key:

```bash
howsh config set api-key YOUR_ANTHROPIC_KEY
```

2. Try it out:

```bash
howsh "find all python files modified today"
# Output: find . -name "*.py" -mtime 0
```

3. Enable always-on suggestions:

```bash
howsh setup   # Add to your shell
source ~/.zshrc  # Reload shell config
howsh on      # Enable suggestions
```

Now just type in plain English and press Tab to accept suggestions!

## Usage

### Direct Translation

```bash
howsh "find all files larger than 100MB"
# Output: find . -size +100M

howsh "show disk usage sorted by size"
# Output: du -sh * | sort -h

howsh "find processes using port 3000"
# Output: lsof -i :3000
```

### Always-On Suggestions

When enabled, howsh shows grayed-out suggestions as you type:

1. Start typing an English description
2. A suggestion appears in gray after your cursor
3. Press **Tab** or **Right Arrow** to accept
4. Press any other key to continue typing

```bash
# Enable suggestions
howsh on

# Disable suggestions
howsh off
```

### Cheat Sheets

Browse built-in bash cheatsheets:

```bash
# List all cheatsheets
howsh list

# View a specific cheatsheet
howsh list tar
howsh list git

# Search across all cheatsheets
howsh list --search "network"
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
howsh config

# Set provider (anthropic or openai)
howsh config set provider anthropic

# Set API key
howsh config set api-key sk-ant-...

# Set model (optional, uses fast default)
howsh config set model claude-3-haiku-20240307
```

## Providers

howsh supports multiple LLM providers:

| Provider | Default Model | Env Variable |
|----------|--------------|--------------|
| Anthropic (default) | claude-3-haiku | `ANTHROPIC_API_KEY` |
| OpenAI | gpt-4o-mini | `OPENAI_API_KEY` |

You can set the API key either through the config command or environment variable:

```bash
# Via config (stored securely)
howsh config set api-key YOUR_KEY

# Via environment variable
export ANTHROPIC_API_KEY=your_key
```

## Shell Integration

howsh integrates with Zsh to provide always-on suggestions:

```bash
# One-time setup (adds to ~/.zshrc)
howsh setup

# Reload your shell
source ~/.zshrc

# Enable suggestions
howsh on
```

The shell integration:
- Monitors your input as you type
- Detects when you're typing English (not bash commands)
- Fetches suggestions in the background
- Shows grayed-out hints that you can accept with Tab

## Examples

```bash
# File operations
howsh "delete all node_modules folders"
# find . -name "node_modules" -type d -exec rm -rf {} +

howsh "find duplicate files"
# find . -type f -exec md5sum {} + | sort | uniq -d -w32

# Text processing
howsh "count lines of code in all javascript files"
# find . -name "*.js" -exec wc -l {} + | tail -1

howsh "replace foo with bar in all python files"
# find . -name "*.py" -exec sed -i 's/foo/bar/g' {} +

# System administration
howsh "show largest files in current directory"
# du -sh * | sort -rh | head -10

howsh "kill all node processes"
# pkill -f node
```

## Development

```bash
# Clone the repo
git clone https://github.com/AdamRamberg/howsh
cd howsh

# Install dependencies
bun install

# Run in development
bun run dev "your query here"

# Build for distribution
bun run build
```

## License

MIT
