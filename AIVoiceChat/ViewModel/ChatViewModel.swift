//
//  ChatViewModel.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @Published var alertManager: AlertManager
    
    @Published var audioPermissionManager: AudioPermissionManager
    @Published var speechPermissionmanager: SpeechPermissionManager
    
    init() {
        let alertManager = AlertManager()
        self.alertManager = alertManager
        self.audioPermissionManager = AudioPermissionManager(alertManager: alertManager)
        self.speechPermissionmanager = SpeechPermissionManager(alertManager: alertManager)
    }
    
    func simulateChat() {
        messages.append(Message(sender: .ai, text: "I am AI"))
        messages.append(Message(sender: .user, text: "Hello, I am User"))
    }
    
    func isPermissionsValid() -> Bool {
        let audioStatus = audioPermissionManager.getPermissionStatus()
        let speechStatus = speechPermissionmanager.permissionStatus
        print("PERMISSION STATUS: audio: \(audioStatus.rawValue) speech: \(speechStatus.rawValue)")
        
        return audioStatus == .granted && speechStatus == .authorized
    }
    
    func requestPermissions() {
        audioPermissionManager.startRequest { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                print("permission success")
            case .failure(let failure):
                print("failure: \(failure.localizedDescription)")
                alertManager.showAlert(for: .goToSettings(title: "go", message: "settings", onAction: { [weak self] in
                    guard let self else { return }
                    openSettings()
                }))
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
