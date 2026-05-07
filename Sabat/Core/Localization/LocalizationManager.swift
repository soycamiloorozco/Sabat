import Combine
import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: UserDefaultsKeys.appLanguage)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: UserDefaultsKeys.appLanguage)
        self.currentLanguage = AppLanguage(rawValue: stored ?? "en") ?? .english
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("sabat.languageChanged")
}
