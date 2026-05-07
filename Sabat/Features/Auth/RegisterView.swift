import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var passwordsMatch: Bool {
        password.isEmpty || confirmPassword.isEmpty || password == confirmPassword
    }

    var body: some View {
        ZStack {
            MidnightBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: SabatSpacing.xl) {
                    header

                    formSection

                    Spacer(minLength: SabatSpacing.xl)

                    actionButtons
                }
                .padding(.horizontal, SabatSpacing.lg)
                .padding(.vertical, SabatSpacing.xxl)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        VStack(spacing: SabatSpacing.sm) {
            Text("Create account")
                .font(.sabatDisplay(36))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Your rest journey begins here.")
                .font(.sabatSerif(18))
                .foregroundStyle(Color.sabatMist)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var formSection: some View {
        VStack(spacing: SabatSpacing.lg) {
            SabatTextField(title: "Your name", text: $name, icon: "person.fill")
            SabatTextField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
            SabatTextField(title: "Password", text: $password, icon: "lock.fill", isSecure: true)
            SabatTextField(title: "Confirm password", text: $confirmPassword, icon: "lock.shield.fill", isSecure: true)

            if let errorMessage {
                Text(errorMessage)
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatDawn)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !passwordsMatch {
                Text("Passwords do not match.")
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatDawn)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: SabatSpacing.md) {
            GoldButton(title: isLoading ? "Creating..." : "Create account", systemImage: "person.badge.plus") {
                HapticEngine.confirm()
                performRegister()
            }
            .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty || !passwordsMatch)

            HStack(spacing: SabatSpacing.sm) {
                Text("Already have an account?")
                    .font(.sabatSans(14))
                    .foregroundStyle(Color.sabatMuted)

                Button {
                    HapticEngine.softTap()
                } label: {
                    Text("Sign in")
                        .font(.sabatSans(14, weight: .semibold))
                        .foregroundStyle(Color.sabatDawn)
                }
            }
        }
    }

    private func performRegister() {
        isLoading = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                isLoading = false
                UserDefaults.standard.set(name, forKey: UserDefaultsKeys.preferredName)
                HapticEngine.success()
                dismiss()
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
