import XCTest

@MainActor
final class HomeCareVoiceLogUITests: XCTestCase {
    func testTabNavigationAndShareButtonVisibility() {
        let app = XCUIApplication()
        app.launch()

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
        let app = XCUIApplication()
        app.launch()

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
        let app = XCUIApplication()
        app.launch()

        let memoInput = app.descendants(matching: .any)["free-memo-field"]
        XCTAssertTrue(memoInput.waitForExistence(timeout: 2))
        memoInput.tap()

        let dismissButton = app.buttons["dismiss-keyboard-button"]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 2))
        dismissButton.tap()

        let hiddenPredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: hiddenPredicate, object: dismissButton)
        let result = XCTWaiter.wait(for: [expectation], timeout: 2)
        XCTAssertEqual(result, .completed)
    }
}
