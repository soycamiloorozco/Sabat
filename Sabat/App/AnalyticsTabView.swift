import SwiftUI

struct AnalyticsTabView: View {
    @EnvironmentObject private var tabController: AppTabController
    @StateObject private var subscription = SubscriptionManager.shared

    var body: some View {
        ZStack {
            InsightsView()
            
            if !subscription.isPremium {
                PaywallOverlay(
                    title: "Insights are for the premium night.",
                    subtitle: "Deep sleep phases, trends, and personalized weekly decoding require Sabat Premium.",
                    icon: "chart.bar.fill",
                    onSubscribe: {
                        tabController.showSubscription = true
                    }
                )
            }
        }
    }
}
