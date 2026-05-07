import AuthenticationServices
import Foundation

struct AppleAuthRequest: Encodable {
    let identityToken: String
    let authorizationCode: String?
    let fullName: String?
    let email: String?
}

struct AuthResponse: Decodable {
    let user: User
    let tokens: AuthTokens
}

@MainActor
final class AuthService {
    private let apiClient: APIClient
    private let keychain: KeychainService

    init(apiClient: APIClient? = nil, keychain: KeychainService? = nil) {
        self.apiClient = apiClient ?? APIClient.shared
        self.keychain = keychain ?? KeychainService.shared
    }

    func signIn(with credential: ASAuthorizationAppleIDCredential) async throws -> User {
        guard
            let identityTokenData = credential.identityToken,
            let identityToken = String(data: identityTokenData, encoding: .utf8)
        else {
            throw ASAuthorizationError(.failed)
        }

        let authorizationCode = credential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
        }

        let fullName = credential.fullName
            .map(PersonNameComponentsFormatter().string(from:))
            .flatMap { $0.isEmpty ? nil : $0 }

        let request = AppleAuthRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            fullName: fullName,
            email: credential.email
        )

        let response: AuthResponse = try await apiClient.request(.authApple, body: request)
        try keychain.save(tokens: response.tokens)
        cache(user: response.user)
        return response.user
    }

    func cache(user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.cachedUser)
        }
        UserDefaults.standard.set(user.name, forKey: UserDefaultsKeys.preferredName)
    }

    func cachedUser() -> User? {
        guard
            let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.cachedUser),
            let user = try? JSONDecoder().decode(User.self, from: data)
        else {
            return nil
        }

        return user
    }

    func signOut() {
        keychain.deleteAll()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.cachedUser)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.preferredName)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
}
