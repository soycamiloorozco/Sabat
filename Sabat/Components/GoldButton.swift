import SwiftUI

struct GoldButton: View {
    let title: String
    var systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SabatSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }

                Text(title)
                    .font(.sabatMono(14, weight: .semibold))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(Color.sabatInk)
            .background(Color.white)
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 42, height: 3)
                    .padding(.leading, 24)
                    .padding(.top, 8)
            }
            .clipShape(Capsule())
            .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
            .opacity(isDisabled ? 0.48 : 1)
        }
        .disabled(isDisabled)
        .buttonStyle(PillPressButtonStyle())
    }
}

private struct PillPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct PillSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
