import Foundation

enum APIClientError: LocalizedError {
    case invalidResponse
    case httpStatus(Int, Data)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The server returned an invalid response."
        case .httpStatus(let status, _):
            "The server returned HTTP \(status)."
        }
    }
}

struct VoiceTurnRequest: Encodable, Sendable {
    let userName: String
    let messages: [ConversationMessage]
}

struct StreamingVoiceResponse {
    let bytes: URLSession.AsyncBytes
    let sessionComplete: Bool
    let replyText: String?
}

struct EmptyAPIResponse: Decodable {}

final class APIClient: @unchecked Sendable {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let authInterceptor: AuthInterceptor

    init(
        baseURL: URL = URL(string: "http://127.0.0.1:3000")!,
        session: URLSession = .shared,
        authInterceptor: AuthInterceptor = AuthInterceptor()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authInterceptor = authInterceptor

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func request<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        try await perform(endpoint: endpoint, bodyData: nil)
    }

    func request<Response: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body
    ) async throws -> Response {
        let bodyData = try encoder.encode(body)
        return try await perform(endpoint: endpoint, bodyData: bodyData)
    }

    func streamVoice(userName: String, messages: [ConversationMessage]) async throws -> StreamingVoiceResponse {
        let bodyData = try encoder.encode(VoiceTurnRequest(userName: userName, messages: messages))
        var request = try makeRequest(endpoint: .voiceTurn, bodyData: bodyData)
        request = authInterceptor.adapt(request, endpoint: .voiceTurn)

        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        if httpResponse.statusCode == 401,
           await authInterceptor.refreshTokenIfPossible(baseURL: baseURL, session: session) {
            var retry = try makeRequest(endpoint: .voiceTurn, bodyData: bodyData)
            retry = authInterceptor.adapt(retry, endpoint: .voiceTurn)
            let (retryBytes, retryResponse) = try await session.bytes(for: retry)
            guard let retryHTTPResponse = retryResponse as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }
            try validate(retryHTTPResponse, data: Data())
            return StreamingVoiceResponse(
                bytes: retryBytes,
                sessionComplete: retryHTTPResponse.value(forHTTPHeaderField: "x-sabat-session-complete") == "true",
                replyText: decodedHeader(retryHTTPResponse.value(forHTTPHeaderField: "x-sabat-reply-text"))
            )
        }

        try validate(httpResponse, data: Data())
        return StreamingVoiceResponse(
            bytes: bytes,
            sessionComplete: httpResponse.value(forHTTPHeaderField: "x-sabat-session-complete") == "true",
            replyText: decodedHeader(httpResponse.value(forHTTPHeaderField: "x-sabat-reply-text"))
        )
    }

    func saveSleepSession(_ session: SleepSession) async throws {
        let _: EmptyAPIResponse = try await request(.sleepSessions, body: session)
    }

    func saveHeartRateSamples(userId: String, samples: [HeartRateSample]) async throws {
        struct Request: Encodable {
            let userId: String
            let samples: [HeartRateSample]
        }
        let _: EmptyAPIResponse = try await request(.heartRate, body: Request(userId: userId, samples: samples))
    }

    func saveRestRitual(userId: String, type: String, startedAt: Date, endedAt: Date?, notes: String?) async throws {
        struct Request: Encodable {
            let userId: String
            let type: String
            let startedAt: Date
            let endedAt: Date?
            let notes: String?
        }
        let _: EmptyAPIResponse = try await request(.rituals, body: Request(userId: userId, type: type, startedAt: startedAt, endedAt: endedAt, notes: notes))
    }

    private func perform<Response: Decodable>(
        endpoint: APIEndpoint,
        bodyData: Data?
    ) async throws -> Response {
        var request = try makeRequest(endpoint: endpoint, bodyData: bodyData)
        request = authInterceptor.adapt(request, endpoint: endpoint)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        if httpResponse.statusCode == 401,
           endpoint != .authApple,
           endpoint != .authRefresh,
           await authInterceptor.refreshTokenIfPossible(baseURL: baseURL, session: session) {
            var retry = try makeRequest(endpoint: endpoint, bodyData: bodyData)
            retry = authInterceptor.adapt(retry, endpoint: endpoint)
            let (retryData, retryResponse) = try await session.data(for: retry)
            guard let retryHTTPResponse = retryResponse as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }
            try validate(retryHTTPResponse, data: retryData)
            return try decoder.decode(Response.self, from: retryData)
        }

        try validate(httpResponse, data: data)
        return try decoder.decode(Response.self, from: data)
    }

    private func makeRequest(endpoint: APIEndpoint, bodyData: Data?) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: endpoint.path))
        request.httpMethod = endpoint.method
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let bodyData {
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }

    private func validate(_ response: HTTPURLResponse, data: Data) throws {
        guard (200..<300).contains(response.statusCode) else {
            throw APIClientError.httpStatus(response.statusCode, data)
        }
    }

    private func decodedHeader(_ value: String?) -> String? {
        value?.removingPercentEncoding ?? value
    }
}
