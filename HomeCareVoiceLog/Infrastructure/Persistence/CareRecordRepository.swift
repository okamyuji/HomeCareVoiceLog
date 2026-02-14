import Foundation
import HomeCareVoiceLogCore
import SwiftData

@MainActor
struct CareRecordRepository {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func addRecord(
        timestamp: Date,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?,
        durationSeconds: Int?
    ) throws -> CareRecordEntity {
        let now = Date()
        let entity = CareRecordEntity(
            timestamp: timestamp,
            category: category,
            transcriptText: transcriptText,
            freeMemoText: freeMemoText,
            durationSeconds: durationSeconds,
            createdAt: now,
            updatedAt: now
        )
        modelContext.insert(entity)
        try modelContext.save()
        return entity
    }

    func records(
        on day: Date,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) throws -> [CareRecordEntity] {
        let range = dayBounds(for: day, calendar: calendar)
        let descriptor = FetchDescriptor<CareRecordEntity>(
            predicate: #Predicate { entity in
                entity.timestamp >= range.start && entity.timestamp < range.end
            },
            sortBy: [SortDescriptor(\CareRecordEntity.timestamp, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func categoryCounts(
        on day: Date,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) throws -> [CareCategory: Int] {
        let rows = try records(on: day, calendar: calendar)
        return rows.reduce(into: [CareCategory: Int]()) { partial, entity in
            partial[entity.category, default: 0] += 1
        }
    }

    func freeMemoRecords(
        on day: Date,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) throws -> [CareRecordEntity] {
        try records(on: day, calendar: calendar).filter { entity in
            entity.category == .freeMemo
        }
    }

    private func dayBounds(for date: Date, calendar: Calendar) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        return DateInterval(start: start, end: end)
    }
}
