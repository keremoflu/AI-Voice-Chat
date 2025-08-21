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
    
    private init () {}
    
    private func getPermissionState() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            guard let self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                permissonStatus = isGranted ? .granted : .denied
            }
        }
    }
}
