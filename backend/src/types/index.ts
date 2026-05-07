export type ConversationRole = "system" | "user" | "assistant";

export type ConversationMessage = {
  id?: string;
  role: ConversationRole;
  content: string;
};

export type UserProfile = {
  id: string;
  name: string;
  email: string | null;
  voiceId: string | null;
};

export type VoiceTurnBody = {
  userName: string;
  messages: ConversationMessage[];
};

export type RagMemory = {
  id: string;
  kind: string;
  content: string;
  source: string;
  salience: number;
  score: number;
  createdAt: Date;
};

export type RagContext = {
  profile: UserProfile | null;
  sleepSummary: string;
  memories: RagMemory[];
};
