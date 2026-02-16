import Foundation
@testable import HomeCareVoiceLog
import XCTest

@MainActor
final class RecordViewModelTests: XCTestCase {
    func testStopRecordingTriggersTranscriptionAutomatically() async {
        let audio = AudioRecorderServiceMock()
        let speech = SpeechTranscriptionServiceMock(result: .success("recognized text"))
        let files = FileManagerMock()
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            fileManager: files
        )

        await viewModel.startRecording()
        await viewModel.stopRecording()

        XCTAssertEqual(speech.transcribeCalledURLs.count, 1)
        XCTAssertEqual(viewModel.transcriptText, "recognized text")
    }

    func testSuccessfulTranscriptionDeletesAudioFile() async {
        let audio = AudioRecorderServiceMock()
        let speech = SpeechTranscriptionServiceMock(result: .success("done"))
        let files = FileManagerMock()
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            fileManager: files
        )

        await viewModel.startRecording()
        await viewModel.stopRecording()

        XCTAssertEqual(files.deletedURLs.count, 1)
    }

    func testFailureKeepsRecoverableErrorState() async {
        let audio = AudioRecorderServiceMock()
        let speech = SpeechTranscriptionServiceMock(result: .failure(SpeechTranscriptionError.recognitionFailed))
        let files = FileManagerMock()
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            fileManager: files
        )

        await viewModel.startRecording()
        await viewModel.stopRecording()

        XCTAssertNotNil(viewModel.lastErrorMessage)
        XCTAssertEqual(files.deletedURLs.count, 0)
    }

    func testElapsedRecordingSecondsIncreaseWhileRecording() async {
        let audio = AudioRecorderServiceMock()
        let speech = SpeechTranscriptionServiceMock(result: .success("ok"))
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            tickIntervalNanoseconds: 20_000_000
        )

        await viewModel.startRecording()
        try? await Task.sleep(nanoseconds: 70_000_000)

        XCTAssertGreaterThanOrEqual(viewModel.elapsedRecordingSeconds, 1)
    }

    func testElapsedRecordingSecondsResetToZeroAfterStopRecording() async {
        let audio = AudioRecorderServiceMock()
        let speech = SpeechTranscriptionServiceMock(result: .success("ok"))
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            tickIntervalNanoseconds: 20_000_000
        )

        await viewModel.startRecording()
        try? await Task.sleep(nanoseconds: 70_000_000)
        await viewModel.stopRecording()

        XCTAssertEqual(viewModel.elapsedRecordingSeconds, 0)
    }

    func testElapsedRecordingSecondsStayZeroWhenStartRecordingFails() async {
        let audio = AudioRecorderServiceMock(startError: NSError(domain: "test", code: 99))
        let speech = SpeechTranscriptionServiceMock(result: .success("ok"))
        let viewModel = RecordViewModel(
            audioRecorder: audio,
            speechTranscriber: speech,
            tickIntervalNanoseconds: 20_000_000
        )

        await viewModel.startRecording()
        try? await Task.sleep(nanoseconds: 70_000_000)

        XCTAssertEqual(viewModel.elapsedRecordingSeconds, 0)
        XCTAssertFalse(viewModel.isRecording)
    }
}

private final class AudioRecorderServiceMock: AudioRecording {
    private var url: URL?
    private let startError: Error?

    init(startError: Error? = nil) {
        self.startError = startError
    }

    func startRecording() async throws -> URL {
        if let startError {
            throw startError
        }
        let output = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("recording.m4a")
        url = output
        return output
    }

    func stopRecording() async throws -> URL {
        guard let url else {
            throw NSError(domain: "test", code: 1)
        }
        return url
    }
}

private final class SpeechTranscriptionServiceMock: SpeechTranscribing {
    let result: Result<String, Error>
    private(set) var transcribeCalledURLs: [URL] = []

    init(result: Result<String, Error>) {
        self.result = result
    }

    func transcribe(fileURL: URL) async throws -> String {
        transcribeCalledURLs.append(fileURL)
        return try result.get()
    }
}

private final class FileManagerMock: FileManaging {
    private(set) var deletedURLs: [URL] = []

    func removeItem(at url: URL) throws {
        deletedURLs.append(url)
    }
}
