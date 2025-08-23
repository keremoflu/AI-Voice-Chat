//
//  PersistanceController.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import CoreData

final class PersistanceController {
    static let shared = PersistanceController()
    let container: NSPersistentContainer
    let containerName = "aichatapp"
    
    init() {
        container = NSPersistentContainer(name: "aichatdatabase")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("LOG: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistanceController {
    enum PersistanceError: Error, LocalizedError {
        case loadPersistanceFailed
        
        var errorDescription: String? {
            switch self {
            case .loadPersistanceFailed:
                return "Loading Persistance Controller is failed."
            }
        }
    }
}
