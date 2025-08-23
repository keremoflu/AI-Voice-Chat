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
    @Published var audioPermissionManager: AudioPermissionManager
    @Published var speechRecognitionManager: SpeechRecognitionManager
    @Published var contentState: ContentViewState = .readyToRecord
    
    private let context = PersistanceController.shared.container.viewContext
    private let speechPermissionmanager: SpeechPermissionManager
    let alertManager: AlertManager

    init(
        alertManager: AlertManager = AlertManager(),
        audioPermissionManager: AudioPermissionManager? = nil,
        speechPermissionManager: SpeechPermissionManager? = nil,
        speechRecognitionManager: SpeechRecognitionManager = SpeechRecognitionManager()
    ) {
        self.alertManager = alertManager
        self.audioPermissionManager = audioPermissionManager ?? AudioPermissionManager(alertManager: alertManager)
        self.speechPermissionmanager = speechPermissionManager ?? SpeechPermissionManager(alertManager: alertManager)
        self.speechRecognitionManager = speechRecognitionManager
        
        loadCoreDataMessages()
    }
    
    func loadCoreDataMessages() {
        messages = CoreDataManager.shared.fetchMessages(context)
        if messages.count == 0 { setFirstLoading() }
    }
    
    func recordingButtonTapped() {
        
        guard isPermissionsValid() else {
            requestAllPermissions()
            return
        }
        
        switch contentState {
        case .readyToRecord:
            do {
                print("record started")
                contentState = .recording
                try speechRecognitionManager.startSpeechRecognition()
            } catch {
                print("speech error")
                contentState = .readyToRecord
            }
            
            
        case .recording:
            contentState = .loadingAfterRecord
            speechRecognitionManager.stopSpeechRecognition { [weak self] transcript in
                guard let self else { return }
                print("TRANSKRIPT: \(transcript)")
                addMessage(Message(id: UUID(), sender: .user, text: transcript))
                
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
                addMessage(Message(id: UUID(), sender: .ai, text: resultText))
            }
        } catch {
            //TODO: Fill Error
            print("sendChatGPTRequest Error")
            setBubbleStatusActive(false)
        }
       

    }
    
    func setBubbleStatusActive(_ bool: Bool) {
        if bool {
            messages.append(Message(id: UUID(), sender: .ai, text: "..."))
        } else {
            if messages.last?.text == "..." {
                messages.removeLast()
            }
        }
    }
    
    private func addMessage(_ message: Message) {
        messages.append(message)
        CoreDataManager.shared.saveMessage(message, context: context)
    }
    
    func setFirstLoading() {
        addMessage(
            Message(id: UUID(), sender: .ai, text: "Hello, how can I help you?")
        )
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
                DispatchQueue.main.async {
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
            }
        } else if speechStatus == .notDetermined {
            requestSpeechRecognitionPermission()
        }
    }
    
       
       private func showPermissionAlert(type: String, message: String) {
           print("🔔 Showing alert for \(type)")
           alertManager.showAlert(for: .goToSettings(
               title: "\(type) Permission Required",
               message: message,
               primaryButtonText: "Go To Settings",
               onAction: { [weak self] in
                   print("🔧 Opening settings...")
                   self?.openSettings()
               }
           ))
       }
    
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
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
