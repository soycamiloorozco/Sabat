import { FastifyInstance } from "fastify";

export default async function userRoutes(fastify: FastifyInstance) {
  fastify.get("/profile", { preHandler: fastify.authenticate }, async (request, reply) => {
    if (!request.userId) {
      return reply.code(401).send({ error: "Unauthorized" });
    }

    const user = await fastify.db.user.findUnique({
      where: { id: request.userId },
      include: { profile: true },
    });

    if (!user) {
      return reply.code(404).send({ error: "User not found" });
    }

    return {
      id: user.id,
      name: user.profile?.displayName ?? "Friend",
      email: user.email,
      voiceId: user.profile?.voiceId ?? null,
    };
  });
}
