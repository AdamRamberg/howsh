import chalk from 'chalk';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { homedir } from 'os';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

export async function setupCommand(): Promise<void> {
  const zshrc = join(homedir(), '.zshrc');

  if (!existsSync(zshrc)) {
    console.log(chalk.yellow('~/.zshrc not found. Creating one...'));
    writeFileSync(zshrc, '');
  }

  const content = readFileSync(zshrc, 'utf-8');

  // Check if already set up
  if (content.includes('bash-gpt.zsh')) {
    console.log(chalk.green('bash-gpt is already set up in your .zshrc'));
    console.log(chalk.dim('\nRun "bash-gpt on" to enable suggestions.'));
    return;
  }

  // Find the shell script location
  // When installed via npm, it will be in the package's src/shell directory
  // We'll use a relative path from the installed location
  const setupLines = `
# bash-gpt shell integration
# Source the zsh plugin for always-on suggestions
if command -v bash-gpt &> /dev/null; then
  BASH_GPT_BIN="$(command -v bash-gpt)"
  BASH_GPT_REAL="$(readlink -f "$BASH_GPT_BIN" 2>/dev/null || realpath "$BASH_GPT_BIN" 2>/dev/null || echo "$BASH_GPT_BIN")"
  BASH_GPT_DIR="$(dirname "$(dirname "$BASH_GPT_REAL")")"

  # Try various installation layouts
  for zsh_path in \\
    "$BASH_GPT_DIR/src/shell/bash-gpt.zsh" \\
    "$BASH_GPT_DIR/lib/node_modules/bash-gpt/src/shell/bash-gpt.zsh" \\
    "$(npm root -g 2>/dev/null)/bash-gpt/src/shell/bash-gpt.zsh" \\
    "$(bun pm -g 2>/dev/null)/bash-gpt/src/shell/bash-gpt.zsh"
  do
    if [[ -f "$zsh_path" ]]; then
      source "$zsh_path"
      break
    fi
  done
fi
`;

  writeFileSync(zshrc, content + setupLines);

  console.log(chalk.green('Added bash-gpt to your .zshrc'));
  console.log(chalk.dim('\nTo activate:'));
  console.log(chalk.cyan('  1. Restart your terminal, or run: source ~/.zshrc'));
  console.log(chalk.cyan('  2. Enable suggestions: bash-gpt on'));
  console.log(chalk.dim('\nType English and press Tab to accept suggestions.'));
}
