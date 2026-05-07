import { FastifyInstance } from "fastify";
import { z } from "zod";
import { completeRitualTurn } from "../lib/anthropic.js";
import { streamElevenLabsTTS } from "../lib/elevenlabs.js";
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

      for await (const chunk of streamElevenLabsTTS(completion.text)) {
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
}
