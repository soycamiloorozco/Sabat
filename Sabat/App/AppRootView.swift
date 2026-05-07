import Combine
import SwiftUI

struct AppRootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var tabController = AppTabController()

    var body: some View {
        Group {
            if router.onboardingCompleted {
                mainApp
            } else {
                onboardingFlow
            }
        }
        .environmentObject(router)
        .environmentObject(tabController)
    }

    // MARK: - Main App (Tab-based with horizontal swipe)

    private var mainApp: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabController.selectedTab) {
                RestTabView()
                    .tag(AppTab.rest)

                AnalyticsTabView()
                    .tag(AppTab.analytics)

                SettingsTabView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.38, dampingFraction: 0.88), value: tabController.selectedTab)
            .onChange(of: tabController.selectedTab) { _, _ in
                HapticEngine.tabTick()
            }

            AppTabBar(selectedTab: $tabController.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        // Modal flows triggered from tabs
        .sheet(isPresented: $tabController.showRitual) {
            RitualView()
                .environmentObject(tabController)
        }
        .fullScreenCover(isPresented: $tabController.showTracking) {
            SleepTrackingView()
                .environmentObject(tabController)
        }
        .sheet(isPresented: $tabController.showSmartAlarm) {
            SmartAlarmView()
        }
        .fullScreenCover(isPresented: $tabController.showWakeUp) {
            WakeUpView()
        }
        .sheet(isPresented: $tabController.showLogin) {
            LoginView()
        }
        .sheet(isPresented: $tabController.showRegister) {
            RegisterView()
        }
        .sheet(isPresented: $tabController.showSubscription) {
            SubscriptionView()
        }
        .sheet(isPresented: $tabController.showMyPlan) {
            MyPlanView()
        }
    }

    // MARK: - Onboarding Flow (kept as navigation stack)

    private var onboardingFlow: some View {
        NavigationStack(path: $router.path) {
            WelcomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    onboardingDestination(for: route)
                }
        }
        .tint(Color.sabatGold)
    }

    @ViewBuilder
    private func onboardingDestination(for route: AppRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeView()
        case .voiceIntro:
            OnboardingVoiceIntroView()
        case .sleepIntro:
            OnboardingSleepIntroView()
        case .signIn:
            SignInView()
        case .nameCollection:
            NameCollectionView()
        case .notifications:
            NotificationsPermissionView()
        case .onboardingComplete:
            OnboardingCompleteView()
        }
    }
}
