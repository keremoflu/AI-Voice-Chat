//
//  CoreDataManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    func saveMessage(_ message: Message, context: NSManagedObjectContext) {
        let object = AIChatEntity(context: context)
        object.id = message.id
        object.sender = message.sender.rawValue
        object.text = message.text
        object.createdAt = Date()
        
        print("CoreData: saveMessage: object: \(message)")
        
        do {
            try context.save()
        } catch {
            print("saveMessage error occured.")
        }
    }
    
    func fetchMessages(_ context: NSManagedObjectContext) -> [Message] {
        let request: NSFetchRequest<AIChatEntity> = AIChatEntity.fetchRequest()
        request.sortDescriptors = [.init(key: "createdAt", ascending: true)]
        
        guard let results = try? context.fetch(request) else {
            return []
        }
        
        let finalResult = results.map {
            Message(
                id: $0.id ?? UUID(),
                sender: ChatSender(rawValue: $0.sender ?? "") ?? .user,
                text: $0.text ?? ""
            )
        }
        
        print("CoreData: fetchMessages: results: \(finalResult)")
        
        return finalResult
    }
    
    func deleteMessage(_ entity: AIChatEntity, context: NSManagedObjectContext) {
        context.delete(entity)
        do {
            try context.save()
        } catch {
            print("CoreDataManager - deleteMessage Error")
        }
    }
}
