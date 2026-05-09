import { FastifyInstance } from "fastify";
import { PrismaClient } from "@prisma/client";
import { indexMemory } from "../lib/rag.js";

const prisma = new PrismaClient();

export default async function healthRoutes(fastify: FastifyInstance) {
  fastify.post("/heart-rate", async (request, reply) => {
    const { userId, samples } = request.body as {
      userId: string;
      samples: Array<{ bpm: number; timestamp: string }>;
    };

    // Save to DB
    await prisma.heartRateData.createMany({
      data: samples.map((s) => ({
        userId,
        bpm: s.bpm,
        timestamp: new Date(s.timestamp),
      })),
    });

    // Check for stress events to index as memories
    const highPulse = samples.filter((s) => s.bpm > 105);
    if (highPulse.length > 0) {
      await indexMemory(prisma, {
        userId,
        kind: "stress_event",
        content: `Elevated heart rate detected: ${highPulse.length} samples above 105 BPM today.`,
        source: "health_kit",
        metadata: { sampleCount: highPulse.length },
        salience: 0.8,
      });
    }

    return { success: true };
  });
}
