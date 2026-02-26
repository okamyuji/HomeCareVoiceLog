import Foundation
import LocalAuthentication

@MainActor
protocol BiometricAuthenticating: Sendable {
    var biometryType: LABiometryType { get }
    var isBiometricAvailable: Bool { get }
    func authenticate() async -> Bool
}

@MainActor
final class BiometricAuthService: BiometricAuthenticating {
    private let context = LAContext()
    let biometryType: LABiometryType
    let isBiometricAvailable: Bool

    init() {
        var error: NSError?
        let available = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
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
