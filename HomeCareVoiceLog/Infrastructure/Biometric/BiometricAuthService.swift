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

    var biometryType: LABiometryType {
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }

    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticate() async -> Bool {
        let authContext = LAContext()
        authContext.localizedCancelTitle = String(localized: "biometric.cancel")

        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            return try await authContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String(localized: "biometric.reason")
            )
        } catch {
            return false
        }
    }
}
