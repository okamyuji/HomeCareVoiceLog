@testable import HomeCareVoiceLog
import XCTest

final class TimelineCaregiverDisplayTests: XCTestCase {
    func testDisplayCaregiverNameReturnsNilForMissingValue() {
        XCTAssertNil(timelineDisplayCaregiverName(nil))
    }

    func testDisplayCaregiverNameReturnsNilForBlankValue() {
        XCTAssertNil(timelineDisplayCaregiverName("   "))
    }

    func testDisplayCaregiverNameReturnsTrimmedValue() {
        XCTAssertEqual(timelineDisplayCaregiverName("  Sato  "), "Sato")
    }
}
