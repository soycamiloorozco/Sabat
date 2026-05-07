import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    HapticEngine.tabTick()
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .semibold))

                        Text(tab.title)
                            .font(.sabatSans(10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        selectedTab == tab
                        ? Color.sabatDawn
                        : Color.sabatPaper.opacity(0.32)
                    )
                }
                .accessibilityLabel(tab.accessibilityLabel)
                .accessibilityHint("Double tap to switch to \(tab.title) tab")
            }
        }
        .frame(height: 64)
        .padding(.horizontal, SabatSpacing.lg)
        .padding(.bottom, 8)
        .background(
            Color.sabatInk
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.sabatInk.opacity(0),
                            Color.sabatInk
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.sabatLine)
                .frame(height: 0.5)
        }
    }
}
