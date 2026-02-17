#!/usr/bin/env bash
# ci_post_xcodebuild.sh
# Xcode Cloud: xcodebuild 完了後に実行されるスクリプト
#
# 用途:
#   - テスト結果からスクリーンショットのアタッチメントを抽出
#   - ビルドアーティファクトの後処理

set -e

echo "=== ci_post_xcodebuild.sh ==="
echo "CI_XCODEBUILD_ACTION: ${CI_XCODEBUILD_ACTION}"
echo "CI_RESULT_BUNDLE_PATH: ${CI_RESULT_BUNDLE_PATH}"

# テストアクション完了後にスクリーンショットを抽出
if [[ "$CI_XCODEBUILD_ACTION" == "test-without-building" ]]; then
    echo "Extracting test attachments..."

    if [ -d "$CI_RESULT_BUNDLE_PATH" ]; then
        ARTIFACTS_DIR="${CI_RESULT_BUNDLE_PATH}/../Artifacts"
        mkdir -p "$ARTIFACTS_DIR"

        # xcresulttool でアタッチメントを抽出
        xcrun xcresulttool get test-results attachments \
            --path "$CI_RESULT_BUNDLE_PATH" \
            --output-path "$ARTIFACTS_DIR" 2>/dev/null || {
            echo "Warning: Could not extract attachments with xcresulttool."
            echo "Screenshots are still available in the test report on App Store Connect."
        }

        # 抽出結果の確認
        if [ -d "$ARTIFACTS_DIR" ]; then
            SCREENSHOT_COUNT=$(find "$ARTIFACTS_DIR" -name "*.png" -o -name "*.jpg" 2>/dev/null | wc -l)
            echo "Extracted ${SCREENSHOT_COUNT} screenshot(s) to ${ARTIFACTS_DIR}"
        fi
    else
        echo "No result bundle found at ${CI_RESULT_BUNDLE_PATH}"
    fi
fi

echo "=== ci_post_xcodebuild.sh completed ==="
