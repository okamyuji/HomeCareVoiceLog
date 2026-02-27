import Foundation

public enum CareCategory: String, CaseIterable, Codable, Sendable {
    case medication
    case meal
    case toileting
    case medicalVisit
    case bathing
    case vitalSigns
    case exercise
    case freeMemo

    public static let simpleCases: [CareCategory] = [.medication, .meal, .toileting, .medicalVisit, .freeMemo]

    public static let detailedCases: [CareCategory] = [
        .medication,
        .meal,
        .toileting,
        .medicalVisit,
        .bathing,
        .vitalSigns,
        .exercise,
        .freeMemo,
    ]

    private static let localizedLabels: [CareCategory: (ja: String, en: String)] = [
        .medication: ("服薬", "Medication"),
        .meal: ("食事", "Meal"),
        .toileting: ("排泄", "Toileting"),
        .medicalVisit: ("通院", "Medical Visit"),
        .bathing: ("入浴", "Bath"),
        .vitalSigns: ("バイタル", "Vitals"),
        .exercise: ("運動", "Exercise"),
        .freeMemo: ("自由メモ", "Free Memo"),
    ]

    public func localizedLabel(locale: Locale) -> String {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        guard let labels = Self.localizedLabels[self] else {
            return rawValue
        }
        return isJapanese ? labels.ja : labels.en
    }
}
