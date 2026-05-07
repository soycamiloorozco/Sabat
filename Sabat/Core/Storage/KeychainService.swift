import Foundation
import Security

enum KeychainKey: String {
    case accessToken
    case refreshToken
}

struct AuthTokens: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}

enum KeychainError: LocalizedError {
    case unhandledStatus(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .unhandledStatus(let status):
            "Keychain operation failed with status \(status)."
        case .invalidData:
            "Stored keychain data is invalid."
        }
    }
}

final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()

    private let service = "xlabs.Sabat"

    private init() {}

    func save(_ value: String, for key: KeychainKey) throws {
        let data = Data(value.utf8)
        let query = baseQuery(for: key)

        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    func read(_ key: KeychainKey) throws -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }

        guard
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidData
        }

        return value
    }

    func save(tokens: AuthTokens) throws {
        try save(tokens.accessToken, for: .accessToken)
        try save(tokens.refreshToken, for: .refreshToken)
    }

    func tokens() throws -> AuthTokens? {
        guard
            let accessToken = try read(.accessToken),
            let refreshToken = try read(.refreshToken)
        else {
            return nil
        }

        return AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    func deleteAll() {
        SecItemDelete(baseQuery(for: .accessToken) as CFDictionary)
        SecItemDelete(baseQuery(for: .refreshToken) as CFDictionary)
    }

    private func baseQuery(for key: KeychainKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
    }
}
