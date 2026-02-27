import SwiftUI

enum VitalSignField: CaseIterable, Equatable {
    case bodyTemperature
    case systolicBP
    case diastolicBP
    case pulseRate
    case oxygenSaturation

    var labelKey: String {
        switch self {
        case .bodyTemperature:
            return "record.vital.bodyTemperature"
        case .systolicBP:
            return "record.vital.systolicBP"
        case .diastolicBP:
            return "record.vital.diastolicBP"
        case .pulseRate:
            return "record.vital.pulseRate"
        case .oxygenSaturation:
            return "record.vital.oxygenSaturation"
        }
    }
}

struct VitalSignsValues: Equatable {
    let bodyTemperature: Double?
    let systolicBP: Int?
    let diastolicBP: Int?
    let pulseRate: Int?
    let oxygenSaturation: Int?

    static let empty = VitalSignsValues(
        bodyTemperature: nil,
        systolicBP: nil,
        diastolicBP: nil,
        pulseRate: nil,
        oxygenSaturation: nil
    )
}

struct VitalSignsParseResult: Equatable {
    let values: VitalSignsValues
    let invalidFields: [VitalSignField]

    var hasInvalidInput: Bool {
        !invalidFields.isEmpty
    }

    func invalidInputMessage(locale: Locale = .current) -> String {
        let labels = invalidFields.map { NSLocalizedString($0.labelKey, comment: "") }
        let prefix = String(localized: "record.saveError.invalidInputPrefix", locale: locale)
        return prefix + ": " + labels.joined(separator: ", ")
    }

    static let empty = VitalSignsParseResult(values: .empty, invalidFields: [])
}

enum VitalSignsInputParser {
    static func parse(
        bodyTemperature: String,
        systolicBP: String,
        diastolicBP: String,
        pulseRate: String,
        oxygenSaturation: String
    ) -> VitalSignsParseResult {
        let parsedBodyTemperature = parseOptionalDouble(bodyTemperature)
        let parsedSystolic = parseOptionalInt(systolicBP)
        let parsedDiastolic = parseOptionalInt(diastolicBP)
        let parsedPulse = parseOptionalInt(pulseRate)
        let parsedOxygen = parseOptionalInt(oxygenSaturation)

        var invalidFields: [VitalSignField] = []
        if parsedBodyTemperature.isInvalid {
            invalidFields.append(.bodyTemperature)
        }
        if parsedSystolic.isInvalid {
            invalidFields.append(.systolicBP)
        }
        if parsedDiastolic.isInvalid {
            invalidFields.append(.diastolicBP)
        }
        if parsedPulse.isInvalid {
            invalidFields.append(.pulseRate)
        }
        if parsedOxygen.isInvalid {
            invalidFields.append(.oxygenSaturation)
        }

        return VitalSignsParseResult(
            values: VitalSignsValues(
                bodyTemperature: parsedBodyTemperature.value,
                systolicBP: parsedSystolic.value,
                diastolicBP: parsedDiastolic.value,
                pulseRate: parsedPulse.value,
                oxygenSaturation: parsedOxygen.value
            ),
            invalidFields: invalidFields
        )
    }

    private static func parseOptionalInt(_ text: String) -> (value: Int?, isInvalid: Bool) {
        parseOptional(text, parser: Int.init)
    }

    private static func parseOptionalDouble(_ text: String) -> (value: Double?, isInvalid: Bool) {
        parseOptional(text) { raw in
            Double(raw.replacingOccurrences(of: ",", with: "."))
        }
    }

    private static func parseOptional<Value>(
        _ text: String,
        parser: (String) -> Value?
    ) -> (value: Value?, isInvalid: Bool) {
        guard let normalized = text.normalizedForStorage else {
            return (nil, false)
        }
        guard let value = parser(normalized) else {
            return (nil, true)
        }
        return (value, false)
    }
}

struct VitalSignsInputView: View {
    @Binding var bodyTemperature: String
    @Binding var systolicBP: String
    @Binding var diastolicBP: String
    @Binding var pulseRate: String
    @Binding var oxygenSaturation: String

    var body: some View {
        Section("record.vitalSigns.section") {
            TextField("record.vital.bodyTemperature", text: $bodyTemperature)
                .keyboardType(.decimalPad)
                .accessibilityIdentifier("vital-body-temperature-field")

            HStack {
                TextField("record.vital.systolicBP", text: $systolicBP)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("vital-systolic-bp-field")
                TextField("record.vital.diastolicBP", text: $diastolicBP)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("vital-diastolic-bp-field")
            }

            TextField("record.vital.pulseRate", text: $pulseRate)
                .keyboardType(.numberPad)
                .accessibilityIdentifier("vital-pulse-rate-field")

            TextField("record.vital.oxygenSaturation", text: $oxygenSaturation)
                .keyboardType(.numberPad)
                .accessibilityIdentifier("vital-oxygen-saturation-field")
        }
    }
}
