import SwiftUI

struct WaveformView: View {
    let phase: RitualPhase

    private var levels: [CGFloat] {
        switch phase {
        case .speaking, .greeting:
            [0.24, 0.62, 0.38, 0.78, 0.44, 0.7, 0.3, 0.56, 0.42, 0.66]
        case .listening:
            [0.18, 0.28, 0.2, 0.34, 0.26, 0.31, 0.22, 0.29, 0.18, 0.25]
        case .processing:
            [0.16, 0.16, 0.16, 0.16, 0.16, 0.16, 0.16, 0.16, 0.16, 0.16]
        case .idle, .complete:
            [0.1, 0.12, 0.1, 0.12, 0.1, 0.12, 0.1, 0.12, 0.1, 0.12]
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(levels.indices, id: \.self) { index in
                Capsule()
                    .fill(Color.sabatGold2.opacity(phase == .complete ? 0.25 : 0.72))
                    .frame(width: 5, height: 52 * levels[index])
                    .animation(
                        .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.04),
                        value: phase
                    )
            }
        }
        .frame(height: 56)
        .accessibilityHidden(true)
    }
}
