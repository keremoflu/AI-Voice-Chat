//
//  ChatViewModel.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
//    @Published var messages: [Message] = []
    @Published var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @Published var audioPermissionManager: AudioPermissionManager
    @Published var speechRecognitionManager: SpeechRecognitionManager
    @Published var contentState: ContentViewState = .readyToRecord
    
    let messageCoordinator: MessageCoordinator
    private let networkManager: NetworkManager
    private let context = PersistanceController.shared.container.viewContext
    private let speechPermissionmanager: SpeechPermissionManager
    let alertManager: AlertManager
    
    init(
        networkManager: NetworkManager,
        alertManager: AlertManager = AlertManager(),
        audioPermissionManager: AudioPermissionManager? = nil,
        speechPermissionManager: SpeechPermissionManager? = nil,
        speechRecognitionManager: SpeechRecognitionManager = SpeechRecognitionManager(),
        messageCoordinator: MessageCoordinator = MessageCoordinator()
    ) {
        self.networkManager = networkManager
        self.alertManager = alertManager
        self.audioPermissionManager = audioPermissionManager ?? AudioPermissionManager(alertManager: alertManager)
        self.speechPermissionmanager = speechPermissionManager ?? SpeechPermissionManager(alertManager: alertManager)
        self.speechRecognitionManager = speechRecognitionManager
        self.messageCoordinator = messageCoordinator
        
    }
    
    func sendChatGPTRequest(prompt: String) async throws {
        
        do {
            await MainActor.run {
                messageCoordinator.setBubbleStatusActive(true)
            }
            let resultMessage = try await ChatGPTManager.shared.requestChatMessage(prompt)
            guard let resultText = resultMessage.resultText else {
                print("sendChatGPTRequest Nil Text")
                return
            }
            
            print("saved last message: \(resultText)")
            UserDefaultsManager.shared.lastMessage = resultText
            
            await MainActor.run {
                messageCoordinator.setBubbleStatusActive(false)
                messageCoordinator.addMessage(Message(id: UUID(), sender: .ai, text: resultText))
            }
        } catch {
            messageCoordinator.setBubbleStatusActive(false)
            alertManager.showAlertContent(type: .requestFailed)
        }
       
    }
    
    func sendPromptRequest(prompt: Prompt) {
        
        guard contentState == .readyToRecord else {
            alertManager.showAlertContent(type: .inProgress)
            return
        }
        
        Task {
            do {
                try await sendChatRequest(text: prompt.text)
                
            } catch (let error) {
                alertManager.showAlertContent(type: .promptRequestFailed(error))
            }
        }
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
            alertManager.showAlertContent(type: .audioPermission)
            return
        }

        if speechStatus == .denied || speechStatus == .restricted {
            alertManager.showAlertContent(type: .speechPermission)
            return
        }

        if audioStatus == .undetermined {
            audioPermissionManager.startRequest { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.requestSpeechRecognitionPermission()
                        
                    case .failure:
                        self?.alertManager.showAlertContent(type: .audioPermission)
                        return
                    }
                }
            }
        } else if speechStatus == .notDetermined {
            requestSpeechRecognitionPermission()
        }
    }
    private func requestSpeechRecognitionPermission() {
        speechPermissionmanager.startRequest { [weak self] result in
            switch result {
            case .success:
                print("requestSpeechRecognitionPermission, speechpermission success.")
            case .failure(let err):
                if case .restricted = err {
                    self?.alertManager.showAlertContent(type: .speechPermission)
                }
                
            }
        }
    }
    
    func sendChatRequest(text: String) async throws {
        //TODO: Add error
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            await MainActor.run {
                contentState = .readyToRecord }
            return
        }
        
        await MainActor.run {
            contentState = .loadingAfterRecord
            messageCoordinator.addMessage(Message(id: UUID(), sender: .user, text: trimmed))
        }
        messageCoordinator.setBubbleStatusActive(true)
        
        do {
            let resultMessage = try await ChatGPTManager.shared.requestChatMessage(trimmed)
            let resultText = resultMessage.resultText ?? "…"
            messageCoordinator.setBubbleStatusActive(false)
            
            await MainActor.run { messageCoordinator.addMessage(Message(id: UUID(), sender: .ai, text: resultText)) }
        } catch {
            messageCoordinator.setBubbleStatusActive(false)
            await MainActor.run { contentState = .readyToRecord }
            throw ChatGPTManager.ChatGPTError.requestFailed
        }
        
        await MainActor.run {
            contentState = .readyToRecord
        }
    }

    func recordingButtonTapped() {
        
        guard isPermissionsValid() else {
            requestAllPermissions()
            return
        }
        
        guard networkManager.isConnectionActive else {
            alertManager.showAlertContent(type: .networkConnection)
            return
        }
        
        switch contentState {
        case .readyToRecord:
          startRecordingProcess()
            
        case .recording:
            loadAfterRecording()
            
        case .loadingAfterRecord: //just waiting.
            alertManager.showAlertContent(type: .inProgress)
        }
    }
    
    func startRecordingProcess() {
        do {
            contentState = .recording
            try speechRecognitionManager.startSpeechRecognition()
        } catch (let error){
            contentState = .readyToRecord
            alertManager.showAlertContent(type: .recordingFailed(error))
        }
    }

    func loadAfterRecording() {
        contentState = .loadingAfterRecord
        speechRecognitionManager.stopSpeechRecognition { [weak self] transcript in
            guard let self else { return }
            
            Task {
                if transcript.isEmpty {
                    await MainActor.run {
                        self.alertManager.showAlertContent(type: .emptyField)
                        self.contentState = .readyToRecord
                    }
                    return
                }
                
                do {
                    try await self.sendChatRequest(text: transcript)
                } catch {
                    await MainActor.run {
                        self.alertManager.showAlertContent(type: .transcriptionFailed(error))
                        self.contentState = .readyToRecord
                    }
                }
            }
        }
    }

    
//    func recordingButtonTapped() {
//        guard isPermissionsValid() else {
//            requestAllPermissions()
//            return
//        }
//        
//        switch contentState {
//        case .readyToRecord:
//            do {
//                contentState = .recording
//                try speechRecognitionManager.startSpeechRecognition()
//            } catch {
//                contentState = .readyToRecord
//            }
//            
//        case .recording:
//            contentState = .loadingAfterRecord
//            speechRecognitionManager.stopSpeechRecognition { [weak self] transcript in
//                guard let self else { return }
//                Task { try await self.send(text: transcript) }
//            }
//            
//        case .loadingAfterRecord:
//            break
//        }
//    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
