import { FastifyInstance } from "fastify";
import { z } from "zod";
import { buildRagContext } from "../lib/rag.js";

const contextQuerySchema = z.object({
  q: z.string().optional(),
});

export default async function memoryRoutes(fastify: FastifyInstance) {
  fastify.get("/context", { preHandler: fastify.authenticate }, async (request, reply) => {
    if (!request.userId) {
      return reply.code(401).send({ error: "Unauthorized" });
    }

    const query = contextQuerySchema.parse(request.query);
    return buildRagContext(
      fastify.db,
      request.userId,
      query.q ? [{ role: "user", content: query.q }] : [],
    );
  });

  fastify.get("/items", { preHandler: fastify.authenticate }, async (request, reply) => {
    if (!request.userId) {
      return reply.code(401).send({ error: "Unauthorized" });
    }

    return fastify.db.userMemory.findMany({
      where: { userId: request.userId },
      orderBy: { createdAt: "desc" },
      take: 100,
      select: {
        id: true,
        kind: true,
        content: true,
        source: true,
        salience: true,
        metadata: true,
        createdAt: true,
      },
    });
  });
}
