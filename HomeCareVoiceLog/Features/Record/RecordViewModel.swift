import Foundation
import Observation

protocol FileManaging {
    func removeItem(at url: URL) throws
}

extension FileManager: FileManaging {}

@Observable
@MainActor
final class RecordViewModel {
    private(set) var isRecording = false
    private(set) var transcriptText = ""
    private(set) var elapsedRecordingSeconds = 0
    private(set) var lastErrorMessage: String?

    private let audioRecorder: AudioRecording
    private let speechTranscriber: SpeechTranscribing
    private let fileManager: FileManaging
    private let tickIntervalNanoseconds: UInt64
    private let sleep: @Sendable (UInt64) async throws -> Void
    private var elapsedTimerTask: Task<Void, Never>?

    var elapsedRecordingText: String {
        let minutes = elapsedRecordingSeconds / 60
        let seconds = elapsedRecordingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(
        audioRecorder: AudioRecording,
        speechTranscriber: SpeechTranscribing,
        fileManager: FileManaging = FileManager.default,
        tickIntervalNanoseconds: UInt64 = 1_000_000_000,
        sleep: @escaping @Sendable (UInt64) async throws -> Void = { nanoseconds in
            try await Task.sleep(nanoseconds: nanoseconds)
        }
    ) {
        self.audioRecorder = audioRecorder
        self.speechTranscriber = speechTranscriber
        self.fileManager = fileManager
        self.tickIntervalNanoseconds = tickIntervalNanoseconds
        self.sleep = sleep
    }

    func startRecording() async {
        do {
            _ = try await audioRecorder.startRecording()
            isRecording = true
            elapsedRecordingSeconds = 0
            startElapsedTimer()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = String(localized: "record.startError")
            isRecording = false
            stopElapsedTimer(resetToZero: true)
        }
    }

    func stopRecording() async {
        isRecording = false
        stopElapsedTimer(resetToZero: true)

        do {
            let fileURL = try await audioRecorder.stopRecording()
            let transcription = try await speechTranscriber.transcribe(fileURL: fileURL)
            transcriptText = transcription
            try? fileManager.removeItem(at: fileURL)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = String(localized: "record.transcriptionError")
        }
    }

    private func startElapsedTimer() {
        elapsedTimerTask?.cancel()
        elapsedTimerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled, isRecording {
                try? await sleep(tickIntervalNanoseconds)
                guard !Task.isCancelled, isRecording else { break }
                elapsedRecordingSeconds += 1
            }
        }
    }

    private func stopElapsedTimer(resetToZero: Bool) {
        elapsedTimerTask?.cancel()
        elapsedTimerTask = nil
        if resetToZero {
            elapsedRecordingSeconds = 0
        }
    }
}
