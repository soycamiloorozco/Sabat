import Foundation

enum APIEndpoint: Equatable {
    case authApple
    case authRefresh
    case userProfile
    case voiceTurn
    case sleepSessions
    case heartRate
    case rituals

    var path: String {
        switch self {
        case .authApple:
            "/auth/apple"
        case .authRefresh:
            "/auth/refresh"
        case .userProfile:
            "/user/profile"
        case .voiceTurn:
            "/voice/turn"
        case .sleepSessions:
            "/sleep/sessions"
        case .heartRate:
            "/health/heart-rate"
        case .rituals:
            "/rituals"
        }
    }

    var method: String {
        switch self {
        case .userProfile:
            "GET"
        case .authApple, .authRefresh, .voiceTurn, .sleepSessions, .heartRate, .rituals:
            "POST"
        }
    }
}
