import { FastifyInstance } from "fastify";
import { z } from "zod";
import { completeRitualTurn, streamOpenAITTS } from "../lib/openai.js";
import { createRealtimeConnection } from "../lib/realtime.js";
import { buildRagContext, indexVoiceTurn } from "../lib/rag.js";

const messageSchema = z.object({
  id: z.string().optional(),
  role: z.enum(["system", "user", "assistant"]),
  content: z.string().min(1),
});

const voiceTurnSchema = z.object({
  userName: z.string().min(1),
  messages: z.array(messageSchema).min(1),
});

export default async function voiceRoutes(fastify: FastifyInstance) {
  // Existing REST endpoint for single turns
  fastify.post("/turn", { preHandler: fastify.authenticate }, async (request, reply) => {
    if (!request.userId) {
      return reply.code(401).send({ error: "Unauthorized" });
    }

    const body = voiceTurnSchema.parse(request.body);
    const ragContext = await buildRagContext(fastify.db, request.userId, body.messages);
    const completion = await completeRitualTurn(body.userName, body.messages, ragContext);
    await indexVoiceTurn(
      fastify.db,
      request.userId,
      body.messages,
      completion.text,
      completion.sessionComplete,
    );

    try {
      reply
        .header("content-type", "audio/mpeg")
        .header("x-sabat-session-complete", String(completion.sessionComplete))
        .header("x-sabat-reply-text", encodeURIComponent(completion.text));

      for await (const chunk of streamOpenAITTS(completion.text)) {
        reply.raw.write(chunk);
      }

      reply.raw.end();
      return reply;
    } catch (error) {
      fastify.log.error({ error }, "voice turn failed");
      return reply.code(503).send({
        error: "Voice service unavailable",
        fallbackText: "Rest now. You've done enough.",
        sessionComplete: true,
      });
    }
  });

  // New WebSocket endpoint for Realtime Voice Agent
  fastify.get("/realtime", { websocket: true, preHandler: fastify.authenticate }, async (connection, request) => {
    if (!request.userId) {
      connection.socket.close(1008, "Unauthorized");
      return;
    }

    // Get user profile for personalization
    const user = await fastify.db.user.findUnique({
      where: { id: request.userId },
      include: { profile: true }
    });

    await createRealtimeConnection(connection.socket, {
      userId: request.userId,
      db: fastify.db,
      userName: user?.profile?.displayName || "Friend",
      language: "es" // Default to Spanish as requested
    });
  });
}


