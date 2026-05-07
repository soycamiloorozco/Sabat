import SwiftUI

struct OnboardingCompleteView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                Spacer()

                HandmadeEyeIllustration(style: .constellation, size: 220)

                VStack(spacing: SabatSpacing.md) {
                    Text("The ritual is ready.")
                        .font(.sabatDisplay(42))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("Tonight, Sabat will meet you by name and leave you in silence.")
                        .font(.sabatSerif(22))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                GoldButton(title: "Go home", systemImage: "house.fill") {
                    router.completeOnboarding()
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
        .navigationBarBackButtonHidden()
    }
}

struct OnboardingCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCompleteView()
            .environmentObject(AppRouter())
    }
}
