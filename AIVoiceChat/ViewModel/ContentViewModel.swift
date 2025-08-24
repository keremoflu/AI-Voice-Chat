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
    
    func sendPromptRequest(prompt: Prompt) {
        
        guard contentState == .readyToRecord else {
            alertManager.showAlertContent(type: .inProgress)
            return
        }
        
        Task {
            do {
                try await send(text: prompt.text)
                
            } catch (let error) {
                alertManager.showAlertContent(type: .promptRequestFailed(error))
            }
        }
    }
    
    func setBubbleStatusActive(_ bool: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if bool {
                messages.append(Message(id: UUID(), sender: .ai, text: "..."))
            } else {
                if messages.last?.text == "..." {
                    messages.removeLast()
                }
            }
        }
    }
    
    private func addMessage(_ message: Message) {
        messages.append(message)
        CoreDataManager.shared.saveMessage(message, context: context)
        UserDefaultsManager.shared.lastMessage = message.text
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
    
//    private func requestSpeechRecognitionPermission() {
//        speechPermissionmanager.startRequest { [weak self] result in
//            switch result {
//            case .success:
//                print("Speech recognition permission granted.")
//            case .failure:
//                self?.alertManager.showAlert(for: .goToSettings(title: "Audio Permission Required", message: "permission required", primaryButtonText: "Go To Settings", onAction: { [weak self] in
//                    self?.openSettings()
//                }))
//            }
//        }
//    }
    
//    func requestPermissions() {
//        audioPermissionManager.startRequest { [weak self] result in
//            guard let self else { return }
//            
//            switch result {
//            case .success:
//                print("permission success")
//            case .failure(_):
//                print("")
//                //TODO: Error Here
//            }
//        }
//    }
    
    func send(text: String) async throws {
        //TODO: Add error
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            await MainActor.run {
                contentState = .readyToRecord }
            return
        }
        
        await MainActor.run {
            contentState = .loadingAfterRecord
            addMessage(Message(id: UUID(), sender: .user, text: trimmed))
        }
        setBubbleStatusActive(true)
        
        do {
            let resultMessage = try await ChatGPTManager.shared.requestChatMessage(trimmed)
            let resultText = resultMessage.resultText ?? "…"
            setBubbleStatusActive(false)
            await MainActor.run {
                addMessage(Message(id: UUID(), sender: .ai, text: resultText))
            }
        } catch {
            setBubbleStatusActive(false)
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
        
        switch contentState {
        case .readyToRecord:
            do {
                contentState = .recording
                try speechRecognitionManager.startSpeechRecognition()
            } catch (let error){
                contentState = .readyToRecord
                alertManager.showAlertContent(type: .recordingFailed(error))
            }
            
        case .recording:
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
                        try await self.send(text: transcript)
                    } catch {
                        await MainActor.run {
                            self.alertManager.showAlertContent(type: .transcriptionFailed(error))
                            self.contentState = .readyToRecord
                        }
                    }
                }
            }
            
        case .loadingAfterRecord:
            alertManager.showAlertContent(type: .inProgress)
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
