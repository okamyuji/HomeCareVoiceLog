import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour = 9
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute = 0
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("detailedRecordModeEnabled") private var detailedRecordModeEnabled = true
    @AppStorage("caregiverName") private var caregiverName = ""

    @Environment(BiometricAuthService.self) private var authService

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("settings.dailyReminder", isOn: $dailyReminderEnabled)
                        .accessibilityIdentifier("daily-reminder-toggle")

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
                    .accessibilityIdentifier("reminder-time-picker")
                }

                Section {
                    Toggle("settings.detailedRecordMode", isOn: $detailedRecordModeEnabled)
                        .accessibilityIdentifier("detailed-record-mode-toggle")
                }

                Section {
                    TextField(
                        "settings.caregiverName",
                        text: Binding(
                            get: { caregiverName },
                            set: { caregiverName = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        )
                    )
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .accessibilityIdentifier("caregiver-name-field")
                }

                if authService.isBiometricAvailable {
                    Section(header: Text("settings.security")) {
                        Toggle(authService.biometryType.settingsToggleLabelKey, isOn: $biometricLockEnabled)
                            .accessibilityIdentifier("biometric-lock-toggle")
                    }
                }
            }
            .navigationTitle("tab.settings")
        }
    }
}
