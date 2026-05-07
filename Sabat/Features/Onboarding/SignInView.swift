import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var authService = AuthService()
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: SabatSpacing.xl) {
                OnboardingProgressView(current: 3, total: 5)
                    .padding(.top, SabatSpacing.lg)

                Spacer(minLength: SabatSpacing.md)

                HandmadeEyeIllustration(style: .constellation, size: 205)

                VStack(spacing: SabatSpacing.md) {
                    Text("Keep the night private.")
                        .font(.sabatDisplay(40))
                        .foregroundStyle(Color.sabatGold2)
                        .multilineTextAlignment(.center)

                    Text("Sign in with Apple so your ritual, voice settings, and sleep history stay tied to you.")
                        .font(.sabatSerif(21))
                        .foregroundStyle(Color.sabatMist)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let errorMessage {
                    SacredCard {
                        Text(errorMessage)
                            .font(.sabatSans(15))
                            .foregroundStyle(Color.sabatMist)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                    isSigningIn = true
                } onCompletion: { result in
                    handle(result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 54)
                .clipShape(Capsule())
                .disabled(isSigningIn)

                Button {
                    let user = User(
                        id: UUID().uuidString,
                        name: "Friend",
                        email: nil,
                        voiceId: nil
                    )
                    authService.cache(user: user)
                    router.navigate(to: .nameCollection)
                } label: {
                    Text("Continue in development")
                        .font(.sabatSans(15, weight: .medium))
                        .foregroundStyle(Color.sabatMist)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay {
                            Capsule()
                                .stroke(Color.sabatLine, lineWidth: 1)
                        }
                }
                .buttonStyle(PillSecondaryButtonStyle())
            }
            .padding(.horizontal, SabatSpacing.lg)
            .padding(.vertical, SabatSpacing.xl)
        }
    }

    private func handle(_ result: Result<ASAuthorization, Error>) {
        Task {
            defer { isSigningIn = false }

            do {
                guard
                    case .success(let authorization) = result,
                    let credential = authorization.credential as? ASAuthorizationAppleIDCredential
                else {
                    if case .failure(let error) = result {
                        throw error
                    }
                    throw ASAuthorizationError(.failed)
                }

                _ = try await authService.signIn(with: credential)
                router.navigate(to: .nameCollection)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AppRouter())
    }
}
