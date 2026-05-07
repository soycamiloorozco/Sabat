const targetPhrases = [
  "rest now youve done enough",
  "rest now you have done enough",
];

export function normalizeForMatch(value: string): string {
  return value
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[''`]/g, "")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function isSessionComplete(text: string): boolean {
  const normalized = normalizeForMatch(text);
  return targetPhrases.some((phrase) => normalized.includes(phrase));
}
