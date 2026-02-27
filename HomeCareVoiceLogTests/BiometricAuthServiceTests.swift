import Foundation
@testable import HomeCareVoiceLog
import LocalAuthentication
import XCTest

@MainActor
final class BiometricAuthServiceTests: XCTestCase {
    func testAuthenticateEvaluatesDeviceOwnerAuthenticationPolicy() async {
        let refreshContext = TestBiometricAuthContext(
            canEvaluatePolicyResult: true,
            biometryType: .faceID
        )
        let authContext = TestBiometricAuthContext(
            canEvaluatePolicyResult: true,
            evaluatePolicyResult: true,
            biometryType: .faceID
        )
        let contextProvider = TestBiometricAuthContextProvider(
            contexts: [refreshContext, authContext]
        )
        let service = BiometricAuthService(contextFactory: { contextProvider.next() })

        let result = await service.authenticate()

        XCTAssertEqual(result, .success)
        XCTAssertEqual(authContext.evaluatedPolicies, [.deviceOwnerAuthentication], "Authentication should allow passcode fallback")
    }

    func testRefreshEvaluatesBiometricAvailabilityPolicy() {
        let refreshContext = TestBiometricAuthContext(
            canEvaluatePolicyResult: true,
            biometryType: .touchID
        )
        let contextProvider = TestBiometricAuthContextProvider(contexts: [refreshContext])

        _ = BiometricAuthService(contextFactory: { contextProvider.next() })

        XCTAssertEqual(refreshContext.canEvaluatePolicies, [.deviceOwnerAuthenticationWithBiometrics])
    }

    func testMockAuthenticateReturnsSuccess() async {
        let mock = BiometricAuthServiceMock(result: .success)
        let result = await mock.authenticate()
        XCTAssertEqual(result, .success)
    }

    func testMockAuthenticateReturnsFailure() async {
        let mock = BiometricAuthServiceMock(result: .failure)
        let result = await mock.authenticate()
        XCTAssertEqual(result, .failure)
    }

    func testMockAuthenticateReturnsUserCancelled() async {
        let mock = BiometricAuthServiceMock(result: .userCancelled)
        let result = await mock.authenticate()
        XCTAssertEqual(result, .userCancelled)
    }

    func testMockBiometricAvailability() {
        let availableMock = BiometricAuthServiceMock(result: .success, available: true)
        XCTAssertTrue(availableMock.isBiometricAvailable)

        let unavailableMock = BiometricAuthServiceMock(result: .success, available: false)
        XCTAssertFalse(unavailableMock.isBiometricAvailable)
    }

    func testMockBiometryType() {
        let faceIDMock = BiometricAuthServiceMock(result: .success, biometry: .faceID)
        XCTAssertEqual(faceIDMock.biometryType, .faceID)

        let touchIDMock = BiometricAuthServiceMock(result: .success, biometry: .touchID)
        XCTAssertEqual(touchIDMock.biometryType, .touchID)

        let opticIDMock = BiometricAuthServiceMock(result: .success, biometry: .opticID)
        XCTAssertEqual(opticIDMock.biometryType, .opticID)

        let noneMock = BiometricAuthServiceMock(result: .success, biometry: .none)
        XCTAssertEqual(noneMock.biometryType, .none)
    }

    func testUnavailableMockAlwaysReturnsFailure() async {
        let mock = BiometricAuthServiceMock(result: .success, available: false)
        let result = await mock.authenticate()
        XCTAssertEqual(result, .failure, "Authentication should fail when biometric is unavailable")
    }
}

@MainActor
final class BiometricAuthServiceMock: BiometricAuthenticating {
    private let result: BiometricAuthResult

    let biometryType: LABiometryType
    let isBiometricAvailable: Bool

    init(result: BiometricAuthResult, available: Bool = true, biometry: LABiometryType = .faceID) {
        self.result = result
        isBiometricAvailable = available
        biometryType = biometry
    }

    func authenticate() async -> BiometricAuthResult {
        guard isBiometricAvailable else { return .failure }
        return result
    }
}

@MainActor
private final class TestBiometricAuthContextProvider {
    private var contexts: [TestBiometricAuthContext]
    private var index = 0

    init(contexts: [TestBiometricAuthContext]) {
        self.contexts = contexts
    }

    func next() -> any BiometricAuthContext {
        guard index < contexts.count else {
            XCTFail("No more test biometric contexts available")
            return TestBiometricAuthContext(canEvaluatePolicyResult: false)
        }

        let context = contexts[index]
        index += 1
        return context
    }
}

@MainActor
private final class TestBiometricAuthContext: BiometricAuthContext {
    let biometryType: LABiometryType
    var localizedCancelTitle: String?
    var canEvaluatePolicies: [LAPolicy] = []
    var evaluatedPolicies: [LAPolicy] = []

    private let canEvaluatePolicyResult: Bool
    private let evaluatePolicyResult: Bool
    private let evaluatePolicyError: Error?

    init(
        canEvaluatePolicyResult: Bool,
        evaluatePolicyResult: Bool = false,
        evaluatePolicyError: Error? = nil,
        biometryType: LABiometryType = .none
    ) {
        self.canEvaluatePolicyResult = canEvaluatePolicyResult
        self.evaluatePolicyResult = evaluatePolicyResult
        self.evaluatePolicyError = evaluatePolicyError
        self.biometryType = biometryType
    }

    func canEvaluatePolicy(_ policy: LAPolicy, error _: NSErrorPointer) -> Bool {
        canEvaluatePolicies.append(policy)
        return canEvaluatePolicyResult
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason _: String) async throws -> Bool {
        evaluatedPolicies.append(policy)
        if let evaluatePolicyError {
            throw evaluatePolicyError
        }
        return evaluatePolicyResult
    }
}
