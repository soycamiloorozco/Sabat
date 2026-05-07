import AVFoundation
import CoreMotion
import Foundation

enum NightTrackerState: String, Sendable {
    case idle
    case detecting
    case confirmed
    case tracking
    case interrupted
}

actor NightTrackerService {
    private let motionManager = CMMotionManager()
    private var audioPlayer: AVAudioPlayer?
    private var state: NightTrackerState = .idle
    private var sessionID: String?
    private var startedAt: Date?
    private var currentPhase: SleepPhase = .light
    private var phaseStartDate: Date?
    private var phaseSamples: [SleepPhaseSample] = []

    func start(sessionID: String, startedAt: Date) async throws {
        state = .detecting
        self.sessionID = sessionID
        self.startedAt = startedAt
        currentPhase = .light
        phaseStartDate = startedAt
        phaseSamples = []

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)

        motionManager.accelerometerUpdateInterval = 0.2
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
        }

        state = .tracking
    }

    func refreshPhase(now: Date = Date()) -> SleepPhase {
        guard state == .tracking else {
            return currentPhase
        }

        let nextPhase = inferPhase()
        if nextPhase != currentPhase {
            closeCurrentPhase(at: now)
            currentPhase = nextPhase
            phaseStartDate = now
        }

        return currentPhase
    }

    func stop(alarm: SleepAlarm?) -> SleepSession {
        let endedAt = Date()
        closeCurrentPhase(at: endedAt)
        motionManager.stopAccelerometerUpdates()
        audioPlayer?.stop()
        audioPlayer = nil
        state = .idle

        let session = SleepSession(
            id: sessionID ?? UUID().uuidString,
            startedAt: startedAt ?? endedAt,
            endedAt: endedAt,
            restScore: calculateRestScore(),
            alarm: alarm,
            phaseSamples: phaseSamples,
            syncedAt: nil
        )

        sessionID = nil
        startedAt = nil
        phaseStartDate = nil
        phaseSamples = []
        currentPhase = .light
        return session
    }

    func currentState() -> NightTrackerState {
        state
    }

    func currentSleepPhase() -> SleepPhase {
        currentPhase
    }

    private func inferPhase() -> SleepPhase {
        guard let data = motionManager.accelerometerData else {
            return fallbackPhase()
        }

        let magnitude = abs(data.acceleration.x) + abs(data.acceleration.y) + abs(data.acceleration.z)
        switch magnitude {
        case 1.75...:
            return SleepPhase.awake
        case 1.35..<1.75:
            return SleepPhase.light
        case 1.1..<1.35:
            return SleepPhase.rem
        default:
            return SleepPhase.deep
        }
    }

    private func fallbackPhase() -> SleepPhase {
        switch currentPhase {
        case .awake:
            .light
        case .light:
            .deep
        case .deep:
            .rem
        case .rem:
            .light
        }
    }

    private func closeCurrentPhase(at date: Date) {
        guard let phaseStartDate, date > phaseStartDate else {
            return
        }

        phaseSamples.append(
            SleepPhaseSample(
                phase: currentPhase,
                startDate: phaseStartDate,
                endDate: date
            )
        )
    }

    private func calculateRestScore() -> Int {
        let deepMinutes = phaseSamples.minutes(for: .deep)
        let remMinutes = phaseSamples.minutes(for: .rem)
        let awakeMinutes = phaseSamples.minutes(for: .awake)
        let rawScore = 55 + min(deepMinutes / 2, 25) + min(remMinutes / 3, 15) - min(awakeMinutes, 20)
        return max(0, min(100, rawScore))
    }
}

private extension Array where Element == SleepPhaseSample {
    func minutes(for phase: SleepPhase) -> Int {
        Int(
            filter { $0.phase == phase }
                .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } / 60
        )
    }
}
