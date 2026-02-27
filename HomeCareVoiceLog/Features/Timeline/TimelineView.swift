import SwiftData
import SwiftUI

@MainActor
struct TimelineView: View {
    @Environment(CareRecordRepository.self) private var repository
    @State private var selectedDay = Date()
    @State private var pendingDeleteRecord: CareRecordEntity?
    @State private var errorAlert: AppErrorAlert?

    var body: some View {
        NavigationStack {
            TimelineRecordList(selectedDay: selectedDay) { record in
                pendingDeleteRecord = record
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
                isPresented: $pendingDeleteRecord.isPresent,
                titleVisibility: .visible,
                presenting: pendingDeleteRecord
            ) { record in
                Button("timeline.deleteConfirmAction", role: .destructive) {
                    deleteRecord(record)
                }
                Button("common.cancel", role: .cancel) {}
            } message: { _ in
                Text("timeline.deleteConfirmMessage")
            }
            .appErrorAlert($errorAlert)
        }
    }

    private func deleteRecord(_ record: CareRecordEntity) {
        do {
            try repository.deleteRecord(record)
        } catch {
            errorAlert = AppErrorAlert(
                titleKey: "timeline.deleteError",
                message: String(localized: "timeline.deleteError.detail")
            )
        }
    }
}

private struct TimelineRecordList: View {
    @Query private var records: [CareRecordEntity]
    private let onDeleteRequest: (CareRecordEntity) -> Void

    init(selectedDay: Date, onDeleteRequest: @escaping (CareRecordEntity) -> Void) {
        self.onDeleteRequest = onDeleteRequest
        let dayInterval = Calendar.current.dayInterval(for: selectedDay)
        _records = Query(
            filter: #Predicate<CareRecordEntity> { entity in
                entity.timestamp >= dayInterval.start && entity.timestamp < dayInterval.end
            },
            sort: [SortDescriptor(\CareRecordEntity.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        List(records) { record in
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
                    if let caregiverName = record.caregiverName {
                        HStack(spacing: 4) {
                            Text("timeline.caregiver")
                                .foregroundStyle(.secondary)
                            Text(caregiverName)
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
            }
            .accessibilityIdentifier("timeline-record-\(record.id.uuidString)")
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    onDeleteRequest(record)
                } label: {
                    Label("timeline.delete", systemImage: "trash")
                }
            }
        }
    }
}
