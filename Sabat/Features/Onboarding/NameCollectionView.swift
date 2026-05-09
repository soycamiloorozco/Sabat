import SwiftUI

struct NameCollectionView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var name = UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredName) ?? ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                OnboardingProgressView(current: 4, total: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.md)

                HandmadeEyeIllustration(style: .sleepy, size: 205)

                VStack(spacing: SabatSpacing.md) {
                    Text("What should Sabat call you?")
                        .font(.sabatDisplay(42))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("Your name shapes the first words you hear when the night begins.")
                        .font(.sabatSerif(21))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                TextField("Preferred name", text: $name)
                    .textInputAutocapitalization(.words)
                    .font(.sabatSans(20, weight: .medium))
                    .foregroundStyle(Color.sabatMist)
                    .padding(SabatSpacing.md)
                    .background(Color.sabatPaper.opacity(0.08))
                    .overlay {
                        Capsule()
                            .stroke(Color.sabatLine)
                    }
                    .clipShape(Capsule())

                Spacer()

                GoldButton(title: "Continue", systemImage: "arrow.right") {
                    UserDefaults.standard.set(trimmedName, forKey: UserDefaultsKeys.preferredName)
                    router.navigate(to: .notifications)
                }
                .disabled(trimmedName.isEmpty)
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
    }
}

struct NameCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NameCollectionView()
            .environmentObject(AppRouter())
    }
}
