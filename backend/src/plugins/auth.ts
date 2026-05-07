import jwt from "@fastify/jwt";
import { FastifyReply, FastifyRequest } from "fastify";
import fp from "fastify-plugin";

declare module "fastify" {
  interface FastifyInstance {
    authenticate(request: FastifyRequest, reply: FastifyReply): Promise<void>;
  }

  interface FastifyRequest {
    userId?: string;
  }
}

type TokenPayload = {
  sub: string;
  tokenUse: "access" | "refresh";
};

export default fp(async (fastify) => {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    fastify.log.warn("JWT_SECRET is not set. Development tokens will be signed with an unsafe fallback.");
  }

  await fastify.register(jwt, {
    secret: secret ?? "development-only-secret",
  });

  fastify.decorate("authenticate", async (request, reply) => {
    try {
      const decoded = await request.jwtVerify<TokenPayload>();
      if (decoded.tokenUse !== "access") {
        throw new Error("Invalid token use");
      }
      request.userId = decoded.sub;
    } catch {
      await reply.code(401).send({ error: "Unauthorized" });
    }
  });
});
