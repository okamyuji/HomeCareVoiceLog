import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: [SortDescriptor(\CareRecordEntity.timestamp, order: .reverse)])
    private var records: [CareRecordEntity]
    @State private var selectedDay = Date()

    var body: some View {
        NavigationStack {
            List(filteredRecords) { record in
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
            .safeAreaInset(edge: .top) {
                DatePicker("Day", selection: $selectedDay, displayedComponents: .date)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.thinMaterial)
            }
            .navigationTitle("Timeline")
        }
    }

    private var filteredRecords: [CareRecordEntity] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDay) }
    }
}
