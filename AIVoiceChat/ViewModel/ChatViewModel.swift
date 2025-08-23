//
//  ChatViewModel.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @Published var alertManager: AlertManager
    
    //TODO: Check if published needed
    @Published var audioPermissionManager: AudioPermissionManager
    @Published var speechPermissionmanager: SpeechPermissionManager
    
    @Published var speechRecognitionManager: SpeechRecognitionManager
    @Published var contentState: ContentViewState = .readyToRecord
    
    var contentStatePublisher: AnyPublisher<ContentViewState, Never> {
        $contentState.eraseToAnyPublisher()
    }
    
    init() {
        let alertManager = AlertManager()
        self.alertManager = alertManager
        self.audioPermissionManager = AudioPermissionManager(alertManager: alertManager)
        self.speechPermissionmanager = SpeechPermissionManager(alertManager: alertManager)
        self.speechRecognitionManager = SpeechRecognitionManager()
    }
    
    func recordingButtonTapped() {
        
        guard isPermissionsValid() else {
            requestAllPermissions()
            return
        }
        
        switch contentState {
        case .readyToRecord: //START RECORD
            do {
                print("record started")
                contentState = .recording
                try speechRecognitionManager.startSpeechRecognition()
            } catch {
                print("speech error")
                contentState = .readyToRecord
                alertManager.showAlert(for: .infoMessage(title: "Recording Error", message: "unknown error occured", primaryButtonText: "OK", onAction: {}))
            }
            
            
        case .recording: //RECORDING - wait transcript
            contentState = .loadingAfterRecord
            speechRecognitionManager.stopSpeechRecognition { [weak self] transcript in
                guard let self else { return }
                print("TRANSKRIPT: \(transcript)")
                addMessage(Message(sender: .user, text: transcript))
                
                //Forward to ChatGPT
                Task { [weak self] in
                    guard let self else { return }
                    try await sendChatGPTRequest(prompt: transcript)
                    await MainActor.run {
                        self.contentState = .readyToRecord
                    }
                }
            }
        case .loadingAfterRecord:
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                alertManager.showAlert(for: .infoMessage(title: "Please", message: "please wait for loading...", primaryButtonText: "OK", onAction: {}))
//            }
            print("")
        }
    }
    
    func sendChatGPTRequest(prompt: String) async throws {
        
        do {
            await MainActor.run {
                setBubbleStatusActive(true)
            }
            let resultMessage = try await ChatGPTManager.shared.requestChatMessage(prompt)
            guard let resultText = resultMessage.resultText else {
                print("sendChatGPTRequest Nil Text")
                return
            }
            await MainActor.run {
                setBubbleStatusActive(false)
                addMessage(Message(sender: .ai, text: resultText))
            }
        } catch {
            //TODO: Fill Error
            print("sendChatGPTRequest Error")
            setBubbleStatusActive(false)
        }
       

    }
    
    func setBubbleStatusActive(_ bool: Bool) {
        if bool {
            messages.append(Message(sender: .ai, text: "...")) //TODO: Find other solution here
        } else {
            if messages.last?.text == "..." {
                messages.removeLast()
            }
        }
    }
    
    private func addMessage(_ message: Message) {
        messages.append(message)
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
    
    
    func requestAllPermissions() {
        //TODO: Must Check. After disabling it doesnt open "go to settings"
        if audioPermissionManager.getPermissionStatus() != .granted {
            audioPermissionManager.startRequest { status in
                print("requestAllPermissions (Audio Status): \(status)")
            }
        } else if speechPermissionmanager.permissionStatus != .authorized {
            speechPermissionmanager.requestSpeechPermission { status in
                print("requestAllPermissions (Speech Status): \(status)")
            }
        } else {
            //all good
        }
    }
    
    func requestPermissions() {
        audioPermissionManager.startRequest { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                print("permission success")
            case .failure(_):
                alertManager.showAlert(for: .infoMessage(title: "Permission denied", message: "Permission is required. Please re-enable to use it", primaryButtonText: "OK", onAction: {
                    
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
