@testable import HomeCareVoiceLog
import SwiftUI
import XCTest

final class PlaceholderTests: XCTestCase {
    func testPlaceholder() {
        XCTAssertTrue(true)
    }

    func testInactiveRelocksWhenBiometricLockEnabledEvenIfBiometricUnavailable() {
        let result = AppLockStateReducer.reduce(
            for: .inactive,
            biometricLockEnabled: true,
            isBiometricAvailable: false,
            isUnlocked: true
        )

        XCTAssertFalse(result.isUnlocked)
    }

    func testActiveDisablesBiometricLockWhenBiometricUnavailable() {
        let result = AppLockStateReducer.reduce(
            for: .active,
            biometricLockEnabled: true,
            isBiometricAvailable: false,
            isUnlocked: true
        )

        XCTAssertTrue(result.shouldRefreshBiometricState)
        XCTAssertFalse(result.biometricLockEnabled)
        XCTAssertTrue(result.isUnlocked)
    }
}
