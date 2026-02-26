import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour = 9
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute = 0
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false

    private let authService = BiometricAuthService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(String(localized: "settings.dailyReminder"), isOn: $dailyReminderEnabled)

                    DatePicker(
                        String(localized: "settings.reminderTime"),
                        selection: Binding(
                            get: {
                                Calendar.current.date(from: DateComponents(hour: dailyReminderHour, minute: dailyReminderMinute)) ?? Date()
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
            .navigationTitle(String(localized: "tab.settings"))
        }
    }

    private var biometricToggleLabel: String {
        switch authService.biometryType {
        case .faceID:
            String(localized: "settings.biometric.faceid")
        case .touchID:
            String(localized: "settings.biometric.touchid")
        default:
            String(localized: "settings.biometric.lock")
        }
    }
}
