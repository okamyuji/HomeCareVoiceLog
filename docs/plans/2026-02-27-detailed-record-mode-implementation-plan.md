# Detailed Record Mode Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 設定で切替可能な「詳細記録モード（デフォルトON）」を導入し、ON時のみ拡張カテゴリとバイタル構造化入力・サマリーのバイタル推移表示を有効化する。

**Architecture:** 画面側は `@AppStorage("detailedRecordModeEnabled")` で表示ロジックを切替し、永続化境界（Repository）で値正規化・更新判定を一元化する。カテゴリ表示は `CareCategory` 側に集約し、簡易/詳細モードで同じ定義を参照して重複を排除する。

**Tech Stack:** SwiftUI, SwiftData, HomeCareVoiceLogCore, XCTest, Swift Testing

---

### Task 1: モード/カテゴリ仕様の土台を追加

**Files:**
- Modify: `Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/CareCategory.swift`
- Test: `Packages/HomeCareVoiceLogCore/Tests/HomeCareVoiceLogCoreTests/CareCategoryTests.swift`（新規）

**Step 1: Write the failing test**
- `simpleCategories` が既存簡易カテゴリのみを返すテストを追加
- `detailedCategories` が拡張カテゴリ（入浴・バイタル・運動を追加）を返すテストを追加

**Step 2: Run test to verify it fails**
- Run: `swift test --package-path Packages/HomeCareVoiceLogCore`
- Expected: 追加テストが未実装シンボルでFAIL

**Step 3: Write minimal implementation**
- `CareCategory` に `bathing` / `vitalSigns` / `exercise` を追加
- `simpleCases` / `detailedCases` を追加し、UIはこの配列を参照する方針に統一
- `localizedLabel(locale:)` に新カテゴリ文言を追加

**Step 4: Run test to verify it passes**
- Run: `swift test --package-path Packages/HomeCareVoiceLogCore`
- Expected: PASS

### Task 2: バイタルデータモデルとRepositoryを拡張

**Files:**
- Modify: `HomeCareVoiceLog/Infrastructure/Persistence/CareRecordEntity.swift`
- Modify: `HomeCareVoiceLog/Infrastructure/Persistence/CareRecordRepository.swift`
- Test: `HomeCareVoiceLogTests/CareRecordRepositoryTests.swift`

**Step 1: Write the failing test**
- `addRecord` がバイタル値を保存できるテストを追加
- `updateRecord` がバイタル値差分なしなら `updatedAt` を更新しないテストを追加

**Step 2: Run test to verify it fails**
- Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' test`
- Expected: 未実装引数/プロパティでFAIL

**Step 3: Write minimal implementation**
- `CareRecordEntity` に optional バイタル項目を追加
  - `bodyTemperature: Double?`
  - `systolicBP: Int?`
  - `diastolicBP: Int?`
  - `pulseRate: Int?`
  - `oxygenSaturation: Int?`
- `addRecord` / `updateRecord` 引数を拡張し、保存・差分判定を一元化
- 既存呼び出しには `nil` を渡して後方互換

**Step 4: Run test to verify it passes**
- Run: 同上テストコマンド
- Expected: PASS

### Task 3: 設定と入力UIを詳細モード対応

**Files:**
- Modify: `HomeCareVoiceLog/Features/Settings/SettingsView.swift`
- Modify: `HomeCareVoiceLog/Features/Record/RecordView.swift`
- Create: `HomeCareVoiceLog/Features/Record/VitalSignsInputView.swift`
- Modify: `HomeCareVoiceLog/Features/Timeline/RecordDetailEditView.swift`（必要最小限の整合）

**Step 1: Write the failing test**
- 既存UIテストへの影響を抑えるため、まず `CareCategory` の配列参照/保存ボタン有効条件をユニットで担保（Repository/formatter側）
- 手動確認ポイントを明文化（ON/OFFでカテゴリ表示・バイタル入力の有無）

**Step 2: Run test to verify it fails**
- Run: 既存 test コマンド
- Expected: 新規キー/引数未対応でFAIL

**Step 3: Write minimal implementation**
- `SettingsView` に `@AppStorage("detailedRecordModeEnabled") = true` のトグルを追加
- `RecordView` でカテゴリ一覧を `simpleCases/detailedCases` で切替
- `selectedCategory == .vitalSigns && detailedRecordModeEnabled` の場合のみ `VitalSignsInputView` を表示
- 保存時にバイタル値をRepositoryへ渡す
- OFFへ切替時に拡張カテゴリ選択中なら安全なカテゴリへフォールバック（例: `.freeMemo`）

**Step 4: Run test to verify it passes**
- Run: project test
- Expected: PASS

### Task 4: サマリー出力を詳細モード対応

**Files:**
- Modify: `Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/CareRecordDraft.swift`
- Modify: `Packages/HomeCareVoiceLogCore/Sources/HomeCareVoiceLogCore/DailySummaryFormatter.swift`
- Modify: `Packages/HomeCareVoiceLogCore/Tests/HomeCareVoiceLogCoreTests/DailySummaryFormatterTests.swift`
- Modify: `HomeCareVoiceLog/Features/SummaryShare/SummaryShareView.swift`

**Step 1: Write the failing test**
- 詳細モードONでバイタル推移セクションが出るテスト
- OFFでバイタル推移セクションが出ないテスト

**Step 2: Run test to verify it fails**
- Run: `swift test --package-path Packages/HomeCareVoiceLogCore`
- Expected: API差分でFAIL

**Step 3: Write minimal implementation**
- `CareRecordDraft` にバイタル項目を追加
- `DailySummaryFormatter.format` に `includeVitalTrend: Bool` を追加
- ON時のみバイタル推移セクションを付与
- `SummaryShareView` で `@AppStorage` を参照して引数を渡す

**Step 4: Run test to verify it passes**
- Run: package tests + app tests
- Expected: PASS

### Task 5: ローカライズと最終統合

**Files:**
- Modify: `HomeCareVoiceLog/Resources/Localizable.xcstrings`
- Modify: `HomeCareVoiceLog.xcodeproj/project.pbxproj`（新規ファイル追加分のみ）

**Step 1: 実装**
- 新カテゴリ・詳細モード・バイタル入力・バイタル推移見出しのキーを英日追加

**Step 2: Verify**
- Run: `swiftformat .`
- Run: `swiftlint --strict --no-cache`
- Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' build`
- Run: `xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 17' test`
- Expected: 全PASS
