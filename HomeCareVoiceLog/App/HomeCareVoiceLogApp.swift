import SwiftData
import SwiftUI

@main
struct HomeCareVoiceLogApp: App {
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var isUnlocked = false
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
            if biometricLockEnabled && !isUnlocked {
                LockScreenView {
                    isUnlocked = true
                }
            } else {
                RootTabView()
                    .modelContainer(container)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && biometricLockEnabled {
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
