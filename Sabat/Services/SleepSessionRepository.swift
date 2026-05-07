import Foundation

actor SleepSessionRepository {
    static let shared = SleepSessionRepository()

    private let defaults: UserDefaults
    private let apiClient: APIClient
    private let healthKitService: HealthKitService
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        defaults: UserDefaults = .standard,
        apiClient: APIClient = .shared,
        healthKitService: HealthKitService = HealthKitService()
    ) {
        self.defaults = defaults
        self.apiClient = apiClient
        self.healthKitService = healthKitService
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func loadSessions() -> [SleepSession] {
        decode([SleepSession].self, key: UserDefaultsKeys.sleepSessions) ?? []
    }

    func loadLastSession() -> SleepSession? {
        decode(SleepSession.self, key: UserDefaultsKeys.lastSleepSession)
    }

    func loadActiveSession() -> SleepSession? {
        decode(SleepSession.self, key: UserDefaultsKeys.activeSleepSession)
    }

    func saveActiveSession(_ session: SleepSession) {
        encode(session, key: UserDefaultsKeys.activeSleepSession)
    }

    func clearActiveSession() {
        defaults.removeObject(forKey: UserDefaultsKeys.activeSleepSession)
    }

    func loadAlarm() -> SleepAlarm? {
        decode(SleepAlarm.self, key: UserDefaultsKeys.sleepAlarm)
    }

    func saveAlarm(_ alarm: SleepAlarm?) {
        if let alarm {
            encode(alarm, key: UserDefaultsKeys.sleepAlarm)
        } else {
            defaults.removeObject(forKey: UserDefaultsKeys.sleepAlarm)
        }
    }

    func requestHealthAuthorization() async throws {
        try await healthKitService.requestAuthorizationIfAvailable()
    }

    func finish(session: SleepSession) async throws -> SleepSession {
        var storedSession = session
        try? await healthKitService.save(session: storedSession)

        do {
            try await apiClient.saveSleepSession(storedSession)
            storedSession.syncedAt = Date()
        } catch {
            enqueuePendingSync(for: storedSession.id)
            persist(storedSession)
            clearActiveSession()
            throw error
        }

        persist(storedSession)
        clearActiveSession()
        removePendingSync(for: storedSession.id)
        return storedSession
    }

    func flushPendingSync() async {
        let ids = decode([String].self, key: UserDefaultsKeys.pendingSleepSync) ?? []
        let sessionsByID = Dictionary(uniqueKeysWithValues: loadSessions().map { ($0.id, $0) })

        for id in ids {
            guard var session = sessionsByID[id] else { continue }
            do {
                try await apiClient.saveSleepSession(session)
                session.syncedAt = Date()
                persist(session)
                removePendingSync(for: id)
            } catch {
                continue
            }
        }
    }

    private func persist(_ session: SleepSession) {
        var sessions = loadSessions().filter { $0.id != session.id }
        sessions.insert(session, at: 0)
        encode(sessions, key: UserDefaultsKeys.sleepSessions)
        encode(session, key: UserDefaultsKeys.lastSleepSession)
    }

    private func enqueuePendingSync(for id: String) {
        var ids = decode([String].self, key: UserDefaultsKeys.pendingSleepSync) ?? []
        if !ids.contains(id) {
            ids.append(id)
            encode(ids, key: UserDefaultsKeys.pendingSleepSync)
        }
    }

    private func removePendingSync(for id: String) {
        let ids = (decode([String].self, key: UserDefaultsKeys.pendingSleepSync) ?? []).filter { $0 != id }
        encode(ids, key: UserDefaultsKeys.pendingSleepSync)
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try? decoder.decode(type, from: data)
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else {
            return
        }

        defaults.set(data, forKey: key)
    }
}
