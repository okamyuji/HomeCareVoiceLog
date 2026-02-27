import Foundation

public struct CareRecordDraft: Equatable, Sendable {
    public let timestamp: Date
    public let category: CareCategory
    public let transcriptText: String?
    public let freeMemoText: String?
    public let bodyTemperature: Double?
    public let systolicBP: Int?
    public let diastolicBP: Int?
    public let pulseRate: Int?
    public let oxygenSaturation: Int?

    public init(
        timestamp: Date,
        category: CareCategory,
        transcriptText: String?,
        freeMemoText: String?,
        bodyTemperature: Double? = nil,
        systolicBP: Int? = nil,
        diastolicBP: Int? = nil,
        pulseRate: Int? = nil,
        oxygenSaturation: Int? = nil
    ) {
        self.timestamp = timestamp
        self.category = category
        self.transcriptText = transcriptText
        self.freeMemoText = freeMemoText
        self.bodyTemperature = bodyTemperature
        self.systolicBP = systolicBP
        self.diastolicBP = diastolicBP
        self.pulseRate = pulseRate
        self.oxygenSaturation = oxygenSaturation
    }
}
