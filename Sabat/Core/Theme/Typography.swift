import SwiftUI

extension Font {
    static func sabatDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func sabatSerif(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func sabatSans(_ size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func sabatMono(_ size: CGFloat, weight: Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
