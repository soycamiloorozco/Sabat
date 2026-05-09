import Combine
import Foundation
import HealthKit

@MainActor
final class DaytimePauseService: ObservableObject {
    static let shared = DaytimePauseService()
    
    @Published var activeRecommendation: PauseRecommendation?
    @Published var isChecking = false
    
    private let healthKit = HealthKitService()
    private let subscription = SubscriptionManager.shared
    
    private init() {}
    
    func checkPulse() async {
        guard subscription.isPremium else { return }
        
        isChecking = true
        defer { isChecking = false }
        
        do {
            try await healthKit.requestAuthorizationIfAvailable()
            
            let oneHourAgo = Date().addingTimeInterval(-3600)
            let samples = try await healthKit.fetchHeartRateSamples(since: oneHourAgo)
            
            // Sync with backend if logged in
            if let user = AuthService().cachedUser() {
                let heartRateSamples = samples.map { sample in
                    HeartRateSample(
                        bpm: sample.quantity.doubleValue(for: HKUnit(from: "count/min")),
                        timestamp: sample.startDate
                    )
                }
                try? await APIClient.shared.saveHeartRateSamples(userId: user.id, samples: heartRateSamples)
            }
            
            let highPulseSamples = samples.filter { sample in
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                return bpm > 95
            }
            
            if highPulseSamples.count >= 3 {
                activeRecommendation = PauseRecommendation(
                    id: UUID(),
                    title: "A moment of stillness",
                    body: "Sabat noticed your pulse is slightly accelerated. Take 2 minutes to breathe with me?",
                    type: .stress
                )
            } else {
                activeRecommendation = nil
            }
        } catch {
            print("DaytimePauseService error: \(error)")
        }
    }
    
    func trackRitualCompletion(type: String, startedAt: Date, notes: String? = nil) async {
        guard let user = AuthService().cachedUser() else { return }
        
        try? await APIClient.shared.saveRestRitual(
            userId: user.id,
            type: type,
            startedAt: startedAt,
            endedAt: Date(),
            notes: notes
        )
    }
}

struct PauseRecommendation: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let type: RecommendationType
    
    enum RecommendationType {
        case stress, routine, afternoon
    }
}
