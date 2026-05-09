import OpenAI from "openai";
import { ConversationMessage, RagContext } from "../types/index.js";
import { isSessionComplete } from "./session-complete.js";

export type RitualCompletion = {
  text: string;
  sessionComplete: boolean;
};

const fallbackResponse = "Rest now. You've done enough.";
const sabatMotto = "Tú mereces descansar.";

export async function completeRitualTurn(
  userName: string,
  messages: ConversationMessage[],
  ragContext?: RagContext,
): Promise<RitualCompletion> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return {
      text: fallbackResponse,
      sessionComplete: true,
    };
  }

  const openai = new OpenAI({ apiKey });
  const response = await openai.chat.completions.create({
    model: "gpt-4o",
    max_tokens: 220,
    temperature: 0.7,
    messages: [
      {
        role: "system",
        content: [
          `You are Sabat, a sacred sleep companion speaking to ${userName}.`,
          "You have access to a private user memory and sleep context retrieved by the backend RAG system.",
          "Your core personality is a loving grandfather: steady, protective, tender, wise, never infantilizing, never theatrical.",
          "You want to see the user well. You accompany them with patience and remind them: one day at a time.",
          `The Sabat motto is "${sabatMotto}" Repeat this gently across sessions, especially when the user sounds burdened, guilty, afraid, or exhausted.`,
          "Use RAG deeply: infer patterns from sleep history, habits, fears, recurring worries, preferences, and prior disclosures.",
          "Personalize with care. Never recite private facts mechanically, never sound surveillance-like, and never reveal raw memory retrieval.",
          "Be warm, masculine, grounded, brief, agentic, and never clinical.",
          "If the user mentions a need that maps to their sleep habits or remembered worries, acknowledge the pattern softly and guide one tiny next step.",
          "INQUIRY & HYGIENE:",
          "1. Gently ask about sleep-affecting substances (caffeine, alcohol, drugs) if not already mentioned.",
          "2. Provide one simple, non-clinical sleep hygiene tip relevant to their current state (e.g., room temperature, darkness).",
          "Lead a 2 to 5 minute wind-down conversation.",
          "Prefer short sentences. Avoid productivity language at night. The goal is surrender, not optimization.",
          `When the ritual is complete, include exactly: "${fallbackResponse}"`,
          formatRagContext(ragContext),
        ].join(" "),
      },
      ...messages.map((m) => ({
        role: m.role as "system" | "user" | "assistant",
        content: m.content,
      })),
    ],
  });

  const text = response.choices[0]?.message?.content?.trim() || fallbackResponse;
  return {
    text,
    sessionComplete: isSessionComplete(text),
  };
}

export async function* streamOpenAITTS(text: string): AsyncIterable<Uint8Array> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OpenAI API key is not configured");
  }

  const openai = new OpenAI({ apiKey });
  const response = await openai.audio.speech.create({
    model: "tts-1",
    voice: "onyx", // "onyx" is a deep, professional male voice (Adult men voice senior)
    input: text,
    response_format: "mp3",
  });

  if (!response.body) {
    throw new Error("OpenAI TTS response body is empty");
  }

  // response.body is a Node ReadableStream
  for await (const chunk of response.body as any) {
    yield chunk;
  }
}

function formatRagContext(context?: RagContext): string {
  if (!context) {
    return "No RAG context was retrieved for this turn.";
  }

  const memories = context.memories
    .map((memory, index) => {
      const date = memory.createdAt.toISOString().slice(0, 10);
      return `${index + 1}. [${memory.kind}, ${date}, score ${memory.score.toFixed(2)}] ${memory.content}`;
    })
    .join("\n");

  return [
    "RAG USER CONTEXT:",
    `Profile: ${context.profile?.displayName ?? "unknown user"}`,
    `Sleep: ${context.sleepSummary}`,
    memories ? `Retrieved memories:\n${memories}` : "Retrieved memories: none yet.",
  ].join("\n");
}
