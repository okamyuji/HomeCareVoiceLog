import Foundation
@testable import HomeCareVoiceLogCore
import Testing

@Test("Formats timeline in chronological order")
func timelineIsChronological() throws {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(timestamp: date(hour: 10, minute: 30), category: .meal, transcriptText: "Lunch", freeMemoText: nil),
        CareRecordDraft(timestamp: date(hour: 8, minute: 15), category: .medication, transcriptText: "Morning meds", freeMemoText: nil),
    ]

    let text = formatter.format(records: records, date: date(hour: 0, minute: 0), locale: Locale(identifier: "en"))
    let first = text.range(of: "Morning meds")
    let second = text.range(of: "Lunch")

    #expect(first != nil)
    #expect(second != nil)
    #expect(try #require(first?.lowerBound) < second!.lowerBound)
}

@Test("Includes category counts and free memo list")
func includesCountsAndMemos() {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(timestamp: date(hour: 9, minute: 0), category: .medication, transcriptText: "Taken", freeMemoText: nil),
        CareRecordDraft(timestamp: date(hour: 12, minute: 0), category: .medication, transcriptText: "Taken", freeMemoText: "Felt dizzy"),
        CareRecordDraft(timestamp: date(hour: 18, minute: 0), category: .freeMemo, transcriptText: nil, freeMemoText: "Doctor called"),
    ]

    let text = formatter.format(records: records, date: date(hour: 0, minute: 0), locale: Locale(identifier: "en"))

    #expect(text.contains("Medication: 2"))
    #expect(text.contains("Free Memo: 1"))
    #expect(text.contains("Felt dizzy"))
    #expect(text.contains("Doctor called"))
}

@Test("Uses Japanese headings when locale is ja")
func usesJapaneseHeadings() {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(timestamp: date(hour: 7, minute: 0), category: .meal, transcriptText: "朝食", freeMemoText: nil),
    ]

    let text = formatter.format(records: records, date: date(hour: 0, minute: 0), locale: Locale(identifier: "ja"))

    #expect(text.contains("タイムライン"))
    #expect(text.contains("カテゴリ別件数"))
    #expect(text.contains("メモ一覧"))
}

@Test("Includes vital trend section when enabled")
func includesVitalTrendWhenEnabled() {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(
            timestamp: date(hour: 7, minute: 30),
            category: .vitalSigns,
            transcriptText: nil,
            freeMemoText: nil,
            bodyTemperature: 36.8,
            systolicBP: 118,
            diastolicBP: 72,
            pulseRate: 68,
            oxygenSaturation: 98
        ),
    ]

    let text = formatter.format(
        records: records,
        date: date(hour: 0, minute: 0),
        locale: Locale(identifier: "en"),
        includeVitalTrend: true
    )

    #expect(text.contains("Vital Trends"))
    #expect(text.contains("07:30"))
    #expect(text.contains("Temp 36.8"))
    #expect(text.contains("BP 118/72"))
}

@Test("Does not include vital trend section when disabled")
func doesNotIncludeVitalTrendWhenDisabled() {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(
            timestamp: date(hour: 7, minute: 30),
            category: .vitalSigns,
            transcriptText: nil,
            freeMemoText: nil,
            bodyTemperature: 36.8,
            systolicBP: 118,
            diastolicBP: 72,
            pulseRate: 68,
            oxygenSaturation: 98
        ),
    ]

    let text = formatter.format(
        records: records,
        date: date(hour: 0, minute: 0),
        locale: Locale(identifier: "en"),
        includeVitalTrend: false
    )

    #expect(!text.contains("Vital Trends"))
}

private func date(hour: Int, minute: Int) -> Date {
    let calendar = Calendar.autoupdatingCurrent
    var components = DateComponents()
    components.year = 2026
    components.month = 2
    components.day = 14
    components.hour = hour
    components.minute = minute
    components.timeZone = TimeZone.autoupdatingCurrent
    return calendar.date(from: components)!
}
