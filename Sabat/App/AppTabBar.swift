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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.sabatDawn.opacity(0.12))
                                .frame(width: 80, height: 48)
                                .matchedGeometryEffect(id: "active_pill", in: animation)
                                .scaleEffect(isSelected ? 1.05 : 1.0)
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
            Capsule()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .shadow(color: Color.black.opacity(0.65), radius: 45, y: 25)
                .overlay {
                    Capsule()
                        .stroke(Color.sabatLine.opacity(0.15), lineWidth: 0.5)
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
