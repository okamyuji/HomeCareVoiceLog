import XCTest

final class HomeCareVoiceLogUITests: XCTestCase {
    func testTabNavigationAndShareButtonVisibility() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Record"].exists)
        XCTAssertTrue(app.tabBars.buttons["Timeline"].exists)
        XCTAssertTrue(app.tabBars.buttons["Summary"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)

        app.tabBars.buttons["Summary"].tap()
        XCTAssertTrue(app.buttons["Generate Summary"].exists)

        app.buttons["Generate Summary"].tap()
        XCTAssertTrue(app.buttons["Share Summary"].waitForExistence(timeout: 2))
    }
}
