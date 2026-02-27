import LocalAuthentication
import SwiftData
import SwiftUI

@main
@MainActor
struct HomeCareVoiceLogApp: App {
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var isUnlocked = false
    @State private var authService = BiometricAuthService()
    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    private let repository: CareRecordRepository

    init() {
        let schema = Schema([
            CareRecordEntity.self,
            ReminderSettingsEntity.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.container = container
            repository = CareRecordRepository(modelContext: container.mainContext)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }

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
            .environment(repository)
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
