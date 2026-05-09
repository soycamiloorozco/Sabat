import Foundation

struct HeartRateSample: Codable, Sendable {
    let bpm: Double
    let timestamp: Date
}
