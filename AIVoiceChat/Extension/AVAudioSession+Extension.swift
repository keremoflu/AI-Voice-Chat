//
//  AVAudioSession+Extension.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import AVFoundation

extension AVAudioSession.RecordPermission {
    func getStateMessage() -> String {
        switch self {
        case .undetermined:
            return "Undetermined"
        case .denied:
            return "Denied"
        case .granted:
            return "Granted"
        @unknown default:
            return "Unknown"
        }
    }
}
