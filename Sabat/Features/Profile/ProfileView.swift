import Combine
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var tabController: AppTabController
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SabatSpacing.xl) {
                    tabHeader

                    languageSection

                    accountSection

                    identitySection

                    voiceSection

                    remindersSection

                    sleepSection

                    planSection

                    if let statusMessage = viewModel.statusMessage {
                        Text(statusMessage)
                            .font(.sabatSans(13))
                            .foregroundStyle(Color.sabatMuted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .transition(.opacity)
                    }

                    GoldButton(title: L10n.saveProfile) {
                        HapticEngine.success()
                        viewModel.save()
                    }
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.top, SabatSpacing.xl)
                .padding(.bottom, 120)
            }
        }
    }

    private var tabHeader: some View {
        VStack(alignment: .leading, spacing: SabatSpacing.sm) {
            Text(L10n.settings)
                .font(.sabatSans(15, weight: .medium))
                .foregroundStyle(Color.sabatMuted)

            Text(L10n.tuneSabat)
                .font(.sabatDisplay(36))
                .foregroundStyle(Color.sabatGold2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var languageSection: some View {
        ProfileSection(title: L10n.language, subtitle: L10n.chooseLanguage) {
            HStack(spacing: SabatSpacing.sm) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        HapticEngine.softTap()
                        localization.setLanguage(language)
                    } label: {
                        Text(language.displayName)
                            .font(.sabatMono(12, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(localization.currentLanguage == language ? Color.sabatInk : Color.sabatMist)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(localization.currentLanguage == language ? Color.white : Color.sabatPaper.opacity(0.055))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PillSecondaryButtonStyle())
                }
            }
        }
    }

    private var accountSection: some View {
        ProfileSection(title: L10n.account, subtitle: L10n.signInToSync) {
            VStack(spacing: SabatSpacing.md) {
                Button {
                    HapticEngine.softTap()
                    tabController.showLogin = true
                } label: {
                    HStack {
                        Text(L10n.signIn)
                            .font(.sabatSans(15, weight: .semibold))
                            .foregroundStyle(Color.sabatMist)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sabatMuted)
                    }
                    .frame(height: 44)
                }

                Button {
                    HapticEngine.softTap()
                    tabController.showRegister = true
                } label: {
                    HStack {
                        Text(L10n.createAccount)
                            .font(.sabatSans(15, weight: .semibold))
                            .foregroundStyle(Color.sabatDawn)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sabatMuted)
                    }
                    .frame(height: 44)
                }
            }
        }
    }

    private var planSection: some View {
        ProfileSection(title: L10n.plan, subtitle: L10n.yourSubscription) {
            VStack(spacing: SabatSpacing.md) {
                Button {
                    HapticEngine.softTap()
                    tabController.showMyPlan = true
                } label: {
                    HStack {
                        Text(L10n.myPlan)
                            .font(.sabatSans(15, weight: .semibold))
                            .foregroundStyle(Color.sabatMist)

                        Spacer()

                        Text(L10n.free)
                            .font(.sabatMono(13, weight: .semibold))
                            .foregroundStyle(Color.sabatMuted)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sabatMuted)
                    }
                    .frame(height: 44)
                }

                Button {
                    HapticEngine.softTap()
                    tabController.showSubscription = true
                } label: {
                    HStack {
                        Text(L10n.upgrade)
                            .font(.sabatSans(15, weight: .semibold))
                            .foregroundStyle(Color.sabatDawn)

                        Spacer()

                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sabatDawn)
                    }
                    .frame(height: 44)
                }
            }
        }
    }

    private var identitySection: some View {
        ProfileSection(title: L10n.identity, subtitle: L10n.howSabatGreets) {
            TextField(L10n.preferredNamePlaceholder, text: $viewModel.preferredName)
                .font(.sabatSerif(22))
                .foregroundStyle(Color.sabatMist)
                .padding(.horizontal, SabatSpacing.lg)
                .frame(height: 48)
                .background(Color.sabatPaper.opacity(0.055))
                .overlay {
                    Capsule()
                        .stroke(Color.sabatLine, lineWidth: 1)
                }
                .clipShape(Capsule())
        }
    }

    private var voiceSection: some View {
        ProfileSection(title: L10n.voice, subtitle: L10n.presenceAndPersonality) {
            HStack(spacing: SabatSpacing.sm) {
                ForEach(VoicePresence.allCases) { presence in
                    Button {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
                            viewModel.voicePresence = presence
                        }
                    } label: {
                        Text(presence.title)
                            .font(.sabatMono(12, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(viewModel.voicePresence == presence ? Color.sabatInk : Color.sabatMist)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.voicePresence == presence ? Color.white : Color.sabatPaper.opacity(0.055))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PillSecondaryButtonStyle())
                }
            }

            Text(L10n.voiceDescription)
                .font(.sabatSans(13))
                .foregroundStyle(Color.sabatMuted)
                .lineSpacing(4)
        }
    }

    private var remindersSection: some View {
        ProfileSection(title: L10n.reminders, subtitle: L10n.smallPauses) {
            Toggle(isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.setNotifications($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.sabatReminders)
                        .font(.sabatSans(16, weight: .semibold))
                        .foregroundStyle(Color.sabatMist)
                    Text(L10n.remindersDescription)
                        .font(.sabatSans(12))
                        .foregroundStyle(Color.sabatMuted)
                }
            }
            .tint(Color.white)

            Toggle(isOn: Binding(
                get: { viewModel.daytimePauseRemindersEnabled },
                set: { viewModel.setDaytimePauseReminders($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.daytimePauses)
                        .font(.sabatSans(16, weight: .semibold))
                        .foregroundStyle(Color.sabatMist)
                    Text(L10n.daytimeDescription)
                        .font(.sabatSans(12))
                        .foregroundStyle(Color.sabatMuted)
                }
            }
            .tint(Color.white)

            DatePicker(L10n.reminderTime, selection: $viewModel.reminderDate, displayedComponents: .hourAndMinute)
                .font(.sabatSans(15))
                .foregroundStyle(Color.sabatMist)
                .tint(Color.white)
        }
    }

    private var sleepSection: some View {
        ProfileSection(title: L10n.sleep, subtitle: L10n.wakeUpSettings) {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                HStack {
                    Text(L10n.smartAlarmWindow)
                        .font(.sabatSans(15, weight: .semibold))
                        .foregroundStyle(Color.sabatMist)
                    Spacer()
                    Text("\(viewModel.alarmWindowMinutes)m")
                        .font(.sabatMono(13, weight: .semibold))
                        .foregroundStyle(Color.sabatMist)
                }

                Slider(
                    value: Binding(
                        get: { Double(viewModel.alarmWindowMinutes) },
                        set: { viewModel.alarmWindowMinutes = Int($0) }
                    ),
                    in: 10...45,
                    step: 5
                )
                .tint(Color.white)

                Text(L10n.windowDescription)
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatMuted)
                    .lineSpacing(4)
            }
        }
    }
}

private struct ProfileSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SabatSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.sabatMono(12, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.sabatMist)
                    .tracking(1.4)

                Text(subtitle)
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatMuted)
            }

            content
        }
        .padding(SabatSpacing.lg)
        .background(Color.sabatPaper.opacity(0.045))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.sabatLine, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
