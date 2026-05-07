import Combine
import SwiftUI

struct MyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MyPlanViewModel()

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SabatSpacing.xxl) {
                    header

                    currentPlanCard

                    if viewModel.status.tier != .free {
                        manageSection
                    }

                    Spacer(minLength: SabatSpacing.xl)

                    upgradeButton
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.vertical, SabatSpacing.xxl)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.sabatMist)
                }
            }
        }
        .task {
            viewModel.load()
        }
    }

    private var header: some View {
        VStack(spacing: SabatSpacing.sm) {
            Text("My plan")
                .font(.sabatDisplay(32))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Manage your Sabat subscription.")
                .font(.sabatSerif(18))
                .foregroundStyle(Color.sabatMist)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var currentPlanCard: some View {
        SacredCard {
            VStack(spacing: SabatSpacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.status.tier.title)
                            .font(.sabatSans(24, weight: .bold))
                            .foregroundStyle(Color.sabatGold2)

                        Text(viewModel.status.displayText)
                            .font(.sabatSans(14))
                            .foregroundStyle(Color.sabatMuted)
                    }

                    Spacer()

                    planBadge
                }

                Divider()
                    .background(Color.sabatLine)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewModel.status.tier.features, id: \.self) { feature in
                        HStack(spacing: SabatSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.sabatDawn)

                            Text(feature)
                                .font(.sabatSans(14))
                                .foregroundStyle(Color.sabatMist)
                        }
                    }
                }
            }
        }
    }

    private var planBadge: some View {
        Text(viewModel.status.tier.isFree ? "Free" : "Active")
            .font(.sabatMono(11, weight: .semibold))
            .textCase(.uppercase)
            .foregroundStyle(viewModel.status.tier.isFree ? Color.sabatMuted : Color.sabatInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                viewModel.status.tier.isFree
                ? Color.sabatPaper.opacity(0.08)
                : Color.sabatDawn
            )
            .clipShape(Capsule())
    }

    private var manageSection: some View {
        VStack(spacing: SabatSpacing.md) {
            ToggleRow(title: "Auto-renew", isOn: $viewModel.status.autoRenew)

            Button {
                HapticEngine.softTap()
            } label: {
                HStack {
                    Text("Cancel subscription")
                        .font(.sabatSans(15, weight: .medium))
                        .foregroundStyle(Color.sabatDawn)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.sabatMuted)
                }
                .frame(height: 48)
            }
        }
    }

    private var upgradeButton: some View {
        GoldButton(title: viewModel.status.tier.isFree ? "Upgrade plan" : "Change plan", systemImage: "arrow.up.arrow.down") {
            HapticEngine.confirm()
        }
    }
}

private struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.sabatSans(15, weight: .medium))
                .foregroundStyle(Color.sabatMist)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color.sabatDawn)
                .labelsHidden()
                .frame(width: 52)
        }
        .frame(height: 48)
    }
}

final class MyPlanViewModel: ObservableObject {
    @Published
    var status = SubscriptionStatus.default

    func load() {
        // TODO: Load from backend / keychain
        status = SubscriptionStatus.default
    }
}

struct MyPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlanView()
    }
}
