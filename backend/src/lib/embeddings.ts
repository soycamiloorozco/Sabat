const fallbackDimensions = 96;

export async function embedText(text: string): Promise<number[]> {
  const apiKey = process.env.OPENAI_API_KEY;
  const model = process.env.OPENAI_EMBEDDING_MODEL ?? "text-embedding-3-small";

  if (!apiKey) {
    return deterministicEmbedding(text);
  }

  const response = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: text,
    }),
  });

  if (!response.ok) {
    throw new Error(`Embedding request failed with status ${response.status}`);
  }

  const payload = await response.json() as {
    data?: Array<{ embedding?: number[] }>;
  };

  const embedding = payload.data?.[0]?.embedding;
  if (!embedding?.length) {
    throw new Error("Embedding response did not include a vector");
  }

  return normalizeVector(embedding);
}

export function cosineSimilarity(a: number[], b: number[]): number {
  const length = Math.min(a.length, b.length);
  if (length === 0) {
    return 0;
  }

  let dot = 0;
  let aMagnitude = 0;
  let bMagnitude = 0;

  for (let index = 0; index < length; index += 1) {
    dot += a[index] * b[index];
    aMagnitude += a[index] ** 2;
    bMagnitude += b[index] ** 2;
  }

  if (aMagnitude === 0 || bMagnitude === 0) {
    return 0;
  }

  return dot / (Math.sqrt(aMagnitude) * Math.sqrt(bMagnitude));
}

function deterministicEmbedding(text: string): number[] {
  const vector = new Array<number>(fallbackDimensions).fill(0);
  const tokens = text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .split(/\s+/)
    .filter(Boolean);

  for (const token of tokens) {
    const hash = hashToken(token);
    const index = Math.abs(hash) % fallbackDimensions;
    vector[index] += hash >= 0 ? 1 : -1;
  }

  return normalizeVector(vector);
}

function hashToken(token: string): number {
  let hash = 0;
  for (let index = 0; index < token.length; index += 1) {
    hash = ((hash << 5) - hash + token.charCodeAt(index)) | 0;
  }
  return hash;
}

function normalizeVector(vector: number[]): number[] {
  const magnitude = Math.sqrt(vector.reduce((sum, value) => sum + value ** 2, 0));
  if (magnitude === 0) {
    return vector;
  }

  return vector.map((value) => value / magnitude);
}
