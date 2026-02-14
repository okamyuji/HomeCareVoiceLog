@testable import HomeCareVoiceLogCore
import Foundation
import Testing

@Test("Formats timeline in chronological order")
func timelineIsChronological() {
    let formatter = DailySummaryFormatter()
    let records = [
        CareRecordDraft(timestamp: date(hour: 10, minute: 30), category: .meal, transcriptText: "Lunch", freeMemoText: nil),
        CareRecordDraft(timestamp: date(hour: 8, minute: 15), category: .medication, transcriptText: "Morning meds", freeMemoText: nil),
    ]

    let text = formatter.format(records: records, date: date(hour: 0, minute: 0), locale: Locale(identifier: "en"))
    let first = text.range(of: "08:15")
    let second = text.range(of: "10:30")

    #expect(first != nil)
    #expect(second != nil)
    #expect(first!.lowerBound < second!.lowerBound)
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

private func date(hour: Int, minute: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    var components = DateComponents()
    components.year = 2026
    components.month = 2
    components.day = 14
    components.hour = hour
    components.minute = minute
    components.timeZone = TimeZone(secondsFromGMT: 0)
    return calendar.date(from: components)!
}
