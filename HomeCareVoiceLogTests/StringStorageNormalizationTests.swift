@testable import HomeCareVoiceLog
import XCTest

final class StringStorageNormalizationTests: XCTestCase {
    func testOptionalNormalizationReturnsNilForMissingValue() {
        let value: String? = nil
        XCTAssertNil(value.normalizedForStorage)
    }

    func testOptionalNormalizationReturnsNilForBlankValue() {
        let value: String? = "   "
        XCTAssertNil(value.normalizedForStorage)
    }

    func testOptionalNormalizationReturnsTrimmedValue() {
        let value: String? = "  Sato  "
        XCTAssertEqual(value.normalizedForStorage, "Sato")
    }
}
