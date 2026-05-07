import SwiftUI

struct OnboardingSleepIntroView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var drift = false

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                OnboardingProgressView(current: 2, total: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.md)

                ZStack {
                    MoonPresenceView(size: 185, intensity: 0.72)
                        .offset(y: drift ? -8 : 8)

                    HandmadeEyeIllustration(style: .sleepy, size: 170, isAwake: false)
                        .offset(y: 96)
                }
                .frame(height: 300)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: drift)
                .onAppear { drift = true }

                VStack(spacing: SabatSpacing.md) {
                    Text("Your night gets a shape.")
                        .font(.sabatDisplay(42))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("Ritual first. Tracking later. Nothing loud, nothing busy, nothing asking you to perform.")
                        .font(.sabatSans(17))
                        .foregroundStyle(Color.sabatMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Spacer()

                GoldButton(title: "Continue") {
                    router.navigate(to: .signIn)
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
    }
}

struct OnboardingSleepIntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSleepIntroView()
            .environmentObject(AppRouter())
    }
}
