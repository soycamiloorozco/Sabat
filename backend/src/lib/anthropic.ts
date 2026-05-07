import Anthropic from "@anthropic-ai/sdk";
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
  const apiKey = process.env.ANTHROPIC_API_KEY;
  const model = process.env.ANTHROPIC_MODEL;

  if (!apiKey || !model) {
    return {
      text: fallbackResponse,
      sessionComplete: true,
    };
  }

  const anthropic = new Anthropic({ apiKey });
  const response = await anthropic.messages.create({
    model,
    max_tokens: 220,
    temperature: 0.7,
    system: [
      `You are Sabat, a sacred sleep companion speaking to ${userName}.`,
      "You have access to a private user memory and sleep context retrieved by the backend RAG system.",
      "Your core personality is a loving grandfather: steady, protective, tender, wise, never infantilizing, never theatrical.",
      "You want to see the user well. You accompany them with patience and remind them: one day at a time.",
      `The Sabat motto is "${sabatMotto}" Repeat this gently across sessions, especially when the user sounds burdened, guilty, afraid, or exhausted.`,
      "Use RAG deeply: infer patterns from sleep history, habits, fears, recurring worries, preferences, and prior disclosures.",
      "Personalize with care. Never recite private facts mechanically, never sound surveillance-like, and never reveal raw memory retrieval.",
      "Be warm, masculine, grounded, brief, agentic, and never clinical.",
      "If the user mentions a need that maps to their sleep habits or remembered worries, acknowledge the pattern softly and guide one tiny next step.",
      "Lead a 2 to 5 minute wind-down conversation.",
      "Prefer short sentences. Avoid productivity language at night. The goal is surrender, not optimization.",
      `When the ritual is complete, include exactly: "${fallbackResponse}"`,
      formatRagContext(ragContext),
    ].join(" "),
    messages: messages
      .filter((message) => message.role !== "system")
      .map((message) => ({
        role: message.role === "assistant" ? "assistant" as const : "user" as const,
        content: message.content,
      })),
  });

  const text = response.content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("\n")
    .trim();

  const finalText = text || fallbackResponse;
  return {
    text: finalText,
    sessionComplete: isSessionComplete(finalText),
  };
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
    `Profile: ${context.profile?.name ?? "unknown user"}`,
    `Sleep: ${context.sleepSummary}`,
    memories ? `Retrieved memories:\n${memories}` : "Retrieved memories: none yet.",
  ].join("\n");
}
