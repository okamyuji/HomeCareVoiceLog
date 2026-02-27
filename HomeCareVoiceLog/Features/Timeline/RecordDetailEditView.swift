import HomeCareVoiceLogCore
import SwiftUI

@MainActor
struct RecordDetailEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let record: CareRecordEntity

    @State private var selectedCategory: CareCategory
    @State private var transcriptText: String
    @State private var freeMemoText: String
    @State private var saveErrorMessage: String?
    @State private var isSaving = false

    init(record: CareRecordEntity) {
        self.record = record
        _selectedCategory = State(initialValue: record.category)
        _transcriptText = State(initialValue: record.transcriptText ?? "")
        _freeMemoText = State(initialValue: record.freeMemoText ?? "")
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
                .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") {
                    save()
                }
                .disabled(isSaving)
                .accessibilityIdentifier("timeline-edit-save-button")
            }
        }
        .alert("record.saveError", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { _ in }
        )) {
            Button("OK") { saveErrorMessage = nil }
        } message: {
            if let saveErrorMessage {
                Text(saveErrorMessage)
            }
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            try CareRecordRepository(modelContext: modelContext).updateRecord(
                record,
                category: selectedCategory,
                transcriptText: normalized(text: transcriptText),
                freeMemoText: normalized(text: freeMemoText)
            )
            dismiss()
        } catch {
            saveErrorMessage = String(localized: "record.saveError.detail")
        }
    }

    private func normalized(text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
