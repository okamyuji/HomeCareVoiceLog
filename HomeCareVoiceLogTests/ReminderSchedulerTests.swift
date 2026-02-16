import Foundation
@testable import HomeCareVoiceLog
import UserNotifications
import XCTest

final class ReminderSchedulerTests: XCTestCase {
    func testSchedulesOneDailyTriggerAtConfiguredTime() async throws {
        let center = NotificationCenterMock()
        let scheduler = ReminderScheduler(center: center)

        try await scheduler.updateDailyReminder(enabled: true, time: DateComponents(hour: 8, minute: 30))

        XCTAssertEqual(center.removedIdentifiers, [ReminderScheduler.reminderIdentifier])
        XCTAssertEqual(center.addedRequests.count, 1)

        let request = try XCTUnwrap(center.addedRequests.first)
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.hour, 8)
        XCTAssertEqual(trigger.dateComponents.minute, 30)
    }

    func testReschedulesWhenTimeChanges() async throws {
        let center = NotificationCenterMock()
        let scheduler = ReminderScheduler(center: center)

        try await scheduler.updateDailyReminder(enabled: true, time: DateComponents(hour: 9, minute: 0))
        try await scheduler.updateDailyReminder(enabled: true, time: DateComponents(hour: 21, minute: 15))

        XCTAssertEqual(center.addedRequests.count, 2)

        let latest = try XCTUnwrap(center.addedRequests.last)
        let trigger = try XCTUnwrap(latest.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.dateComponents.hour, 21)
        XCTAssertEqual(trigger.dateComponents.minute, 15)
    }
}

private final class NotificationCenterMock: NotificationScheduling {
    var authorizationGranted = true
    var removedIdentifiers: [String] = []
    var addedRequests: [UNNotificationRequest] = []

    func requestAuthorization(options _: UNAuthorizationOptions) async throws -> Bool {
        authorizationGranted
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}
