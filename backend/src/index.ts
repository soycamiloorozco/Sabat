import websocket from "@fastify/websocket";
import cors from "@fastify/cors";
import Fastify from "fastify";
import authPlugin from "./plugins/auth.js";
import prismaPlugin from "./plugins/prisma.js";
import authRoutes from "./routes/auth.js";
import memoryRoutes from "./routes/memory.js";
import sleepRoutes from "./routes/sleep.js";
import userRoutes from "./routes/user.js";
import voiceRoutes from "./routes/voice.js";

import healthRoutes from "./routes/health.js";
import ritualRoutes from "./routes/rituals.js";

const server = Fastify({
  logger: true,
});

await server.register(cors, {
  origin: true,
});
await server.register(websocket);

await server.register(prismaPlugin);
await server.register(authPlugin);

server.get("/health", async () => ({
  ok: true,
  service: "sabat-backend",
}));

await server.register(authRoutes, { prefix: "/auth" });
await server.register(memoryRoutes, { prefix: "/memory" });
await server.register(sleepRoutes, { prefix: "/sleep" });
await server.register(userRoutes, { prefix: "/user" });
await server.register(voiceRoutes, { prefix: "/voice" });
await server.register(healthRoutes, { prefix: "/health" });
await server.register(ritualRoutes, { prefix: "/rituals" });

const publicApiUrl = process.env.PUBLIC_API_URL;
if (publicApiUrl) {
  setInterval(() => {
    fetch(`${publicApiUrl}/health`).catch((error) => {
      server.log.warn({ error }, "keep-alive ping failed");
    });
  }, 10 * 60 * 1000).unref();
}

const port = Number(process.env.PORT ?? 3000);
await server.listen({ host: "0.0.0.0", port });
