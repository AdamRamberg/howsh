#!/usr/bin/env node

import { Command } from 'commander';
import { translateCommand } from './commands/translate.js';
import { listCommand } from './commands/list.js';
import { toggleOnCommand, toggleOffCommand } from './commands/toggle.js';
import { setupCommand } from './commands/setup.js';
import { configCommand } from './commands/config.js';

const program = new Command();

program
  .name('bash-gpt')
  .description('Turn English into bash commands with AI-powered suggestions')
  .version('0.1.0');

// Default command: translate English to bash
program
  .argument('[description...]', 'English description to translate to bash')
  .option('--suggest', 'Quick mode for shell integration (no streaming)')
  .action(async (description: string[], options: { suggest?: boolean }) => {
    if (description.length > 0) {
      await translateCommand(description.join(' '), options);
    } else {
      program.help();
    }
  });

// Toggle commands
program
  .command('on')
  .description('Enable always-on suggestions')
  .action(toggleOnCommand);

program
  .command('off')
  .description('Disable suggestions')
  .action(toggleOffCommand);

// Cheatsheet command
program
  .command('list [query]')
  .description('Browse bash cheatsheets')
  .option('-s, --search', 'Search across all cheatsheets')
  .action(listCommand);

// Setup command
program
  .command('setup')
  .description('Add bash-gpt to your shell configuration')
  .action(setupCommand);

// Config command
program
  .command('config [args...]')
  .description('View or modify configuration')
  .action(configCommand);

program.parse();
