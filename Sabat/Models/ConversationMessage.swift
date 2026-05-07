import Combine
import Foundation

enum ConversationRole: String, Codable, Sendable {
    case system
    case user
    case assistant
}

struct ConversationMessage: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let role: ConversationRole
    let content: String

    init(id: UUID = UUID(), role: ConversationRole, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}
