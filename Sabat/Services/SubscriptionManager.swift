import Foundation
import Combine

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var currentTier: SubscriptionTier = .free
    
    private let tierKey = "app.sabat.subscription.tier"
    
    var isPremium: Bool {
        currentTier != .free
    }
    
    private init() {
        if let rawValue = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: rawValue) {
            self.currentTier = tier
        }
    }
    
    func purchase(_ tier: SubscriptionTier) async {
        // Mock purchase delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        self.currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
    }
    
    func restore() async {
        // Mock restore
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
