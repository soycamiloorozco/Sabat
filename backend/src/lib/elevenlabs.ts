export async function* streamElevenLabsTTS(text: string): AsyncIterable<Uint8Array> {
  const apiKey = process.env.ELEVENLABS_API_KEY;
  const voiceId = process.env.ELEVENLABS_VOICE_ID;

  if (!apiKey || !voiceId) {
    throw new Error("ElevenLabs credentials are not configured");
  }

  const response = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}/stream?optimize_streaming_latency=4&output_format=mp3_44100_128`,
    {
      method: "POST",
      headers: {
        "xi-api-key": apiKey,
        "Content-Type": "application/json",
        Accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text,
        model_id: "eleven_turbo_v2_5",
        voice_settings: {
          stability: 0.56,
          similarity_boost: 0.82,
          style: 0.24,
          use_speaker_boost: true,
        },
      }),
    },
  );

  if (!response.ok || !response.body) {
    throw new Error(`ElevenLabs stream failed with status ${response.status}`);
  }

  for await (const chunk of response.body as unknown as AsyncIterable<Uint8Array>) {
    yield chunk;
  }
}
