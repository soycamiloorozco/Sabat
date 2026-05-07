import SwiftUI

enum HandmadeEyeStyle {
    case radiant
    case constellation
    case sleepy
}

struct HandmadeEyeIllustration: View {
    let style: HandmadeEyeStyle
    var size: CGFloat = 210
    var isAwake = true

    @State private var isBreathing = false

    var body: some View {
        ZStack {
            if style == .constellation {
                constellationDots
            } else {
                radiantMarks
            }

            eyeCore
                .scaleEffect(isBreathing && isAwake ? 1.035 : 0.985)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.sabatPaper.opacity(isAwake ? 0.22 : 0.1), radius: isAwake ? 20 : 8)
        .onAppear {
            isBreathing = true
        }
        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: isBreathing)
        .accessibilityHidden(true)
    }

    private var eyeCore: some View {
        ZStack {
            EyeShape()
                .fill(Color.sabatPaper2)
                .frame(width: size * 0.32, height: style == .sleepy ? size * 0.16 : size * 0.25)
                .rotationEffect(.degrees(style == .sleepy ? -1.5 : 0))

            if style == .sleepy {
                Capsule()
                    .fill(Color.sabatInk)
                    .frame(width: size * 0.035, height: size * 0.12)
                    .offset(y: -1)
            } else {
                Circle()
                    .fill(Color.sabatInk)
                    .frame(width: size * 0.055, height: size * 0.055)
            }
        }
    }

    private var radiantMarks: some View {
        ZStack {
            ForEach(markIndices, id: \.self) { index in
                let angle = angle(for: index)
                let isUpper = sin(angle.radians) < 0
                let show = style == .radiant || style == .sleepy || isUpper

                if show {
                    Capsule()
                        .fill(Color.sabatPaper2)
                        .frame(width: size * 0.022, height: markHeight(for: index))
                        .offset(y: -size * markRadius(for: index))
                        .rotationEffect(angle)
                }
            }
        }
        .scaleEffect(isBreathing && isAwake ? 1.04 : 0.98)
    }

    private var constellationDots: some View {
        ZStack {
            ForEach(dotIndices, id: \.self) { index in
                Circle()
                    .fill(Color.sabatPaper2)
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .offset(dotOffset(for: index))
                    .opacity(0.74 + Double(index % 4) * 0.06)
            }
        }
        .scaleEffect(isBreathing && isAwake ? 1.025 : 0.99)
    }

    private var markIndices: Range<Int> {
        style == .sleepy ? 0..<18 : 0..<34
    }

    private var dotIndices: Range<Int> {
        0..<74
    }

    private func angle(for index: Int) -> Angle {
        let spread = style == .sleepy ? 170.0 : 360.0
        let start = style == .sleepy ? -85.0 : 0.0
        let base = start + (Double(index) / Double(max(markIndices.count - 1, 1))) * spread
        let wobble = sin(Double(index) * 1.7) * 3.2
        return .degrees(base + wobble)
    }

    private func markHeight(for index: Int) -> CGFloat {
        let rhythm = CGFloat((index * 9) % 17) / 17
        return size * (0.16 + rhythm * 0.07)
    }

    private func markRadius(for index: Int) -> CGFloat {
        0.33 + CGFloat((index * 5) % 7) * 0.006
    }

    private func dotSize(for index: Int) -> CGFloat {
        size * (0.018 + CGFloat((index * 11) % 8) * 0.0028)
    }

    private func dotOffset(for index: Int) -> CGSize {
        let angle = Double(index) * 2.399963
        let radius = sqrt(Double(index) / Double(max(dotIndices.count, 1)))
        let x = cos(angle) * radius * Double(size) * 0.43
        let y = sin(angle) * radius * Double(size) * 0.28
        return CGSize(width: x, height: y)
    }
}

private struct EyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let left = CGPoint(x: rect.minX, y: rect.midY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)

        path.move(to: left)
        path.addQuadCurve(
            to: right,
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.18)
        )
        path.addQuadCurve(
            to: left,
            control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.26)
        )

        return path
    }
}
