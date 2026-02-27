import XCTest

@MainActor
final class HomeCareVoiceLogUITests: XCTestCase {
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launchEnvironment["UITEST_DISABLE_BIOMETRIC_LOCK"] = "1"
        app.launch()
        return app
    }

    func testTabNavigationAndShareButtonVisibility() {
        let app = launchApp()

        let tabButtons = app.tabBars.buttons
        XCTAssertGreaterThanOrEqual(tabButtons.count, 4)

        tabButtons.element(boundBy: 2).tap()
        let generateButton = app.buttons["generate-summary"]
        let generateExists = generateButton.waitForExistence(timeout: 2)
        XCTAssertTrue(generateExists)

        generateButton.tap()
        let shareButton = app.buttons["share-summary"]
        let shareExists = shareButton.waitForExistence(timeout: 2)
        XCTAssertTrue(shareExists)
    }

    func testCategorySelectionUpdatesSelectedLabel() {
        let app = launchApp()

        let categorySelector = app.buttons["category-selector-row"]
        XCTAssertTrue(categorySelector.waitForExistence(timeout: 2))
        categorySelector.tap()

        let targetCategory = app.buttons["category-option-medication"]
        XCTAssertTrue(targetCategory.waitForExistence(timeout: 2))
        targetCategory.tap()

        let selectedLabel = app.staticTexts["selected-category-medication"]
        XCTAssertTrue(selectedLabel.waitForExistence(timeout: 2))
    }

    func testKeyboardCanBeDismissedWithExplicitButton() {
        let app = launchApp()

        let memoInput = app.descendants(matching: .any)["free-memo-field"]
        XCTAssertTrue(memoInput.waitForExistence(timeout: 2))
        memoInput.tap()

        let dismissButton = app.buttons["dismiss-keyboard-button"]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 2))
        dismissButton.tap()
    }
}
