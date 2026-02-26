import SwiftUI

struct LockScreenView: View {
    let onUnlock: () -> Void
    private let authService: BiometricAuthService

    @State private var isAuthenticating = false
    @State private var hasAttemptedAuth = false

    init(onUnlock: @escaping () -> Void, authService: BiometricAuthService = BiometricAuthService()) {
        self.onUnlock = onUnlock
        self.authService = authService
    }

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
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .task {
            guard !hasAttemptedAuth else { return }
            hasAttemptedAuth = true
            await authenticate()
        }
    }

    private func authenticate() async {
        isAuthenticating = true
        let success = await authService.authenticate()
        isAuthenticating = false
        if success {
            onUnlock()
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
        default:
            "lock.button.unlock"
        }
    }
}
