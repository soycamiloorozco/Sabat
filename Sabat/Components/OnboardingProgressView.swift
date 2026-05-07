import SwiftUI

struct OnboardingProgressView: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.white : Color.sabatPaper.opacity(0.28))
                    .frame(width: index == current ? 22 : 6, height: 6)
                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: current)
            }
        }
        .accessibilityLabel("Onboarding step \(current + 1) of \(total)")
    }
}
