import SwiftData
import SwiftUI

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
            switch newPhase {
            case .active:
                authService.refresh()
                if biometricLockEnabled, !authService.isBiometricAvailable {
                    biometricLockEnabled = false
                }
            case .inactive, .background:
                if biometricLockEnabled {
                    isUnlocked = false
                }
            @unknown default:
                break
            }
        }
    }
}
