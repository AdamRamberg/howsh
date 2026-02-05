import Conf from 'conf';

export type Provider = 'anthropic' | 'openai';

interface ConfigSchema {
  provider: Provider;
  apiKey?: string;
  model?: string;
}

const config = new Conf<ConfigSchema>({
  projectName: 'howsh',
  schema: {
    provider: { type: 'string', default: 'anthropic' },
    apiKey: { type: 'string' },
    model: { type: 'string' }
  }
});

const DEFAULT_MODELS: Record<Provider, string> = {
  anthropic: 'claude-opus-4-5-20251101',
  openai: 'gpt-4o-mini'
};

const MODEL_ALIASES: Record<string, { provider: Provider; model: string }> = {
  'haiku': { provider: 'anthropic', model: 'claude-haiku-4-5-20251001' },
  'sonnet': { provider: 'anthropic', model: 'claude-sonnet-4-5-20250929' },
  'opus': { provider: 'anthropic', model: 'claude-opus-4-5-20251101' },
  '4o': { provider: 'openai', model: 'gpt-4o' },
  '4o-mini': { provider: 'openai', model: 'gpt-4o-mini' },
};

export function resolveModel(alias: string): { provider: Provider; model: string } | null {
  return MODEL_ALIASES[alias] || null;
}

const ENV_KEYS: Record<Provider, string> = {
  anthropic: 'ANTHROPIC_API_KEY',
  openai: 'OPENAI_API_KEY'
};

export function getConfig(): { provider: Provider; model: string; apiKey: string | undefined } {
  const provider = config.get('provider') as Provider;
  const model = config.get('model') || DEFAULT_MODELS[provider];
  const apiKey = config.get('apiKey') || process.env[ENV_KEYS[provider]];

  return { provider, model, apiKey };
}

export function setConfig(key: string, value: string): void {
  if (key === 'provider') {
    if (value !== 'anthropic' && value !== 'openai') {
      throw new Error('Provider must be "anthropic" or "openai"');
    }
    config.set('provider', value as Provider);
  } else if (key === 'api-key') {
    config.set('apiKey', value);
  } else if (key === 'model') {
    const resolved = resolveModel(value);
    if (resolved) {
      config.set('model', resolved.model);
      config.set('provider', resolved.provider);
    } else {
      config.set('model', value);
    }
  } else {
    throw new Error(`Unknown config key: ${key}`);
  }
}

export function getConfigPath(): string {
  return config.path;
}

export function maskApiKey(key: string | undefined): string {
  if (!key) return '(not set)';
  if (key.length <= 8) return '***';
  return `${key.slice(0, 4)}...${key.slice(-4)}`;
}

export function getApiKeySetupMessage(): string {
  return `
No API key configured.

Choose a provider and set your API key:

  Anthropic (recommended for bash translation):
    howsh config set provider anthropic
    howsh config set api-key YOUR_ANTHROPIC_KEY
    Get a key: https://console.anthropic.com/

  OpenAI:
    howsh config set provider openai
    howsh config set api-key YOUR_OPENAI_KEY
    Get a key: https://platform.openai.com/api-keys

Or use environment variables:
    export ANTHROPIC_API_KEY=your_key
    export OPENAI_API_KEY=your_key
`;
}
