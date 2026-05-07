import Combine
import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SubscriptionViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SabatSpacing.xxl) {
                    header

                    planCards

                    Spacer(minLength: SabatSpacing.xl)

                    restoreButton
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.vertical, SabatSpacing.xxl)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        VStack(spacing: SabatSpacing.sm) {
            Text("Choose your plan")
                .font(.sabatDisplay(32))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Unlock the full Sabat experience.")
                .font(.sabatSerif(18))
                .foregroundStyle(Color.sabatMist)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var planCards: some View {
        VStack(spacing: SabatSpacing.lg) {
            ForEach(SubscriptionTier.allCases) { tier in
                PlanCard(
                    tier: tier,
                    isSelected: viewModel.selectedTier == tier,
                    action: {
                        HapticEngine.softTap()
                        viewModel.selectTier(tier)
                    }
                )
            }
        }
    }

    private var restoreButton: some View {
        Button {
            HapticEngine.softTap()
        } label: {
            Text("Restore purchases")
                .font(.sabatSans(13, weight: .medium))
                .foregroundStyle(Color.sabatMuted)
        }
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: SabatSpacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tier.title)
                            .font(.sabatSans(20, weight: .bold))
                            .foregroundStyle(isSelected ? Color.sabatInk : Color.sabatGold2)

                        Text(tier.subtitle)
                            .font(.sabatSans(13))
                            .foregroundStyle(isSelected ? Color.sabatInk.opacity(0.7) : Color.sabatMuted)
                    }

                    Spacer()

                    Text(tier.price)
                        .font(.sabatMono(16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.sabatInk : Color.sabatDawn)
                }

                Divider()
                    .background(isSelected ? Color.sabatInk.opacity(0.12) : Color.sabatLine)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: SabatSpacing.sm) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isSelected ? Color.sabatInk : Color.sabatDawn)
                                .frame(width: 16)

                            Text(feature)
                                .font(.sabatSans(14))
                                .foregroundStyle(isSelected ? Color.sabatInk.opacity(0.85) : Color.sabatMist)
                        }
                    }
                }

                if !tier.isFree {
                    Text("Subscribe")
                        .font(.sabatMono(13, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(isSelected ? Color.sabatInk : Color.sabatDawn)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            isSelected
                            ? Color.sabatInk.opacity(0.1)
                            : Color.sabatDawn.opacity(0.15)
                        )
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }
            }
            .padding(SabatSpacing.lg)
            .background(
                isSelected
                ? Color.sabatDawn
                : Color.sabatPaper.opacity(0.05)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color.sabatDawn.opacity(0.6) : Color.sabatLine,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(PillSecondaryButtonStyle())
    }
}

// MARK: - ViewModel

final class SubscriptionViewModel: ObservableObject {
    @Published
    var selectedTier: SubscriptionTier = .monthly

    func selectTier(_ tier: SubscriptionTier) {
        selectedTier = tier
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
