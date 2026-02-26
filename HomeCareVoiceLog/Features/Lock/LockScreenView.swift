import SwiftUI

struct LockScreenView: View {
    let onUnlock: () -> Void
    let authService: BiometricAuthService

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
                Label(biometricButtonLabel, systemImage: biometricIconName)
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
        isAuthenticating = true
        showAuthFailure = false
        defer { isAuthenticating = false }
        if await authService.authenticate() {
            onUnlock()
        } else {
            showAuthFailure = true
        }
    }

    private var biometricIconName: String {
        switch authService.biometryType {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        case .opticID:
            "opticid"
        default:
            "lock.open"
        }
    }

    private var biometricButtonLabel: LocalizedStringKey {
        switch authService.biometryType {
        case .faceID:
            "lock.button.faceid"
        case .touchID:
            "lock.button.touchid"
        case .opticID:
            "lock.button.opticid"
        default:
            "lock.button.unlock"
        }
    }
}
