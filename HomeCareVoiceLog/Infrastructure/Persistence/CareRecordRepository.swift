import Foundation
import HomeCareVoiceLogCore
import Observation
import SwiftData

@MainActor
@Observable
final class CareRecordRepository {
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
        durationSeconds: Int?,
        caregiverName: String? = nil,
        bodyTemperature: Double? = nil,
        systolicBP: Int? = nil,
        diastolicBP: Int? = nil,
        pulseRate: Int? = nil,
        oxygenSaturation: Int? = nil
    ) throws -> CareRecordEntity {
        let now = Date()
        let normalizedTranscriptText = transcriptText.normalizedForStorage
        let normalizedFreeMemoText = freeMemoText.normalizedForStorage
        let normalizedCaregiverName = caregiverName.normalizedForStorage
        let entity = CareRecordEntity(
            timestamp: timestamp,
            category: category,
            transcriptText: normalizedTranscriptText,
            freeMemoText: normalizedFreeMemoText,
            caregiverName: normalizedCaregiverName,
            bodyTemperature: bodyTemperature,
            systolicBP: systolicBP,
            diastolicBP: diastolicBP,
            pulseRate: pulseRate,
            oxygenSaturation: oxygenSaturation,
            durationSeconds: durationSeconds,
            createdAt: now,
            updatedAt: now
        )
        modelContext.insert(entity)
        try modelContext.save()
        return entity
    }

    func updateRecord(
        _ record: CareRecordEntity,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?,
        bodyTemperature: Double? = nil,
        systolicBP: Int? = nil,
        diastolicBP: Int? = nil,
        pulseRate: Int? = nil,
        oxygenSaturation: Int? = nil
    ) throws {
        let normalizedTranscriptText = transcriptText.normalizedForStorage
        let normalizedFreeMemoText = freeMemoText.normalizedForStorage
        guard
            record.category != category ||
            record.transcriptText != normalizedTranscriptText ||
            record.freeMemoText != normalizedFreeMemoText ||
            record.bodyTemperature != bodyTemperature ||
            record.systolicBP != systolicBP ||
            record.diastolicBP != diastolicBP ||
            record.pulseRate != pulseRate ||
            record.oxygenSaturation != oxygenSaturation
        else {
            return
        }
        record.category = category
        record.transcriptText = normalizedTranscriptText
        record.freeMemoText = normalizedFreeMemoText
        record.bodyTemperature = bodyTemperature
        record.systolicBP = systolicBP
        record.diastolicBP = diastolicBP
        record.pulseRate = pulseRate
        record.oxygenSaturation = oxygenSaturation
        record.updatedAt = Date()
        try modelContext.save()
    }

    func deleteRecord(_ record: CareRecordEntity) throws {
        modelContext.delete(record)
        try modelContext.save()
    }

    func records(
        on day: Date,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) throws -> [CareRecordEntity] {
        let range = calendar.dayInterval(for: day)
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
}
