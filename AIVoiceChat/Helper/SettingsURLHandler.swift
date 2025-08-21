//
//  SettingsURLHandler.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import SwiftUI

final class SettingsURLHandler {
    private init() {}
    static let shared = SettingsURLHandler()
    
    typealias SettingsError = SettingsURLHandlerError
    
    func openAppSettings() throws {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            throw SettingsError.noValidURL
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            throw SettingsError.failedOpenURL
        }
        
        UIApplication.shared.open(url)
    }
}

extension SettingsURLHandler {
    enum SettingsURLHandlerError: Error, LocalizedError {
        case noValidURL
        case failedOpenURL
        
        var errorDescription: String? {
            switch self {
            case .noValidURL:
                return "Settins URL can not be opened right now!"
            case .failedOpenURL:
                return "Failed to open settings! As manual, Please go Settings -> App -> Permissions and enable Microphone permission."
            }
        }
    }
}
