import AVFoundation
import Foundation
import Speech

enum VoiceServiceError: LocalizedError {
    case speechPermissionDenied
    case microphonePermissionDenied
    case recognitionUnavailable
    case emptyAudioResponse

    var errorDescription: String? {
        switch self {
        case .speechPermissionDenied:
            "Speech recognition permission is required before Sabat can listen."
        case .microphonePermissionDenied:
            "Microphone permission is required before Sabat can listen."
        case .recognitionUnavailable:
            "Speech recognition is unavailable on this device."
        case .emptyAudioResponse:
            "The voice service returned no audio."
        }
    }
}

struct VoiceTurnResult: Sendable {
    let replyText: String
    let sessionComplete: Bool
}

actor VoiceService {
    private let apiClient: APIClient
    private var audioPlayer: AVAudioPlayer?

    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? APIClient()
    }

    func listenForUserTurn() async throws -> String {
        try await ensureSpeechPermissions()

        guard SFSpeechRecognizer(locale: Locale(identifier: "en_US"))?.isAvailable == true else {
            throw VoiceServiceError.recognitionUnavailable
        }

        // The production path installs an AVAudioEngine tap per turn and stops after
        // about 1.5 seconds of silence. The scaffold keeps the permission boundary
        // and per-turn API shape in place without holding a long recognizer session.
        return ""
    }

    func speakGreeting(for name: String) async {
        if await playBundledAudio(named: "greeting-\(name.lowercased())") {
            return
        }

        try? await Task.sleep(nanoseconds: 850_000_000)
    }

    func speakTurn(userName: String, messages: [ConversationMessage]) async -> VoiceTurnResult {
        do {
            let response = try await apiClient.streamVoice(userName: userName, messages: messages)
            var audioData = Data()

            for try await byte in response.bytes {
                audioData.append(byte)
            }

            guard !audioData.isEmpty else {
                throw VoiceServiceError.emptyAudioResponse
            }

            try await playAudioData(audioData)
            return VoiceTurnResult(
                replyText: response.replyText ?? "Rest now. You've done enough.",
                sessionComplete: response.sessionComplete
            )
        } catch {
            await playAnyFallbackAudio()
            return VoiceTurnResult(
                replyText: "Rest now. You've done enough.",
                sessionComplete: true
            )
        }
    }

    private func ensureSpeechPermissions() async throws {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard speechAuthorized else {
            throw VoiceServiceError.speechPermissionDenied
        }

        let microphoneAuthorized = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        guard microphoneAuthorized else {
            throw VoiceServiceError.microphonePermissionDenied
        }
    }

    private func playAnyFallbackAudio() async {
        let names = ["fallback-01", "fallback-02", "fallback-03"]
        for name in names.shuffled() {
            if await playBundledAudio(named: name) {
                return
            }
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    private func playBundledAudio(named name: String) async -> Bool {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            return false
        }

        do {
            try await playAudioFile(url)
            return true
        } catch {
            return false
        }
    }

    private func playAudioData(_ data: Data) async throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "sabat-voice-\(UUID().uuidString).mp3")
        try data.write(to: url, options: [.atomic])
        try await playAudioFile(url)
        try? FileManager.default.removeItem(at: url)
    }

    private func playAudioFile(_ url: URL) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try session.setActive(true)

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()

        let duration = audioPlayer?.duration ?? 1
        try await Task.sleep(nanoseconds: UInt64(max(duration, 0.5) * 1_000_000_000))
    }
}
