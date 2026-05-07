import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsRequested)
        UserDefaults.standard.set(granted, forKey: UserDefaultsKeys.notificationsEnabled)
        return granted
    }

    func configureSabatReminders(
        includeDaytimePauses: Bool,
        nightlyReminderDate: Date
    ) async {
        center.removePendingNotificationRequests(withIdentifiers: ReminderIdentifier.all)

        if includeDaytimePauses {
            for reminder in DaytimePauseReminder.defaults {
                await scheduleDaytimePause(reminder)
            }
        }

        await scheduleNightlyReminder(at: nightlyReminderDate)
    }

    func cancelDaytimePauses() {
        center.removePendingNotificationRequests(
            withIdentifiers: DaytimePauseReminder.defaults.map(\.identifier)
        )
    }

    private func scheduleDaytimePause(_ reminder: DaytimePauseReminder) async {
        var dateComponents = DateComponents()
        dateComponents.hour = reminder.hour
        dateComponents.minute = reminder.minute

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private func scheduleNightlyReminder(at date: Date) async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        let content = UNMutableNotificationContent()
        content.title = "Sabat is waiting."
        content.body = "One day at a time. You deserve to rest."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: ReminderIdentifier.nightly,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }
}

private enum ReminderIdentifier {
    static let morningPause = "sabat.pause.morning"
    static let afternoonPause = "sabat.pause.afternoon"
    static let eveningPause = "sabat.pause.evening"
    static let nightly = "sabat.reminder.nightly"

    static let all = [
        morningPause,
        afternoonPause,
        eveningPause,
        nightly
    ]
}

private struct DaytimePauseReminder {
    let identifier: String
    let hour: Int
    let minute: Int
    let title: String
    let body: String

    static let defaults = [
        DaytimePauseReminder(
            identifier: ReminderIdentifier.morningPause,
            hour: 10,
            minute: 30,
            title: "Pause for a breath.",
            body: "One day at a time. You deserve to rest."
        ),
        DaytimePauseReminder(
            identifier: ReminderIdentifier.afternoonPause,
            hour: 14,
            minute: 30,
            title: "Come back to yourself.",
            body: "Put one hand on your chest. Breathe slowly. You deserve to rest."
        ),
        DaytimePauseReminder(
            identifier: ReminderIdentifier.eveningPause,
            hour: 18,
            minute: 0,
            title: "Let the day loosen.",
            body: "You do not have to carry everything into the night."
        )
    ]
}
