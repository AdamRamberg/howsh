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
  if (content.includes('cmdai.zsh')) {
    console.log(chalk.green('cmdai is already set up in your .zshrc'));
    console.log(chalk.dim('\nRun "cmdai on" to enable suggestions.'));
    return;
  }

  // Find the shell script location
  // When installed via npm, it will be in the package's src/shell directory
  // We'll use a relative path from the installed location
  const setupLines = `
# cmdai shell integration
# Source the zsh plugin for always-on suggestions
if command -v cmdai &> /dev/null; then
  CMDAI_BIN="$(command -v cmdai)"
  CMDAI_REAL="$(readlink -f "$CMDAI_BIN" 2>/dev/null || realpath "$CMDAI_BIN" 2>/dev/null || echo "$CMDAI_BIN")"
  CMDAI_DIR="$(dirname "$(dirname "$CMDAI_REAL")")"

  # Try various installation layouts
  for zsh_path in \\
    "$CMDAI_DIR/src/shell/cmdai.zsh" \\
    "$CMDAI_DIR/lib/node_modules/cmdai/src/shell/cmdai.zsh" \\
    "$(npm root -g 2>/dev/null)/cmdai/src/shell/cmdai.zsh" \\
    "$(bun pm -g 2>/dev/null)/cmdai/src/shell/cmdai.zsh"
  do
    if [[ -f "$zsh_path" ]]; then
      source "$zsh_path"
      break
    fi
  done
fi
`;

  writeFileSync(zshrc, content + setupLines);

  console.log(chalk.green('Added cmdai to your .zshrc'));
  console.log(chalk.dim('\nTo activate:'));
  console.log(chalk.cyan('  1. Restart your terminal, or run: source ~/.zshrc'));
  console.log(chalk.cyan('  2. Enable suggestions: cmdai on'));
  console.log(chalk.dim('\nType English and press Tab to accept suggestions.'));
}
