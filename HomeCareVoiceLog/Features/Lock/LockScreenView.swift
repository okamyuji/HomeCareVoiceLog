import SwiftUI

struct LockScreenView: View {
    let onUnlock: () -> Void
    @Environment(BiometricAuthService.self) private var authService

    @State private var isAuthenticating = false
    @State private var showAuthFailure = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("lock.title")
                .font(.title2)
                .fontWeight(.semibold)

            Text("lock.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if showAuthFailure {
                Text("lock.authFailed")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("auth-failure-message")
            }

            Spacer()

            Button {
                Task {
                    await authenticate()
                }
            } label: {
                Label(biometricInfo.labelKey, systemImage: biometricInfo.iconName)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isAuthenticating)
            .accessibilityIdentifier("biometric-unlock-button")
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .task {
            await authenticate()
        }
    }

    private func authenticate() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        showAuthFailure = false
        defer { isAuthenticating = false }
        switch await authService.authenticate() {
        case .success:
            onUnlock()
        case .failure:
            showAuthFailure = true
        case .userCancelled:
            break
        }
    }

    private var biometricInfo: (iconName: String, labelKey: LocalizedStringKey) {
        switch authService.biometryType {
        case .faceID:
            ("faceid", "lock.button.faceid")
        case .touchID:
            ("touchid", "lock.button.touchid")
        case .opticID:
            ("opticid", "lock.button.opticid")
        case .none:
            ("lock.open", "lock.button.unlock")
        @unknown default:
            ("lock.open", "lock.button.unlock")
        }
    }
}
