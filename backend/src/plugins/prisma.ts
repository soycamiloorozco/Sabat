import { PrismaClient } from "@prisma/client";
import fp from "fastify-plugin";

declare module "fastify" {
  interface FastifyInstance {
    db: PrismaClient;
  }
}

export default fp(async (fastify) => {
  const db = new PrismaClient();

  fastify.decorate("db", db);
  fastify.addHook("onClose", async () => {
    await db.$disconnect();
  });
});
