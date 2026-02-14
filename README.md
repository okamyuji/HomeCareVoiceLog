# HomeCareVoiceLog

iOS 17+ home care voice logging app. Fully local/offline, no login.

## Verification Commands

```bash
swiftformat . --lint
swiftlint
cd Packages/HomeCareVoiceLogCore && swift test
xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build
```
