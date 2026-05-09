import SwiftUI

struct PaywallOverlay: View {
    let title: String
    let subtitle: String
    let icon: String
    var onSubscribe: () -> Void
    
    var body: some View {
        ZStack {
            // Blurred background effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            
            VStack(spacing: SabatSpacing.xl) {
                Spacer()
                
                VStack(spacing: SabatSpacing.lg) {
                    Image(systemName: icon)
                        .font(.system(size: 54, weight: .light))
                        .foregroundStyle(Color.sabatGold2)
                        .padding(.bottom, 8)
                    
                    Text(title)
                        .font(.sabatDisplay(34))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.sabatSerif(20))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SabatSpacing.xl)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button {
                    HapticEngine.confirm()
                    onSubscribe()
                } label: {
                    Text("Unlock with Sabat Premium")
                        .font(.sabatMono(14, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.sabatInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.sabatGold2)
                        .clipShape(Capsule())
                        .shadow(color: Color.sabatGold2.opacity(0.3), radius: 15, y: 5)
                }
                .buttonStyle(PillSecondaryButtonStyle())
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.bottom, SabatSpacing.xxl)
            }
        }
        .ignoresSafeArea()
    }
}

struct PaywallOverlay_Previews: PreviewProvider {
    static var previews: some View {
        PaywallOverlay(
            title: "Insights are for the premium night.",
            subtitle: "Deep sleep phases, trends, and personalized weekly decoding require Sabat Premium.",
            icon: "chart.bar.fill",
            onSubscribe: {}
        )
    }
}
