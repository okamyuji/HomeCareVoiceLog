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
            if biometricLockEnabled && !isUnlocked && authService.isBiometricAvailable {
                LockScreenView(onUnlock: {
                    isUnlocked = true
                }, authService: authService)
            } else {
                RootTabView(authService: authService)
                    .modelContainer(container)
                    .onAppear {
                        if biometricLockEnabled && !authService.isBiometricAvailable {
                            biometricLockEnabled = false
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                authService.refresh()
            }
            if newPhase != .active && biometricLockEnabled && authService.isBiometricAvailable {
                isUnlocked = false
            }
        }
        .onChange(of: biometricLockEnabled) { _, newValue in
            if !newValue {
                isUnlocked = true
            }
        }
    }
}
