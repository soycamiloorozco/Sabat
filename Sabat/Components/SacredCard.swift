import SwiftUI

struct SacredCard<Content: View>: View {
    var padding: CGFloat = SabatSpacing.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color.sabatPaper.opacity(0.045))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.sabatLine, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
