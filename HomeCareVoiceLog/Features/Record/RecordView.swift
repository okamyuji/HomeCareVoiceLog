import HomeCareVoiceLogCore
import SwiftUI

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = RecordViewModel(
        audioRecorder: AudioRecorderService(),
        speechTranscriber: SpeechTranscriptionService()
    )
    @State private var selectedCategory: CareCategory = .freeMemo
    @State private var freeMemo = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(CareCategory.allCases, id: \.self) { category in
                        Text(category.localizedLabel(locale: .current)).tag(category)
                    }
                }

                TextField("Free Memo", text: $freeMemo, axis: .vertical)
                    .lineLimit(3...6)

                if let error = viewModel.lastErrorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                if !viewModel.transcriptText.isEmpty {
                    Section("Transcript") {
                        Text(viewModel.transcriptText)
                    }
                }

                Button(viewModel.isRecording ? "Stop Recording" : "Start Recording") {
                    Task {
                        if viewModel.isRecording {
                            await viewModel.stopRecording()
                            try? CareRecordRepository(modelContext: modelContext).addRecord(
                                timestamp: Date(),
                                category: selectedCategory,
                                transcriptText: viewModel.transcriptText.isEmpty ? nil : viewModel.transcriptText,
                                freeMemoText: freeMemo.isEmpty ? nil : freeMemo,
                                durationSeconds: nil
                            )
                            freeMemo = ""
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                }
            }
            .navigationTitle("Record")
        }
    }
}
