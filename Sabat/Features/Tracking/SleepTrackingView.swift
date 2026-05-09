import Combine
import SwiftUI

struct SleepTrackingView: View {
    @EnvironmentObject private var tabController: AppTabController
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SleepTrackingViewModel()

    @State private var breathe = false
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Pure black background for OLED
            Color.black.ignoresSafeArea()

            // Subtle ambient gradient at top
            VStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.04, blue: 0.10).opacity(0.6),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Current Time (Large)
                timeDisplay

                Spacer()

                // Alarm Info
                alarmInfoSection

                Spacer()

                // Breathing Animation
                breathingOrb
                    .frame(height: 160)

                Spacer()
                    .frame(height: 40)

                // Bottom Controls
                bottomControls
                    .padding(.bottom, SabatSpacing.xxl)
            }
            .padding(.horizontal, SabatSpacing.lg)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .task {
            viewModel.start()
            // Lower screen brightness for sleep
            UIScreen.main.brightness = 0.05
        }
        .onDisappear {
            // Restore brightness
            UIScreen.main.brightness = 0.5
        }
    }

    // MARK: - Time Display

    private var timeDisplay: some View {
        VStack(spacing: 8) {
            Text(currentTime.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.85))
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(currentTime.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.sabatSans(16, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.3))
                .textCase(.uppercase)
        }
    }

    // MARK: - Alarm Info

    private var alarmInfoSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.sabatDawn.opacity(0.7))

            Text("Alarm \(viewModel.configuredWakeTime.formatted(date: .omitted, time: .shortened))")
                .font(.sabatMono(16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
        .clipShape(Capsule())
    }

    // MARK: - Breathing Orb

    private var breathingOrb: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.15, green: 0.35, blue: 0.7).opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(breathe ? 1.3 : 0.7)

            // Core orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.6, blue: 1.0).opacity(0.25),
                            Color(red: 0.1, green: 0.3, blue: 0.8).opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(breathe ? 1.15 : 0.85)

            // Inner bright dot
            Circle()
                .fill(Color.white.opacity(breathe ? 0.18 : 0.06))
                .frame(width: 6, height: 6)
                .blur(radius: 3)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4.0)
                .repeatForever(autoreverses: true)
            ) {
                breathe = true
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: SabatSpacing.md) {
            Button {
                HapticEngine.confirm()
                UIScreen.main.brightness = 0.5
                dismiss()
                tabController.showWakeUp = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Wake up")
                        .font(.sabatSans(16, weight: .semibold))
                }
                .foregroundStyle(Color.sabatInk)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.white.opacity(0.9))
                .clipShape(Capsule())
            }
            .buttonStyle(PillSecondaryButtonStyle())

            Button {
                HapticEngine.softTap()
                UIScreen.main.brightness = 0.5
                viewModel.stop()
                dismiss()
            } label: {
                Text("End session")
                    .font(.sabatSans(14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.25))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackingView()
            .environmentObject(AppTabController())
    }
}
