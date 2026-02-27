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
            String(localized: "error.speech.unavailable")
        case .onDeviceNotAvailable:
            String(localized: "error.speech.onDevice")
        case .recognitionFailed:
            String(localized: "error.speech.failed")
        case .permissionDenied:
            String(localized: "error.speech.permission")
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
            // Use a class-based wrapper to safely track whether the continuation has been resumed.
            // The recognitionTask callback may be called multiple times from arbitrary threads.
            final class ResumeGuard: @unchecked Sendable {
                private var resumed = false
                private let lock = NSLock()

                func resumeOnce(_ block: () -> Void) {
                    lock.lock()
                    defer { lock.unlock() }
                    guard !resumed else { return }
                    resumed = true
                    block()
                }
            }
            let resumeGuard = ResumeGuard()

            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    resumeGuard.resumeOnce { continuation.resume(throwing: error) }
                    return
                }

                guard let result else {
                    resumeGuard.resumeOnce { continuation.resume(throwing: SpeechTranscriptionError.recognitionFailed) }
                    return
                }

                if result.isFinal {
                    let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    resumeGuard.resumeOnce { continuation.resume(returning: text) }
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
