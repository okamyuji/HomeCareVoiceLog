import AVFoundation
import Foundation

@MainActor
protocol AudioRecording {
    func startRecording() async throws -> URL
    func stopRecording() async throws -> URL
}

enum AudioRecorderError: LocalizedError {
    case missingRecorder
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .missingRecorder:
            return String(localized: "error.audio.missingRecorder")
        case .permissionDenied:
            return String(localized: "error.audio.permission")
        }
    }
}

final class AudioRecorderService: NSObject, AudioRecording {
    private var recorder: AVAudioRecorder?
    private var outputURL: URL?

    func startRecording() async throws -> URL {
        let session = AVAudioSession.sharedInstance()
        let granted = await requestRecordPermission()
        guard granted else {
            throw AudioRecorderError.permissionDenied
        }

        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let directory = FileManager.default.temporaryDirectory
        let url = directory.appendingPathComponent("homecare-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.record()
        self.recorder = recorder
        outputURL = url
        return url
    }

    func stopRecording() async throws -> URL {
        guard let recorder, let outputURL else {
            throw AudioRecorderError.missingRecorder
        }
        recorder.stop()
        self.recorder = nil
        self.outputURL = nil
        return outputURL
    }

    private func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
