//
//  ChatGPTData.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct ChatGPTData {
    enum Models {
        case gpt4o
        case gpt4omini
        case gpt4turbo
        
        var name: String {
            switch self {
            case .gpt4o:
                return "gpt-4o"
            case .gpt4omini:
                return "gpt-4o-mini"
            case .gpt4turbo:
                return "gpt-4-turbo"
            }
        }
    }
}
