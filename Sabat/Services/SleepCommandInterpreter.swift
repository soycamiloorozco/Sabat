import Foundation

struct SleepCommandInterpretation: Sendable {
    let alarm: SleepAlarm
    let confirmation: String
}

struct SleepCommandInterpreter {
    func interpret(_ text: String, now: Date = Date()) -> SleepCommandInterpretation? {
        let normalized = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        guard containsWakeIntent(in: normalized), let date = parseWakeTime(from: normalized, now: now) else {
            return nil
        }

        let alarm = SleepAlarm(
            targetWakeTime: date,
            windowMinutes: 30,
            source: .voice,
            isEnabled: true
        )

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        return SleepCommandInterpretation(
            alarm: alarm,
            confirmation: "Perfect. I'll wake you around \(formatter.string(from: date)) with a 30-minute light-sleep window."
        )
    }

    private func containsWakeIntent(in text: String) -> Bool {
        text.contains("wake me up") ||
        text.contains("wake me") ||
        text.contains("despiertame") ||
        text.contains("despertame") ||
        text.contains("levantame")
    }

    private func parseWakeTime(from text: String, now: Date) -> Date? {
        let patterns = [
            #"\b(\d{1,2})[:.](\d{2})\s*(a\.?m\.?|p\.?m\.?)\b"#,
            #"\b(\d{1,2})\s*(a\.?m\.?|p\.?m\.?)\b"#,
            #"\b(\d{1,2})[:.](\d{2})\b"#,
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
                continue
            }

            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            guard let match = regex.firstMatch(in: text, options: [], range: range) else {
                continue
            }

            let components = captureGroups(in: text, match: match)
            if let date = buildDate(from: components, now: now) {
                return date
            }
        }

        return nil
    }

    private func captureGroups(in text: String, match: NSTextCheckingResult) -> [String] {
        (1..<match.numberOfRanges).compactMap { index in
            let range = match.range(at: index)
            guard let swiftRange = Range(range, in: text) else { return nil }
            return String(text[swiftRange])
        }
    }

    private func buildDate(from components: [String], now: Date) -> Date? {
        guard let first = components.first, var hour = Int(first) else {
            return nil
        }

        var minute = 0
        var ampm: String?

        if components.count >= 2, let parsedMinute = Int(components[1]) {
            minute = parsedMinute
        } else if components.count >= 2 {
            ampm = components[1]
        }

        if components.count >= 3 {
            ampm = components[2]
        }

        if let ampm {
            let normalized = ampm.replacingOccurrences(of: ".", with: "").lowercased()
            if normalized == "pm", hour < 12 {
                hour += 12
            } else if normalized == "am", hour == 12 {
                hour = 0
            }
        } else if hour <= 7 {
            // Wake times without AM/PM are usually morning requests.
            hour += 0
        }

        var calendar = Calendar.current
        calendar.timeZone = .current

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute

        guard var candidate = calendar.date(from: dateComponents) else {
            return nil
        }

        if candidate <= now {
            candidate = calendar.date(byAdding: .day, value: 1, to: candidate) ?? candidate
        }

        return candidate
    }
}
