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
        
        let languageCode = UserDefaultsManager.shared.speechCountry.code
        print("languageCode: \(languageCode)")
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))
        
        guard let recognitionRequest else { return }
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.speechTranscript = result.bestTranscription.formattedString
                }
            }
        }
       
        let format = audioNote.outputFormat(forBus: 0)
        audioNote.installTap(onBus: 0, bufferSize: 1024, format: format) { audioBuffer, _ in
            recognitionRequest.append(audioBuffer)
        }
        
        avAudioEngine.prepare()
        try avAudioEngine.start()
    }
    
    func stopSpeechRecognition(completion: @escaping (String) -> Void) {
        avAudioEngine.stop()
        avAudioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            recognitionTask?.cancel()
            recognitionRequest = nil
            recognitionTask = nil
            
            let finalTranscription = speechTranscript
            speechTranscript = ""
            completion(finalTranscription)
        }
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
