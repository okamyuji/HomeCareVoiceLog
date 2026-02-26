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
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HomeCareVoiceLog", category: "BiometricAuth")

    private let context = LAContext()
    let biometryType: LABiometryType
    let isBiometricAvailable: Bool

    init() {
        var error: NSError?
        let available = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        if let error {
            Self.logger.warning("Biometric availability check failed: \(error.localizedDescription)")
        }
        isBiometricAvailable = available
        biometryType = context.biometryType
    }

    func authenticate() async -> Bool {
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
            return false
        }
    }
}
