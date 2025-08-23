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
    
    
    //TODO: Check if published needed
    @Published var audioPermissionManager: AudioPermissionManager
    @Published var speechPermissionmanager: SpeechPermissionManager
    @Published var alertManager: AlertManager
    
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
            }
            
            
        case .recording: //RECORDING - wait transcript
            contentState = .loadingAfterRecord
            speechRecognitionManager.stopSpeechRecognition { [weak self] transcript in
                guard let self else { return }
                print("TRANSKRIPT: \(transcript)")
                addMessage(Message(sender: .user, text: transcript))
                
                //TODO: If message is empty - cancel process
                
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
            print("loadingAfterRecord case")
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
        print("isPermissionsValid: \(audioStatus == .granted && speechStatus == .authorized)")
        return audioStatus == .granted && speechStatus == .authorized
    }
    
    
    func requestAllPermissions() {

        let audioStatus = audioPermissionManager.getPermissionStatus()
        let speechStatus = speechPermissionmanager.permissionStatus
        
        if audioStatus == .denied {
            alertManager.showAlert(for: .goToSettings(title: "Audio Permission Required", message: "permission required", primaryButtonText: "Go To Settings", onAction: { [weak self] in
                self?.openSettings()
            }))
            return
        }

        if speechStatus == .denied || speechStatus == .restricted {
            alertManager.showAlert(for: .goToSettings(title: "Speech Permission Required", message: "permission required", primaryButtonText: "Go To Settings", onAction: { [weak self] in
                self?.openSettings()
            }))
            return
        }

        if audioStatus == .undetermined {
            audioPermissionManager.startRequest { [weak self] result in
                switch result {
                case .success:
                    self?.requestSpeechRecognitionPermission()
                case .failure:
                    self?.alertManager.showAlert(for: .goToSettings(title: "Audio Permission Required", message: "permission required", primaryButtonText: "Go To Settings", onAction: { [weak self] in
                        self?.openSettings()
                    }))
                    return
                }
            }
        } else if speechStatus == .notDetermined {
            requestSpeechRecognitionPermission()
        }
    }
    
    func requestAllPermissions(isAllGranted: @escaping (Bool) -> Void) {

        let audioStatus = audioPermissionManager.getPermissionStatus()
        let speechStatus = speechPermissionmanager.permissionStatus
        
        if audioStatus == .denied {
           isAllGranted(false)
            return
        }

        if speechStatus == .denied || speechStatus == .restricted {
            isAllGranted(false)
            return
        }

        if audioStatus == .undetermined {
            audioPermissionManager.startRequest { [weak self] result in
                switch result {
                case .success:
                    self?.requestSpeechRecognitionPermission()
                case .failure:
                    isAllGranted(false)
                    return
                }
            }
        } else if speechStatus == .notDetermined {
            requestSpeechRecognitionPermission()
        }
    }

    // Konuşma tanıma izni isteme işlevini ayrı bir fonksiyonda tut
    private func requestSpeechRecognitionPermission() {
        speechPermissionmanager.startRequest { [weak self] result in
            switch result {
            case .success:
                print("Speech recognition permission granted.")
            case .failure:
                self?.alertManager.showAlert(for: .goToSettings(title: "Audio Permission Required", message: "permission required", primaryButtonText: "Go To Settings", onAction: { [weak self] in
                    self?.openSettings()
                }))
            }
        }
    }
    
    func requestPermissions() {
        audioPermissionManager.startRequest { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                print("permission success")
            case .failure(_):
                print("")
                //TODO: Error Here
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
