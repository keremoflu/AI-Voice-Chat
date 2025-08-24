//
//  NetworkData.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct NetworkData {
    static var chatgptApiKey: String {
        ProcessInfo.processInfo.environment["chatGPT_api_key"] ?? ""
    }
}
