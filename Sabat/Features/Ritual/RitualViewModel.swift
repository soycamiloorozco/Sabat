import Combine
import Foundation

enum RitualPhase: String {
    case idle
    case greeting
    case listening
    case processing
    case speaking
    case complete

    var title: String {
        switch self {
        case .idle:
            "Settle in"
        case .greeting:
            "Sabat is speaking"
        case .listening:
            "Sabat is listening"
        case .processing:
            "Holding the moment"
        case .speaking:
            "Rest into the words"
        case .complete:
            "Silence"
        }
    }
}

enum VoiceTone {
    case still
    case listening
    case warm
    case low
}

final class RitualViewModel: ObservableObject {
    @Published
    var phase: RitualPhase = .idle
    @Published
    var messages: [ConversationMessage] = []
    @Published
    var typedTurn = ""
    @Published
    var errorMessage: String?
    @Published
    var isBusy = false
    @Published
    var voiceEnergy = 0.36
    @Published
    var voiceTone: VoiceTone = .still

    private let voiceService: VoiceService
    private let sleepRepository: SleepSessionRepository
    private let commandInterpreter = SleepCommandInterpreter()
    private var hasStarted = false
    private var voiceEnergyTask: Task<Void, Never>?

    init(
        voiceService: VoiceService = VoiceService(),
        sleepRepository: SleepSessionRepository = .shared
    ) {
        self.voiceService = voiceService
        self.sleepRepository = sleepRepository
    }

    func startIfNeeded(userName: String) {
        guard !hasStarted else { return }
        hasStarted = true

        Task {
            phase = .greeting
            voiceTone = .warm
            startVoiceEnergyLoop(tone: .warm)
            await voiceService.speakGreeting(for: userName)
            stopVoiceEnergyLoop(restingEnergy: 0.4)

            let greeting = "Good evening, \(userName). One day at a time. You deserve to rest. What are you carrying into the night?"
            messages.append(ConversationMessage(role: .assistant, content: greeting))
            phase = .listening
            voiceTone = .listening
            voiceEnergy = 0.32
        }
    }

    func listenForTurn(userName: String) {
        guard !isBusy else { return }

        Task {
            isBusy = true
            errorMessage = nil
            phase = .listening
            voiceTone = .listening
            voiceEnergy = 0.42

            do {
                let transcript = try await voiceService.listenForUserTurn()
                if transcript.isEmpty {
                    errorMessage = "Speech capture is scaffolded. Type a short response for now."
                } else {
                    await submit(transcript, userName: userName)
                }
            } catch {
                errorMessage = error.localizedDescription
            }

            isBusy = false
        }
    }

    func submitTypedTurn(userName: String) {
        let text = typedTurn.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isBusy else { return }
        typedTurn = ""

        Task {
            await submit(text, userName: userName)
        }
    }

    private func submit(_ text: String, userName: String) async {
        isBusy = true
        errorMessage = nil
        messages.append(ConversationMessage(role: .user, content: text))

        if let interpretation = commandInterpreter.interpret(text) {
            await sleepRepository.saveAlarm(interpretation.alarm)
            messages.append(ConversationMessage(role: .assistant, content: interpretation.confirmation))
            completeSession(alarm: interpretation.alarm)
            isBusy = false
            return
        }

        phase = .processing
        voiceTone = .still
        voiceEnergy = 0.24

        phase = .speaking
        voiceTone = inferTone(for: text)
        startVoiceEnergyLoop(tone: voiceTone)
        let result = await voiceService.speakTurn(userName: userName, messages: messages)
        stopVoiceEnergyLoop(restingEnergy: 0.38)
        messages.append(ConversationMessage(role: .assistant, content: result.replyText))

        if result.sessionComplete {
            let alarm = await sleepRepository.loadAlarm()
            completeSession(alarm: alarm)
        } else {
            phase = .listening
            voiceTone = .listening
            voiceEnergy = 0.34
        }

        isBusy = false
    }

    private func completeSession(alarm: SleepAlarm?) {
        phase = .complete
        voiceTone = .still
        stopVoiceEnergyLoop(restingEnergy: 0.18)

        let session = SleepSession(
            id: UUID().uuidString,
            startedAt: Date(),
            alarm: alarm
        )

        Task {
            await sleepRepository.saveActiveSession(session)
        }
    }

    private func inferTone(for text: String) -> VoiceTone {
        let lowercased = text.lowercased()
        if lowercased.contains("afraid") || lowercased.contains("fear") || lowercased.contains("anxious") {
            return .low
        }
        if lowercased.contains("tired") || lowercased.contains("sad") || lowercased.contains("heavy") {
            return .warm
        }
        return .warm
    }

    private func startVoiceEnergyLoop(tone: VoiceTone) {
        voiceEnergyTask?.cancel()
        let pattern: [Double]
        switch tone {
        case .still:
            pattern = [0.22, 0.24, 0.2, 0.23]
        case .listening:
            pattern = [0.28, 0.36, 0.31, 0.42, 0.34]
        case .warm:
            pattern = [0.42, 0.7, 0.56, 0.82, 0.48, 0.66]
        case .low:
            pattern = [0.34, 0.52, 0.45, 0.6, 0.38, 0.5]
        }

        voiceEnergyTask = Task { [weak self] in
            var index = 0
            while !Task.isCancelled {
                let value = pattern[index % pattern.count]
                await MainActor.run {
                    self?.voiceEnergy = value
                }
                index += 1
                try? await Task.sleep(nanoseconds: 360_000_000)
            }
        }
    }

    private func stopVoiceEnergyLoop(restingEnergy: Double) {
        voiceEnergyTask?.cancel()
        voiceEnergyTask = nil
        voiceEnergy = restingEnergy
    }
}
