//
//  AudioRecordManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation
import AVFoundation

final class AudioRecordManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var onCompleted: ((URL?) -> Void)?
    @Published var recordedFileURL: URL?
    
    let session = AVAudioSession.sharedInstance()
    
    static let shared = AudioRecordManager()
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey : 12000,
        AVNumberOfChannelsKey : 1,
        AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
    ]
    
    private func setupSession() {
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker]) //TODO: Set .record mode only in production
        try? session.setActive(true)
    }
    
    private func getTempFileURL() -> URL {
        let tempFileName = UUID().uuidString + ".m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(tempFileName)
    }
    
//    func startRecording(onCompleted: @escaping (URL?) -> Void) {
//        setupSession()
//        
//        let fileURL = getTempFileURL()
//        recordedFileURL = fileURL
//        
//        audioRecorder = try? AVAudioRecorder(url: fileURL, settings: settings)
//        audioRecorder?.record()
//        self.onCompleted = onCompleted
//    }
    
    func startRecording(onCompleted: @escaping (URL?) -> Void) {
        setupSession()
        
        let fileURL = getTempFileURL()
        recordedFileURL = fileURL
        self.onCompleted = onCompleted
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: self.settings)
                self.audioRecorder?.record()
            } catch {
                DispatchQueue.main.async {
                    self.onCompleted?(nil)
                }
            }
        }
    }

    
    //TODO: Check If audio is above 1 second
    func stopRecording() {
        guard let recorder = audioRecorder else {
            onCompleted?(nil)
            reset()
            return
        }
        
        recorder.stop()
        
        let fileURL = recordedFileURL
        onCompleted?(fileURL)
        reset()
    }
    
    private func reset() {
        audioRecorder = nil
        recordedFileURL = nil
        onCompleted = nil
        try? session.setActive(false)
    }
}

extension AudioRecordManager {
    enum AudioRecordError: Error, LocalizedError {
        case startRecordFailed
        case setupRecordingFailed
        
        var errorDescription: String? {
            switch self {
            case .setupRecordingFailed:
                return "Setup Recording is Failed!"
            case .startRecordFailed:
                return "Starting Record Audio is Failed!"
            }
        }
    }
}
