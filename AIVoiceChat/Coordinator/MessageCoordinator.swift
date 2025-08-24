//
//  MessageCoordinator.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation

class MessageCoordinator: ObservableObject {
    @Published var messages: [Message] = []
    private let thinkMessage = Message(id: UUID(), sender: .ai, text: "...")
    private let context = PersistanceController.shared.container.viewContext
    
    init() {
        loadCoreDataMessages()
    }
    
    func loadCoreDataMessages() {
        messages = CoreDataManager.shared.fetchMessages(context)
        if messages.isEmpty { setFirstLoading() }
    }
    
    func setFirstLoading() {
        addMessage(
            Message(id: UUID(), sender: .ai, text: "Hello, how can I help you?")
        )
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
        CoreDataManager.shared.saveMessage(message, context: context)
    }
    
    func setBubbleStatusActive(_ isActive: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            isActive ? messages.append(thinkMessage) : messages.removeAll { $0 == self.thinkMessage }
        }
    }
    
}
