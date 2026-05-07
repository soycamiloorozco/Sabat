import Foundation

struct SleepSession: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let startedAt: Date
    var endedAt: Date?
    var restScore: Int?
    var alarm: SleepAlarm?
    var phaseSamples: [SleepPhaseSample]
    var syncedAt: Date?

    init(
        id: String,
        startedAt: Date,
        endedAt: Date? = nil,
        restScore: Int? = nil,
        alarm: SleepAlarm? = nil,
        phaseSamples: [SleepPhaseSample] = [],
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.restScore = restScore
        self.alarm = alarm
        self.phaseSamples = phaseSamples
        self.syncedAt = syncedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startedAt
        case endedAt
        case restScore
        case alarm
        case phaseSamples
        case syncedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        endedAt = try container.decodeIfPresent(Date.self, forKey: .endedAt)
        restScore = try container.decodeIfPresent(Int.self, forKey: .restScore)
        alarm = try container.decodeIfPresent(SleepAlarm.self, forKey: .alarm)
        phaseSamples = try container.decodeIfPresent([SleepPhaseSample].self, forKey: .phaseSamples) ?? []
        syncedAt = try container.decodeIfPresent(Date.self, forKey: .syncedAt)
    }

    var duration: TimeInterval? {
        guard let endedAt else { return nil }
        return endedAt.timeIntervalSince(startedAt)
    }
}

struct SleepAlarm: Codable, Hashable, Sendable {
    var targetWakeTime: Date
    var windowMinutes: Int
    var source: Source
    var isEnabled: Bool

    enum Source: String, Codable, Sendable {
        case user
        case voice
    }
}

struct SleepPhaseSample: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let phase: SleepPhase
    let startDate: Date
    let endDate: Date

    init(id: UUID = UUID(), phase: SleepPhase, startDate: Date, endDate: Date) {
        self.id = id
        self.phase = phase
        self.startDate = startDate
        self.endDate = endDate
    }
}
