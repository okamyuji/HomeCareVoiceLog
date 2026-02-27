import Foundation
@testable import HomeCareVoiceLog
import HomeCareVoiceLogCore
import SwiftData
import XCTest

@MainActor
final class CaregiverNamePersistenceTests: XCTestCase {
    func testAddRecordPersistsNormalizedCaregiverName() throws {
        let repository = try makeRepository()

        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 8, minute: 0),
            category: .meal,
            transcriptText: "Breakfast",
            freeMemoText: nil,
            durationSeconds: 10,
            caregiverName: "  Yamada  "
        )

        XCTAssertEqual(record.caregiverName, "Yamada")
    }

    func testAddRecordTreatsBlankCaregiverNameAsNil() throws {
        let repository = try makeRepository()

        let record = try repository.addRecord(
            timestamp: date(year: 2026, month: 2, day: 14, hour: 8, minute: 0),
            category: .meal,
            transcriptText: "Breakfast",
            freeMemoText: nil,
            durationSeconds: 10,
            caregiverName: "   "
        )

        XCTAssertNil(record.caregiverName)
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
