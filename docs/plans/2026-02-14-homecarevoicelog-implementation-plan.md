# HomeCareVoiceLog Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an iOS 17+ SwiftUI app for home caregiving records with voice-first capture, automatic post-recording transcription (Apple Speech, on-device preferred), daily reminder, and text sharing via iOS Share Sheet (LINE/Mail), fully local and no login.

**Architecture:** The app uses a hybrid structure: Xcode app target for UI/runtime and a local Swift Package for domain/application logic. Persistence uses SwiftData only. Voice capture is done in the app layer (AVFoundation), transcription in an application service boundary, and daily summary generation in the package to keep logic testable. Localization is device-language-driven (ja/en) from day one.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, AVFoundation, Speech, UserNotifications, XCTest, Swift Testing (package), SwiftLint, SwiftFormat, Xcode project + local Swift Package.

---

## Confirmed Product Scope (Fixed)

- Platform: iOS 17+
- Data scope: single care recipient only
- Categories: medication, meal, toileting, medical-visit + free memo
- Voice flow: record -> stop -> auto-transcribe (no extra user action)
- Speech engine: Apple Speech Framework (on-device preferred)
- Storage: SwiftData only
- Summary: manual generation on share action, format = timeline + per-category count + free memo list
- Share: text via iOS share flow (LINE/Mail, etc.)
- Notification: one daily local reminder with required time setting
- Localization: Japanese and English, follow device language
- Audio retention: delete recorded audio file after successful transcription
- Non-functional gates: swiftlint pass, swiftformat pass, build pass, Xcode project buildable

## Project Layout Target

```text
HomeCareVoiceLog/
├── HomeCareVoiceLog.xcodeproj
├── HomeCareVoiceLog/                      # iOS app target
│   ├── App/
│   ├── Features/
│   │   ├── Record/
│   │   ├── Timeline/
│   │   ├── SummaryShare/
│   │   └── Settings/
│   ├── Infrastructure/
│   │   ├── Audio/
│   │   ├── Speech/
│   │   ├── Notifications/
│   │   └── Persistence/
│   ├── Resources/
│   │   └── Localizable.xcstrings
│   └── Supporting/
├── Packages/
│   └── HomeCareVoiceLogCore/              # local SPM package
│       ├── Sources/HomeCareVoiceLogCore/
│       └── Tests/HomeCareVoiceLogCoreTests/
├── HomeCareVoiceLogTests/
├── HomeCareVoiceLogUITests/
├── .swiftlint.yml
├── .swiftformat
└── docs/plans/
    └── 2026-02-14-homecarevoicelog-implementation-plan.md
```

## Data Model Contract

- `CareCategory`: `.medication`, `.meal`, `.toileting`, `.medicalVisit`, `.freeMemo`
- `CareRecord` (SwiftData):
  - `id: UUID`
  - `timestamp: Date`
  - `category: CareCategory`
  - `transcriptText: String?`
  - `freeMemoText: String?`
  - `durationSeconds: Int?`
  - `createdAt: Date`
  - `updatedAt: Date`
- `ReminderSettings` (SwiftData):
  - `id: UUID`
  - `dailyReminderEnabled: Bool`
  - `dailyReminderTime: DateComponents`

## Task Plan

### Task 1: Bootstrap repo structure and quality gates

**Files:**
- Create: `HomeCareVoiceLog/README.md`
- Create: `HomeCareVoiceLog/.swiftlint.yml`
- Create: `HomeCareVoiceLog/.swiftformat`
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Package.swift`
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/Placeholder.swift`
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Tests/HomeCareVoiceLogCoreTests/PlaceholderTests.swift`

**Step 1: Write failing lint/format CI shell checks**
- Add scripts section to README with exact commands.

**Step 2: Run format/lint commands to confirm baseline behavior**
Run: `swiftformat . --lint`
Run: `swiftlint`
Expected: either pass or actionable failures.

**Step 3: Commit**
Run: `git add . && git commit -m "chore: bootstrap project structure and quality gates"`

### Task 2: Create Xcode iOS app + attach local package

**Files:**
- Create: `HomeCareVoiceLog/HomeCareVoiceLog.xcodeproj` (via Xcode)
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/App/HomeCareVoiceLogApp.swift`
- Modify: `HomeCareVoiceLog/HomeCareVoiceLog.xcodeproj/project.pbxproj`

**Step 1: Create the app target**
- SwiftUI App, iOS 17, product name `HomeCareVoiceLog`.

**Step 2: Add local package dependency**
- Add `Packages/HomeCareVoiceLogCore` to app target.

**Step 3: Build to verify wiring**
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: `** BUILD SUCCEEDED **`

**Step 4: Commit**
Run: `git add . && git commit -m "chore: create xcode app and attach local core package"`

### Task 3: Implement domain/application core in SPM (TDD)

**Files:**
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/CareCategory.swift`
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/CareRecordDraft.swift`
- Create: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/DailySummaryFormatter.swift`
- Test: `HomeCareVoiceLog/Packages/HomeCareVoiceLogCore/Tests/HomeCareVoiceLogCoreTests/DailySummaryFormatterTests.swift`

**Step 1: Write failing tests for summary format**
- Test timeline ordering, category counts, free memo extraction.

**Step 2: Run package tests (expect fail)**
Run: `cd Packages/HomeCareVoiceLogCore && swift test`
Expected: failing assertions for missing formatter.

**Step 3: Implement minimal formatter**
- Deterministic output, locale-aware labels (ja/en).

**Step 4: Re-run tests (expect pass)**
Run: `cd Packages/HomeCareVoiceLogCore && swift test`
Expected: all pass.

**Step 5: Commit**
Run: `git add . && git commit -m "feat(core): add care categories and daily summary formatter"`

### Task 4: SwiftData models and repository layer in app target

**Files:**
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Persistence/CareRecordEntity.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Persistence/ReminderSettingsEntity.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Persistence/CareRecordRepository.swift`
- Test: `HomeCareVoiceLog/HomeCareVoiceLogTests/CareRecordRepositoryTests.swift`

**Step 1: Write failing repository tests**
- Insert/fetch by day, category counting, memo-only records.

**Step 2: Run app tests (expect fail)**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HomeCareVoiceLogTests/CareRecordRepositoryTests`

**Step 3: Implement repository with SwiftData**
- Provide query methods needed by timeline and summary.

**Step 4: Re-run tests (expect pass)**
- Same command as Step 2.

**Step 5: Commit**
Run: `git add . && git commit -m "feat(data): add swiftdata entities and repository"`

### Task 5: Voice capture + auto transcription + audio deletion

**Files:**
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Audio/AudioRecorderService.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Speech/SpeechTranscriptionService.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Features/Record/RecordViewModel.swift`
- Test: `HomeCareVoiceLog/HomeCareVoiceLogTests/RecordViewModelTests.swift`

**Step 1: Write failing ViewModel tests**
- Stop recording triggers transcription automatically.
- Successful transcription deletes local audio file.
- Failure keeps recoverable error state.

**Step 2: Run tests (expect fail)**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HomeCareVoiceLogTests/RecordViewModelTests`

**Step 3: Implement services + VM**
- `SFSpeechRecognitionRequest.requiresOnDeviceRecognition = true`
- No manual tap needed after stop.
- Delete file after successful transcription persist.

**Step 4: Re-run tests (expect pass)**
- Same command as Step 2.

**Step 5: Commit**
Run: `git add . && git commit -m "feat(record): add auto transcription flow and post-success audio deletion"`

### Task 6: SwiftUI screens and share flow

**Files:**
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Features/Record/RecordView.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Features/Timeline/TimelineView.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Features/SummaryShare/SummaryShareView.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Features/Settings/SettingsView.swift`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/App/RootTabView.swift`
- Test: `HomeCareVoiceLog/HomeCareVoiceLogUITests/HomeCareVoiceLogUITests.swift`

**Step 1: Write failing UI smoke test**
- Tab navigation works.
- Share button appears for selected date.

**Step 2: Implement views**
- Record screen: category selection + free memo text + voice recording controls.
- Timeline screen: date-grouped list.
- Summary screen: manual generate on button tap and ShareLink.
- Settings: daily reminder toggle + time picker.

**Step 3: Re-run UI test**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HomeCareVoiceLogUITests`

**Step 4: Commit**
Run: `git add . && git commit -m "feat(ui): add record timeline summary share and settings screens"`

### Task 7: Localization (ja/en) and reminder scheduling

**Files:**
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Resources/Localizable.xcstrings`
- Create: `HomeCareVoiceLog/HomeCareVoiceLog/Infrastructure/Notifications/ReminderScheduler.swift`
- Modify: `HomeCareVoiceLog/HomeCareVoiceLog/Supporting/Info.plist`
- Test: `HomeCareVoiceLog/HomeCareVoiceLogTests/ReminderSchedulerTests.swift`

**Step 1: Write failing reminder tests**
- One daily trigger at configured local time.
- Reschedule behavior on time change.

**Step 2: Implement scheduler**
- Local notifications only.
- Permission request and single pending reminder policy.

**Step 3: Add ja/en localized strings**
- Category labels, errors, buttons, summary headings.

**Step 4: Run tests/build**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16'`
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build`

**Step 5: Commit**
Run: `git add . && git commit -m "feat(i18n-notify): add ja-en localization and daily reminder scheduling"`

### Task 8: Final verification gates (must-pass)

**Files:**
- Modify: `HomeCareVoiceLog/README.md`

**Step 1: Format check**
Run: `swiftformat . --lint`
Expected: pass.

**Step 2: Lint check**
Run: `swiftlint`
Expected: pass.

**Step 3: Package tests**
Run: `cd Packages/HomeCareVoiceLogCore && swift test`
Expected: pass.

**Step 4: App tests and build**
Run: `xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16'`
Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: all pass.

**Step 5: Document final commands/results in README**
- Add reproducible verification section.

**Step 6: Commit**
Run: `git add . && git commit -m "chore: finalize verification and documentation"`

## Error Handling and Edge Cases (Implementation Requirements)

- Recording permission denied: show localized actionable error.
- Speech permission denied/unavailable: keep saved text memo flow available.
- On-device recognition not available at runtime: show explicit localized warning and do not silently downgrade behavior.
- Empty transcription result: allow manual memo completion and save with category.
- Notification denied: keep local setting UI but show disabled status guidance.
- Share action canceled: no state mutation.

## Definition of Done

- Xcode project builds and tests pass on iOS 17 simulator.
- Local SPM package tests pass.
- `swiftformat --lint` and `swiftlint` pass.
- Recording stop automatically triggers transcription.
- Daily summary text shares to iOS share targets (including LINE/Mail if installed).
- Reminder time can be configured and schedules one daily local notification.
- App works fully offline and without login.
