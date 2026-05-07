import { Prisma, PrismaClient } from "@prisma/client";
import { ConversationMessage, RagContext, RagMemory } from "../types/index.js";
import { cosineSimilarity, embedText } from "./embeddings.js";

type MemoryKind =
  | "voice_disclosure"
  | "sleep_summary"
  | "habit"
  | "preference"
  | "concern"
  | "system_summary";

type IndexMemoryInput = {
  userId: string;
  kind: MemoryKind;
  content: string;
  source: string;
  metadata?: Record<string, unknown>;
  salience?: number;
};

export async function buildRagContext(
  db: PrismaClient,
  userId: string,
  messages: ConversationMessage[],
): Promise<RagContext> {
  const user = await db.user.findUnique({
    where: { id: userId },
    include: {
      profile: true,
      sessions: {
        orderBy: { startedAt: "desc" },
        take: 14,
      },
    },
  });

  const queryText = messages
    .slice(-6)
    .map((message) => `${message.role}: ${message.content}`)
    .join("\n");

  const memories = await retrieveMemories(db, userId, queryText, 10);

  return {
    profile: user
      ? {
          id: user.id,
          name: user.profile?.displayName ?? "Friend",
          email: user.email,
          voiceId: user.profile?.voiceId ?? null,
        }
      : null,
    sleepSummary: summarizeSleep(user?.sessions ?? []),
    memories,
  };
}

export async function indexVoiceTurn(
  db: PrismaClient,
  userId: string,
  messages: ConversationMessage[],
  assistantReply: string,
  sessionComplete: boolean,
): Promise<void> {
  const latestUserMessage = [...messages].reverse().find((message) => message.role === "user");
  if (!latestUserMessage) {
    return;
  }

  await db.voiceConversation.create({
    data: {
      userId,
      messages: [...messages, { role: "assistant", content: assistantReply }],
      sessionComplete,
    },
  });

  await indexMemory(db, {
    userId,
    kind: classifyMemory(latestUserMessage.content),
    content: latestUserMessage.content,
    source: "voice_turn",
    metadata: {
      sessionComplete,
      assistantReply,
    },
    salience: inferSalience(latestUserMessage.content),
  });
}

export async function indexSleepSessionMemory(
  db: PrismaClient,
  userId: string,
  session: {
    id: string;
    startedAt: Date;
    endedAt: Date | null;
    restScore: number | null;
    phases?: unknown;
  },
): Promise<void> {
  const content = [
    `Sleep session ${session.id}`,
    `Started: ${session.startedAt.toISOString()}`,
    session.endedAt ? `Ended: ${session.endedAt.toISOString()}` : "Still active or no end time recorded",
    session.restScore === null ? "Rest score unavailable" : `Rest score: ${session.restScore}`,
    session.phases ? `Phase and alarm data: ${JSON.stringify(session.phases).slice(0, 1000)}` : "",
  ]
    .filter(Boolean)
    .join(". ");

  await indexMemory(db, {
    userId,
    kind: "sleep_summary",
    content,
    source: "sleep_session",
    metadata: { sessionId: session.id },
    salience: 0.72,
  });
}

async function indexMemory(db: PrismaClient, input: IndexMemoryInput): Promise<void> {
  const content = input.content.trim();
  if (content.length < 3) {
    return;
  }

  const embedding = await embedText(content);
  await db.userMemory.create({
    data: {
      userId: input.userId,
      kind: input.kind,
      content,
      source: input.source,
      metadata: (input.metadata ?? {}) as Prisma.InputJsonValue,
      embedding,
      salience: input.salience ?? 0.5,
    },
  });
}

async function retrieveMemories(
  db: PrismaClient,
  userId: string,
  queryText: string,
  limit: number,
): Promise<RagMemory[]> {
  const queryEmbedding = await embedText(queryText || "sleep ritual emotional context");
  const candidates = await db.userMemory.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: 200,
  });

  return candidates
    .map((memory) => {
      const vector = Array.isArray(memory.embedding)
        ? memory.embedding.filter((value): value is number => typeof value === "number")
        : [];
      const score = cosineSimilarity(queryEmbedding, vector) * 0.78 + memory.salience * 0.22;
      return {
        id: memory.id,
        kind: memory.kind,
        content: memory.content,
        source: memory.source,
        salience: memory.salience,
        score,
        createdAt: memory.createdAt,
      };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);
}

function summarizeSleep(
  sessions: Array<{
    startedAt: Date;
    endedAt: Date | null;
    restScore: number | null;
  }>,
): string {
  if (sessions.length === 0) {
    return "No tracked sleep sessions yet. Treat sleep knowledge as unknown and ask gently.";
  }

  const scored = sessions.filter((session) => session.restScore !== null);
  const averageScore = scored.length
    ? Math.round(scored.reduce((sum, session) => sum + (session.restScore ?? 0), 0) / scored.length)
    : null;

  const durations = sessions
    .filter((session) => session.endedAt)
    .map((session) => ((session.endedAt?.getTime() ?? 0) - session.startedAt.getTime()) / 3_600_000)
    .filter((duration) => duration > 0 && duration < 16);

  const averageHours = durations.length
    ? (durations.reduce((sum, duration) => sum + duration, 0) / durations.length).toFixed(1)
    : null;

  return [
    `Recent tracked nights: ${sessions.length}`,
    averageScore === null ? "Average rest score unavailable" : `Average rest score: ${averageScore}`,
    averageHours === null ? "Average duration unavailable" : `Average sleep duration: ${averageHours} hours`,
    `Most recent session started ${sessions[0]?.startedAt.toISOString()}`,
  ].join(". ");
}

function classifyMemory(content: string): MemoryKind {
  const normalized = content.toLowerCase();
  if (/(afraid|fear|scared|worried|anxious|panic|temor|miedo|ansiedad)/.test(normalized)) {
    return "concern";
  }
  if (/(guilt|guilty|shame|culpa|vergüenza|verguenza|dolor|pain|hurt|alone|solo|sola)/.test(normalized)) {
    return "concern";
  }
  if (/(always|usually|habit|routine|cada noche|suelo|siempre)/.test(normalized)) {
    return "habit";
  }
  if (/(prefer|like|don't like|me gusta|prefiero)/.test(normalized)) {
    return "preference";
  }
  return "voice_disclosure";
}

function inferSalience(content: string): number {
  const normalized = content.toLowerCase();
  let score = 0.5;
  if (/(afraid|fear|scared|worried|anxious|panic|temor|miedo|ansiedad)/.test(normalized)) {
    score += 0.25;
  }
  if (/(guilt|guilty|shame|culpa|vergüenza|verguenza|dolor|pain|hurt|alone|solo|sola)/.test(normalized)) {
    score += 0.18;
  }
  if (/(always|never|every night|cada noche|siempre|nunca)/.test(normalized)) {
    score += 0.15;
  }
  if (content.length > 180) {
    score += 0.1;
  }
  return Math.min(0.95, score);
}
