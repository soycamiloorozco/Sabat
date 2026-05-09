import SwiftUI
import UserNotifications

struct NotificationsPermissionView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var isRequesting = false
    @State private var statusText = "Sabat can visit during the day with one gentle breath. One day at a time. You deserve to rest."
    private let notificationService = NotificationService.shared

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                OnboardingProgressView(current: 5, total: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.lg)

                notificationGlyph

                VStack(spacing: SabatSpacing.md) {
                    Text("Let Sabat find you in the day")
                        .font(.sabatDisplay(42))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text(statusText)
                        .font(.sabatSans(17))
                        .foregroundStyle(Color.sabatMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Spacer()

                VStack(spacing: SabatSpacing.md) {
                    GoldButton(title: isRequesting ? "Requesting" : "Allow pauses") {
                        requestNotifications()
                    }
                    .disabled(isRequesting)

                    Button {
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsRequested)
                        router.navigate(to: .onboardingComplete)
                    } label: {
                        Text("Not now")
                            .font(.sabatMono(13, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.sabatMist)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                    }
                    .buttonStyle(PillSecondaryButtonStyle())
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
    }

    private var notificationGlyph: some View {
        ZStack {
            MoonPresenceView(size: 132, intensity: 0.58)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.sabatInk)
                .frame(width: 72, height: 72)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.white.opacity(0.18), radius: 18)
                .offset(y: 72)
        }
        .frame(height: 250)
        .accessibilityHidden(true)
    }

    private func requestNotifications() {
        guard !isRequesting else { return }
        isRequesting = true

        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsRequested)
                UserDefaults.standard.set(granted, forKey: UserDefaultsKeys.notificationsEnabled)
                UserDefaults.standard.set(granted, forKey: UserDefaultsKeys.daytimePauseRemindersEnabled)
                if granted {
                    let nightlyDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.nightlyReminderTime) as? Date
                        ?? Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())
                        ?? Date()
                    await notificationService.configureSabatReminders(
                        includeDaytimePauses: true,
                        nightlyReminderDate: nightlyDate
                    )
                }
                await MainActor.run {
                    isRequesting = false
                    router.navigate(to: .onboardingComplete)
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    statusText = "Notifications can be enabled later from Profile."
                }
            }
        }
    }
}

struct NotificationsPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsPermissionView()
            .environmentObject(AppRouter())
    }
}
