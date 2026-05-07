import Combine
import Foundation

final class InsightsViewModel: ObservableObject {
    @Published
    var sessions: [SleepSession] = []
    @Published
    var isPreviewData = true
    @Published
    var insights: [SleepInsight] = []
    @Published
    var isLoadingInsights = false

    private let sleepRepository: SleepSessionRepository
    private let insightService = LLMInsightService.shared

    init(sleepRepository: SleepSessionRepository = .shared) {
        self.sleepRepository = sleepRepository
    }

    func load() {
        Task {
            let sessions = await sleepRepository.loadSessions()
            let insights = await insightService.generateInsights(from: sessions)
            await MainActor.run {
                self.sessions = sessions
                self.isPreviewData = sessions.isEmpty
                self.insights = insights
                self.isLoadingInsights = false
            }
        }
    }

    var displayNights: [InsightNight] {
        guard !sessions.isEmpty else { return [] }

        return sessions.prefix(7).enumerated().map { index, session in
            let duration = session.duration ?? TimeInterval(7.4 * 3600)
            return InsightNight(
                id: session.id,
                weekday: session.startedAt.formatted(.dateTime.weekday(.abbreviated)),
                score: session.restScore ?? max(52, 86 - index * 4),
                hours: duration / 3600,
                deepMinutes: session.phaseSamples.minutes(for: .deep),
                remMinutes: session.phaseSamples.minutes(for: .rem),
                awakeMinutes: session.phaseSamples.minutes(for: .awake)
            )
        }
    }

    var averageScore: Int {
        let nights = displayNights
        guard !nights.isEmpty else { return 0 }
        return nights.map(\.score).reduce(0, +) / nights.count
    }

    var averageHours: Double {
        let nights = displayNights
        guard !nights.isEmpty else { return 0 }
        return nights.map(\.hours).reduce(0, +) / Double(nights.count)
    }

    var consistency: Int {
        let nights = displayNights
        guard !nights.isEmpty else { return 0 }
        let average = averageHours
        let drift = nights.map { abs($0.hours - average) }.reduce(0, +) / Double(nights.count)
        return max(42, min(96, Int(96 - drift * 18)))
    }

    var phaseTotals: PhaseTotals {
        displayNights.reduce(PhaseTotals()) { totals, night in
            PhaseTotals(
                deep: totals.deep + night.deepMinutes,
                rem: totals.rem + night.remMinutes,
                light: totals.light + max(0, Int(night.hours * 60) - night.deepMinutes - night.remMinutes - night.awakeMinutes),
                awake: totals.awake + night.awakeMinutes
            )
        }
    }
}

struct InsightNight: Identifiable, Hashable {
    let id: String
    let weekday: String
    let score: Int
    let hours: Double
    let deepMinutes: Int
    let remMinutes: Int
    let awakeMinutes: Int

    static let previewWeek = [
        InsightNight(id: "mon", weekday: "Mon", score: 76, hours: 7.1, deepMinutes: 82, remMinutes: 96, awakeMinutes: 18),
        InsightNight(id: "tue", weekday: "Tue", score: 81, hours: 7.7, deepMinutes: 94, remMinutes: 102, awakeMinutes: 12),
        InsightNight(id: "wed", weekday: "Wed", score: 68, hours: 6.3, deepMinutes: 61, remMinutes: 84, awakeMinutes: 31),
        InsightNight(id: "thu", weekday: "Thu", score: 84, hours: 8.0, deepMinutes: 101, remMinutes: 110, awakeMinutes: 9),
        InsightNight(id: "fri", weekday: "Fri", score: 79, hours: 7.4, deepMinutes: 88, remMinutes: 93, awakeMinutes: 16),
        InsightNight(id: "sat", weekday: "Sat", score: 87, hours: 8.2, deepMinutes: 108, remMinutes: 118, awakeMinutes: 7),
        InsightNight(id: "sun", weekday: "Sun", score: 83, hours: 7.8, deepMinutes: 96, remMinutes: 106, awakeMinutes: 11)
    ]
}

struct PhaseTotals {
    var deep = 0
    var rem = 0
    var light = 0
    var awake = 0

    var total: Int {
        max(1, deep + rem + light + awake)
    }
}

private extension Array where Element == SleepPhaseSample {
    func minutes(for phase: SleepPhase) -> Int {
        Int(
            filter { $0.phase == phase }
                .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } / 60
        )
    }
}
