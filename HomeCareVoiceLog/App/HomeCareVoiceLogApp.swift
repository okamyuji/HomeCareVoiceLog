import LocalAuthentication
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

struct AppErrorAlert: Identifiable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let message: String
}

extension View {
    func appErrorAlert(_ item: Binding<AppErrorAlert?>) -> some View {
        alert(
            item.wrappedValue?.titleKey ?? "",
            isPresented: item.isPresent(),
            presenting: item.wrappedValue
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { alert in
            Text(alert.message)
        }
    }
}

extension Binding {
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(
            get: { wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    wrappedValue = nil
                }
            }
        )
    }
}

extension LABiometryType {
    var lockIconName: String {
        switch self {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        case .opticID:
            "opticid"
        case .none:
            "lock.open"
        @unknown default:
            "lock.open"
        }
    }

    var lockButtonLabelKey: LocalizedStringKey {
        switch self {
        case .faceID:
            "lock.button.faceid"
        case .touchID:
            "lock.button.touchid"
        case .opticID:
            "lock.button.opticid"
        case .none:
            "lock.button.unlock"
        @unknown default:
            "lock.button.unlock"
        }
    }

    var settingsToggleLabelKey: LocalizedStringKey {
        switch self {
        case .faceID:
            "settings.biometric.faceid"
        case .touchID:
            "settings.biometric.touchid"
        case .opticID:
            "settings.biometric.opticid"
        case .none:
            "settings.biometric.lock"
        @unknown default:
            "settings.biometric.lock"
        }
    }
}
