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
        case .calm: "Calm"
        case .deep: "Deep"
        case .near: "Near"
        }
    }
}

enum AlarmSound: String, CaseIterable, Identifiable {
    case gong
    case forest
    case midnight
    case dawn

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gong: "Sacred Gong"
        case .forest: "Old Forest"
        case .midnight: "Midnight Mist"
        case .dawn: "Solar Dawn"
        }
    }
}

enum SleepDetectionMethod: String, CaseIterable, Identifiable {
    case accelerometer
    case microphone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .accelerometer: "Accelerometer"
        case .microphone: "Microphone & Ambient"
        }
    }
}

final class ProfileViewModel: ObservableObject {
    @Published var preferredName: String
    @Published var notificationsEnabled: Bool
    @Published var daytimePauseRemindersEnabled: Bool
    @Published var voicePresence: VoicePresence
    @Published var alarmSound: AlarmSound
    @Published var detectionMethod: SleepDetectionMethod
    @Published var alarmDays: Set<Int>
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
        alarmSound = AlarmSound(
            rawValue: UserDefaults.standard.string(forKey: "app.sabat.alarm.sound") ?? AlarmSound.gong.rawValue
        ) ?? .gong
        detectionMethod = SleepDetectionMethod(
            rawValue: UserDefaults.standard.string(forKey: "app.sabat.detection.method") ?? SleepDetectionMethod.accelerometer.rawValue
        ) ?? .accelerometer
        
        let savedDays = UserDefaults.standard.array(forKey: "app.sabat.alarm.days") as? [Int] ?? [1, 2, 3, 4, 5, 6, 7]
        alarmDays = Set(savedDays)

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
        UserDefaults.standard.set(alarmSound.rawValue, forKey: "app.sabat.alarm.sound")
        UserDefaults.standard.set(detectionMethod.rawValue, forKey: "app.sabat.detection.method")
        UserDefaults.standard.set(Array(alarmDays), forKey: "app.sabat.alarm.days")
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
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                if self.statusMessage == L10n.profileUpdated {
                    self.statusMessage = nil
                }
            }
        }
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
