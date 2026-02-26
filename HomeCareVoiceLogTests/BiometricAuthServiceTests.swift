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
}

@MainActor
private final class BiometricAuthServiceMock: BiometricAuthenticating {
    private let shouldSucceed: Bool
    private let available: Bool

    var biometryType: LABiometryType { .faceID }
    var isBiometricAvailable: Bool { available }

    init(shouldSucceed: Bool, available: Bool = true) {
        self.shouldSucceed = shouldSucceed
        self.available = available
    }

    func authenticate() async -> Bool {
        shouldSucceed
    }
}
