import Combine
import Foundation
import UserNotifications

enum VoicePresence: String, CaseIterable, Identifiable {
    case calm
    case deep
    case near

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm:
            "Calm"
        case .deep:
            "Deep"
        case .near:
            "Near"
        }
    }
}

final class ProfileViewModel: ObservableObject {
    @Published var preferredName: String
    @Published var notificationsEnabled: Bool
    @Published var daytimePauseRemindersEnabled: Bool
    @Published var voicePresence: VoicePresence
    @Published var reminderDate: Date
    @Published var alarmWindowMinutes: Int
    @Published var statusMessage: String?
    private let notificationService = NotificationService.shared

    init() {
        preferredName = UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredName) ?? "Friend"
        notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        daytimePauseRemindersEnabled = UserDefaults.standard.bool(
            forKey: UserDefaultsKeys.daytimePauseRemindersEnabled
        )
        voicePresence = VoicePresence(
            rawValue: UserDefaults.standard.string(forKey: UserDefaultsKeys.voicePresence) ?? VoicePresence.calm.rawValue
        ) ?? .calm

        if let storedDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.nightlyReminderTime) as? Date {
            reminderDate = storedDate
        } else {
            reminderDate = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        }

        alarmWindowMinutes = UserDefaults.standard.integer(forKey: UserDefaultsKeys.smartAlarmWindowMinutes)
        if alarmWindowMinutes == 0 {
            alarmWindowMinutes = 30
        }
    }

    func save() {
        let trimmedName = preferredName.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmedName.isEmpty ? "Friend" : trimmedName, forKey: UserDefaultsKeys.preferredName)
        UserDefaults.standard.set(voicePresence.rawValue, forKey: UserDefaultsKeys.voicePresence)
        UserDefaults.standard.set(reminderDate, forKey: UserDefaultsKeys.nightlyReminderTime)
        UserDefaults.standard.set(alarmWindowMinutes, forKey: UserDefaultsKeys.smartAlarmWindowMinutes)
        UserDefaults.standard.set(
            daytimePauseRemindersEnabled,
            forKey: UserDefaultsKeys.daytimePauseRemindersEnabled
        )
        Task {
            await notificationService.configureSabatReminders(
                includeDaytimePauses: notificationsEnabled && daytimePauseRemindersEnabled,
                nightlyReminderDate: reminderDate
            )
        }
        statusMessage = L10n.profileUpdated
    }

    func setNotifications(_ isEnabled: Bool) {
        if isEnabled {
            requestNotifications()
        } else {
            notificationsEnabled = false
            daytimePauseRemindersEnabled = false
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.notificationsEnabled)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.daytimePauseRemindersEnabled)
            Task {
                await notificationService.configureSabatReminders(
                    includeDaytimePauses: false,
                    nightlyReminderDate: reminderDate
                )
            }
            statusMessage = L10n.notificationsNotEnabled
        }
    }

    func setDaytimePauseReminders(_ isEnabled: Bool) {
        daytimePauseRemindersEnabled = isEnabled
        UserDefaults.standard.set(isEnabled, forKey: UserDefaultsKeys.daytimePauseRemindersEnabled)

        if isEnabled && !notificationsEnabled {
            requestNotifications()
            return
        }

        Task {
            if isEnabled {
                await notificationService.configureSabatReminders(
                    includeDaytimePauses: true,
                    nightlyReminderDate: reminderDate
                )
                await MainActor.run {
                    statusMessage = L10n.remindersOn
                }
            } else {
                await notificationService.configureSabatReminders(
                    includeDaytimePauses: false,
                    nightlyReminderDate: reminderDate
                )
                await MainActor.run {
                    statusMessage = L10n.notificationsNotEnabled
                }
            }
        }
    }

    private func requestNotifications() {
        Task {
            do {
                let granted = try await notificationService.requestAuthorization()
                await MainActor.run {
                    notificationsEnabled = granted
                    if granted {
                        daytimePauseRemindersEnabled = true
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.daytimePauseRemindersEnabled)
                    }
                    statusMessage = granted ? L10n.remindersOn : L10n.notificationsNotEnabled
                }

                if granted {
                    await notificationService.configureSabatReminders(
                        includeDaytimePauses: true,
                        nightlyReminderDate: reminderDate
                    )
                }
            } catch {
                await MainActor.run {
                    notificationsEnabled = false
                    statusMessage = L10n.notificationsLater
                }
            }
        }
    }
}
