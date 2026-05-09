import SwiftUI

struct MidnightBackground: View {
    var body: some View {
        ZStack {
            // Base Deep Blue Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.04, blue: 0.08), // Darker bluish top
                    Color.sabatInk // Standard Sabat Ink bottom
                ],
                startPoint: .top,
                endPoint: .center
            )
            
            // Suble Grain Noise Overlay
            GrainNoiseView()
                .opacity(0.12) // More prominent as requested
                .blendMode(.screen)
            
            // Subtle Handmade texture
            HandmadeTextureView()
                .opacity(0.25)
        }
        .ignoresSafeArea()
    }
}

private struct GrainNoiseView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0...25000 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 0.8, height: 0.8)
                context.fill(Path(rect), with: .color(.white.opacity(0.6)))
            }
        }
    }
}

private struct HandmadeTextureView: View {
    private let marks = Array(0..<60)

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                ForEach(marks, id: \.self) { index in
                    Capsule()
                        .fill(Color.sabatPaper.opacity(index.isMultiple(of: 3) ? 0.25 : 0.12))
                        .frame(
                            width: CGFloat(12 + (index * 9) % 35),
                            height: 1.5
                        )
                        .rotationEffect(.degrees(Double((index * 23) % 45) - 22))
                        .position(
                            x: CGFloat((index * 131) % Int(width)),
                            y: CGFloat((index * 197) % Int(height))
                        )
                }
            }
        }
    }
}
