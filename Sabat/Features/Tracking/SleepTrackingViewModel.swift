import Combine
import Foundation

enum SleepTrackingPhase: String {
    case detecting
    case confirmed
    case tracking
    case alarm
}

final class SleepTrackingViewModel: ObservableObject {
    @Published
    var phase: SleepTrackingPhase = .detecting
    @Published
    var errorMessage: String?
    @Published
    var configuredWakeTime = Date().addingTimeInterval(8 * 60 * 60)
    @Published
    var wakeWindowMinutes = 30
    @Published
    var currentSleepPhase: SleepPhase = .light

    private let tracker: NightTrackerService
    private let alarmService: SmartAlarmService
    private let sleepRepository: SleepSessionRepository
    private var monitorTask: Task<Void, Never>?
    private var activeSession: SleepSession?

    init(
        tracker: NightTrackerService = NightTrackerService(),
        alarmService: SmartAlarmService = SmartAlarmService(),
        sleepRepository: SleepSessionRepository = .shared
    ) {
        self.tracker = tracker
        self.alarmService = alarmService
        self.sleepRepository = sleepRepository
    }

    func start() {
        guard monitorTask == nil else { return }

        Task {
            do {
                let session = await prepareSession()
                activeSession = session
                configuredWakeTime = session.alarm?.targetWakeTime ?? configuredWakeTime
                wakeWindowMinutes = session.alarm?.windowMinutes ?? wakeWindowMinutes

                try? await sleepRepository.requestHealthAuthorization()
                _ = try? await alarmService.requestAuthorization()
                try await tracker.start(sessionID: session.id, startedAt: session.startedAt)

                if let alarm = session.alarm {
                    try? await alarmService.configure(alarm)
                }

                phase = .tracking
                monitorTask = startMonitoring()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateWakeTime(_ wakeTime: Date) {
        configuredWakeTime = wakeTime

        Task {
            guard var session = activeSession else { return }
            let alarm = SleepAlarm(
                targetWakeTime: wakeTime,
                windowMinutes: wakeWindowMinutes,
                source: session.alarm?.source ?? .user,
                isEnabled: true
            )
            session.alarm = alarm
            activeSession = session
            await sleepRepository.saveAlarm(alarm)
            await sleepRepository.saveActiveSession(session)
            try? await alarmService.configure(alarm)
        }
    }

    func stop() {
        monitorTask?.cancel()
        monitorTask = nil

        Task {
            let session = await tracker.stop(alarm: activeSession?.alarm)
            do {
                _ = try await sleepRepository.finish(session: session)
            } catch {
                errorMessage = "Saved locally. Server sync will retry later."
            }
        }
    }

    private func prepareSession() async -> SleepSession {
        if let stored = await sleepRepository.loadActiveSession() {
            return stored
        }

        let alarm = await sleepRepository.loadAlarm() ?? SleepAlarm(
            targetWakeTime: configuredWakeTime,
            windowMinutes: wakeWindowMinutes,
            source: .user,
            isEnabled: true
        )
        let session = SleepSession(id: UUID().uuidString, startedAt: Date(), alarm: alarm)
        await sleepRepository.saveAlarm(alarm)
        await sleepRepository.saveActiveSession(session)
        return session
    }

    private func startMonitoring() -> Task<Void, Never> {
        Task {
            while !Task.isCancelled {
                let detectedPhase = await tracker.refreshPhase()
                await MainActor.run {
                    self.currentSleepPhase = detectedPhase
                }

                if let activeSession, activeSession.alarm != nil {
                    let fired = try? await alarmService.fireEarlyAlarmIfNeeded(currentPhase: detectedPhase)
                    if fired == true {
                        await MainActor.run {
                            self.phase = .alarm
                        }
                    }
                }

                try? await Task.sleep(nanoseconds: 60_000_000_000)
            }
        }
    }
}
