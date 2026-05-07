//
//  SabatApp.swift
//  Sabat
//
//  Created by COrozco on 7/05/26.
//

import SwiftUI
import BackgroundTasks

@main
struct SabatApp: App {
    @UIApplicationDelegateAdaptor(SabatAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

final class SabatAppDelegate: NSObject, UIApplicationDelegate {
    private let sleepTrackingTaskIdentifier = "app.sabat.sleep-tracking"
    private let sleepRepository = SleepSessionRepository.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: sleepTrackingTaskIdentifier, using: nil) { task in
            task.setTaskCompleted(success: true)
        }

        Task {
            await sleepRepository.flushPendingSync()
        }

        return true
    }
}
