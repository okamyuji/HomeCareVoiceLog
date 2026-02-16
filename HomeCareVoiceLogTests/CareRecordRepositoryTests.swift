import Foundation
@testable import HomeCareVoiceLog
import HomeCareVoiceLogCore
import SwiftData
import XCTest

@MainActor
final class CareRecordRepositoryTests: XCTestCase {
    func testInsertAndFetchByDay() throws {
        let repository = try makeRepository()

        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .meal,
            transcriptText: "Breakfast",
            freeMemoText: nil,
            durationSeconds: 12
        )
        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 10, minute: 0),
            category: .medication,
            transcriptText: "Taken",
            freeMemoText: nil,
            durationSeconds: 8
        )
        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 15, hour: 8, minute: 0),
            category: .meal,
            transcriptText: "Other day",
            freeMemoText: nil,
            durationSeconds: nil
        )

        let records = try repository.records(on: date(year: 2026, month: 2, day: 14, hour: 0, minute: 0))

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records.first?.category, .meal)
        XCTAssertEqual(records.last?.category, .medication)
    }

    func testCategoryCounts() throws {
        let repository = try makeRepository()

        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .medication,
            transcriptText: "A",
            freeMemoText: nil,
            durationSeconds: nil
        )
        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 11, minute: 0),
            category: .medication,
            transcriptText: "B",
            freeMemoText: nil,
            durationSeconds: nil
        )
        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 15, minute: 0),
            category: .freeMemo,
            transcriptText: nil,
            freeMemoText: "Call doctor",
            durationSeconds: nil
        )

        let counts = try repository.categoryCounts(on: date(year: 2026, month: 2, day: 14, hour: 0, minute: 0))

        XCTAssertEqual(counts[.medication], 2)
        XCTAssertEqual(counts[.freeMemo], 1)
    }

    func testMemoOnlyRecords() throws {
        let repository = try makeRepository()

        try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 20, minute: 0),
            category: .freeMemo,
            transcriptText: nil,
            freeMemoText: "Observe appetite",
            durationSeconds: nil
        )

        let memos = try repository.freeMemoRecords(on: date(year: 2026, month: 2, day: 14, hour: 0, minute: 0))

        XCTAssertEqual(memos.count, 1)
        XCTAssertEqual(memos[0].freeMemoText, "Observe appetite")
        XCTAssertNil(memos[0].transcriptText)
    }

    private func makeRepository() throws -> CareRecordRepository {
        let schema = Schema([
            CareRecordEntity.self,
            ReminderSettingsEntity.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return CareRecordRepository(modelContext: ModelContext(container))
    }

    private func date(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return Calendar(identifier: .gregorian).date(from: components)!
    }
}
