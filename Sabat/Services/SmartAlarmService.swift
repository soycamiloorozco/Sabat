import Foundation
import UserNotifications

actor SmartAlarmService {
    private let center = UNUserNotificationCenter.current()
    private var alarm: SleepAlarm?

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func configure(_ alarm: SleepAlarm) async throws {
        self.alarm = alarm
        try await scheduleGuaranteeAlarm(for: alarm)
    }

    func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        alarm = nil
    }

    func shouldFireAlarm(currentPhase: SleepPhase, now: Date = Date()) -> Bool {
        guard let alarm, alarm.isEnabled else {
            return false
        }

        let windowStart = alarm.targetWakeTime.addingTimeInterval(TimeInterval(-alarm.windowMinutes * 60))
        let inWindow = now >= windowStart && now <= alarm.targetWakeTime
        return inWindow && (currentPhase == .awake || currentPhase == .light)
    }

    func fireEarlyAlarmIfNeeded(currentPhase: SleepPhase, now: Date = Date()) async throws -> Bool {
        guard shouldFireAlarm(currentPhase: currentPhase, now: now), let alarm else {
            return false
        }

        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        try await scheduleImmediateAlarm(for: alarm)
        return true
    }

    private func scheduleGuaranteeAlarm(for alarm: SleepAlarm) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: alarm.targetWakeTime
        )

        let content = UNMutableNotificationContent()
        content.title = "Wake up"
        content.body = wakeWindowBody(for: alarm)
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        try await center.add(request)
    }

    private func scheduleImmediateAlarm(for alarm: SleepAlarm) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Gentle wake-up"
        content.body = wakeWindowBody(for: alarm)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        try await center.add(request)
    }

    private func wakeWindowBody(for alarm: SleepAlarm) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        let start = alarm.targetWakeTime.addingTimeInterval(TimeInterval(-alarm.windowMinutes * 60))
        return "Wake up easy between \(formatter.string(from: start)) and \(formatter.string(from: alarm.targetWakeTime))."
    }

    private var notificationIdentifier: String {
        "app.sabat.smart-alarm"
    }
}
