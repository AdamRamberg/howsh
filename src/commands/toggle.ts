import chalk from 'chalk';
import { writeFileSync, readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir, homedir } from 'os';

const STATE_FILE = join(tmpdir(), 'howsh-state');

export function getToggleState(): boolean {
  try {
    if (existsSync(STATE_FILE)) {
      return readFileSync(STATE_FILE, 'utf-8').trim() === 'on';
    }
  } catch {
    // Ignore errors
  }
  return false;
}

export function setToggleState(on: boolean): void {
  writeFileSync(STATE_FILE, on ? 'on' : 'off');
}

export async function toggleOnCommand(): Promise<void> {
  setToggleState(true);
  console.log(chalk.green('howsh suggestions enabled.'));
  console.log(chalk.dim('Start typing English to see suggestions.'));
  console.log(chalk.dim('Press Tab or Right Arrow to accept.'));

  // Check if shell integration is set up
  const zshrc = join(homedir(), '.zshrc');
  if (existsSync(zshrc)) {
    const content = readFileSync(zshrc, 'utf-8');
    if (!content.includes('howsh.zsh')) {
      console.log(chalk.yellow('\nNote: Run "howsh setup" to enable shell integration.'));
    }
  }
}

export async function toggleOffCommand(): Promise<void> {
  setToggleState(false);
  console.log(chalk.yellow('howsh suggestions disabled.'));
}
