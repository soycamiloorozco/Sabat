import Foundation

enum SubscriptionTier: String, Codable, CaseIterable, Identifiable {
    case free
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    var price: String {
        switch self {
        case .free: "Free"
        case .monthly: "$4.99 / month"
        case .yearly: "$39.99 / year"
        }
    }

    var subtitle: String {
        switch self {
        case .free: "Basic sleep tracking"
        case .monthly: "Full experience, billed monthly"
        case .yearly: "Best value, save 33%"
        }
    }

    var productID: String {
        switch self {
        case .free: ""
        case .monthly: "app.sabat.subscription.monthly"
        case .yearly: "app.sabat.subscription.yearly"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "Sleep tracking",
                "Basic rest score",
                "Smart alarm (1x)",
            ]
        case .monthly:
            return [
                "Everything in Free",
                "Unlimited smart alarms",
                "Deep sleep insights",
                "Voice ritual — unlimited",
                "Sleep journal export",
            ]
        case .yearly:
            return [
                "Everything in Monthly",
                "Priority voice responses",
                "Sleep trends & predictions",
                "Family sharing (up to 4)",
                "Early access to new features",
            ]
        }
    }

    var isFree: Bool { self == .free }
}

struct SubscriptionStatus: Codable {
    var tier: SubscriptionTier
    var expiresAt: Date?
    var isActive: Bool
    var autoRenew: Bool

    static var `default`: SubscriptionStatus {
        SubscriptionStatus(tier: .free, expiresAt: nil, isActive: true, autoRenew: false)
    }

    var displayText: String {
        if tier == .free {
            return "Free plan"
        }
        if let expiresAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(tier.title) · Renews \(formatter.string(from: expiresAt))"
        }
        return tier.title
    }
}
