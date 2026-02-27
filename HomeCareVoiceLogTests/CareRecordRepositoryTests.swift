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

    func testUpdateRecordPersistsChanges() throws {
        let repository = try makeRepository()
        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .meal,
            transcriptText: "Before",
            freeMemoText: "Before memo",
            durationSeconds: 12
        )
        let originalUpdatedAt = record.updatedAt

        try repository.updateRecord(
            record,
            category: .medication,
            transcriptText: "After",
            freeMemoText: "After memo"
        )

        let records = try repository.records(on: date(year: 2026, month: 2, day: 14, hour: 0, minute: 0))
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].category, .medication)
        XCTAssertEqual(records[0].transcriptText, "After")
        XCTAssertEqual(records[0].freeMemoText, "After memo")
        XCTAssertGreaterThanOrEqual(records[0].updatedAt, originalUpdatedAt)
    }

    func testUpdateRecordNoChangesDoesNotTouchUpdatedAt() throws {
        let repository = try makeRepository()
        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .meal,
            transcriptText: "No Change",
            freeMemoText: "No Change Memo",
            durationSeconds: 12
        )
        let originalUpdatedAt = record.updatedAt

        try repository.updateRecord(
            record,
            category: .meal,
            transcriptText: "No Change",
            freeMemoText: "No Change Memo"
        )

        XCTAssertEqual(record.updatedAt, originalUpdatedAt)
    }

    func testAddRecordNormalizesTextFields() throws {
        let repository = try makeRepository()

        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .freeMemo,
            transcriptText: "  Transcript  ",
            freeMemoText: "   ",
            durationSeconds: nil
        )

        XCTAssertEqual(record.transcriptText, "Transcript")
        XCTAssertNil(record.freeMemoText)
    }

    func testUpdateRecordSkipsSaveWhenNormalizedValuesAreEqual() throws {
        let repository = try makeRepository()
        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .meal,
            transcriptText: "A",
            freeMemoText: nil,
            durationSeconds: nil
        )
        let originalUpdatedAt = record.updatedAt

        try repository.updateRecord(
            record,
            category: .meal,
            transcriptText: "  A  ",
            freeMemoText: "   "
        )

        XCTAssertEqual(record.updatedAt, originalUpdatedAt)
        XCTAssertEqual(record.transcriptText, "A")
        XCTAssertNil(record.freeMemoText)
    }

    func testDeleteRecordRemovesEntity() throws {
        let repository = try makeRepository()
        let keep = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 9, minute: 0),
            category: .meal,
            transcriptText: "Keep",
            freeMemoText: nil,
            durationSeconds: nil
        )
        let deleteTarget = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 10, minute: 0),
            category: .medication,
            transcriptText: "Delete",
            freeMemoText: nil,
            durationSeconds: nil
        )

        try repository.deleteRecord(deleteTarget)

        let records = try repository.records(on: date(year: 2026, month: 2, day: 14, hour: 0, minute: 0))
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].id, keep.id)
    }

    func testAddRecordPersistsVitalSigns() throws {
        let repository = try makeRepository()

        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 8, minute: 0),
            category: .vitalSigns,
            transcriptText: nil,
            freeMemoText: nil,
            durationSeconds: nil,
            bodyTemperature: 36.7,
            systolicBP: 120,
            diastolicBP: 78,
            pulseRate: 70,
            oxygenSaturation: 97
        )

        XCTAssertEqual(record.bodyTemperature, 36.7)
        XCTAssertEqual(record.systolicBP, 120)
        XCTAssertEqual(record.diastolicBP, 78)
        XCTAssertEqual(record.pulseRate, 70)
        XCTAssertEqual(record.oxygenSaturation, 97)
    }

    func testUpdateRecordNoVitalChangesDoesNotTouchUpdatedAt() throws {
        let repository = try makeRepository()
        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 8, minute: 0),
            category: .vitalSigns,
            transcriptText: nil,
            freeMemoText: nil,
            durationSeconds: nil,
            bodyTemperature: 36.5,
            systolicBP: 112,
            diastolicBP: 70,
            pulseRate: 66,
            oxygenSaturation: 99
        )
        let originalUpdatedAt = record.updatedAt

        try repository.updateRecord(
            record,
            category: .vitalSigns,
            transcriptText: nil,
            freeMemoText: nil,
            bodyTemperature: 36.5,
            systolicBP: 112,
            diastolicBP: 70,
            pulseRate: 66,
            oxygenSaturation: 99
        )

        XCTAssertEqual(record.updatedAt, originalUpdatedAt)
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
