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
  if (content.includes('howsh.zsh')) {
    console.log(chalk.green('howsh is already set up in your .zshrc'));
    console.log(chalk.dim('\nRun "howsh on" to enable suggestions.'));
    return;
  }

  // Find the shell script location
  // When installed via npm, it will be in the package's src/shell directory
  // We'll use a relative path from the installed location
  const setupLines = `
# howsh shell integration
# Source the zsh plugin for always-on suggestions
if command -v howsh &> /dev/null; then
  HOWSH_BIN="$(command -v howsh)"
  HOWSH_REAL="$(readlink -f "$HOWSH_BIN" 2>/dev/null || realpath "$HOWSH_BIN" 2>/dev/null || echo "$HOWSH_BIN")"
  HOWSH_DIR="$(dirname "$(dirname "$HOWSH_REAL")")"

  # Try various installation layouts
  for zsh_path in \\
    "$HOWSH_DIR/src/shell/howsh.zsh" \\
    "$HOWSH_DIR/lib/node_modules/howsh/src/shell/howsh.zsh" \\
    "$(npm root -g 2>/dev/null)/howsh/src/shell/howsh.zsh" \\
    "$(bun pm -g 2>/dev/null)/howsh/src/shell/howsh.zsh"
  do
    if [[ -f "$zsh_path" ]]; then
      source "$zsh_path"
      break
    fi
  done
fi
`;

  writeFileSync(zshrc, content + setupLines);

  console.log(chalk.green('Added howsh to your .zshrc'));
  console.log(chalk.dim('\nTo activate:'));
  console.log(chalk.cyan('  1. Restart your terminal, or run: source ~/.zshrc'));
  console.log(chalk.cyan('  2. Enable suggestions: howsh on'));
  console.log(chalk.dim('\nType English and press Tab to accept suggestions.'));
}
