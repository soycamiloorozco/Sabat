import Foundation

struct User: Codable, Hashable, Identifiable, Sendable {
    let id: String
    var name: String
    var email: String?
    var voiceId: String?

    static let preview = User(
        id: "preview-user",
        name: "Mateo",
        email: nil,
        voiceId: nil
    )
}
