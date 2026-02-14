@testable import HomeCareVoiceLog
import Foundation
import XCTest

@MainActor
final class RecordViewModelTests: XCTestCase {
    func testStopRecordingTriggersTranscriptionAutomatically() async throws {
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

    func testSuccessfulTranscriptionDeletesAudioFile() async throws {
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

    func testFailureKeepsRecoverableErrorState() async throws {
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
}

private final class AudioRecorderServiceMock: AudioRecording {
    private var url: URL?

    func startRecording() async throws -> URL {
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
