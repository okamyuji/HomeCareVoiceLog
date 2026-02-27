import XCTest

@MainActor
final class AppStoreScreenshots: XCTestCase {
    let app = XCUIApplication()

    override func setUp() async throws {
        continueAfterFailure = false
        app.launchArguments.append("-ui-testing")
        app.launchEnvironment["UITEST_DISABLE_BIOMETRIC_LOCK"] = "1"
        app.launch()
    }

    func testTakeAppStoreScreenshots() async {
        // Screenshot 1: Record screen with category selected
        let categorySelector = app.buttons["category-selector-row"]
        XCTAssertTrue(categorySelector.waitForExistence(timeout: 3))
        categorySelector.tap()
        let mealCategory = app.buttons["category-option-meal"]
        if mealCategory.waitForExistence(timeout: 2) {
            mealCategory.tap()
        }
        try? await Task.sleep(for: .seconds(0.5))

        let screenshot1 = app.screenshot()
        let attach1 = XCTAttachment(screenshot: screenshot1)
        attach1.name = "01_record"
        attach1.lifetime = .keepAlways
        add(attach1)

        // Screenshot 2: Timeline screen
        let tabButtons = app.tabBars.buttons
        tabButtons.element(boundBy: 1).tap()
        try? await Task.sleep(for: .seconds(1))
        let screenshot2 = app.screenshot()
        let attach2 = XCTAttachment(screenshot: screenshot2)
        attach2.name = "02_timeline"
        attach2.lifetime = .keepAlways
        add(attach2)

        // Screenshot 3: Summary screen
        tabButtons.element(boundBy: 2).tap()
        try? await Task.sleep(for: .seconds(1))
        let screenshot3 = app.screenshot()
        let attach3 = XCTAttachment(screenshot: screenshot3)
        attach3.name = "03_summary"
        attach3.lifetime = .keepAlways
        add(attach3)
    }
}
