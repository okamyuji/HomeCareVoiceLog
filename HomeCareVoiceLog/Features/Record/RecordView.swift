import HomeCareVoiceLogCore
import SwiftUI
import UIKit

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = RecordViewModel(
        audioRecorder: AudioRecorderService(),
        speechTranscriber: SpeechTranscriptionService()
    )
    @State private var selectedCategory: CareCategory = .freeMemo
    @State private var freeMemo = ""
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case freeMemo
    }

    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    CategorySelectionView(selectedCategory: $selectedCategory)
                } label: {
                    HStack {
                        Text(String(localized: "record.category"))
                        Spacer()
                        Text(selectedCategory.localizedLabel(locale: .current))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("selected-category-\(selectedCategory.rawValue)")
                    }
                }
                .accessibilityIdentifier("category-selector-row")

                TextField(String(localized: "record.freeMemo"), text: $freeMemo, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .freeMemo)
                    .accessibilityIdentifier("free-memo-field")

                if viewModel.isRecording {
                    Section {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                            Text(String(localized: "record.recording"))
                            Spacer()
                            Text(viewModel.elapsedRecordingText)
                                .monospacedDigit()
                        }
                    }
                }

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
                            let recordedDuration = viewModel.elapsedRecordingSeconds
                            await viewModel.stopRecording()
                            _ = try? CareRecordRepository(modelContext: modelContext).addRecord(
                                timestamp: Date(),
                                category: selectedCategory,
                                transcriptText: viewModel.transcriptText.isEmpty ? nil : viewModel.transcriptText,
                                freeMemoText: freeMemo.isEmpty ? nil : freeMemo,
                                durationSeconds: recordedDuration > 0 ? recordedDuration : nil
                            )
                            freeMemo = ""
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "tab.record"))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "keyboard.done")) {
                        dismissKeyboard()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if focusedField == .freeMemo {
                    HStack {
                        Spacer()
                        Button(String(localized: "keyboard.dismiss")) {
                            dismissKeyboard()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("dismiss-keyboard-button")
                }
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

private struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: CareCategory

    var body: some View {
        List(CareCategory.allCases, id: \.self) { category in
            Button {
                selectedCategory = category
                dismiss()
            } label: {
                HStack {
                    Text(category.localizedLabel(locale: .current))
                    Spacer()
                    if category == selectedCategory {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
            .accessibilityIdentifier("category-option-\(category.rawValue)")
        }
        .navigationTitle(String(localized: "record.categorySelectionTitle"))
    }
}
