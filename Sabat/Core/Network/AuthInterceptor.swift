import Foundation

private struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

final class AuthInterceptor: @unchecked Sendable {
    private let keychain: KeychainService
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(keychain: KeychainService = .shared) {
        self.keychain = keychain
    }

    func adapt(_ request: URLRequest, endpoint: APIEndpoint) -> URLRequest {
        guard endpoint != .authApple, endpoint != .authRefresh else {
            return request
        }

        var request = request
        if let accessToken = try? keychain.read(.accessToken) {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    func refreshTokenIfPossible(baseURL: URL, session: URLSession) async -> Bool {
        guard let refreshToken = try? keychain.read(.refreshToken) else {
            return false
        }

        do {
            var request = URLRequest(url: baseURL.appending(path: APIEndpoint.authRefresh.path))
            request.httpMethod = APIEndpoint.authRefresh.method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(RefreshTokenRequest(refreshToken: refreshToken))

            let (data, response) = try await session.data(for: request)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                return false
            }

            let tokens = try decoder.decode(AuthTokens.self, from: data)
            try keychain.save(tokens: tokens)
            return true
        } catch {
            return false
        }
    }
}
