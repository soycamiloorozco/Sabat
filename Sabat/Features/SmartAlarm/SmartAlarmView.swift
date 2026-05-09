import Combine
import SwiftUI

struct SmartAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabController: AppTabController
    @StateObject private var viewModel = SmartAlarmViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SabatSpacing.xxl) {
                    headerSection

                    timeDisplaySection

                    wakeWindowSection

                    phaseIndicatorSection

                    smartAlarmToggleSection

                    Spacer(minLength: SabatSpacing.xl)

                    actionButtonsSection
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.vertical, SabatSpacing.xxl)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.sabatMist)
                        .padding(8)
                        .background(Color.sabatPaper.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .task {
            viewModel.load()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: SabatSpacing.sm) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.sabatDawn)

            Text("Smart Alarm")
                .font(.sabatDisplay(36))
                .foregroundStyle(Color.sabatGold2)

            Text("Wake up gently during light sleep")
                .font(.sabatSerif(18))
                .foregroundStyle(Color.sabatMuted)
                .multilineTextAlignment(.center)
        }
    }

    private var timeDisplaySection: some View {
        VStack(spacing: SabatSpacing.lg) {
            Text(viewModel.formattedWakeTime)
                .font(.sabatMono(72, weight: .light))
                .foregroundStyle(Color.sabatDawn)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.sabatDawn.opacity(0.25), lineWidth: 1.5)
                        .padding(.horizontal, -28)
                        .padding(.vertical, -12)
                }
                .padding(.vertical, 12)

            DatePicker(
                "Wake me up",
                selection: $viewModel.wakeTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .frame(height: 140)
            .onChange(of: viewModel.wakeTime) { _, newValue in
                viewModel.updateWakeTime(newValue)
            }
        }
    }

    private var wakeWindowSection: some View {
        SacredCard {
            VStack(spacing: SabatSpacing.md) {
                HStack {
                    Image(systemName: "sun.haze.fill")
                        .foregroundStyle(Color.sabatDawn)
                    Text("Wake-up window")
                        .font(.sabatSans(14, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                    Spacer()
                }

                Text("\(viewModel.windowMinutes) minutes before target time")
                    .font(.sabatSerif(20))
                    .foregroundStyle(Color.sabatMist)

                Slider(
                    value: .init(
                        get: { Double(viewModel.windowMinutes) },
                        set: { viewModel.windowMinutes = Int($0) }
                    ),
                    in: 10...60,
                    step: 5
                )
                .tint(Color.sabatDawn)
                .onChange(of: viewModel.windowMinutes) { _, _ in
                    HapticEngine.selectionChanged()
                    viewModel.updateWindow()
                }

                let windowStart = viewModel.wakeTime.addingTimeInterval(TimeInterval(-viewModel.windowMinutes * 60))
                HStack {
                    Text("Earliest: \(windowStart.formatted(date: .omitted, time: .shortened))")
                        .font(.sabatMono(13))
                        .foregroundStyle(Color.sabatDawn.opacity(0.85))
                    Spacer()
                    Text("Target: \(viewModel.wakeTime.formatted(date: .omitted, time: .shortened))")
                        .font(.sabatMono(13))
                        .foregroundStyle(Color.sabatGold2)
                }
            }
        }
    }

    private var phaseIndicatorSection: some View {
        SacredCard {
            VStack(spacing: SabatSpacing.md) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(Color.sabatDawn)
                    Text("Sleep phase detection")
                        .font(.sabatSans(14, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                    Spacer()
                }

                HStack(spacing: SabatSpacing.md) {
                    ForEach(SleepPhase.allCases, id: \.self) { phase in
                        PhasePill(
                            phase: phase,
                            isActive: viewModel.detectedPhase == phase
                        )
                    }
                }

                Text(viewModel.phaseExplanation)
                    .font(.sabatSans(14))
                    .foregroundStyle(Color.sabatMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
    }

    private var smartAlarmToggleSection: some View {
        SacredCard {
            HStack(spacing: SabatSpacing.md) {
                VStack(alignment: .leading, spacing: SabatSpacing.xs) {
                    Text("Smart wake-up")
                        .font(.sabatSans(16, weight: .semibold))
                        .foregroundStyle(Color.sabatMist)

                    Text("Alarm adapts to your sleep cycle")
                        .font(.sabatSans(13))
                        .foregroundStyle(Color.sabatMuted)
                }

                Spacer()

                Toggle("", isOn: $viewModel.isSmartAlarmEnabled)
                    .tint(Color.sabatDawn)
                    .labelsHidden()
                    .frame(width: 52)
                    .onChange(of: viewModel.isSmartAlarmEnabled) { _, _ in
                        HapticEngine.softTap()
                        viewModel.updateAlarmSettings()
                    }
            }
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: SabatSpacing.md) {
            // Primary: Go to Sleep (saves alarm + opens lock screen)
            GoldButton(title: "Go to sleep", systemImage: "moon.zzz.fill") {
                HapticEngine.success()
                viewModel.saveAlarm()
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tabController.showTracking = true
                }
            }

            // Secondary: Just save alarm
            Button {
                HapticEngine.softTap()
                viewModel.saveAlarm()
                dismiss()
            } label: {
                Text(viewModel.isAlarmActive ? "Update alarm only" : "Set alarm only")
                    .font(.sabatSans(15, weight: .medium))
                    .foregroundStyle(Color.sabatDawn)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay {
                        Capsule()
                            .stroke(Color.sabatDawn.opacity(0.4), lineWidth: 1)
                    }
            }
            .buttonStyle(PillSecondaryButtonStyle())

            if viewModel.isAlarmActive {
                Button {
                    HapticEngine.softTap()
                    viewModel.cancelAlarm()
                } label: {
                    Text("Cancel alarm")
                        .font(.sabatSans(15, weight: .medium))
                        .foregroundStyle(Color.sabatMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(PillSecondaryButtonStyle())
            }
        }
    }
}

// MARK: - Phase Pill

private struct PhasePill: View {
    let phase: SleepPhase
    let isActive: Bool

    var body: some View {
        Text(phase.rawValue.capitalized)
            .font(.sabatSans(12, weight: isActive ? .semibold : .regular))
            .foregroundStyle(isActive ? Color.sabatInk : Color.sabatMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isActive
                ? Color.sabatDawn
                : Color.sabatPaper.opacity(0.06)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isActive ? Color.sabatDawn.opacity(0.6) : Color.sabatLine,
                        lineWidth: 1
                    )
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isActive)
    }
}

// MARK: - Preview

struct SmartAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        SmartAlarmView()
    }
}
