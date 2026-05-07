import SwiftUI

struct OnboardingVoiceIntroView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var phraseIndex = 0

    private let phrases = [
        "A voice that does not rush you.",
        "Like a grandfather who wants to see you well.",
        "You deserve to rest."
    ]

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                OnboardingProgressView(current: 1, total: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.md)

                VoiceOrbView(phase: .greeting)

                VStack(spacing: SabatSpacing.md) {
                    Text(phrases[phraseIndex])
                        .font(.sabatDisplay(40))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Sabat remembers what weighs on you, then brings you back one breath at a time.")
                        .font(.sabatSans(17))
                        .foregroundStyle(Color.sabatMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Spacer()

                GoldButton(title: "Continue") {
                    router.navigate(to: .sleepIntro)
                }
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                withAnimation(.easeInOut(duration: 0.45)) {
                    phraseIndex = (phraseIndex + 1) % phrases.count
                }
            }
        }
    }
}

struct OnboardingVoiceIntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingVoiceIntroView()
            .environmentObject(AppRouter())
    }
}
