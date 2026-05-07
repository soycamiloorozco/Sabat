import SwiftUI

struct MidnightBackground: View {
    var body: some View {
        Color.sabatInk
            .overlay {
                HandmadeTextureView()
                    .opacity(0.18)
            }
        .ignoresSafeArea()
    }
}

private struct HandmadeTextureView: View {
    private let marks = Array(0..<34)

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                ForEach(marks, id: \.self) { index in
                    Capsule()
                        .fill(Color.sabatPaper.opacity(index.isMultiple(of: 4) ? 0.13 : 0.07))
                        .frame(
                            width: CGFloat(8 + (index * 7) % 22),
                            height: 1.2
                        )
                        .rotationEffect(.degrees(Double((index * 19) % 22) - 11))
                        .position(
                            x: CGFloat((index * 47) % Int(width)),
                            y: CGFloat((index * 83) % Int(height))
                        )
                }
            }
        }
    }
}
