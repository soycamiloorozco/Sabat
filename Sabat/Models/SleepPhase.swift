import Foundation

enum SleepPhase: String, Codable, CaseIterable, Sendable {
    case awake
    case light
    case deep
    case rem
}
