import HomeCareVoiceLogCore
import SwiftUI
import UIKit

struct RecordView: View {
    @Environment(CareRecordRepository.self) private var repository
    @AppStorage("detailedRecordModeEnabled") private var detailedRecordModeEnabled = true
    @AppStorage("caregiverName") private var caregiverName = ""
    let viewModel: RecordViewModel
    @State private var selectedCategory: CareCategory = .freeMemo
    @State private var freeMemo = ""
    @State private var bodyTemperature = ""
    @State private var systolicBP = ""
    @State private var diastolicBP = ""
    @State private var pulseRate = ""
    @State private var oxygenSaturation = ""
    @State private var errorAlert: AppErrorAlert?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case freeMemo
    }

    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    CategorySelectionView(
                        selectedCategory: $selectedCategory,
                        categories: selectableCategories
                    )
                } label: {
                    HStack {
                        Text("record.category")
                        Spacer()
                        Text(selectedCategory.localizedLabel(locale: .current))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("selected-category-\(selectedCategory.rawValue)")
                    }
                }
                .accessibilityIdentifier("category-selector-row")

                TextField("record.freeMemo", text: $freeMemo, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .freeMemo)
                    .accessibilityIdentifier("free-memo-field")

                if isShowingVitalInput {
                    VitalSignsInputView(
                        bodyTemperature: $bodyTemperature,
                        systolicBP: $systolicBP,
                        diastolicBP: $diastolicBP,
                        pulseRate: $pulseRate,
                        oxygenSaturation: $oxygenSaturation
                    )
                }

                if viewModel.isRecording {
                    Section {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                            Text("record.recording")
                            Spacer()
                            Text(viewModel.elapsedRecordingText)
                                .monospacedDigit()
                        }
                    }
                }

                if let error = viewModel.lastErrorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                if !viewModel.transcriptText.isEmpty {
                    Section("record.transcript") {
                        Text(viewModel.transcriptText)
                    }
                }

                Button(recordButtonLabel) {
                    Task {
                        if viewModel.isRecording {
                            let recordedDuration = viewModel.elapsedRecordingSeconds
                            await viewModel.stopRecording()
                            let vitalResult = parsedVitalSigns
                            if vitalResult.hasInvalidInput {
                                errorAlert = AppErrorAlert(
                                    titleKey: "record.saveError",
                                    message: vitalResult.invalidInputMessage()
                                )
                                return
                            }
                            do {
                                try repository.addRecord(
                                    timestamp: Date(),
                                    category: selectedCategory,
                                    transcriptText: viewModel.transcriptText.normalizedForStorage,
                                    freeMemoText: freeMemo.normalizedForStorage,
                                    durationSeconds: recordedDuration > 0 ? recordedDuration : nil,
                                    caregiverName: caregiverName.normalizedForStorage,
                                    bodyTemperature: vitalResult.values.bodyTemperature,
                                    systolicBP: vitalResult.values.systolicBP,
                                    diastolicBP: vitalResult.values.diastolicBP,
                                    pulseRate: vitalResult.values.pulseRate,
                                    oxygenSaturation: vitalResult.values.oxygenSaturation
                                )
                                freeMemo = ""
                                resetVitalInputs()
                            } catch {
                                errorAlert = AppErrorAlert(
                                    titleKey: "record.saveError",
                                    message: String(localized: "record.saveError.detail")
                                )
                            }
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                }
            }
            .navigationTitle("tab.record")
            .appErrorAlert($errorAlert)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("keyboard.done") {
                        dismissKeyboard()
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if focusedField == .freeMemo {
                    Button("keyboard.dismiss") {
                        dismissKeyboard()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .accessibilityIdentifier("dismiss-keyboard-button")
                }
            }
            .onChange(of: detailedRecordModeEnabled) { _, isEnabled in
                if !isEnabled, !CareCategory.simpleCases.contains(selectedCategory) {
                    selectedCategory = .freeMemo
                }
            }
            .onChange(of: selectedCategory) { _, newCategory in
                if newCategory != .vitalSigns {
                    resetVitalInputs()
                }
            }
        }
    }

    private var recordButtonLabel: LocalizedStringKey {
        viewModel.isRecording ? "record.stop" : "record.start"
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

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func resetVitalInputs() {
        bodyTemperature = ""
        systolicBP = ""
        diastolicBP = ""
        pulseRate = ""
        oxygenSaturation = ""
    }

}

private struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: CareCategory
    let categories: [CareCategory]

    var body: some View {
        List(categories, id: \.self) { category in
            Button {
                selectedCategory = category
                dismiss()
            } label: {
                HStack {
                    Text(category.localizedLabel(locale: .current))
                    Spacer()
                    if category == selectedCategory {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .accessibilityIdentifier("category-option-\(category.rawValue)")
        }
        .navigationTitle("record.categorySelectionTitle")
    }
}
