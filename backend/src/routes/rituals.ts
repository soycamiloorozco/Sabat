import { FastifyInstance } from "fastify";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export default async function ritualRoutes(fastify: FastifyInstance) {
  fastify.post("/", async (request, reply) => {
    const { userId, type, startedAt, endedAt, notes } = request.body as {
      userId: string;
      type: string;
      startedAt: string;
      endedAt?: string;
      notes?: string;
    };

    const ritual = await prisma.restRitual.create({
      data: {
        userId,
        type,
        startedAt: new Date(startedAt),
        endedAt: endedAt ? new Date(endedAt) : null,
        notes,
      },
    });

    return ritual;
  });

  fastify.get("/user/:userId", async (request, reply) => {
    const { userId } = request.params as { userId: string };
    const rituals = await prisma.restRitual.findMany({
      where: { userId },
      orderBy: { startedAt: "desc" },
      take: 20,
    });
    return rituals;
  });
}
