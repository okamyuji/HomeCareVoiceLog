import Foundation
import LocalAuthentication
import os.log

@MainActor
protocol BiometricAuthenticating: Sendable {
    var biometryType: LABiometryType { get }
    var isBiometricAvailable: Bool { get }
    func authenticate() async -> Bool
}

@MainActor
final class BiometricAuthService: BiometricAuthenticating {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "HomeCareVoiceLog",
        category: "BiometricAuth"
    )

    var biometryType: LABiometryType {
        LAContext().biometryType
    }

    var isBiometricAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
    }

    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = String(localized: "biometric.cancel")

        var error: NSError?
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            if let error {
                Self.logger.warning("Biometric policy evaluation unavailable: \(error.localizedDescription)")
            }
            return false
        }

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String(localized: "biometric.reason")
            )
        } catch {
            Self.logger.error("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }
}
