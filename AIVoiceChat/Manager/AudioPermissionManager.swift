//
//  AudioPermissionManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import AVFoundation

final class AudioPermissionManager: ObservableObject {
    
    @Published var permissonStatus: AVAudioSession.RecordPermission = .undetermined
    
    func startRequest(responseState: @escaping (Result<AVAudioSession.RecordPermission, AudioPermissionError>) -> Void) {
        switch permissonStatus {
        case .undetermined:
            requestRecordPermission { [weak self] isGranted in
                guard let self else {
                    responseState(.failure(.unknown))
                    return
                }
                permissonStatus = getPermissionStatus()
                responseState(isGranted ? .success(.granted) : .failure(.disabled))
            }
        case .denied:
            responseState(.failure(.unknown))
        case .granted:
            responseState(.success(.granted))
        @unknown default:
            responseState(.failure(.unknown))
        }
    }
    
    func getPermissionStatus () -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
    
    func requestRecordPermission(completionHandler: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.permissonStatus = isGranted ? .granted : .denied
                completionHandler(isGranted)
            }
        }
    }
}

extension AudioPermissionManager {
    enum AudioPermissionError: Error, LocalizedError {
        case disabled
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .disabled:
                return "Microphone Usage Permission is denied. If it's a mistake, please go settings and enable it."
            case .unknown:
                return "Unknown Permission State, please try again later."
            }
        }
    }
}
