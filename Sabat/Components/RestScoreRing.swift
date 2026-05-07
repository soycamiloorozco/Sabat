import SwiftUI

struct RestScoreRing: View {
    let score: Int
    @State private var animatedScore: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.sabatLine, lineWidth: 14)

            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    Color.sabatGold2,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedScore)

            VStack(spacing: SabatSpacing.xs) {
                Text("\(score)")
                    .font(.sabatDisplay(54))
                    .foregroundStyle(Color.sabatGold2)
                    .contentTransition(.numericText())
                Text("Rest score")
                    .font(.sabatSans(14, weight: .semibold))
                    .foregroundStyle(Color.sabatMuted)
            }
        }
        .frame(width: 190, height: 190)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rest score")
        .accessibilityValue("\(score) out of 100")
        .onAppear {
            animatedScore = CGFloat(score)
        }
        .onChange(of: score) { _, newValue in
            animatedScore = CGFloat(newValue)
        }
    }
}
