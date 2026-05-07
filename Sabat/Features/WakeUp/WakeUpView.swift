import Combine
import SwiftUI

struct WakeUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WakeUpViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                Spacer()

                RestScoreRing(score: viewModel.restScore.overall)

                VStack(spacing: SabatSpacing.sm) {
                    Text("Morning.")
                        .font(.sabatDisplay(46))
                        .foregroundStyle(Color.sabatGold2)

                    Text("You slept \(viewModel.sleepDurationText). Your first reflection will close the loop here.")
                        .font(.sabatSerif(21))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                GoldButton(title: "Return home", systemImage: "house.fill") {
                    HapticEngine.success()
                    dismiss()
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
        .navigationBarBackButtonHidden()
        .task {
            viewModel.load()
        }
    }
}

struct WakeUpView_Previews: PreviewProvider {
    static var previews: some View {
        WakeUpView()
    }
}
