import Foundation

public enum CareCategory: String, CaseIterable, Codable, Sendable {
    case medication
    case meal
    case toileting
    case medicalVisit
    case freeMemo

    public func localizedLabel(locale: Locale) -> String {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        switch (self, isJapanese) {
        case (.medication, true):
            return "服薬"
        case (.meal, true):
            return "食事"
        case (.toileting, true):
            return "排泄"
        case (.medicalVisit, true):
            return "通院"
        case (.freeMemo, true):
            return "自由メモ"
        case (.medication, false):
            return "Medication"
        case (.meal, false):
            return "Meal"
        case (.toileting, false):
            return "Toileting"
        case (.medicalVisit, false):
            return "Medical Visit"
        case (.freeMemo, false):
            return "Free Memo"
        }
    }
}
