import SwiftData
import SwiftUI

enum AppLockStateReducer {
    struct Result {
        var shouldRefreshBiometricState: Bool
        var biometricLockEnabled: Bool
        var isUnlocked: Bool
    }

    static func reduce(
        for phase: ScenePhase,
        biometricLockEnabled: Bool,
        isBiometricAvailable: Bool,
        isUnlocked: Bool
    ) -> Result {
        switch phase {
        case .active:
            return Result(
                shouldRefreshBiometricState: true,
                biometricLockEnabled: biometricLockEnabled && isBiometricAvailable,
                isUnlocked: isUnlocked
            )
        case .inactive, .background:
            return Result(
                shouldRefreshBiometricState: false,
                biometricLockEnabled: biometricLockEnabled,
                isUnlocked: biometricLockEnabled ? false : isUnlocked
            )
        @unknown default:
            return Result(
                shouldRefreshBiometricState: false,
                biometricLockEnabled: biometricLockEnabled,
                isUnlocked: isUnlocked
            )
        }
    }
}

@main
struct HomeCareVoiceLogApp: App {
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var isUnlocked = false
    @State private var authService = BiometricAuthService()
    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer = {
        let schema = Schema([
            CareRecordEntity.self,
            ReminderSettingsEntity.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if biometricLockEnabled, !isUnlocked, authService.isBiometricAvailable {
                    LockScreenView(onUnlock: {
                        isUnlocked = true
                    })
                } else {
                    RootTabView()
                }
            }
            .modelContainer(container)
            .environment(authService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            var isBiometricAvailable = authService.isBiometricAvailable
            if newPhase == .active {
                authService.refresh()
                isBiometricAvailable = authService.isBiometricAvailable
            }

            let result = AppLockStateReducer.reduce(
                for: newPhase,
                biometricLockEnabled: biometricLockEnabled,
                isBiometricAvailable: isBiometricAvailable,
                isUnlocked: isUnlocked
            )
            biometricLockEnabled = result.biometricLockEnabled
            isUnlocked = result.isUnlocked
        }
        .onChange(of: biometricLockEnabled) { _, newValue in
            if !newValue {
                isUnlocked = true
            }
        }
    }
}
