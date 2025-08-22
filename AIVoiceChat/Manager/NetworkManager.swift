//
//  NetworkManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation
import Network

final class NetworkManager: ObservableObject {
    private let networkMonitor: NWPathMonitor
    private let queue: DispatchQueue
    
    @Published var isConnectionActive = false
    
    init() {
        self.networkMonitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "networkQueue")
        
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnectionActive = path.status == .satisfied || path.isExpensive == true
                
                print("path Status: \(path.status == .satisfied)")
                print("path isExpensive: \(path.isExpensive)")
            }
        }
        networkMonitor.start(queue: queue)
    }
}
