//
//  ChatMessage.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct ChatMessage: Codable {
    let output: [Output]
}

struct Output: Codable {
    let content: [Contents]
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
    }
}

struct Contents: Codable {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
    }
}

