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
    var durationSeconds: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        timestamp: Date,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?,
        durationSeconds: Int?,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.timestamp = timestamp
        categoryRawValue = category.rawValue
        self.transcriptText = transcriptText
        self.freeMemoText = freeMemoText
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var category: CareCategory {
        get { CareCategory(rawValue: categoryRawValue) ?? .freeMemo }
        set { categoryRawValue = newValue.rawValue }
    }
}
