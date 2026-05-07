import Foundation

enum APIEndpoint: Equatable {
    case authApple
    case authRefresh
    case userProfile
    case voiceTurn
    case sleepSessions

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
        }
    }

    var method: String {
        switch self {
        case .userProfile:
            "GET"
        case .authApple, .authRefresh, .voiceTurn, .sleepSessions:
            "POST"
        }
    }
}
