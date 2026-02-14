# Recording Indicator And Elapsed Time Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make recording state explicit by showing a simple visual indicator and live elapsed recording time while recording, then hide it immediately when recording stops.

**Architecture:** Keep timing state in `RecordViewModel` as the single source of truth (`elapsedRecordingSeconds`, formatted display text). Start a lightweight repeating task when recording starts, cancel/reset it when stopping or on start failure. `RecordView` renders a minimal indicator section only when `isRecording == true`.

**Tech Stack:** Swift 6, SwiftUI, XCTest, async/await, existing `RecordViewModel` + `RecordView`.

---

### Task 1: Add failing ViewModel tests for elapsed timer lifecycle

**Files:**
- Modify: `HomeCareVoiceLogTests/RecordViewModelTests.swift`

**Step 1: Write failing tests**
- Add test that `elapsedRecordingSeconds` increases while recording.
- Add test that elapsed value resets to `0` after stop.
- Add test that elapsed value stays `0` if start fails.

**Step 2: Run test to verify it fails**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HomeCareVoiceLogTests/RecordViewModelTests`
Expected: FAIL due to missing timer state/logic.

**Step 3: Commit**
```bash
git add HomeCareVoiceLogTests/RecordViewModelTests.swift
git commit -m "test(record): add failing elapsed timer lifecycle coverage"
```

### Task 2: Implement timer state in RecordViewModel

**Files:**
- Modify: `HomeCareVoiceLog/Features/Record/RecordViewModel.swift`

**Step 1: Add minimal state and timing loop**
- Add published `elapsedRecordingSeconds` and a formatted computed string.
- Start an internal repeating task on successful `startRecording()`.
- Cancel/reset timing task on `stopRecording()` and failure paths.

**Step 2: Run test to verify it passes**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HomeCareVoiceLogTests/RecordViewModelTests`
Expected: PASS.

**Step 3: Commit**
```bash
git add HomeCareVoiceLog/Features/Record/RecordViewModel.swift HomeCareVoiceLogTests/RecordViewModelTests.swift
git commit -m "feat(record): track elapsed recording time in view model"
```

### Task 3: Show recording indicator + live time in UI

**Files:**
- Modify: `HomeCareVoiceLog/Features/Record/RecordView.swift`
- Modify: `HomeCareVoiceLog/Resources/Localizable.xcstrings`

**Step 1: Render minimal recording indicator section**
- Add a simple red-dot + label indicator shown only while recording.
- Show formatted elapsed time from view model in monospaced digits.

**Step 2: Verify behavior manually and by build**
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**
```bash
git add HomeCareVoiceLog/Features/Record/RecordView.swift HomeCareVoiceLog/Resources/Localizable.xcstrings
git commit -m "feat(record-ui): show recording indicator and live elapsed time"
```

### Task 4: Quality gates and completion checks

**Files:**
- Modify: none (verification only)

**Step 1: Run formatting/lint/build gates**
Run: `swiftformat .`
Run: `swiftlint`
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: all commands pass.

**Step 2: Commit verification report**
```bash
git status
```
Expected: only intended files changed.
