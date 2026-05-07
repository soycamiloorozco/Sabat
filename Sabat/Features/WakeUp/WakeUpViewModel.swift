import Combine
import Foundation

final class WakeUpViewModel: ObservableObject {
    @Published
    var restScore = RestScore.empty
    @Published
    var sleepDurationText = "--"

    private let sleepRepository: SleepSessionRepository

    init(sleepRepository: SleepSessionRepository = .shared) {
        self.sleepRepository = sleepRepository
    }

    func load() {
        Task {
            guard let session = await sleepRepository.loadLastSession() else { return }
            let deepMinutes = minutes(for: .deep, in: session.phaseSamples)
            let lightMinutes = minutes(for: .light, in: session.phaseSamples)
            let score = session.restScore ?? 0
            let durationText = session.duration.flatMap { Self.durationFormatter.string(from: $0) } ?? "--"

            await MainActor.run {
                self.restScore = RestScore(overall: score, deepMinutes: deepMinutes, lightMinutes: lightMinutes)
                self.sleepDurationText = durationText
            }
        }
    }

    private func minutes(for phase: SleepPhase, in samples: [SleepPhaseSample]) -> Int {
        Int(samples.filter { $0.phase == phase }.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } / 60)
    }

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}
