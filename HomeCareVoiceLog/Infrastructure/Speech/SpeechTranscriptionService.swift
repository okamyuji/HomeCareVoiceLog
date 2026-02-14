import Foundation
import Speech

@MainActor
protocol SpeechTranscribing {
    func transcribe(fileURL: URL) async throws -> String
}

enum SpeechTranscriptionError: LocalizedError {
    case recognizerUnavailable
    case onDeviceNotAvailable
    case recognitionFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is unavailable."
        case .onDeviceNotAvailable:
            return "On-device speech recognition is not available on this device."
        case .recognitionFailed:
            return "Speech recognition failed."
        case .permissionDenied:
            return "Speech recognition permission denied."
        }
    }
}

final class SpeechTranscriptionService: SpeechTranscribing {
    func transcribe(fileURL: URL) async throws -> String {
        let authStatus = await SFSpeechRecognizer.requestAuthorization()
        guard authStatus == .authorized else {
            throw SpeechTranscriptionError.permissionDenied
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale.current), recognizer.isAvailable else {
            throw SpeechTranscriptionError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        request.requiresOnDeviceRecognition = true
        guard request.requiresOnDeviceRecognition else {
            throw SpeechTranscriptionError.onDeviceNotAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    continuation.resume(throwing: SpeechTranscriptionError.recognitionFailed)
                    return
                }

                if result.isFinal {
                    let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    continuation.resume(returning: text)
                }
            }
        }
    }
}

private extension SFSpeechRecognizer {
    static func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}
