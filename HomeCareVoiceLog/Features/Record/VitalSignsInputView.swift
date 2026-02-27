import SwiftUI

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
    let hasInvalidInput: Bool

    static let empty = VitalSignsParseResult(values: .empty, hasInvalidInput: false)
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

        let hasInvalidInput = parsedBodyTemperature.isInvalid ||
            parsedSystolic.isInvalid ||
            parsedDiastolic.isInvalid ||
            parsedPulse.isInvalid ||
            parsedOxygen.isInvalid

        return VitalSignsParseResult(
            values: VitalSignsValues(
                bodyTemperature: parsedBodyTemperature.value,
                systolicBP: parsedSystolic.value,
                diastolicBP: parsedDiastolic.value,
                pulseRate: parsedPulse.value,
                oxygenSaturation: parsedOxygen.value
            ),
            hasInvalidInput: hasInvalidInput
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
