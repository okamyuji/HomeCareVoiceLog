import Foundation

public struct DailySummaryFormatter: Sendable {
    public init() {}

    public func format(records: [CareRecordDraft], date: Date, locale: Locale) -> String {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        let sorted = records.sorted { $0.timestamp < $1.timestamp }
        let displayTimeZone = TimeZone.autoupdatingCurrent
        let displayCalendar = Calendar.autoupdatingCurrent
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = displayCalendar
        dateFormatter.timeZone = displayTimeZone
        dateFormatter.dateFormat = isJapanese ? "yyyy/MM/dd" : "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.calendar = displayCalendar
        timeFormatter.timeZone = displayTimeZone
        timeFormatter.dateFormat = "HH:mm"

        let title = isJapanese ? "日次サマリー (\(dateFormatter.string(from: date)))" : "Daily Summary (\(dateFormatter.string(from: date)))"
        let timelineHeading = isJapanese ? "タイムライン" : "Timeline"
        let countsHeading = isJapanese ? "カテゴリ別件数" : "Category Counts"
        let memosHeading = isJapanese ? "メモ一覧" : "Free Memos"

        let timelineLines = sorted.map { record in
            let time = timeFormatter.string(from: record.timestamp)
            let category = record.category.localizedLabel(locale: locale)
            let detail = cleanedText(record.transcriptText) ?? cleanedText(record.freeMemoText) ?? ""
            return detail.isEmpty ? "- \(time) \(category)" : "- \(time) \(category): \(detail)"
        }

        let countsLines = CareCategory.allCases.map { category in
            let count = sorted.filter { $0.category == category }.count
            return "- \(category.localizedLabel(locale: locale)): \(count)"
        }

        let memoLines = sorted
            .compactMap { cleanedText($0.freeMemoText) }
            .map { "- \($0)" }

        let memosSection = memoLines.isEmpty ? ["- \(isJapanese ? "なし" : "None")"] : memoLines

        return ([
            title,
            "",
            timelineHeading,
        ] + timelineLines + [
            "",
            countsHeading,
        ] + countsLines + [
            "",
            memosHeading,
        ] + memosSection).joined(separator: "\n")
    }

    private func cleanedText(_ text: String?) -> String? {
        guard let text else {
            return nil
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
