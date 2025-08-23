//
//  SpeechRecognitionManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import Speech
import AVFoundation

protocol SpeechRecognizer {
    func startSpeechRecognition() throws
    func stopSpeechRecognition(completion: @escaping (String) -> Void)
}

final class SpeechRecognitionManager: ObservableObject, SpeechRecognizer {
    
    private var recognitionTask: SFSpeechRecognitionTask?
    private let avAudioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    @Published var speechTranscript = ""
    
    func startSpeechRecognition() throws {
       recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
       let audioNote = avAudioEngine.inputNode
       
        //TODO: Enable if we need live transcription
//        recognitionRequest?.shouldReportPartialResults = true
        
        //TODO: Fetch from User Default
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest!) { result, error in //TODO: Remove Force Unwrap
            if let result = result {
                DispatchQueue.main.async {
                    self.speechTranscript = result.bestTranscription.formattedString
                }
            }
        }
       
        let format = audioNote.outputFormat(forBus: 0)
        audioNote.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] audioBuffer, _ in
            guard let self else { return }
            recognitionRequest?.append(audioBuffer)
        }
        
        avAudioEngine.prepare()
        try avAudioEngine.start()
    }
    
    func stopSpeechRecognition(completion: @escaping (String) -> Void) {
        avAudioEngine.stop()
        avAudioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        completion(speechTranscript)
    }
}

extension SpeechRecognitionManager {
    enum SpeechRecognitionError: Error, LocalizedError {
        case startFailed
        case speechRequestFailed
        case speechResultFailed(String?)
        
        var errorDescription: String? {
            switch self {
            case .speechRequestFailed:
                return "Speech Recognition Request is failed."
            case .startFailed:
                return "Starting Speech Recognition is failed."
            case .speechResultFailed (let message):
                return "Resulting Speech Recognition is failed. \(message ?? "")"
            }
        }
    }
}
