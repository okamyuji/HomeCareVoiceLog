import Foundation
@testable import HomeCareVoiceLog
import LocalAuthentication
import XCTest

@MainActor
final class BiometricAuthServiceTests: XCTestCase {
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
