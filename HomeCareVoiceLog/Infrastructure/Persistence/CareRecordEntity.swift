import Foundation
import HomeCareVoiceLogCore
import SwiftData

@Model
final class CareRecordEntity {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var categoryRawValue: String
    var transcriptText: String?
    var freeMemoText: String?
    var caregiverName: String?
    var bodyTemperature: Double?
    var systolicBP: Int?
    var diastolicBP: Int?
    var pulseRate: Int?
    var oxygenSaturation: Int?
    var durationSeconds: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        timestamp: Date,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?,
        caregiverName: String? = nil,
        bodyTemperature: Double? = nil,
        systolicBP: Int? = nil,
        diastolicBP: Int? = nil,
        pulseRate: Int? = nil,
        oxygenSaturation: Int? = nil,
        durationSeconds: Int?,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.timestamp = timestamp
        categoryRawValue = category.rawValue
        self.transcriptText = transcriptText
        self.freeMemoText = freeMemoText
        self.caregiverName = caregiverName
        self.bodyTemperature = bodyTemperature
        self.systolicBP = systolicBP
        self.diastolicBP = diastolicBP
        self.pulseRate = pulseRate
        self.oxygenSaturation = oxygenSaturation
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var category: CareCategory {
        get { CareCategory(rawValue: categoryRawValue) ?? .freeMemo }
        set { categoryRawValue = newValue.rawValue }
    }
}
