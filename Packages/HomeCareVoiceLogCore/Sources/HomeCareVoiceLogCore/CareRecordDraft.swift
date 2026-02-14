import Foundation

public struct CareRecordDraft: Equatable, Sendable {
    public let timestamp: Date
    public let category: CareCategory
    public let transcriptText: String?
    public let freeMemoText: String?

    public init(
        timestamp: Date,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?
    ) {
        self.timestamp = timestamp
        self.category = category
        self.transcriptText = transcriptText
        self.freeMemoText = freeMemoText
    }
}
