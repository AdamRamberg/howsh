import chalk from 'chalk';
import ora from 'ora';
import { translate, translateStream } from '../lib/llm.js';
import { isAlreadyBash } from '../lib/detect.js';

export async function translateCommand(input: string, options: { suggest?: boolean; model?: string }): Promise<void> {
  const trimmedInput = input.trim();

  if (!trimmedInput) {
    console.error(chalk.red('Please provide a description to translate.'));
    process.exit(1);
  }

  // If already bash, just return it
  if (isAlreadyBash(trimmedInput)) {
    console.log(trimmedInput);
    return;
  }

  // Quick mode for shell integration (--suggest flag)
  if (options.suggest) {
    try {
      const result = await translate(trimmedInput, options.model);
      console.log(result);
    } catch (error) {
      // Silent failure for suggest mode
      process.exit(1);
    }
    return;
  }

  // Interactive mode with spinner and streaming
  const spinner = ora('Translating...').start();

  try {
    let result = '';
    for await (const chunk of translateStream(trimmedInput, options.model)) {
      if (spinner.isSpinning) {
        spinner.stop();
      }
      result += chunk;
      process.stdout.write(chunk);
    }
    console.log(); // New line after output
  } catch (error) {
    spinner.stop();
    if (error instanceof Error) {
      console.error(chalk.red(error.message));
    } else {
      console.error(chalk.red('An error occurred while translating.'));
    }
    process.exit(1);
  }
}
