import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var tabController: AppTabController
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView {
                VStack(spacing: SabatSpacing.xl) {
                    greetingHeader

                    tonightPanel

                    smartAlarmPanel

                    if let session = viewModel.lastSession {
                        lastSessionPanel(session)
                    } else {
                        firstNightPanel
                    }
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.vertical, SabatSpacing.xl)
            }
            .refreshable {
                viewModel.load()
            }
            .tint(Color.sabatDawn)
        }
        .task {
            viewModel.load()
        }
    }

    private var greetingHeader: some View {
        VStack(spacing: SabatSpacing.md) {
            Text("Good evening,")
                .font(.sabatSans(15, weight: .medium))
                .foregroundStyle(Color.sabatMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.preferredName)
                .font(.sabatDisplay(40))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Begin the last conversation of the day.")
                .font(.sabatSerif(20))
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
                    .font(.sabatSerif(22))
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

                Text("A 2 to 5 minute wind-down, then silence.")
                    .font(.sabatSerif(26))
                    .foregroundStyle(Color.sabatMist)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                GoldButton(title: "Begin ritual", systemImage: "waveform") {
                    HapticEngine.confirm()
                    tabController.showRitual = true
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
