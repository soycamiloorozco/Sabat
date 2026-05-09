import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    HapticEngine.tabTick()
                    // Slightly more responsive spring for the main pill
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.75, blendDuration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        // THE "GHOST PILL" (Trailing Blur Effect)
                        if isSelected {
                            Capsule()
                                .fill(Color.sabatDawn.opacity(0.08))
                                .frame(width: 84, height: 52)
                                .blur(radius: 8)
                                .matchedGeometryEffect(id: "ghost_pill", in: animation)
                                // Slower spring for the ghost to create a "trailing" feel
                                .animation(.spring(response: 0.5, dampingFraction: 0.9), value: selectedTab)
                        }

                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.sabatDawn.opacity(0.18),
                                            Color.sabatDawn.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 48)
                                .matchedGeometryEffect(id: "active_pill", in: animation)
                                .scaleEffect(isSelected ? 1.05 : 1.0)
                                // Inner highlight for glass look
                                .overlay {
                                    Capsule()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                }
                        }
                        
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? Color.sabatDawn : Color.sabatMuted)
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                            
                            Text(tab.title)
                                .font(.sabatMono(9, weight: .semibold))
                                .textCase(.uppercase)
                                .foregroundStyle(isSelected ? Color.sabatDawn : Color.sabatMuted)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(tab.accessibilityLabel)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            ZStack {
                // Outer Atmospheric Glow
                Capsule()
                    .fill(Color.sabatDawn.opacity(0.05))
                    .blur(radius: 30)
                    .offset(y: 10)

                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .shadow(color: Color.black.opacity(0.7), radius: 50, y: 30)
                    .overlay {
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 24)
    }
}

struct AppTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            MidnightBackground()
            AppTabBar(selectedTab: .constant(.rest))
        }
    }
}
