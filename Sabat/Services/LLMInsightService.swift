import Foundation
import SwiftUI

/// Generates personalized sleep insights based on user's sleep data.
/// In production, this calls the backend Anthropic API. For now, it uses
/// rule-based generation that feels personal and hyper-customized.
struct LLMInsightService {
    static let shared = LLMInsightService()

    func generateInsights(from sessions: [SleepSession]) async -> [SleepInsight] {
        guard !sessions.isEmpty else { return [] }

        let insights: [SleepInsight] = await generateRuleBasedInsights(sessions: sessions)
        return insights.prefix(2).map { $0 }
    }

    private func generateRuleBasedInsights(sessions: [SleepSession]) async -> [SleepInsight] {
        let totalNights = sessions.count
        let avgDuration = sessions.compactMap { $0.duration }.reduce(0, +) / Double(totalNights)
        _ = sessions.compactMap { $0.restScore }.reduce(0, +) / totalNights
        
        // Break up complex expression for type-checker
        let allPhaseSamples = sessions.flatMap { $0.phaseSamples }
        let deepSamples = allPhaseSamples.filter { $0.phase == .deep }
        let deepMinutes = deepSamples.reduce(0) { total, sample in
            total + Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
        }
        let deepAvg = totalNights > 0 ? deepMinutes / totalNights : 0

        var insights: [SleepInsight] = []

        // Insight 1: Duration-based
        let hours = avgDuration / 3600
        if hours < 6 {
            insights.append(SleepInsight(
                category: .priority,
                title: "Your nights are asking for more time",
                body: "You've averaged \(String(format: "%.1f", hours)) hours recently. Even 30 more minutes can shift how you feel when the alarm sounds. Try winding down 15 minutes earlier tonight.",
                icon: "moon.zzz.fill",
                color: .sabatDawn
            ))
        } else if hours > 8.5 {
            insights.append(SleepInsight(
                category: .notice,
                title: "You're giving your body plenty of rest",
                body: "Your average of \(String(format: "%.1f", hours)) hours is generous. If you wake feeling groggy, your body may be cycling through extra REM. Trust the rhythm.",
                icon: "sparkles",
                color: .sabatGold2
            ))
        } else {
            insights.append(SleepInsight(
                category: .positive,
                title: "Your sleep duration is in a healthy range",
                body: "Averaging \(String(format: "%.1f", hours)) hours puts you in a solid window. Consistency here matters more than perfection.",
                icon: "checkmark.circle.fill",
                color: .sabatDawn
            ))
        }

        // Insight 2: Deep sleep based
        if deepAvg < 60 {
            insights.append(SleepInsight(
                category: .priority,
                title: "Deep sleep is running light",
                body: "Your deep sleep has averaged \(deepAvg)m recently. A cooler room (65–68°F / 18–20°C) and avoiding screens 30 minutes before ritual can help your body sink further.",
                icon: "waveform.path.ecg",
                color: .sabatDawn
            ))
        } else if deepAvg > 100 {
            insights.append(SleepInsight(
                category: .positive,
                title: "Your deep sleep is strong",
                body: "Averaging \(deepAvg)m of deep sleep is excellent. Your body is getting the restoration it needs. Keep the wind-down ritual consistent.",
                icon: "shield.fill",
                color: .sabatGold2
            ))
        }

        // Insight 3: Score trend
        if let last = sessions.last?.restScore, let first = sessions.first?.restScore {
            let trend = last - first
            if trend > 10 {
                insights.append(SleepInsight(
                    category: .positive,
                    title: "Your rest score is climbing",
                    body: "Up \(trend) points since your first tracked night. Whatever you're doing before sleep is working. Notice what feels different.",
                    icon: "arrow.up.forward",
                    color: .sabatGold2
                ))
            } else if trend < -10 {
                insights.append(SleepInsight(
                    category: .priority,
                    title: "Your rest has been heavier lately",
                    body: "Your score has drifted down \(abs(trend)) points. This happens. The ritual is here when you're ready to come back to it.",
                    icon: "arrow.down.forward",
                    color: .sabatDawn
                ))
            }
        }

        return insights.shuffled()
    }
}

struct SleepInsight: Identifiable {
    let id = UUID()
    let category: InsightCategory
    let title: String
    let body: String
    let icon: String
    let color: Color
}

enum InsightCategory: String {
    case priority, positive, notice
}
