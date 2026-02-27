import Foundation

public struct DailySummaryFormatter: Sendable {
    public init() {}

    public func format(
        records: [CareRecordDraft],
        date: Date,
        locale: Locale,
        includeVitalTrend: Bool = false
    ) -> String {
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

        let dateString = dateFormatter.string(from: date)
        let title = isJapanese ? "日次サマリー (\(dateString))" : "Daily Summary (\(dateString))"
        let timelineHeading = isJapanese ? "タイムライン" : "Timeline"
        let countsHeading = isJapanese ? "カテゴリ別件数" : "Category Counts"
        let memosHeading = isJapanese ? "メモ一覧" : "Free Memos"
        let vitalHeading = isJapanese ? "バイタル推移" : "Vital Trends"

        let timelineLines = makeTimelineLines(records: sorted, locale: locale, timeFormatter: timeFormatter)
        let countsLines = makeCountsLines(records: sorted, locale: locale, includeDetailedCategories: includeVitalTrend)
        let memosSection = makeMemoSection(records: sorted, isJapanese: isJapanese)
        let vitalSection = makeVitalSection(
            records: sorted,
            isJapanese: isJapanese,
            includeVitalTrend: includeVitalTrend,
            vitalHeading: vitalHeading,
            timeFormatter: timeFormatter
        )

        var sections: [String] = [
            title,
            "",
            timelineHeading,
        ]
        sections += timelineLines
        sections += [
            "",
            countsHeading,
        ]
        sections += countsLines
        sections += [
            "",
            memosHeading,
        ]
        sections += memosSection
        sections += vitalSection
        return sections.joined(separator: "\n")
    }

    private func makeTimelineLines(
        records: [CareRecordDraft],
        locale: Locale,
        timeFormatter: DateFormatter
    ) -> [String] {
        records.map { record in
            let time = timeFormatter.string(from: record.timestamp)
            let category = record.category.localizedLabel(locale: locale)
            let detail = cleanedText(record.transcriptText) ?? cleanedText(record.freeMemoText) ?? ""
            return detail.isEmpty ? "- \(time) \(category)" : "- \(time) \(category): \(detail)"
        }
    }

    private func makeCountsLines(
        records: [CareRecordDraft],
        locale: Locale,
        includeDetailedCategories: Bool
    ) -> [String] {
        let summaryCategories = includeDetailedCategories ? CareCategory.detailedCases : CareCategory.simpleCases
        return summaryCategories.map { category in
            let count = records.filter { $0.category == category }.count
            return "- \(category.localizedLabel(locale: locale)): \(count)"
        }
    }

    private func makeMemoSection(records: [CareRecordDraft], isJapanese: Bool) -> [String] {
        let memoLines = records
            .compactMap { cleanedText($0.freeMemoText) }
            .map { "- \($0)" }
        return memoLines.isEmpty ? ["- \(isJapanese ? "なし" : "None")"] : memoLines
    }

    private func makeVitalSection(
        records: [CareRecordDraft],
        isJapanese: Bool,
        includeVitalTrend: Bool,
        vitalHeading: String,
        timeFormatter: DateFormatter
    ) -> [String] {
        guard includeVitalTrend else {
            return []
        }
        let vitalLines: [String] = records.compactMap { record in
            let measurements = formattedMeasurements(for: record, isJapanese: isJapanese)
            guard !measurements.isEmpty else {
                return nil
            }
            let time = timeFormatter.string(from: record.timestamp)
            return "- \(time) \(measurements.joined(separator: ", "))"
        }
        let emptyLabel = "- \(isJapanese ? "なし" : "None")"
        return ["", vitalHeading] + (vitalLines.isEmpty ? [emptyLabel] : vitalLines)
    }

    private func formattedMeasurements(for record: CareRecordDraft, isJapanese: Bool) -> [String] {
        var items: [String] = []
        if let bodyTemperature = record.bodyTemperature {
            items.append((isJapanese ? "体温" : "Temp") + " " + String(format: "%.1f", bodyTemperature))
        }
        if let systolicBP = record.systolicBP, let diastolicBP = record.diastolicBP {
            items.append((isJapanese ? "血圧" : "BP") + " \(systolicBP)/\(diastolicBP)")
        }
        if let pulseRate = record.pulseRate {
            items.append((isJapanese ? "脈拍" : "Pulse") + " \(pulseRate)")
        }
        if let oxygenSaturation = record.oxygenSaturation {
            items.append((isJapanese ? "SpO₂" : "SpO2") + " \(oxygenSaturation)%")
        }
        return items
    }

    private func cleanedText(_ text: String?) -> String? {
        guard let text else {
            return nil
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
