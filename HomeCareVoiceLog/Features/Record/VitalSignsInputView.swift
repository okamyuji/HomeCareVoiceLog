import SwiftUI

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
