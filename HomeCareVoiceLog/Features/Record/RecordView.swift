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
                Picker(String(localized: "record.category"), selection: $selectedCategory) {
                    ForEach(CareCategory.allCases, id: \.self) { category in
                        Text(category.localizedLabel(locale: .current)).tag(category)
                    }
                }

                TextField(String(localized: "record.freeMemo"), text: $freeMemo, axis: .vertical)
                    .lineLimit(3...6)

                if let error = viewModel.lastErrorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                if !viewModel.transcriptText.isEmpty {
                    Section(String(localized: "record.transcript")) {
                        Text(viewModel.transcriptText)
                    }
                }

                Button(viewModel.isRecording ? String(localized: "record.stop") : String(localized: "record.start")) {
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
            .navigationTitle(String(localized: "tab.record"))
        }
    }
}
