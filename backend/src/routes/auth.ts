import { createHash } from "node:crypto";
import { FastifyInstance } from "fastify";
import { z } from "zod";

const appleAuthSchema = z.object({
  identityToken: z.string().min(1),
  authorizationCode: z.string().optional().nullable(),
  fullName: z.string().optional().nullable(),
  email: z.string().email().optional().nullable(),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

type TokenPayload = {
  sub: string;
  tokenUse: "access" | "refresh";
};

export default async function authRoutes(fastify: FastifyInstance) {
  fastify.post("/apple", async (request) => {
    const body = appleAuthSchema.parse(request.body);
    const appleSubject = createHash("sha256")
      .update(body.identityToken)
      .digest("hex");

    const displayName = body.fullName?.trim() || "Friend";
    const user = await fastify.db.user.upsert({
      where: { appleSubject },
      update: {
        email: body.email ?? undefined,
        profile: {
          upsert: {
            create: { displayName },
            update: { displayName },
          },
        },
      },
      create: {
        appleSubject,
        email: body.email,
        profile: {
          create: { displayName },
        },
      },
      include: { profile: true },
    });

    return {
      user: {
        id: user.id,
        name: user.profile?.displayName ?? displayName,
        email: user.email,
        voiceId: user.profile?.voiceId ?? null,
      },
      tokens: issueTokens(fastify, user.id),
    };
  });

  fastify.post("/refresh", async (request, reply) => {
    const body = refreshSchema.parse(request.body);

    try {
      const decoded = fastify.jwt.verify<TokenPayload>(body.refreshToken);
      if (decoded.tokenUse !== "refresh") {
        throw new Error("Invalid token use");
      }

      return issueTokens(fastify, decoded.sub);
    } catch {
      return reply.code(401).send({ error: "Refresh token expired" });
    }
  });
}

function issueTokens(fastify: FastifyInstance, userId: string) {
  return {
    accessToken: fastify.jwt.sign(
      { sub: userId, tokenUse: "access" },
      { expiresIn: "15m" },
    ),
    refreshToken: fastify.jwt.sign(
      { sub: userId, tokenUse: "refresh" },
      { expiresIn: "30d" },
    ),
  };
}
