import Foundation

final class HomeViewModel: ObservableObject {
    @Published
    var preferredName = "Friend"
    @Published
    var lastSession: SleepSession?

    private let sleepRepository: SleepSessionRepository

    init(sleepRepository: SleepSessionRepository = .shared) {
        self.sleepRepository = sleepRepository
    }

    func load() {
        preferredName = UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredName) ?? "Friend"

        Task {
            let session = await sleepRepository.loadLastSession()
            await MainActor.run {
                self.lastSession = session
            }
        }
    }
}
