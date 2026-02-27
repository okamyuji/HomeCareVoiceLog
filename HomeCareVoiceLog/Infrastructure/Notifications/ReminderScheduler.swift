import Foundation
import UserNotifications

protocol NotificationScheduling {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

final class UserNotificationCenterAdapter: NotificationScheduling {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }

    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

enum ReminderSchedulerError: LocalizedError {
    case notificationPermissionDenied

    var errorDescription: String? {
        switch self {
        case .notificationPermissionDenied:
            String(localized: "error.notification.permission")
        }
    }
}

struct ReminderScheduler {
    static let reminderIdentifier = "daily-care-reminder"

    private let center: NotificationScheduling

    init(center: NotificationScheduling = UserNotificationCenterAdapter()) {
        self.center = center
    }

    func updateDailyReminder(enabled: Bool, time: DateComponents) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        guard enabled else {
            return
        }

        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else {
            throw ReminderSchedulerError.notificationPermissionDenied
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "reminder.title")
        content.body = String(localized: "reminder.body")
        content.sound = .default

        var components = DateComponents()
        components.hour = time.hour ?? 9
        components.minute = time.minute ?? 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.reminderIdentifier,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }
}
