import Combine
import Foundation

final class SmartAlarmViewModel: ObservableObject {
    @Published
    var wakeTime = Date().addingTimeInterval(8 * 60 * 60)
    @Published
    var windowMinutes = 30
    @Published
    var isSmartAlarmEnabled = true
    @Published
    var isAlarmActive = false
    @Published
    var detectedPhase: SleepPhase = .light
    @Published
    var formattedWakeTime = "7:00 AM"
    @Published
    var phaseExplanation = "Monitoring movement to detect your current sleep phase."

    private let alarmService: SmartAlarmService
    private let sleepRepository: SleepSessionRepository
    private let tracker: NightTrackerService
    private var phaseMonitorTask: Task<Void, Never>?

    init(
        alarmService: SmartAlarmService = SmartAlarmService(),
        sleepRepository: SleepSessionRepository = .shared,
        tracker: NightTrackerService = NightTrackerService()
    ) {
        self.alarmService = alarmService
        self.sleepRepository = sleepRepository
        self.tracker = tracker
        updateFormattedTime()
        updatePhaseExplanation()
    }

    func load() {
        Task {
            if let alarm = await sleepRepository.loadAlarm() {
                await MainActor.run {
                    self.wakeTime = alarm.targetWakeTime
                    self.windowMinutes = alarm.windowMinutes
                    self.isSmartAlarmEnabled = alarm.isEnabled
                    self.isAlarmActive = alarm.isEnabled
                    self.updateFormattedTime()
                }
            }
        }

        startPhaseMonitoring()
    }

    func updateWakeTime(_ newValue: Date) {
        wakeTime = newValue
        updateFormattedTime()
    }

    func updateWindow() {
        // Triggered by slider; save happens on "Set alarm"
    }

    func updateAlarmSettings() {
        // Triggered by toggle; save happens on "Set alarm"
    }

    func saveAlarm() {
        let alarm = SleepAlarm(
            targetWakeTime: wakeTime,
            windowMinutes: windowMinutes,
            source: .user,
            isEnabled: isSmartAlarmEnabled
        )

        Task {
            await sleepRepository.saveAlarm(alarm)
            if isSmartAlarmEnabled {
                try? await alarmService.configure(alarm)
            } else {
                await alarmService.cancel()
            }
            await MainActor.run {
                self.isAlarmActive = isSmartAlarmEnabled
            }
        }
    }

    func cancelAlarm() {
        Task {
            await alarmService.cancel()
            await sleepRepository.saveAlarm(nil)
            await MainActor.run {
                self.isAlarmActive = false
                self.isSmartAlarmEnabled = false
            }
        }
    }

    // MARK: - Phase Monitoring (Simulation / Real)

    private func startPhaseMonitoring() {
        phaseMonitorTask?.cancel()
        phaseMonitorTask = Task {
            while !Task.isCancelled {
                let phase = await tracker.currentSleepPhase()
                await MainActor.run {
                    self.detectedPhase = phase
                    self.updatePhaseExplanation()
                }
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5s refresh for UI
            }
        }
    }

    private func updateFormattedTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formattedWakeTime = formatter.string(from: wakeTime)
    }

    private func updatePhaseExplanation() {
        switch detectedPhase {
        case .awake:
            phaseExplanation = "You are awake. High movement detected. Alarm can fire now."
        case .light:
            phaseExplanation = "Light sleep phase. Occasional movement. Optimal wake window."
        case .deep:
            phaseExplanation = "Deep sleep phase. Minimal movement. Body is restoring."
        case .rem:
            phaseExplanation = "REM phase. Muscle atonia (paralysis). Dreaming occurs."
        }
    }
}
