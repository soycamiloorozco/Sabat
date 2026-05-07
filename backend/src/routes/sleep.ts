import { FastifyInstance } from "fastify";
import { z } from "zod";
import { indexSleepSessionMemory } from "../lib/rag.js";

const sleepPhaseSampleSchema = z.object({
  id: z.string().optional(),
  phase: z.enum(["awake", "light", "deep", "rem"]),
  startDate: z.string().datetime(),
  endDate: z.string().datetime(),
});

const sleepAlarmSchema = z.object({
  targetWakeTime: z.string().datetime(),
  windowMinutes: z.number().int().min(5).max(120),
  source: z.enum(["user", "voice"]),
  isEnabled: z.boolean(),
});

const sleepSessionSchema = z.object({
  id: z.string().min(1),
  startedAt: z.string().datetime(),
  endedAt: z.string().datetime().nullable().optional(),
  restScore: z.number().int().min(0).max(100).nullable().optional(),
  alarm: sleepAlarmSchema.nullable().optional(),
  phaseSamples: z.array(sleepPhaseSampleSchema).default([]),
  syncedAt: z.string().datetime().nullable().optional(),
});

export default async function sleepRoutes(fastify: FastifyInstance) {
  fastify.post("/sessions", { preHandler: fastify.authenticate }, async (request, reply) => {
    if (!request.userId) {
      return reply.code(401).send({ error: "Unauthorized" });
    }

    const body = sleepSessionSchema.parse(request.body);
    const payload = {
      phaseSamples: body.phaseSamples,
      alarm: body.alarm ?? null,
      syncedAt: body.syncedAt ?? null,
    };

    const storedSession = await fastify.db.sleepSession.upsert({
      where: { id: body.id },
      update: {
        startedAt: new Date(body.startedAt),
        endedAt: body.endedAt ? new Date(body.endedAt) : null,
        restScore: body.restScore ?? null,
        phases: payload,
      },
      create: {
        id: body.id,
        userId: request.userId,
        startedAt: new Date(body.startedAt),
        endedAt: body.endedAt ? new Date(body.endedAt) : null,
        restScore: body.restScore ?? null,
        phases: payload,
      },
    });

    await indexSleepSessionMemory(fastify.db, request.userId, storedSession);

    return {};
  });
}
