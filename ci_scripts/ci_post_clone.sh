#!/usr/bin/env bash
# ci_post_clone.sh
# Xcode Cloud: リポジトリクローン後に実行されるスクリプト
#
# 用途:
#   - Swift Package Manager の依存関係は Xcode Cloud が自動解決するため、
#     通常このスクリプトでの追加作業は不要
#   - 必要に応じてビルド番号の設定や環境変数の注入に使用

set -e

echo "=== ci_post_clone.sh ==="
echo "CI_WORKSPACE: ${CI_WORKSPACE}"
echo "CI_BRANCH: ${CI_BRANCH}"
echo "CI_TAG: ${CI_TAG}"
echo "CI_COMMIT: ${CI_COMMIT}"
echo "CI_BUILD_NUMBER: ${CI_BUILD_NUMBER}"

# ビルド番号をXcode Cloud のビルド番号に同期（オプション）
if [ -n "$CI_BUILD_NUMBER" ]; then
    PLIST_PATH="${CI_WORKSPACE}/HomeCareVoiceLog/Info.plist"
    if [ -f "$PLIST_PATH" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${CI_BUILD_NUMBER}" "$PLIST_PATH"
        echo "Updated CFBundleVersion to ${CI_BUILD_NUMBER}"
    fi
fi

echo "=== ci_post_clone.sh completed ==="
