import LocalAuthentication
import Observation
import os.log

@MainActor
protocol BiometricAuthenticating: Sendable {
    var biometryType: LABiometryType { get }
    var isBiometricAvailable: Bool { get }
    func authenticate() async -> Bool
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
