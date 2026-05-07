import SwiftUI

struct MoonPresenceView: View {
    var size: CGFloat = 210
    var intensity: Double = 1

    @State private var breath = false
    private let grains = Array(0..<90)

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08 * intensity))
                .frame(width: size * 1.08, height: size * 1.08)
                .blur(radius: 18)
                .scaleEffect(breath ? 1.06 : 0.98)

            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay {
                    ZStack {
                        ForEach(grains, id: \.self) { index in
                            Circle()
                                .fill(Color.sabatInk.opacity(0.08 + Double(index % 5) * 0.02))
                                .frame(width: grainSize(index), height: grainSize(index))
                                .offset(grainOffset(index))
                                .blur(radius: 0.4)
                        }
                    }
                    .clipShape(Circle())
                }
                .shadow(color: Color.white.opacity(0.42 * intensity), radius: breath ? 34 : 22)
        }
        .frame(width: size * 1.18, height: size * 1.18)
        .onAppear {
            breath = true
        }
        .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: breath)
        .accessibilityHidden(true)
    }

    private func grainSize(_ index: Int) -> CGFloat {
        CGFloat(2 + (index * 13) % 8)
    }

    private func grainOffset(_ index: Int) -> CGSize {
        let angle = Double(index) * 2.399963
        let radius = sqrt(Double(index) / Double(max(grains.count, 1))) * Double(size) * 0.43
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
}
