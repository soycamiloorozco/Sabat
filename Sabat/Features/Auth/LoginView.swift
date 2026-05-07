import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

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
            Text("Welcome back")
                .font(.sabatDisplay(36))
                .foregroundStyle(Color.sabatGold2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Sign in to continue your rest journey.")
                .font(.sabatSerif(18))
                .foregroundStyle(Color.sabatMist)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var formSection: some View {
        VStack(spacing: SabatSpacing.lg) {
            SabatTextField(
                title: "Email",
                text: $email,
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )

            SabatTextField(
                title: "Password",
                text: $password,
                icon: "lock.fill",
                isSecure: true
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.sabatSans(13))
                    .foregroundStyle(Color.sabatDawn)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: SabatSpacing.md) {
            GoldButton(title: isLoading ? "Signing in..." : "Sign in", systemImage: "arrow.right") {
                HapticEngine.confirm()
                performLogin()
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button {
                HapticEngine.softTap()
            } label: {
                Text("Forgot password?")
                    .font(.sabatSans(14, weight: .medium))
                    .foregroundStyle(Color.sabatMuted)
            }

            HStack(spacing: SabatSpacing.sm) {
                Text("New to Sabat?")
                    .font(.sabatSans(14))
                    .foregroundStyle(Color.sabatMuted)

                Button {
                    HapticEngine.softTap()
                } label: {
                    Text("Create account")
                        .font(.sabatSans(14, weight: .semibold))
                        .foregroundStyle(Color.sabatDawn)
                }
            }
        }
    }

    private func performLogin() {
        isLoading = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                isLoading = false
                // TODO: Wire to AuthService
                HapticEngine.success()
                dismiss()
            }
        }
    }
}

// MARK: - Reusable Text Field

struct SabatTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: SabatSpacing.xs) {
            Text(title)
                .font(.sabatSans(13, weight: .medium))
                .foregroundStyle(Color.sabatMuted)

            HStack(spacing: SabatSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.sabatMuted)
                    .frame(width: 20)

                if isSecure {
                    SecureField(title, text: $text)
                        .font(.sabatSans(16))
                        .foregroundStyle(Color.sabatMist)
                } else {
                    TextField(title, text: $text)
                        .font(.sabatSans(16))
                        .foregroundStyle(Color.sabatMist)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(.horizontal, SabatSpacing.md)
            .frame(height: 48)
            .background(Color.sabatPaper.opacity(0.06))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.sabatLine, lineWidth: 1)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
