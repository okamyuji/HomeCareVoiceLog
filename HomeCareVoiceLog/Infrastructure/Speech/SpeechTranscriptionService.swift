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
            return String(localized: "error.speech.unavailable")
        case .onDeviceNotAvailable:
            return String(localized: "error.speech.onDevice")
        case .recognitionFailed:
            return String(localized: "error.speech.failed")
        case .permissionDenied:
            return String(localized: "error.speech.permission")
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

        if !recognizer.supportsOnDeviceRecognition {
            throw SpeechTranscriptionError.onDeviceNotAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            var finished = false
            recognizer.recognitionTask(with: request) { result, error in
                if finished {
                    return
                }
                if let error {
                    finished = true
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    finished = true
                    continuation.resume(throwing: SpeechTranscriptionError.recognitionFailed)
                    return
                }

                if result.isFinal {
                    finished = true
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
