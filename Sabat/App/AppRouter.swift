import Combine
import SwiftUI

enum AppRoute: Hashable {
    case welcome
    case voiceIntro
    case sleepIntro
    case signIn
    case nameCollection
    case notifications
    case onboardingComplete
}

final class AppRouter: ObservableObject {
    @Published
    var path = NavigationPath()
    @Published
    var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)

    var hasCompletedOnboarding: Bool {
        onboardingCompleted
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func replaceStack(with route: AppRoute) {
        path = NavigationPath()
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        onboardingCompleted = true
    }
}
