import Foundation
import SwiftData

@Model
final class ReminderSettingsEntity {
    @Attribute(.unique) var id: UUID
    var dailyReminderEnabled: Bool
    var dailyReminderHour: Int
    var dailyReminderMinute: Int

    init(
        id: UUID = UUID(),
        dailyReminderEnabled: Bool,
        dailyReminderTime: DateComponents
    ) {
        self.id = id
        self.dailyReminderEnabled = dailyReminderEnabled
        dailyReminderHour = dailyReminderTime.hour ?? 9
        dailyReminderMinute = dailyReminderTime.minute ?? 0
    }

    var dailyReminderTime: DateComponents {
        get {
            DateComponents(hour: dailyReminderHour, minute: dailyReminderMinute)
        }
        set {
            dailyReminderHour = newValue.hour ?? 9
            dailyReminderMinute = newValue.minute ?? 0
        }
    }
}
