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
                    VStack(spacing: 4) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Color.sabatDawn.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                    .matchedGeometryEffect(id: "active_pill", in: animation)
                            }
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? Color.sabatDawn : Color.sabatMuted)
                        }
                        
                        Text(tab.title)
                            .font(.sabatMono(10, weight: .semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(isSelected ? Color.sabatDawn : Color.sabatMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(tab.accessibilityLabel)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .shadow(color: Color.black.opacity(0.4), radius: 25, y: 15)
                .overlay {
                    Capsule()
                        .stroke(Color.sabatLine.opacity(0.3), lineWidth: 0.5)
                }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 12)
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
