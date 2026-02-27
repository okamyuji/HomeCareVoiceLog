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
        _transcriptText = State(wrappedValue: record.transcriptText ?? "")
        _freeMemoText = State(wrappedValue: record.freeMemoText ?? "")
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
                transcriptText: normalized(text: transcriptText),
                freeMemoText: normalized(text: freeMemoText)
            )
            dismiss()
        } catch {
            errorAlert = AppErrorAlert(
                titleKey: "record.saveError",
                message: String(localized: "record.saveError.detail")
            )
        }
    }

    private func normalized(text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
