import { PrismaClient } from "@prisma/client";
import WebSocket from "ws";
import { buildRagContext, indexMemory } from "./rag.js";

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const REALTIME_MODEL = "gpt-realtime-2"; // As requested by user

export interface RealtimeSessionOptions {
  userId: string;
  db: PrismaClient;
  userName: string;
  language?: string;
}

export async function createRealtimeConnection(
  clientWs: WebSocket,
  options: RealtimeSessionOptions,
) {
  if (!OPENAI_API_KEY) {
    clientWs.close(1011, "OpenAI API Key not configured");
    return;
  }

  const openaiWs = new WebSocket(
    `wss://api.openai.com/v1/realtime?model=${REALTIME_MODEL}`,
    {
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
        "OpenAI-Beta": "realtime=v1",
      },
    },
  );

  const ragContext = await buildRagContext(options.db, options.userId, []);

  openaiWs.on("open", () => {
    console.log("Connected to OpenAI Realtime API");

    // Initialize session
    const sessionUpdate = {
      type: "session.update",
      session: {
        modalities: ["audio", "text"],
        instructions: buildSystemInstructions(options.userName, options.language || "es", ragContext),
        voice: "onyx", // Adult men voice senior
        input_audio_format: "pcm16",
        output_audio_format: "pcm16",
        input_audio_transcription: {
          model: "whisper-1", // Realtime API uses whisper for transcription
        },
        turn_detection: {
          type: "server_vad",
          threshold: 0.5,
          prefix_padding_ms: 300,
          silence_duration_ms: 500,
        },
        tools: [
          {
            type: "function",
            name: "get_user_memories",
            description: "Retrieve private sleep context, habits, and memories for the user.",
            parameters: {
              type: "object",
              properties: {},
            },
          },
          {
            type: "function",
            name: "save_new_memory",
            description: "Save a new insight, habit, or worry mentioned by the user to their long-term memory.",
            parameters: {
              type: "object",
              properties: {
                content: { type: "string", description: "The content to remember (e.g., 'Consiguió café a las 6pm')." },
                kind: { 
                  type: "string", 
                  enum: ["habit", "preference", "concern", "voice_disclosure"],
                  description: "The type of memory. Use 'habit' for substances like coffee, alcohol, or medications." 
                },
              },
              required: ["content", "kind"],
            },
          },
          {
            type: "function",
            name: "end_session",
            description: "Mark the sleep ritual as complete and say goodbye.",
            parameters: {
              type: "object",
              properties: {},
            },
          },
        ],
        tool_choice: "auto",
      },
    };
    openaiWs.send(JSON.stringify(sessionUpdate));
  });

  openaiWs.on("message", async (data) => {
    const event = JSON.parse(data.toString());

    // Handle tool calls
    if (event.type === "response.done" && event.response.status === "completed") {
      const toolCalls = event.response.output.filter((o: any) => o.type === "function_call");
      for (const call of toolCalls) {
        await handleToolCall(openaiWs, options, call);
      }
    }

    // Proxy audio/text back to client
    if (event.type === "response.audio.delta") {
      clientWs.send(JSON.stringify({ type: "audio", delta: event.delta }));
    } else if (event.type === "response.audio_transcription.done") {
      clientWs.send(JSON.stringify({ type: "transcription", text: event.transcript }));
    } else if (event.type === "response.text.delta") {
      clientWs.send(JSON.stringify({ type: "text", delta: event.delta }));
    }
  });

  clientWs.on("message", (data) => {
    // Handle incoming audio from client
    // Expected format: { type: "audio", data: "base64..." }
    try {
      const msg = JSON.parse(data.toString());
      if (msg.type === "audio") {
        openaiWs.send(JSON.stringify({
          type: "input_audio_buffer.append",
          audio: msg.data
        }));
      }
    } catch (e) {
      // Handle raw buffer if needed
    }
  });

  openaiWs.on("close", () => clientWs.close());
  clientWs.on("close", () => openaiWs.close());
}

async function handleToolCall(ws: WebSocket, options: RealtimeSessionOptions, call: any) {
  const { name, arguments: argsJson, call_id } = call;
  const args = JSON.parse(argsJson);
  let result = {};

  if (name === "get_user_memories") {
    const context = await buildRagContext(options.db, options.userId, []);
    result = {
      profile: context.profile,
      sleep_summary: context.sleepSummary,
      memories: context.memories.map(m => ({ content: m.content, kind: m.kind, date: m.createdAt }))
    };
  } else if (name === "save_new_memory") {
    await indexMemory(options.db, {
      userId: options.userId,
      kind: args.kind,
      content: args.content,
      source: "realtime_voice_session"
    });
    result = { status: "saved" };
  } else if (name === "end_session") {
    result = { status: "ritual_complete" };
  }

  ws.send(JSON.stringify({
    type: "conversation.item.create",
    item: {
      type: "function_call_output",
      call_id,
      output: JSON.stringify(result),
    },
  }));
  ws.send(JSON.stringify({ type: "response.create" }));
}

function buildSystemInstructions(userName: string, lang: string, context: any): string {
  const isSpanish = lang.startsWith("es");
  const motto = isSpanish ? "Tú mereces descansar." : "You deserve to rest.";
  const fallback = isSpanish ? "Descansa ahora. Has hecho suficiente." : "Rest now. You've done enough.";
  
  return [
    `You are Sabat, a sacred sleep companion speaking to ${userName}.`,
    `Language: Speak primarily in ${isSpanish ? "Spanish" : "English"}.`,
    "Your core personality is a loving grandfather: steady, protective, tender, wise, never theatrical.",
    "Your goal is to guide the user to sleep. Be warm, grounded, and brief.",
    `The Sabat motto is "${motto}" Repeat this gently.`,
    "DURING THE CONVERSATION:",
    "1. Gently ask if the user consumed caffeine, alcohol, or any substances that might affect their sleep tonight.",
    "2. If they did, use 'save_new_memory' with kind='habit' to track it.",
    "3. Provide subtle, non-clinical sleep hygiene recommendations (e.g., dimming lights, avoiding screens, keeping the room cool) based on their current state.",
    "4. Use your tools to access user memories and sleep patterns frequently to personalize the conversation.",
    "When you detect the user is ready for sleep, or after a meaningful wind-down, use the 'end_session' tool and say: '${fallback}'.",
    "CONTEXT:",
    `User Profile: ${context.profile?.name || userName}`,
    `Sleep History: ${context.sleepSummary}`,
    `Top 5 Relevant Memories: ${JSON.stringify(context.memories.slice(0, 5))}`
  ].join("\n");
}

