import SwiftUI

struct VoiceOrbView: View {
    let phase: RitualPhase

    @State private var pulse = false

    private var glowOpacity: Double {
        switch phase {
        case .greeting, .speaking:
            0.28
        case .listening:
            0.2
        case .processing:
            0.14
        case .idle:
            0.16
        case .complete:
            0.08
        }
    }

    private var eyeStyle: HandmadeEyeStyle {
        switch phase {
        case .processing:
            .constellation
        case .complete:
            .sleepy
        default:
            .radiant
        }
    }

    var body: some View {
        ZStack {
            HandmadeEyeIllustration(
                style: eyeStyle,
                size: phase == .processing ? 220 : 240,
                isAwake: phase != .complete
            )
            .scaleEffect(pulse ? 1.015 : 0.985)

            if phase != .complete {
                Circle()
                    .stroke(
                        Color.sabatPaper.opacity(glowOpacity),
                        lineWidth: 1
                    )
                    .frame(width: 248, height: 248)
                    .scaleEffect(pulse ? 1.08 : 0.95)
                    .blur(radius: 0.4)
                    .opacity(pulse ? 0.35 : 0.18)
            }

            if phase == .listening {
                Image(systemName: "mic.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.sabatInk)
                    .frame(width: 42, height: 42)
                    .background(Color.sabatPaper2)
                    .clipShape(Circle())
                    .offset(y: 112)
                    .shadow(color: Color.sabatPaper.opacity(0.18), radius: 14, x: 0, y: 6)
            }
        }
        .frame(height: 300)
        .onAppear {
            pulse = true
        }
        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
        .accessibilityHidden(true)
    }
}
