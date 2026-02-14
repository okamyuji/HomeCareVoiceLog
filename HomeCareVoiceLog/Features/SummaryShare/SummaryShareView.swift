import HomeCareVoiceLogCore
import SwiftUI

struct SummaryShareView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDay = Date()
    @State private var summaryText = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(String(localized: "summary.targetDay"), selection: $selectedDay, displayedComponents: .date)
                Button(String(localized: "summary.generate")) {
                    generateSummary()
                }
                .accessibilityIdentifier("generate-summary")

                if !summaryText.isEmpty {
                    Section(String(localized: "summary.preview")) {
                        Text(summaryText)
                            .font(.footnote)
                    }

                    ShareLink(item: summaryText) {
                        Label(String(localized: "summary.share"), systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("share-summary")
                }
            }
            .navigationTitle(String(localized: "tab.summary"))
        }
    }

    private func generateSummary() {
        let repository = CareRecordRepository(modelContext: modelContext)
        let formatter = DailySummaryFormatter()
        let records = (try? repository.records(on: selectedDay)) ?? []
        let drafts = records.map {
            CareRecordDraft(
                timestamp: $0.timestamp,
                category: $0.category,
                transcriptText: $0.transcriptText,
                freeMemoText: $0.freeMemoText
            )
        }

        summaryText = formatter.format(records: drafts, date: selectedDay, locale: .current)
    }
}
