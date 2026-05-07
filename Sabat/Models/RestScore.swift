import Foundation

struct RestScore: Codable, Hashable, Sendable {
    let overall: Int
    let deepMinutes: Int
    let lightMinutes: Int

    static let empty = RestScore(overall: 0, deepMinutes: 0, lightMinutes: 0)
}
