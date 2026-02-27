import HomeCareVoiceLogCore
import SwiftUI

struct SummaryShareView: View {
    @Environment(CareRecordRepository.self) private var repository
    @State private var selectedDay = Date()
    @State private var summaryText = ""
    @State private var errorAlert: AppErrorAlert?

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("summary.targetDay", selection: $selectedDay, displayedComponents: .date)
                Button("summary.generate") {
                    generateSummary()
                }
                .accessibilityIdentifier("generate-summary")

                if !summaryText.isEmpty {
                    Section("summary.preview") {
                        Text(summaryText)
                            .font(.footnote)
                    }

                    ShareLink(item: summaryText) {
                        Label("summary.share", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("share-summary")
                }
            }
            .navigationTitle("tab.summary")
            .appErrorAlert($errorAlert)
        }
    }

    private func generateSummary() {
        let formatter = DailySummaryFormatter()
        let records: [CareRecordEntity]
        do {
            records = try repository.records(on: selectedDay)
        } catch {
            errorAlert = AppErrorAlert(
                titleKey: "summary.error",
                message: String(localized: "summary.generateError")
            )
            return
        }
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
