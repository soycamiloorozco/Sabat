import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var tabController: AppTabController
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var subscription = SubscriptionManager.shared
    @StateObject private var pauseService = DaytimePauseService.shared

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView {
                VStack(spacing: SabatSpacing.xl) {
                    greetingHeader

                    if let recommendation = pauseService.activeRecommendation {
                        daytimePausePanel(recommendation)
                    }

                    tonightPanel

                    smartAlarmPanel

                    if let session = viewModel.lastSession {
                        lastSessionPanel(session)
                    } else {
                        firstNightPanel
                    }
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.top, SabatSpacing.xl)
                .padding(.bottom, SabatSpacing.xxl)
            }
            .refreshable {
                viewModel.load()
                await pauseService.checkPulse()
            }
            .tint(Color.sabatDawn)
        }
        .task {
            viewModel.load()
            await pauseService.checkPulse()
        }
    }

    private func daytimePausePanel(_ recommendation: PauseRecommendation) -> some View {
        SacredCard {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                HStack {
                    Image(systemName: "lungs.fill")
                        .foregroundStyle(Color.sabatDawn)
                    Text("Daytime Pause")
                        .font(.sabatSans(14, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                    Spacer()
                    
                    Button {
                        withAnimation {
                            pauseService.activeRecommendation = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.sabatMuted)
                    }
                }

                Text(recommendation.title)
                    .font(.sabatDisplay(28))
                    .foregroundStyle(Color.sabatGold2)

                Text(recommendation.body)
                    .font(.sabatSerif(18))
                    .foregroundStyle(Color.sabatMist)
                    .fixedSize(horizontal: false, vertical: true)

                GoldButton(title: "Take a breath", systemImage: "wind") {
                    HapticEngine.confirm()
                    tabController.showRitual = true
                }
                .padding(.top, 4)
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var greetingHeader: some View {
        VStack(spacing: SabatSpacing.md) {
            Text("Good evening,")
                .font(.sabatSans(15, weight: .medium))
                .foregroundStyle(Color.sabatMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.preferredName)
                .font(.sabatDisplay(48))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Begin the last conversation of the day.")
                .font(.sabatSerif(24))
                .foregroundStyle(Color.sabatMist)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var smartAlarmPanel: some View {
        SacredCard {
            VStack(alignment: .center, spacing: SabatSpacing.lg) {
                HStack {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(Color.sabatDawn)
                    Text("Smart Alarm")
                        .font(.sabatSans(15, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                    Spacer()
                }

                Text("Wake up gently during your lightest sleep phase.")
                    .font(.sabatSerif(26))
                    .foregroundStyle(Color.sabatMist)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    HapticEngine.softTap()
                    tabController.showSmartAlarm = true
                } label: {
                    HStack(spacing: SabatSpacing.sm) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Configure alarm")
                            .font(.sabatMono(14, weight: .semibold))
                            .textCase(.uppercase)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundStyle(Color.sabatInk)
                    .background(Color.sabatDawn)
                    .clipShape(Capsule())
                }
                .buttonStyle(PillSecondaryButtonStyle())
            }
        }
    }

    private var tonightPanel: some View {
        SacredCard {
            VStack(alignment: .center, spacing: SabatSpacing.lg) {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundStyle(Color.sabatGold2)
                    Text("Tonight")
                        .font(.sabatSans(15, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                    Spacer()
                }

                if subscription.isPremium {
                    Text("A 2 to 5 minute wind-down, then silence.")
                        .font(.sabatSerif(32))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    GoldButton(title: "Begin ritual", systemImage: "waveform") {
                        HapticEngine.confirm()
                        tabController.showRitual = true
                    }
                } else {
                    Text("Silence immediately. No companion.")
                        .font(.sabatSerif(32))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    GoldButton(title: "Start sleep tracking", systemImage: "moon.fill") {
                        HapticEngine.confirm()
                        tabController.showTracking = true
                    }
                    
                    Button {
                        tabController.showSubscription = true
                    } label: {
                        Text("Unlock Voice Companion")
                            .font(.sabatMono(12, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.sabatGold2)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }

    private func lastSessionPanel(_ session: SleepSession) -> some View {
        SacredCard {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                Text("Last session")
                    .font(.sabatSans(15, weight: .semibold))
                    .foregroundStyle(Color.sabatMuted)

                Text(session.startedAt, style: .date)
                    .font(.sabatSerif(24))
                    .foregroundStyle(Color.sabatMist)

                if let restScore = session.restScore {
                    Text("Rest score \(restScore)")
                        .font(.sabatSans(17, weight: .medium))
                        .foregroundStyle(Color.sabatGold2)
                }
            }
        }
    }

    private var firstNightPanel: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                Text("Your first night")
                    .font(.sabatSans(15, weight: .semibold))
                    .foregroundStyle(Color.sabatMuted)

                Text("Tap 'Begin ritual' above to start your wind-down. After you sleep, your rest score and sleep phases will appear here.")
                    .font(.sabatSerif(20))
                    .foregroundStyle(Color.sabatMist)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppTabController())
    }
}
