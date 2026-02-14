import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderHour") private var dailyReminderHour = 9
    @AppStorage("dailyReminderMinute") private var dailyReminderMinute = 0

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Daily Reminder", isOn: $dailyReminderEnabled)

                DatePicker(
                    "Reminder Time",
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
            .navigationTitle("Settings")
        }
    }
}
