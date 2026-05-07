import SwiftUI

struct SleepBarsChart: View {
    let sessions: [SleepSession]

    private var barHeights: [CGFloat] {
        sessions.isEmpty ? [0.18, 0.22, 0.2, 0.18, 0.24, 0.19, 0.21] : [0.48, 0.62, 0.54, 0.72, 0.58, 0.64, 0.7]
    }

    var body: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: SabatSpacing.lg) {
                Text("Week")
                    .font(.sabatSans(15, weight: .semibold))
                    .foregroundStyle(Color.sabatMuted)

                HStack(alignment: .bottom, spacing: SabatSpacing.sm) {
                    ForEach(barHeights.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.sabatGold2.opacity(sessions.isEmpty ? 0.24 : 0.72))
                            .frame(maxWidth: .infinity)
                            .frame(height: 150 * barHeights[index])
                    }
                }
                .frame(height: 160)
            }
        }
    }
}
