import Combine
import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SabatSpacing.xl) {
                    header

                    if viewModel.sessions.isEmpty {
                        emptyStateSection
                    } else {
                        insightsSection
                        scoreSection
                        weekSection
                        phaseSection
                        rhythmSection
                        nightsSection
                    }
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.top, SabatSpacing.xl)
                .padding(.bottom, SabatSpacing.xxl)
            }
            .refreshable {
                viewModel.load()
            }
            .tint(Color.sabatDawn)
        }
        .task {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SabatSpacing.sm) {
            Text(L10n.analytics)
                .font(.sabatSans(15, weight: .medium))
                .foregroundStyle(Color.sabatMuted)

            Text(L10n.yourWeekDecoded)
                .font(.sabatDisplay(32))
                .foregroundStyle(Color.sabatGold2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var insightsSection: some View {
        VStack(spacing: SabatSpacing.md) {
            HStack {
                Text(L10n.personalizedInsight)
                    .font(.sabatMono(12, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.sabatMuted)
                    .tracking(1.4)

                Spacer()

                if viewModel.isLoadingInsights {
                    ProgressView()
                        .tint(Color.sabatMuted)
                        .scaleEffect(0.7)
                }
            }

            ForEach(viewModel.insights) { insight in
                InsightCard(insight: insight)
            }

            if viewModel.insights.isEmpty && !viewModel.isLoadingInsights {
                Text(L10n.noInsightYet)
                    .font(.sabatSerif(16))
                    .foregroundStyle(Color.sabatMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SabatSpacing.md)
            }
        }
    }

    private var emptyStateSection: some View {
        SacredCard {
            VStack(spacing: SabatSpacing.lg) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.sabatDawn.opacity(0.6))

                Text(L10n.noNightsTracked)
                    .font(.sabatDisplay(28))
                    .foregroundStyle(Color.sabatGold2)
                    .multilineTextAlignment(.center)

                Text(L10n.noNightsDescription)
                    .font(.sabatSerif(18))
                    .foregroundStyle(Color.sabatMist)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    HapticEngine.softTap()
                } label: {
                    Text(L10n.startTonight)
                        .font(.sabatMono(14, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.sabatInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.sabatDawn)
                        .clipShape(Capsule())
                }
                .buttonStyle(PillSecondaryButtonStyle())
            }
            .padding(.vertical, SabatSpacing.xl)
        }
    }

    private var scoreSection: some View {
        HStack(spacing: SabatSpacing.md) {
            RestScoreRing(score: viewModel.averageScore)
                .frame(maxWidth: .infinity)

            VStack(spacing: SabatSpacing.md) {
                MetricTile(title: "Avg sleep", value: String(format: "%.1fh", viewModel.averageHours), caption: "7 night mean")
                MetricTile(title: "Consistency", value: "\(viewModel.consistency)%", caption: "bedtime rhythm")
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var weekSection: some View {
        AnalyticsSection(title: "Week rhythm", subtitle: "Score and total sleep by night") {
            VStack(spacing: SabatSpacing.lg) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(viewModel.displayNights) { night in
                        VStack(spacing: SabatSpacing.sm) {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 18, height: max(34, night.hours / 9 * 128))
                                .overlay(alignment: .top) {
                                    Capsule()
                                        .fill(Color.sabatInk.opacity(0.18))
                                        .frame(height: CGFloat(max(2, 100 - night.score)) / 100 * 52)
                                }
                                .clipShape(Capsule())
                                .accessibilityLabel("Sleep duration on \(night.weekday): \(String(format: "%.1f", night.hours)) hours, score: \(night.score)")

                            Text(night.weekday)
                                .font(.sabatMono(10, weight: .semibold))
                                .foregroundStyle(Color.sabatMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 170)

                HStack {
                    LegendDot(label: "Sleep duration", color: .white)
                    Spacer()
                    LegendDot(label: "Score pressure", color: Color.sabatInk.opacity(0.38))
                }
            }
        }
    }

    private var phaseSection: some View {
        AnalyticsSection(title: "Sleep phases", subtitle: "Estimated split across the week") {
            VStack(spacing: SabatSpacing.lg) {
                GeometryReader { proxy in
                    let totalWidth = proxy.size.width
                    HStack(spacing: 4) {
                        phaseBar(width: totalWidth, minutes: viewModel.phaseTotals.deep, opacity: 1)
                            .accessibilityLabel("Deep sleep: \(viewModel.phaseTotals.deep) minutes")
                        phaseBar(width: totalWidth, minutes: viewModel.phaseTotals.rem, opacity: 0.72)
                            .accessibilityLabel("REM sleep: \(viewModel.phaseTotals.rem) minutes")
                        phaseBar(width: totalWidth, minutes: viewModel.phaseTotals.light, opacity: 0.42)
                            .accessibilityLabel("Light sleep: \(viewModel.phaseTotals.light) minutes")
                        phaseBar(width: totalWidth, minutes: viewModel.phaseTotals.awake, opacity: 0.22)
                            .accessibilityLabel("Awake time: \(viewModel.phaseTotals.awake) minutes")
                    }
                }
                .frame(height: 20)
                .clipShape(Capsule())

                VStack(spacing: SabatSpacing.sm) {
                    PhaseRow(name: "Deep", minutes: viewModel.phaseTotals.deep, opacity: 1)
                    PhaseRow(name: "REM", minutes: viewModel.phaseTotals.rem, opacity: 0.72)
                    PhaseRow(name: "Light", minutes: viewModel.phaseTotals.light, opacity: 0.42)
                    PhaseRow(name: "Awake", minutes: viewModel.phaseTotals.awake, opacity: 0.22)
                }
            }
        }
    }

    private var rhythmSection: some View {
        VStack(spacing: SabatSpacing.md) {
            HStack(spacing: SabatSpacing.md) {
                MetricTile(title: "Best night", value: "\(viewModel.displayNights.map(\.score).max() ?? 0)", caption: "rest score")
                MetricTile(title: "Deep total", value: "\(viewModel.phaseTotals.deep)m", caption: "weekly")
            }

            HStack(spacing: SabatSpacing.md) {
                MetricTile(title: "Awake time", value: "\(viewModel.phaseTotals.awake)m", caption: "interruptions")
                MetricTile(title: "Smart alarm", value: "Light", caption: "target phase")
            }
        }
    }

    private var nightsSection: some View {
        AnalyticsSection(title: "Night log", subtitle: "Recent sessions") {
            VStack(spacing: SabatSpacing.sm) {
                ForEach(viewModel.displayNights) { night in
                    HStack(spacing: SabatSpacing.md) {
                        Text(night.weekday)
                            .font(.sabatMono(12, weight: .semibold))
                            .foregroundStyle(Color.sabatMuted)
                            .frame(width: 42, alignment: .leading)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: "%.1f hours", night.hours))
                                .font(.sabatSans(15, weight: .semibold))
                                .foregroundStyle(Color.sabatMist)

                            Text("\(night.deepMinutes)m deep • \(night.remMinutes)m REM")
                                .font(.sabatSans(12))
                                .foregroundStyle(Color.sabatMuted)
                        }

                        Spacer()

                        Text("\(night.score)")
                            .font(.sabatDisplay(24))
                            .foregroundStyle(Color.sabatGold2)
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.sabatLine)
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    private func phaseBar(width: CGFloat, minutes: Int, opacity: Double) -> some View {
        Rectangle()
            .fill(Color.white.opacity(opacity))
            .frame(width: max(8, width * CGFloat(minutes) / CGFloat(viewModel.phaseTotals.total)))
    }
}

private struct AnalyticsSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SabatSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.sabatMono(12, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.sabatMist)
                    .tracking(1.4)

                Text(subtitle)
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatMuted)
            }

            content
        }
        .padding(SabatSpacing.md)
        .background(Color.sabatPaper.opacity(0.045))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.sabatLine, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.sabatMono(10, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(Color.sabatMuted)
                .tracking(1.1)

            Text(value)
                .font(.sabatDisplay(30))
                .foregroundStyle(Color.sabatGold2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(caption)
                .font(.sabatSans(12))
                .foregroundStyle(Color.sabatMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SabatSpacing.md)
        .background(Color.sabatPaper.opacity(0.045))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.sabatLine, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LegendDot: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.sabatSans(11))
                .foregroundStyle(Color.sabatMuted)
        }
    }
}

private struct PhaseRow: View {
    let name: String
    let minutes: Int
    let opacity: Double

    var body: some View {
        HStack {
            LegendDot(label: name, color: Color.white.opacity(opacity))
            Spacer()
            Text("\(minutes)m")
                .font(.sabatMono(12, weight: .semibold))
                .foregroundStyle(Color.sabatMist)
        }
    }
}

private struct InsightCard: View {
    let insight: SleepInsight

    var body: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                HStack(spacing: SabatSpacing.sm) {
                    Image(systemName: insight.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(insight.color)

                    Text(insight.title)
                        .font(.sabatSans(16, weight: .semibold))
                        .foregroundStyle(Color.sabatGold2)
                        .lineLimit(2)

                    Spacer()
                }

                Text(insight.body)
                    .font(.sabatSerif(15))
                    .foregroundStyle(Color.sabatMist)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(insight.color)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                .padding(.vertical, SabatSpacing.md)
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
