import Foundation
import HomeCareVoiceLogCore
import SwiftUI

@MainActor
struct RecordDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CareRecordRepository.self) private var repository
    @AppStorage("detailedRecordModeEnabled") private var detailedRecordModeEnabled = true

    private let record: CareRecordEntity

    @State private var selectedCategory: CareCategory
    @State private var transcriptText: String
    @State private var freeMemoText: String
    @State private var bodyTemperature: String
    @State private var systolicBP: String
    @State private var diastolicBP: String
    @State private var pulseRate: String
    @State private var oxygenSaturation: String
    @State private var errorAlert: AppErrorAlert?

    init(record: CareRecordEntity) {
        self.record = record
        _selectedCategory = State(wrappedValue: record.category)
        _transcriptText = State(wrappedValue: record.transcriptText.normalizedForStorage ?? "")
        _freeMemoText = State(wrappedValue: record.freeMemoText.normalizedForStorage ?? "")
        _bodyTemperature = State(wrappedValue: Self.formattedDouble(record.bodyTemperature))
        _systolicBP = State(wrappedValue: Self.formattedInt(record.systolicBP))
        _diastolicBP = State(wrappedValue: Self.formattedInt(record.diastolicBP))
        _pulseRate = State(wrappedValue: Self.formattedInt(record.pulseRate))
        _oxygenSaturation = State(wrappedValue: Self.formattedInt(record.oxygenSaturation))
    }

    var body: some View {
        Form {
            Picker("record.category", selection: $selectedCategory) {
                ForEach(selectableCategories, id: \.self) { category in
                    Text(category.localizedLabel(locale: .current))
                        .tag(category)
                }
            }
            .accessibilityIdentifier("timeline-edit-category-picker")

            TextField("timeline.edit.transcript", text: $transcriptText, axis: .vertical)
                .lineLimit(3 ... 6)
                .accessibilityIdentifier("timeline-edit-transcript-field")

            TextField("record.freeMemo", text: $freeMemoText, axis: .vertical)
                .lineLimit(3 ... 6)
                .accessibilityIdentifier("timeline-edit-memo-field")

            if isShowingVitalInput {
                VitalSignsInputView(
                    bodyTemperature: $bodyTemperature,
                    systolicBP: $systolicBP,
                    diastolicBP: $diastolicBP,
                    pulseRate: $pulseRate,
                    oxygenSaturation: $oxygenSaturation
                )
            }
        }
        .navigationTitle("timeline.editTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") {
                    save()
                }
                .disabled(!isModified)
                .accessibilityIdentifier("timeline-edit-save-button")
            }
        }
        .appErrorAlert($errorAlert)
        .onChange(of: detailedRecordModeEnabled) { _, isEnabled in
            if !isEnabled, !CareCategory.simpleCases.contains(selectedCategory) {
                selectedCategory = .freeMemo
            }
        }
        .onChange(of: selectedCategory) { _, newCategory in
            if newCategory != .vitalSigns {
                clearVitalInputs()
            }
        }
    }

    private func save() {
        let vitalResult = parsedVitalSigns
        if vitalResult.hasInvalidInput {
            errorAlert = AppErrorAlert(
                titleKey: "record.saveError",
                message: String(localized: "record.saveError.detail")
            )
            return
        }
        do {
            try repository.updateRecord(
                record,
                category: selectedCategory,
                transcriptText: transcriptText.normalizedForStorage,
                freeMemoText: freeMemoText.normalizedForStorage,
                bodyTemperature: vitalResult.values.bodyTemperature,
                systolicBP: vitalResult.values.systolicBP,
                diastolicBP: vitalResult.values.diastolicBP,
                pulseRate: vitalResult.values.pulseRate,
                oxygenSaturation: vitalResult.values.oxygenSaturation
            )
            dismiss()
        } catch {
            errorAlert = AppErrorAlert(
                titleKey: "record.saveError",
                message: String(localized: "record.saveError.detail")
            )
        }
    }

    private var isModified: Bool {
        let vitalResult = parsedVitalSigns
        return record.category != selectedCategory ||
            record.transcriptText.normalizedForStorage != transcriptText.normalizedForStorage ||
            record.freeMemoText.normalizedForStorage != freeMemoText.normalizedForStorage ||
            vitalResult.hasInvalidInput ||
            record.bodyTemperature != vitalResult.values.bodyTemperature ||
            record.systolicBP != vitalResult.values.systolicBP ||
            record.diastolicBP != vitalResult.values.diastolicBP ||
            record.pulseRate != vitalResult.values.pulseRate ||
            record.oxygenSaturation != vitalResult.values.oxygenSaturation
    }

    private var selectableCategories: [CareCategory] {
        detailedRecordModeEnabled ? CareCategory.detailedCases : CareCategory.simpleCases
    }

    private var isShowingVitalInput: Bool {
        detailedRecordModeEnabled && selectedCategory == .vitalSigns
    }

    private var parsedVitalSigns: VitalSignsParseResult {
        guard isShowingVitalInput else {
            return .empty
        }
        return VitalSignsInputParser.parse(
            bodyTemperature: bodyTemperature,
            systolicBP: systolicBP,
            diastolicBP: diastolicBP,
            pulseRate: pulseRate,
            oxygenSaturation: oxygenSaturation
        )
    }

    private func clearVitalInputs() {
        bodyTemperature = ""
        systolicBP = ""
        diastolicBP = ""
        pulseRate = ""
        oxygenSaturation = ""
    }

    private static func formattedInt(_ value: Int?) -> String {
        value.map(String.init) ?? ""
    }

    private static func formattedDouble(_ value: Double?) -> String {
        guard let value else { return "" }
        return String(format: "%.1f", value)
    }
}
