import XCTest

@MainActor
final class AppStoreScreenshots: XCTestCase {
    let app = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTakeAppStoreScreenshots() {
        // Screenshot 1: Record screen (main feature)
        let categorySelector = app.buttons["category-selector-row"]
        XCTAssertTrue(categorySelector.waitForExistence(timeout: 3))
        let screenshot1 = app.screenshot()
        let attach1 = XCTAttachment(screenshot: screenshot1)
        attach1.name = "01_record"
        attach1.lifetime = .keepAlways
        add(attach1)

        // Select a category to show more context
        categorySelector.tap()
        let mealCategory = app.buttons["category-option-meal"]
        if mealCategory.waitForExistence(timeout: 2) {
            mealCategory.tap()
        }

        let screenshot1b = app.screenshot()
        let attach1b = XCTAttachment(screenshot: screenshot1b)
        attach1b.name = "01b_record_with_category"
        attach1b.lifetime = .keepAlways
        add(attach1b)

        // Screenshot 2: Timeline screen
        let tabButtons = app.tabBars.buttons
        tabButtons.element(boundBy: 1).tap()
        sleep(1)
        let screenshot2 = app.screenshot()
        let attach2 = XCTAttachment(screenshot: screenshot2)
        attach2.name = "02_timeline"
        attach2.lifetime = .keepAlways
        add(attach2)

        // Screenshot 3: Summary screen
        tabButtons.element(boundBy: 2).tap()
        sleep(1)
        let screenshot3 = app.screenshot()
        let attach3 = XCTAttachment(screenshot: screenshot3)
        attach3.name = "03_summary"
        attach3.lifetime = .keepAlways
        add(attach3)

        // Screenshot 4: Settings screen
        tabButtons.element(boundBy: 3).tap()
        sleep(1)
        let screenshot4 = app.screenshot()
        let attach4 = XCTAttachment(screenshot: screenshot4)
        attach4.name = "04_settings"
        attach4.lifetime = .keepAlways
        add(attach4)
    }
}
