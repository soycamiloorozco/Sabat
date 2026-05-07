import Foundation

/// Centralized localization strings. Default is English.
/// All UI text goes through here to prevent mixed-language experiences.
enum L10n {
    private static func tr(_ key: String) -> String {
        let language = LocalizationManager.shared.currentLanguage
        let dict = language == .spanish ? Translations.spanish : Translations.english
        return dict[key] ?? key
    }

    // MARK: - General
    static var goodEvening: String { tr("Good evening,") }
    static var beginLastConversation: String { tr("Begin the last conversation of the day.") }
    static var tonight: String { tr("Tonight") }
    static var smartAlarm: String { tr("Smart Alarm") }
    static var analytics: String { tr("Analytics") }
    static var settings: String { tr("Settings") }
    static var rest: String { tr("Rest") }
    static var save: String { tr("Save") }
    static var continueText: String { tr("Continue") }
    static var cancel: String { tr("Cancel") }

    // MARK: - Home
    static var wakeUpGently: String { tr("Wake up gently during your lightest sleep phase.") }
    static var configureAlarm: String { tr("Configure alarm") }
    static var windDownDescription: String { tr("A 2 to 5 minute wind-down, then silence.") }
    static var beginRitual: String { tr("Begin ritual") }
    static var lastSession: String { tr("Last session") }
    static var firstNightTitle: String { tr("Your first night") }
    static var firstNightDescription: String { tr("Tap 'Begin ritual' above to start your wind-down. After you sleep, your rest score and sleep phases will appear here.") }
    static var noNightsTracked: String { tr("No nights tracked yet.") }
    static var startTonight: String { tr("Start tonight") }
    static var noNightsDescription: String { tr("Begin your first ritual tonight and Sabat will build your sleep picture here.") }

    // MARK: - Smart Alarm
    static var smartAlarmTitle: String { tr("Smart Alarm") }
    static var wakeUpGentlyLightSleep: String { tr("Wake up gently during light sleep") }
    static var wakeUpWindow: String { tr("Wake-up window") }
    static var minutesBeforeTarget: String { tr("minutes before target time") }
    static var earliest: String { tr("Earliest") }
    static var target: String { tr("Target") }
    static var sleepPhaseDetection: String { tr("Sleep phase detection") }
    static var smartWakeUp: String { tr("Smart wake-up") }
    static var alarmAdapts: String { tr("Alarm adapts to your sleep cycle") }
    static var setAlarm: String { tr("Set alarm") }
    static var updateAlarm: String { tr("Update alarm") }
    static var cancelAlarm: String { tr("Cancel alarm") }

    // MARK: - Ritual
    static var sabatVoice: String { tr("Sabat Voice") }
    static var listening: String { tr("Listening...") }
    static var thinking: String { tr("Thinking...") }
    static var enterSleepMode: String { tr("Enter sleep mode") }
    static var tellSabat: String { tr("Tell Sabat what is here") }

    // MARK: - Sleep Tracking
    static var sabatWithYou: String { tr("Sabat is with you tonight.") }
    static var trackingDescription: String { tr("Your sleep is being tracked and prepared for Health and your sleep log.") }
    static var wakeMeUp: String { tr("Wake me up") }
    static var currentPhase: String { tr("Current phase") }
    static var wakeUpEasy: String { tr("Wake up easy between") }
    static var and: String { tr("and") }
    static var endSession: String { tr("End session") }
    static var imAwake: String { tr("I'm awake") }

    // MARK: - Wake Up
    static var morning: String { tr("Morning.") }
    static var returnHome: String { tr("Return home") }

    // MARK: - Profile
    static var tuneSabat: String { tr("Tune Sabat") }
    static var identity: String { tr("Identity") }
    static var howSabatGreets: String { tr("How Sabat greets you") }
    static var preferredNamePlaceholder: String { tr("Preferred name") }
    static var voice: String { tr("Voice") }
    static var presenceAndPersonality: String { tr("Presence and personality") }
    static var voiceDescription: String { tr("Sabat should feel like a loving grandfather: close, steady, and patient.") }
    static var reminders: String { tr("Reminders") }
    static var smallPauses: String { tr("Small pauses across the day") }
    static var sabatReminders: String { tr("Sabat reminders") }
    static var remindersDescription: String { tr("Night ritual plus gentle daytime breath cues.") }
    static var daytimePauses: String { tr("Daytime pauses") }
    static var daytimeDescription: String { tr("A small reminder to stop, breathe, and hear.") }
    static var reminderTime: String { tr("Reminder time") }
    static var sleep: String { tr("Sleep") }
    static var wakeUpSettings: String { tr("Wake-up settings") }
    static var smartAlarmWindow: String { tr("Smart alarm window") }
    static var windowDescription: String { tr("Sabat will aim for light sleep inside this window once tracking is enabled.") }
    static var saveProfile: String { tr("Save profile") }
    static var profileSaved: String { tr("Profile saved.") }
    static var account: String { tr("Account") }
    static var signInToSync: String { tr("Sign in to sync across devices") }
    static var signIn: String { tr("Sign in") }
    static var createAccount: String { tr("Create account") }
    static var plan: String { tr("Plan") }
    static var yourSubscription: String { tr("Your Sabat subscription") }
    static var myPlan: String { tr("My plan") }
    static var free: String { tr("Free") }
    static var upgrade: String { tr("Upgrade") }
    static var language: String { tr("Language") }
    static var chooseLanguage: String { tr("Choose your preferred language") }

    // MARK: - Onboarding
    static var welcomeTitle: String { tr("Sabat") }
    static var welcomeSubtitle: String { tr("A calm voice with presence for the last conversation of the day.") }
    static var beginYourRest: String { tr("Begin your rest") }
    static var voiceIntro1: String { tr("A voice that does not rush you.") }
    static var voiceIntro2: String { tr("Like a grandfather who wants to see you well.") }
    static var voiceIntro3: String { tr("You deserve to rest.") }
    static var voiceIntroDescription: String { tr("Sabat remembers what weighs on you, then brings you back one breath at a time.") }
    static var nightShape: String { tr("Your night gets a shape.") }
    static var nightShapeDescription: String { tr("Ritual first. Tracking later. Nothing loud, nothing busy, nothing asking you to perform.") }
    static var keepPrivate: String { tr("Keep the night private.") }
    static var keepPrivateDescription: String { tr("Sign in with Apple so your ritual, voice settings, and sleep history stay tied to you.") }
    static var continueInDev: String { tr("Continue in development") }
    static var whatCallYou: String { tr("What should Sabat call you?") }
    static var nameShapes: String { tr("Your name shapes the first words you hear when the night begins.") }
    static var letSabatFind: String { tr("Let Sabat find you in the day") }
    static var allowPauses: String { tr("Allow pauses") }
    static var notNow: String { tr("Not now") }
    static var ritualReady: String { tr("The ritual is ready.") }
    static var ritualReadyDescription: String { tr("Tonight, Sabat will meet you by name and leave you in silence.") }
    static var goHome: String { tr("Go home") }

    // MARK: - Analytics
    static var yourWeekDecoded: String { tr("Your week, decoded quietly.") }
    static var avgSleep: String { tr("Avg sleep") }
    static var sevenNightMean: String { tr("7 night mean") }
    static var consistency: String { tr("Consistency") }
    static var bedtimeRhythm: String { tr("bedtime rhythm") }
    static var weekRhythm: String { tr("Week rhythm") }
    static var scoreAndTotal: String { tr("Score and total sleep by night") }
    static var sleepDuration: String { tr("Sleep duration") }
    static var scorePressure: String { tr("Score pressure") }
    static var sleepPhases: String { tr("Sleep phases") }
    static var estimatedSplit: String { tr("Estimated split across the week") }
    static var bestNight: String { tr("Best night") }
    static var restScore: String { tr("rest score") }
    static var deepTotal: String { tr("Deep total") }
    static var weekly: String { tr("weekly") }
    static var awakeTime: String { tr("Awake time") }
    static var interruptions: String { tr("interruptions") }
    static var smartAlarmTarget: String { tr("Smart alarm") }
    static var targetPhase: String { tr("target phase") }
    static var nightLog: String { tr("Night log") }
    static var recentSessions: String { tr("Recent sessions") }
    static var hoursAbbrev: String { tr("hours") }
    static var deepAbbrev: String { tr("deep") }
    static var remAbbrev: String { tr("REM") }
    static var noData: String { tr("No data") }

    // MARK: - Auth
    static var welcomeBack: String { tr("Welcome back") }
    static var signInToContinue: String { tr("Sign in to continue your rest journey.") }
    static var email: String { tr("Email") }
    static var password: String { tr("Password") }
    static var signingIn: String { tr("Signing in...") }
    static var signInAction: String { tr("Sign in action") }
    static var forgotPassword: String { tr("Forgot password?") }
    static var newToSabat: String { tr("New to Sabat?") }
    static var createAccountAction: String { tr("Create account action") }
    static var createAccountTitle: String { tr("Create account title") }
    static var restJourneyBegins: String { tr("Your rest journey begins here.") }
    static var yourName: String { tr("Your name") }
    static var confirmPassword: String { tr("Confirm password") }
    static var creating: String { tr("Creating...") }
    static var alreadyHaveAccount: String { tr("Already have an account?") }

    // MARK: - Subscription
    static var chooseYourPlan: String { tr("Choose your plan") }
    static var unlockFull: String { tr("Unlock the full Sabat experience.") }
    static var restorePurchases: String { tr("Restore purchases") }
    static var monthly: String { tr("Monthly") }
    static var monthlySubtitle: String { tr("Full experience, billed monthly") }
    static var yearly: String { tr("Yearly") }
    static var yearlySubtitle: String { tr("Best value, save 33%") }
    static var freePlan: String { tr("Free plan") }
    static var basicTracking: String { tr("Basic sleep tracking") }
    static var subscribe: String { tr("Subscribe") }
    static var managePlan: String { tr("Manage your Sabat subscription.") }
    static var autoRenew: String { tr("Auto-renew") }
    static var cancelSubscription: String { tr("Cancel subscription") }
    static var upgradePlan: String { tr("Upgrade plan") }
    static var changePlan: String { tr("Change plan") }
    static var active: String { tr("Active") }
    static var freePlanStatus: String { tr("Free plan status") }

    // MARK: - LLM Insights
    static var personalizedInsight: String { tr("Personalized insight") }
    static var basedOnYourSleep: String { tr("Based on your sleep patterns") }
    static var insightLoading: String { tr("Analyzing your rest...") }
    static var noInsightYet: String { tr("Complete a few nights to receive personalized insights.") }

    // MARK: - Misc
    static var notificationsLater: String { tr("Notifications can be enabled later from Profile.") }
    static var profileUpdated: String { tr("Profile updated.") }
    static var remindersOn: String { tr("Reminders are on.") }
    static var notificationsNotEnabled: String { tr("Notifications were not enabled.") }
}
