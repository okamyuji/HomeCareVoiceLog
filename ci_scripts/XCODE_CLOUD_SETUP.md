# Xcode Cloud セットアップ手順書

## 前提条件

- Apple Developer Program メンバーシップ（年額 $99）
- Xcode 15.0 以降
- GitHubリポジトリへのアクセス権
- **月25計算時間が無料で含まれます（追加料金不要）**

---

## ワークフロー A: CI ビルド＆テスト（プッシュ時自動実行）

### 設定手順

1. Xcode で `HomeCareVoiceLog.xcodeproj` を開く
2. メニュー: **Integrate > Create Workflow...**
3. 以下を設定:

| 項目 | 設定値 |
| ---- | ------ |
| Product | HomeCareVoiceLog |
| Name | CI - Build & Test |

### Start Conditions（トリガー）

| 項目 | 設定値 |
| ---- | ------ |
| Source Control | Branch Changes |
| Branch | `main`, `codex/homecarevoicelog-impl` |
| Auto-cancel | ON (新しいビルドで古いビルドをキャンセル) |

### Environment

| 項目 | 設定値 |
| ---- | ------ |
| Xcode Version | Latest Release |
| macOS Version | Latest |
| Clean | OFF (ビルドキャッシュを活用して計算時間を節約) |

### Actions

#### Action 1: Build

| 項目 | 設定値 |
| ---- | ------ |
| Action | Build |
| Platform | iOS |
| Scheme | HomeCareVoiceLog |

#### Action 2: Test

| 項目 | 設定値 |
| ---- | ------ |
| Action | Test |
| Platform | iOS Simulator |
| Destination | iPhone 16 Pro Max |

#### Action 3: Analyze

| 項目 | 設定値 |
| ---- | ------ |
| Action | Analyze |
| Platform | iOS |
| Scheme | HomeCareVoiceLog |

### Post-Actions

| 項目 | 設定値 |
| ---- | ------ |
| Notify | Email (on failure) |

---

## ワークフロー B: UIテスト＆スクリーンショット取得

### 設定手順

1. Integrate > Manage Workflows... > **+** ボタン
2. 以下を設定:

| 項目 | 設定値 |
| ---- | ------ |
| Product | HomeCareVoiceLog |
| Name | Screenshots - UI Tests |

### Start Conditions

| 項目 | 設定値 |
| ---- | ------ |
| Source Control | Tag Changes |
| Tag pattern | `v*` |
| + Manual | ON (手動実行も可能にする) |

### Environment

| 項目 | 設定値 |
| ---- | ------ |
| Xcode Version | Latest Release |
| macOS Version | Latest |

### Actions

#### Action 1: Test

| 項目 | 設定値 |
| ---- | ------ |
| Action | Test |
| Platform | iOS Simulator |
| Destination | iPhone 16 Pro Max (6.9インチ, App Store用スクリーンショットサイズ) |
| **Screenshots & Videos** | **On, and keep all** (重要: すべてのスクリーンショットを保持) |

### スクリーンショットの取得

テスト完了後、App Store Connect でテスト結果を確認:

1. [App Store Connect](https://appstoreconnect.apple.com) にログイン
2. Xcode Cloud > ビルド結果を選択
3. テストレポートからスクリーンショットのアタッチメントをダウンロード

**注意**: `AppStoreScreenshots.swift` は既に `XCTAttachment` で `lifetime = .keepAlways` が設定済みのため、Xcode Cloud でそのまま動作します。

---

## ワークフロー C: TestFlight 自動配布

### 設定手順

1. Integrate > Manage Workflows... > **+** ボタン
2. 以下を設定:

| 項目 | 設定値 |
| ---- | ------ |
| Product | HomeCareVoiceLog |
| Name | Release - TestFlight |

### Start Conditions

| 項目 | 設定値 |
| ---- | ------ |
| Source Control | Tag Changes |
| Tag pattern | `release/*` |
| + Manual | ON |

### Environment

| 項目 | 設定値 |
| ---- | ------ |
| Xcode Version | Latest Release |
| macOS Version | Latest |

### Actions

#### Action 1: Archive

| 項目 | 設定値 |
| ---- | ------ |
| Action | Archive |
| Platform | iOS |
| Scheme | HomeCareVoiceLog |
| Deployment Preparation | TestFlight (Internal Testing Only) |

### Post-Actions

| 項目 | 設定値 |
| ---- | ------ |
| TestFlight Internal Testing | ON |
| Notify | Email (all outcomes) |

---

## 便利機能の有効化

### Slack 通知連携（オプション）

1. App Store Connect > Xcode Cloud > Settings
2. Slack App を追加: [Xcode Cloud for Slack](https://slack.com/apps/A024NMX1588-xcode-cloud)
3. 通知するチャンネルとイベント（成功/失敗）を選択

### Webhook（オプション）

1. App Store Connect > Xcode Cloud > Settings > Webhooks
2. Webhook URL を追加
3. ビルドイベントの JSON ペイロードが送信される

### 使用量モニタリング

- App Store Connect > Xcode Cloud > Usage で計算時間の使用状況を確認
- 月25時間の残量を定期的にチェック

---

## 計算時間の節約Tips

1. **Clean Build を OFF**: キャッシュを活用（大幅に時間短縮）
2. **Auto-cancel**: 同じブランチの古いビルドを自動キャンセル
3. **テストプランの分離**: ユニットテストとUIテストを分けて必要な時だけ実行
4. **手動トリガー**: スクリーンショットやリリースビルドは手動実行で不要な実行を防止
5. **ブランチフィルタ**: 必要なブランチのみでワークフローを実行

---

## トラブルシューティング

### ビルドが失敗する場合

- App Store Connect のビルドログを確認
- `ci_post_clone.sh` のログ出力を確認
- コード署名の問題は Xcode Cloud が自動管理するため、通常は発生しない

### スクリーンショットが取得できない場合

- ワークフロー B の「Screenshots & Videos」設定が「On, and keep all」になっているか確認
- `AppStoreScreenshots.swift` の `lifetime = .keepAlways` が設定されているか確認
- テストレポートのアタッチメントセクションを確認

### 計算時間の超過

- App Store Connect > Usage で使用状況を確認
- 不要なワークフローを無効化
- Standard プラン ($49.99/月) へのアップグレードを検討
