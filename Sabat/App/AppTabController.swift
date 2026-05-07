import Combine
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case rest
    case analytics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rest: "Rest"
        case .analytics: "Analytics"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .rest: "moon.fill"
        case .analytics: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }

    var accessibilityLabel: String {
        title
    }
}

@MainActor
final class AppTabController: ObservableObject {
    @Published
    var selectedTab: AppTab = .rest

    @Published
    var showRitual = false

    @Published
    var showTracking = false

    @Published
    var showSmartAlarm = false

    @Published
    var showWakeUp = false

    @Published
    var showLogin = false

    @Published
    var showRegister = false

    @Published
    var showSubscription = false

    @Published
    var showMyPlan = false

    func selectTab(_ tab: AppTab) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            selectedTab = tab
        }
    }
}
