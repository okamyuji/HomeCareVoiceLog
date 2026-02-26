import LocalAuthentication
import Observation
import os.log

enum BiometricAuthResult: Equatable {
    case success
    case failure
    case userCancelled
}

@MainActor
protocol BiometricAuthenticating: Sendable {
    var biometryType: LABiometryType { get }
    var isBiometricAvailable: Bool { get }
    func authenticate() async -> BiometricAuthResult
}

@Observable
@MainActor
final class BiometricAuthService: BiometricAuthenticating {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "HomeCareVoiceLog",
        category: "BiometricAuth"
    )

    private(set) var biometryType: LABiometryType = .none
    private(set) var isBiometricAvailable: Bool = false

    init() {
        refresh()
    }

    /// Re-query the system for current biometric availability and type.
    /// Call this when the app returns to the foreground to pick up
    /// any changes the user made in device Settings.
    func refresh() {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        if !available, let error {
            Self.logger.warning("Biometric availability check failed: \(error.localizedDescription)")
        }
        isBiometricAvailable = available
        biometryType = context.biometryType
    }

    func authenticate() async -> BiometricAuthResult {
        guard isBiometricAvailable else {
            Self.logger.warning("Biometric authentication unavailable, policy evaluation skipped.")
            return .failure
        }

        let context = LAContext()
        context.localizedCancelTitle = String(localized: "biometric.cancel")

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String(localized: "biometric.reason")
            )
            return success ? .success : .failure
        } catch let error as LAError where error.code == .userCancel {
            return .userCancelled
        } catch {
            Self.logger.error("Biometric authentication failed: \(error.localizedDescription)")
            return .failure
        }
    }
}
