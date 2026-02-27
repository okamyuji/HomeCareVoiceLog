import SwiftData
import SwiftUI

@MainActor
struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\CareRecordEntity.timestamp, order: .reverse)])
    private var records: [CareRecordEntity]
    @State private var selectedDay = Date()
    @State private var pendingDeleteRecord: CareRecordEntity?
    @State private var deleteErrorMessage: String?

    var body: some View {
        NavigationStack {
            List(filteredRecords) { record in
                NavigationLink {
                    RecordDetailEditView(record: record)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.category.localizedLabel(locale: .current))
                            .font(.headline)
                        Text(record.timestamp, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let transcript = record.transcriptText, !transcript.isEmpty {
                            Text(transcript)
                        }
                        if let memo = record.freeMemoText, !memo.isEmpty {
                            Text(memo)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityIdentifier("timeline-record-\(record.id.uuidString)")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        pendingDeleteRecord = record
                    } label: {
                        Label("timeline.delete", systemImage: "trash")
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                DatePicker("timeline.day", selection: $selectedDay, displayedComponents: .date)
                    .accessibilityIdentifier("timeline-date-picker")
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.thinMaterial)
            }
            .navigationTitle("tab.timeline")
            .confirmationDialog(
                "timeline.deleteConfirmTitle",
                isPresented: Binding(
                    get: { pendingDeleteRecord != nil },
                    set: { if !$0 { pendingDeleteRecord = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("timeline.deleteConfirmAction", role: .destructive) {
                    deletePendingRecord()
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("timeline.deleteConfirmMessage")
            }
            .alert("timeline.deleteError", isPresented: Binding(
                get: { deleteErrorMessage != nil },
                set: { _ in }
            )) {
                Button("OK") { deleteErrorMessage = nil }
            } message: {
                if let deleteErrorMessage {
                    Text(deleteErrorMessage)
                }
            }
        }
    }

    private var filteredRecords: [CareRecordEntity] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDay) }
    }

    private func deletePendingRecord() {
        guard let pendingDeleteRecord else { return }
        defer { self.pendingDeleteRecord = nil }

        do {
            try CareRecordRepository(modelContext: modelContext).deleteRecord(pendingDeleteRecord)
        } catch {
            deleteErrorMessage = String(localized: "timeline.deleteError.detail")
        }
    }
}
