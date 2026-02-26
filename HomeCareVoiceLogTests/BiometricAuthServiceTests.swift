import Foundation
@testable import HomeCareVoiceLog
import LocalAuthentication
import XCTest

@MainActor
final class BiometricAuthServiceTests: XCTestCase {
    func testMockAuthenticateReturnsTrue() async {
        let mock = BiometricAuthServiceMock(shouldSucceed: true)
        let result = await mock.authenticate()
        XCTAssertTrue(result)
    }

    func testMockAuthenticateReturnsFalse() async {
        let mock = BiometricAuthServiceMock(shouldSucceed: false)
        let result = await mock.authenticate()
        XCTAssertFalse(result)
    }

    func testMockBiometricAvailability() {
        let availableMock = BiometricAuthServiceMock(shouldSucceed: true, available: true)
        XCTAssertTrue(availableMock.isBiometricAvailable)

        let unavailableMock = BiometricAuthServiceMock(shouldSucceed: true, available: false)
        XCTAssertFalse(unavailableMock.isBiometricAvailable)
    }

    func testMockBiometryType() {
        let faceIDMock = BiometricAuthServiceMock(shouldSucceed: true, biometry: .faceID)
        XCTAssertEqual(faceIDMock.biometryType, .faceID)

        let touchIDMock = BiometricAuthServiceMock(shouldSucceed: true, biometry: .touchID)
        XCTAssertEqual(touchIDMock.biometryType, .touchID)

        let noneMock = BiometricAuthServiceMock(shouldSucceed: true, biometry: .none)
        XCTAssertEqual(noneMock.biometryType, .none)
    }

    func testUnavailableMockAlwaysReturnsFalse() async {
        let mock = BiometricAuthServiceMock(shouldSucceed: true, available: false)
        let result = await mock.authenticate()
        XCTAssertFalse(result, "Authentication should fail when biometric is unavailable")
    }
}

@MainActor
final class BiometricAuthServiceMock: BiometricAuthenticating {
    private let shouldSucceed: Bool

    let biometryType: LABiometryType
    let isBiometricAvailable: Bool

    init(shouldSucceed: Bool, available: Bool = true, biometry: LABiometryType = .faceID) {
        self.shouldSucceed = shouldSucceed
        self.isBiometricAvailable = available
        self.biometryType = biometry
    }

    func authenticate() async -> Bool {
        guard isBiometricAvailable else { return false }
        return shouldSucceed
    }
}
