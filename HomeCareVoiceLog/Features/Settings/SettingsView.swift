import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour = 9
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute = 0
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false

    @State private var authService = BiometricAuthService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("settings.dailyReminder", isOn: $dailyReminderEnabled)

                    DatePicker(
                        "settings.reminderTime",
                        selection: Binding(
                            get: {
                                let components = DateComponents(hour: dailyReminderHour, minute: dailyReminderMinute)
                                return Calendar.current.date(from: components) ?? Date()
                            },
                            set: { value in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: value)
                                dailyReminderHour = components.hour ?? 9
                                dailyReminderMinute = components.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }

                if authService.isBiometricAvailable {
                    Section(header: Text("settings.security")) {
                        Toggle(biometricToggleLabel, isOn: $biometricLockEnabled)
                    }
                }
            }
            .navigationTitle("tab.settings")
        }
    }

    private var biometricToggleLabel: LocalizedStringKey {
        switch authService.biometryType {
        case .faceID:
            "settings.biometric.faceid"
        case .touchID:
            "settings.biometric.touchid"
        default:
            "settings.biometric.lock"
        }
    }
}
