import chalk from 'chalk';
import { getConfig, setConfig, getConfigPath, maskApiKey } from '../lib/config.js';

export async function configCommand(args: string[]): Promise<void> {
  if (args.length === 0) {
    // Show current config
    showConfig();
    return;
  }

  const [action, key, value] = args;

  if (action === 'set') {
    if (!key || !value) {
      console.error(chalk.red('Usage: bash-gpt config set <key> <value>'));
      console.log('\nAvailable keys:');
      console.log('  provider  - LLM provider (anthropic or openai)');
      console.log('  api-key   - API key for the selected provider');
      console.log('  model     - Model to use (optional, uses fast default)');
      process.exit(1);
    }

    try {
      setConfig(key, value);
      console.log(chalk.green(`Set ${key} successfully.`));
    } catch (error) {
      if (error instanceof Error) {
        console.error(chalk.red(error.message));
      }
      process.exit(1);
    }
    return;
  }

  console.error(chalk.red(`Unknown config action: ${action}`));
  console.log('Usage: bash-gpt config [set <key> <value>]');
  process.exit(1);
}

function showConfig(): void {
  const { provider, model, apiKey } = getConfig();

  console.log(chalk.bold('bash-gpt configuration:\n'));
  console.log(`  ${chalk.cyan('provider')}: ${provider}`);
  console.log(`  ${chalk.cyan('model')}: ${model}`);
  console.log(`  ${chalk.cyan('api-key')}: ${maskApiKey(apiKey)}`);
  console.log(`\n  ${chalk.dim('Config file:')} ${getConfigPath()}`);
}
