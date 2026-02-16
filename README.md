# HomeCareVoiceLog

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS_17+-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-2196F3?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Data-SwiftData-34C759?logo=apple&logoColor=white)](https://developer.apple.com/xcode/swiftdata/)
[![License](https://img.shields.io/badge/License-GPL_3.0-blue.svg)](LICENSE)
[![App Store](https://img.shields.io/badge/App_Store-Available-0D96F6?logo=app-store&logoColor=white)](https://apps.apple.com/app/id6759207743)

Voice-powered daily care logging for home caregivers. Fully local/offline, no login required.

## Verification Commands

```bash
swiftformat . --lint
swiftlint
cd Packages/HomeCareVoiceLogCore && swift test
xcodebuild test -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild -project HomeCareVoiceLog.xcodeproj -scheme HomeCareVoiceLog -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Documentation

- [Support / サポート](docs/support.md)
- [Privacy Policy / プライバシーポリシー](docs/privacy-policy.md)

## License

This project is licensed under the **GNU General Public License v3.0** with an **App Store Exception**.

### What this means

**You are free to:**

- View, study, and learn from the source code
- Fork and modify the code for your own use
- Distribute modified versions, provided you also release them under GPL-3.0

**You must:**

- Disclose the source code of any derivative work
- License derivative works under GPL-3.0
- State all changes you made
- Include the original copyright and license notice

**App Store Exception:**
The copyright holder grants permission to distribute this software through the Apple App Store, provided that the complete corresponding source code remains available under GPL-3.0 through a publicly accessible repository.

**You may NOT:**

- Distribute modified versions as closed-source software
- Remove or alter the license or copyright notices
- Distribute through app stores without making the source code publicly available under GPL-3.0

### Why GPL-3.0?

This project is open source so that caregivers and developers can benefit from transparent, privacy-respecting software. The GPL-3.0 license ensures that any improvements to this code remain open and accessible to the community, while preventing closed-source forks from being sold without contributing back.

See [LICENSE](LICENSE) for the full license text.
