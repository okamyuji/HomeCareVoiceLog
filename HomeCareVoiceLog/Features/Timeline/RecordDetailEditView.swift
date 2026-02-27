import HomeCareVoiceLogCore
import SwiftUI

@MainActor
struct RecordDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CareRecordRepository.self) private var repository

    private let record: CareRecordEntity

    @State private var selectedCategory: CareCategory
    @State private var transcriptText: String
    @State private var freeMemoText: String
    @State private var errorAlert: AppErrorAlert?

    init(record: CareRecordEntity) {
        self.record = record
        _selectedCategory = State(wrappedValue: record.category)
        _transcriptText = State(wrappedValue: record.transcriptText.normalizedForStorage ?? "")
        _freeMemoText = State(wrappedValue: record.freeMemoText.normalizedForStorage ?? "")
    }

    var body: some View {
        Form {
            Picker("record.category", selection: $selectedCategory) {
                ForEach(CareCategory.allCases, id: \.self) { category in
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
    }

    private func save() {
        do {
            try repository.updateRecord(
                record,
                category: selectedCategory,
                transcriptText: transcriptText.normalizedForStorage,
                freeMemoText: freeMemoText.normalizedForStorage
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
        record.category != selectedCategory ||
            record.transcriptText.normalizedForStorage != transcriptText.normalizedForStorage ||
            record.freeMemoText.normalizedForStorage != freeMemoText.normalizedForStorage
    }
}
