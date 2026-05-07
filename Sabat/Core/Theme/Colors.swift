import SwiftUI

extension Color {
    static let sabatInk = Color(red: 0.065, green: 0.066, blue: 0.064)
    static let sabatDeep = Color(red: 0.095, green: 0.096, blue: 0.092)
    static let sabatNight = Color(red: 0.14, green: 0.14, blue: 0.135)
    static let sabatPaper = Color(red: 0.965, green: 0.965, blue: 0.945)
    static let sabatPaper2 = Color(red: 0.995, green: 0.995, blue: 0.982)
    static let sabatGold = Color.sabatPaper
    static let sabatGold2 = Color.sabatPaper2
    static let sabatLine = Color.sabatPaper.opacity(0.16)
    static let sabatMist = Color.sabatPaper.opacity(0.92)
    static let sabatMuted = Color.sabatPaper.opacity(0.72)
    static let sabatSmoke = Color(red: 0.38, green: 0.38, blue: 0.36)

    // Blue dawn accents — used for time, alarm, and active states
    static let sabatDawn = Color(red: 0.47, green: 0.68, blue: 0.92)
    static let sabatDawnDeep = Color(red: 0.22, green: 0.42, blue: 0.72)
    static let sabatDawnGlow = Color(red: 0.47, green: 0.68, blue: 0.92).opacity(0.25)
    static let sabatDawnMist = Color(red: 0.47, green: 0.68, blue: 0.92).opacity(0.12)
}
