# Record Category Selection And Keyboard Dismiss UX Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce category mis-selection risk and make keyboard dismissal obvious on the record screen.

**Architecture:** Replace inline category picker with a dedicated category selection screen pushed from the record form. Keep selected state in `RecordView` and show current selection in the source row. Add explicit keyboard dismissal controls using `@FocusState`: a clear in-form dismiss button while focused and a keyboard toolbar dismiss action.

**Tech Stack:** SwiftUI, XCTest UI tests, localization via `.xcstrings`, existing `RecordView` screen composition.

---

### Task 1: Add failing UI tests (RED)

**Files:**
- Modify: `HomeCareVoiceLogUITests/HomeCareVoiceLogUITests.swift`

**Step 1: Write failing tests**
- Add test that taps category row, navigates to category selection list, chooses an item, then verifies the selected label updates.
- Add test that focuses free memo field, verifies explicit keyboard dismiss button exists, taps it, then verifies button disappears.

**Step 2: Run tests to confirm fail**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:HomeCareVoiceLogUITests/HomeCareVoiceLogUITests`
Expected: FAIL due to missing identifiers/new UI controls.

### Task 2: Implement category selection screen + keyboard dismissal controls (GREEN)

**Files:**
- Modify: `HomeCareVoiceLog/Features/Record/RecordView.swift`
- Modify: `HomeCareVoiceLog/Resources/Localizable.xcstrings`

**Step 1: Category selection redesign**
- Replace inline picker with `NavigationLink` row (`category-selector-row`).
- Add dedicated `CategorySelectionView` list with checkmark on selected category.
- Apply accessibility identifiers needed by UI tests.

**Step 2: Keyboard dismissal improvements**
- Add `@FocusState` for free memo field.
- Show explicit in-form dismiss button (`dismiss-keyboard-button`) when focused.
- Add keyboard toolbar `Done` button as secondary close path.

**Step 3: Run UI tests to verify pass**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:HomeCareVoiceLogUITests/HomeCareVoiceLogUITests`
Expected: PASS.

### Task 3: Quality gates

**Files:**
- Modify: none

**Step 1: Run formatting/lint/build**
Run: `swiftformat .`
Run: `swiftlint --no-cache`
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' build`
Expected: all pass.
