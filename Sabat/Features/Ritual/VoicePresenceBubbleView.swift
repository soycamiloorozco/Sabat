import SwiftUI

struct VoicePresenceBubbleView: View {
    let phase: RitualPhase
    let energy: Double
    let tone: VoiceTone

    @State private var breath = false
    @State private var drift = false

    private let particles = Array(0..<120)

    private var baseSize: CGFloat {
        switch phase {
        case .speaking:
            230
        case .listening:
            205
        case .processing:
            184
        case .complete:
            154
        default:
            196
        }
    }

    private var toneOpacity: Double {
        switch tone {
        case .still:
            0.62
        case .listening:
            0.72
        case .warm:
            0.88
        case .low:
            0.78
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let available = min(proxy.size.width, proxy.size.height)
            let size = min(available * 0.72, baseSize + CGFloat(energy * 86))

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06 + energy * 0.08))
                    .frame(width: size * 1.5, height: size * 1.5)
                    .blur(radius: 36)
                    .scaleEffect(breath ? 1.08 : 0.94)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.98),
                                Color.sabatPaper.opacity(toneOpacity),
                                Color.sabatSmoke.opacity(0.28 + energy * 0.16)
                            ],
                            center: UnitPoint(x: 0.46, y: 0.38),
                            startRadius: 8,
                            endRadius: size * 0.58
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay {
                        particleTexture(size: size)
                            .clipShape(Circle())
                    }
                    .overlay(alignment: .topLeading) {
                        Circle()
                            .fill(Color.white.opacity(0.46))
                            .frame(width: size * 0.28, height: size * 0.18)
                            .blur(radius: 18)
                            .offset(x: size * 0.18, y: size * 0.18)
                    }
                    .scaleEffect(0.96 + energy * 0.12)
                    .offset(y: drift ? -8 : 8)
                    .shadow(color: Color.white.opacity(0.22 + energy * 0.16), radius: 24 + energy * 26)
                    .animation(.spring(response: 0.42, dampingFraction: 0.74), value: energy)

                if phase == .listening {
                    listeningRing(size: size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                breath = true
                drift = true
            }
            .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: breath)
            .animation(.easeInOut(duration: 4.1).repeatForever(autoreverses: true), value: drift)
        }
        .accessibilityLabel("Sabat voice presence")
    }

    private func particleTexture(size: CGFloat) -> some View {
        ZStack {
            ForEach(particles, id: \.self) { index in
                Circle()
                    .fill(Color.sabatInk.opacity(0.035 + Double(index % 5) * 0.012))
                    .frame(width: particleSize(index), height: particleSize(index))
                    .offset(particleOffset(index, size: size))
                    .blur(radius: index.isMultiple(of: 3) ? 1.2 : 0.2)
            }
        }
    }

    private func listeningRing(size: CGFloat) -> some View {
        Circle()
            .stroke(Color.white.opacity(0.22), lineWidth: 1)
            .frame(width: size * 1.2, height: size * 1.2)
            .scaleEffect(breath ? 1.08 : 0.96)
    }

    private func particleSize(_ index: Int) -> CGFloat {
        CGFloat(2 + (index * 17) % 14)
    }

    private func particleOffset(_ index: Int, size: CGFloat) -> CGSize {
        let angle = Double(index) * 2.399963
        let radius = sqrt(Double(index) / Double(max(particles.count, 1))) * Double(size) * 0.43
        let wave = sin(Double(index) * 0.73 + energy * 4) * 5
        return CGSize(width: cos(angle) * radius + wave, height: sin(angle) * radius - wave * 0.4)
    }
}
