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
                // Background Atmosphere Glow
                Circle()
                    .fill(Color(red: 0.1, green: 0.3, blue: 0.8).opacity(0.12 + energy * 0.12))
                    .frame(width: size * 1.8, height: size * 1.8)
                    .blur(radius: 60)
                    .scaleEffect(breath ? 1.15 : 0.85)

                // The Core Living Fluid
                ZStack {
                    // Deep base
                    Circle()
                        .fill(Color(red: 0.05, green: 0.1, blue: 0.3))
                        .frame(width: size, height: size)
                    
                    // Cyan Flow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.7, blue: 1.0).opacity(0.9),
                                    Color(red: 0.1, green: 0.4, blue: 0.9).opacity(0.4),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size * 0.5
                            )
                        )
                        .offset(x: breath ? 15 : -15, y: drift ? -10 : 10)
                        .blur(radius: 20)
                    
                    // Highlight Flow
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: size * 0.4, height: size * 0.3)
                        .blur(radius: 25)
                        .offset(x: -size * 0.15, y: -size * 0.15)
                        .rotationEffect(.degrees(drift ? 45 : -45))
                }
                .clipShape(Circle())
                .frame(width: size, height: size)
                .overlay {
                    particleTexture(size: size)
                        .clipShape(Circle())
                        .blendMode(.screen)
                }
                .overlay {
                    // Edge Glow
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .scaleEffect(0.94 + energy * 0.18)
                .offset(y: drift ? -12 : 12)
                .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.3 + energy * 0.4), radius: 30 + energy * 40)
                .animation(.interpolatingSpring(stiffness: 120, damping: 15), value: energy)

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
