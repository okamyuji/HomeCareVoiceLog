import HomeCareVoiceLogCore
import SwiftUI
import UIKit

struct RecordView: View {
    @Environment(CareRecordRepository.self) private var repository
    let viewModel: RecordViewModel
    @State private var selectedCategory: CareCategory = .freeMemo
    @State private var freeMemo = ""
    @State private var errorAlert: AppErrorAlert?
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
                        Text("record.category")
                        Spacer()
                        Text(selectedCategory.localizedLabel(locale: .current))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("selected-category-\(selectedCategory.rawValue)")
                    }
                }
                .accessibilityIdentifier("category-selector-row")

                TextField("record.freeMemo", text: $freeMemo, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .freeMemo)
                    .accessibilityIdentifier("free-memo-field")

                if viewModel.isRecording {
                    Section {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                            Text("record.recording")
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
                    Section("record.transcript") {
                        Text(viewModel.transcriptText)
                    }
                }

                Button(recordButtonLabel) {
                    Task {
                        if viewModel.isRecording {
                            let recordedDuration = viewModel.elapsedRecordingSeconds
                            await viewModel.stopRecording()
                            do {
                                try repository.addRecord(
                                    timestamp: Date(),
                                    category: selectedCategory,
                                    transcriptText: viewModel.transcriptText.normalizedForStorage,
                                    freeMemoText: freeMemo.normalizedForStorage,
                                    durationSeconds: recordedDuration > 0 ? recordedDuration : nil
                                )
                                freeMemo = ""
                            } catch {
                                errorAlert = AppErrorAlert(
                                    titleKey: "record.saveError",
                                    message: String(localized: "record.saveError.detail")
                                )
                            }
                        } else {
                            await viewModel.startRecording()
                        }
                    }
                }
            }
            .navigationTitle("tab.record")
            .appErrorAlert($errorAlert)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("keyboard.done") {
                        dismissKeyboard()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if focusedField == .freeMemo {
                    HStack {
                        Spacer()
                        Button("keyboard.dismiss") {
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

    private var recordButtonLabel: LocalizedStringKey {
        viewModel.isRecording ? "record.stop" : "record.start"
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
        .navigationTitle("record.categorySelectionTitle")
    }
}
