import { describe, expect, it } from "vitest";
import { isSessionComplete, normalizeForMatch } from "../src/lib/session-complete.js";

describe("Sabat persona guardrails", () => {
  const fixtures = [
    "Rest now. You've done enough.",
    "Rest now, you have done enough.",
    "The night can hold the rest. Rest now. You've done enough.",
  ];

  it("detects the normalized session-ending phrase", () => {
    for (const fixture of fixtures) {
      expect(isSessionComplete(fixture)).toBe(true);
    }
  });

  it("normalizes punctuation and smart quotes", () => {
    expect(normalizeForMatch("Rest now. You've done enough.")).toBe("rest now youve done enough");
  });

  it("does not end ordinary turns early", () => {
    expect(isSessionComplete("Tell me what still feels unfinished.")).toBe(false);
  });
});
