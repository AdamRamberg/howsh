import { generateText, streamText } from 'ai';
import { createAnthropic } from '@ai-sdk/anthropic';
import { createOpenAI } from '@ai-sdk/openai';
import { getConfig, getApiKeySetupMessage, resolveModel } from './config.js';
import { TRANSLATION_PROMPT } from './prompt.js';

export async function translate(englishInput: string, modelOverride?: string): Promise<string> {
  const config = getConfig();
  const resolved = modelOverride ? resolveModel(modelOverride) : null;
  const selectedProvider = resolved?.provider || config.provider;
  const selectedModel = resolved?.model || modelOverride || config.model;
  const apiKey = config.apiKey;

  if (!apiKey) {
    throw new Error(getApiKeySetupMessage());
  }

  const modelInstance = selectedProvider === 'openai'
    ? createOpenAI({ apiKey })(selectedModel)
    : createAnthropic({ apiKey })(selectedModel);

  const result = await generateText({
    model: modelInstance,
    system: TRANSLATION_PROMPT,
    prompt: englishInput,
  });

  return result.text.trim();
}

export async function* translateStream(englishInput: string, modelOverride?: string): AsyncGenerator<string> {
  const config = getConfig();
  const resolved = modelOverride ? resolveModel(modelOverride) : null;
  const selectedProvider = resolved?.provider || config.provider;
  const selectedModel = resolved?.model || modelOverride || config.model;
  const apiKey = config.apiKey;

  if (!apiKey) {
    throw new Error(getApiKeySetupMessage());
  }

  const modelInstance = selectedProvider === 'openai'
    ? createOpenAI({ apiKey })(selectedModel)
    : createAnthropic({ apiKey })(selectedModel);

  const result = streamText({
    model: modelInstance,
    system: TRANSLATION_PROMPT,
    prompt: englishInput,
  });

  for await (const chunk of result.textStream) {
    yield chunk;
  }
}

// Quick translation for shell integration (no streaming, fast response)
export async function translateQuick(englishInput: string): Promise<string> {
  return translate(englishInput);
}
