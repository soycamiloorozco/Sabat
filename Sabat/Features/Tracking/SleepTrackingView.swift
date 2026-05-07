import Combine
import SwiftUI

struct SleepTrackingView: View {
    @EnvironmentObject private var tabController: AppTabController
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SleepTrackingViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                Spacer()

                VoiceOrbView(phase: .complete)

                VStack(spacing: SabatSpacing.md) {
                    Text("Sabat is with you tonight.")
                        .font(.sabatDisplay(40))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("Your sleep is being tracked and prepared for Health and your sleep log.")
                        .font(.sabatSerif(21))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: SabatSpacing.md) {
                    DatePicker(
                        "Wake me up",
                        selection: $viewModel.configuredWakeTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .onChange(of: viewModel.configuredWakeTime) { _, newValue in
                        viewModel.updateWakeTime(newValue)
                    }

                    Text("Current phase: \(viewModel.currentSleepPhase.rawValue.capitalized)")
                        .font(.sabatSans(15, weight: .semibold))
                        .foregroundStyle(Color.sabatGold2)

                    let windowStart = viewModel.configuredWakeTime.addingTimeInterval(TimeInterval(-viewModel.wakeWindowMinutes * 60))
                    Text("Wake up easy between \(windowStart.formatted(date: .omitted, time: .shortened)) and \(viewModel.configuredWakeTime.formatted(date: .omitted, time: .shortened))")
                        .font(.sabatSans(15))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.sabatSans(14))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                GoldButton(title: "Wake up flow", systemImage: "alarm.fill") {
                    HapticEngine.confirm()
                    dismiss()
                    tabController.showWakeUp = true
                }

                Button {
                    HapticEngine.softTap()
                    viewModel.stop()
                    dismiss()
                } label: {
                    Text("End session")
                        .font(.sabatSans(15, weight: .medium))
                        .foregroundStyle(Color.sabatMist)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay {
                            Capsule()
                                .stroke(Color.sabatLine, lineWidth: 1)
                        }
                }
                .buttonStyle(PillSecondaryButtonStyle())
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
        .navigationBarBackButtonHidden()
        .task {
            viewModel.start()
        }
    }
}

struct SleepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackingView()
            .environmentObject(AppTabController())
    }
}
