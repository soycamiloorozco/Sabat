import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                Capsule()
                    .fill(Color.sabatPaper2)
                    .frame(width: 140, height: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.lg)

                OnboardingProgressView(current: 0, total: 5)

                HandmadeEyeIllustration(style: .radiant, size: 230)

                VStack(spacing: SabatSpacing.md) {
                    Text("Sabat")
                        .font(.sabatDisplay(64))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("A calm voice with presence for the last conversation of the day.")
                        .font(.sabatSerif(23))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                GoldButton(title: "Begin your rest", systemImage: "moon.stars.fill") {
                    router.navigate(to: .voiceIntro)
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.bottom, SabatSpacing.xl)
        }
        .navigationBarBackButtonHidden()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppRouter())
    }
}
