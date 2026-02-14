import Foundation

protocol FileManaging {
    func removeItem(at url: URL) throws
}

extension FileManager: FileManaging {}

@MainActor
final class RecordViewModel: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var transcriptText = ""
    @Published private(set) var lastErrorMessage: String?

    private let audioRecorder: AudioRecording
    private let speechTranscriber: SpeechTranscribing
    private let fileManager: FileManaging

    init(
        audioRecorder: AudioRecording,
        speechTranscriber: SpeechTranscribing,
        fileManager: FileManaging = FileManager.default
    ) {
        self.audioRecorder = audioRecorder
        self.speechTranscriber = speechTranscriber
        self.fileManager = fileManager
    }

    func startRecording() async {
        do {
            _ = try await audioRecorder.startRecording()
            isRecording = true
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
            isRecording = false
        }
    }

    func stopRecording() async {
        do {
            let fileURL = try await audioRecorder.stopRecording()
            isRecording = false
            let transcription = try await speechTranscriber.transcribe(fileURL: fileURL)
            transcriptText = transcription
            try? fileManager.removeItem(at: fileURL)
            lastErrorMessage = nil
        } catch {
            isRecording = false
            lastErrorMessage = error.localizedDescription
        }
    }
}
