import { generateText, streamText } from 'ai';
import { createAnthropic } from '@ai-sdk/anthropic';
import { createOpenAI } from '@ai-sdk/openai';
import { getConfig, getApiKeySetupMessage } from './config.js';
import { TRANSLATION_PROMPT } from './prompt.js';

export async function translate(englishInput: string): Promise<string> {
  const { provider, model, apiKey } = getConfig();

  if (!apiKey) {
    throw new Error(getApiKeySetupMessage());
  }

  const modelInstance = provider === 'openai'
    ? createOpenAI({ apiKey })(model)
    : createAnthropic({ apiKey })(model);

  const result = await generateText({
    model: modelInstance,
    system: TRANSLATION_PROMPT,
    prompt: englishInput,
  });

  return result.text.trim();
}

export async function* translateStream(englishInput: string): AsyncGenerator<string> {
  const { provider, model, apiKey } = getConfig();

  if (!apiKey) {
    throw new Error(getApiKeySetupMessage());
  }

  const modelInstance = provider === 'openai'
    ? createOpenAI({ apiKey })(model)
    : createAnthropic({ apiKey })(model);

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
