//
//  PromptBuilder.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct PromptBuilder {
    static func getPrompt(for message: String) -> String {
        
        if let lastUserMessage = UserDefaultsManager.shared.lastMessage {
            print("prompt: \("Please answer this question: \(message) Analyze language and response as same language type. Make responses short. (Give answer based on this last message (if related) : -\(lastUserMessage)-)")")
             return "Please answer this question: \(message) Analyze language and response as same language type. Make responses short. Don't add special characters"
        } else {
            print("prompt else: \("Please answer this question: \(message) Analyze language and response as same language type. Make responses short.")")
            return "Please answer this question: \(message) Analyze language and response as same language type. Make responses short. Don't add special characters"
        }
        
    }
}
