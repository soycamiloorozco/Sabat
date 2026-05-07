import Combine
import SwiftUI

struct RitualView: View {
    @EnvironmentObject private var tabController: AppTabController
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RitualViewModel()
    @FocusState private var isTextFieldFocused: Bool

    private var userName: String {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredName) ?? "Friend"
    }

    var body: some View {
        ZStack {
            MidnightBackground()

            VStack(spacing: 0) {
                topBar

                VoicePresenceBubbleView(
                    phase: viewModel.phase,
                    energy: viewModel.voiceEnergy,
                    tone: viewModel.voiceTone
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    if let lastAssistantMessage {
                        Text(lastAssistantMessage)
                            .font(.sabatSerif(24))
                            .foregroundStyle(Color.sabatMist)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.82)
                            .padding(.horizontal, SabatSpacing.xl)
                            .padding(.bottom, SabatSpacing.xl)
                            .transition(.opacity)
                    }
                }

                inputArea
                    .padding(.horizontal, SabatSpacing.md)
                    .padding(.bottom, SabatSpacing.md)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.startIfNeeded(userName: userName)
        }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sabat Voice")
                    .font(.sabatSans(24, weight: .semibold))
                    .foregroundStyle(Color.sabatMist)

                Text(busyTitle)
                    .font(.sabatMono(12, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.sabatMuted)
                    .tracking(1.2)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            .buttonStyle(PillSecondaryButtonStyle())
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, SabatSpacing.lg)
        .padding(.top, SabatSpacing.xl)
        .padding(.bottom, SabatSpacing.md)
    }

    private var inputArea: some View {
        VStack(spacing: SabatSpacing.sm) {
            if viewModel.phase == .complete {
                GoldButton(title: "Enter sleep mode", systemImage: "moon.fill") {
                    HapticEngine.confirm()
                    dismiss()
                    tabController.showTracking = true
                }
            } else {
                HStack(spacing: SabatSpacing.sm) {
                    Button {
                        HapticEngine.softTap()
                        viewModel.listenForTurn(userName: userName)
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.sabatInk)
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(viewModel.phase == .listening ? 1 : 0.92))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isBusy)
                    .buttonStyle(PillSecondaryButtonStyle())
                    .accessibilityLabel("Listen")

                    TextField("Tell Sabat what is here", text: $viewModel.typedTurn, axis: .vertical)
                        .lineLimit(1...3)
                        .focused($isTextFieldFocused)
                        .font(.sabatSans(16))
                        .foregroundStyle(Color.sabatMist)
                        .padding(.horizontal, SabatSpacing.lg)
                        .frame(minHeight: 52)
                        .background(Color.sabatPaper.opacity(0.08))
                        .overlay {
                            Capsule()
                                .stroke(Color.sabatLine, lineWidth: 1)
                        }
                        .clipShape(Capsule())

                    Button {
                        HapticEngine.softTap()
                        viewModel.submitTypedTurn(userName: userName)
                        isTextFieldFocused = false
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.sabatInk)
                            .frame(width: 52, height: 52)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isBusy || viewModel.typedTurn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(viewModel.typedTurn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.44 : 1)
                    .buttonStyle(PillSecondaryButtonStyle())
                    .accessibilityLabel("Send")
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.sabatSans(12))
                        .foregroundStyle(Color.sabatMuted)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
            }
        }
    }

    private var lastAssistantMessage: String? {
        viewModel.messages.last(where: { $0.role == .assistant })?.content
    }

    private var busyTitle: String {
        if viewModel.isBusy {
            return viewModel.phase == .listening ? "Listening..." : "Thinking..."
        }
        return viewModel.phase.title
    }
}

struct RitualView_Previews: PreviewProvider {
    static var previews: some View {
        RitualView()
            .environmentObject(AppTabController())
    }
}
