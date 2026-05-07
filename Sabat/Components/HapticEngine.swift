import UIKit

enum HapticEngine {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let selection = UISelectionFeedbackGenerator()
    private static let notification = UINotificationFeedbackGenerator()

    static func prepare() {
        light.prepare()
        medium.prepare()
        selection.prepare()
    }

    /// Tick on tab change — light, crisp
    static func tabTick() {
        light.prepare()
        light.impactOccurred(intensity: 0.55)
    }

    /// Softer tap for toggles and small interactions
    static func softTap() {
        light.prepare()
        light.impactOccurred(intensity: 0.35)
    }

    /// Medium confirmation for primary actions (set alarm, begin ritual)
    static func confirm() {
        medium.prepare()
        medium.impactOccurred(intensity: 0.7)
    }

    /// Selection change — used for sliders, pickers
    static func selectionChanged() {
        selection.prepare()
        selection.selectionChanged()
    }

    /// Success — alarm saved, ritual complete
    static func success() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    /// Error — something went wrong
    static func error() {
        notification.prepare()
        notification.notificationOccurred(.error)
    }
}
