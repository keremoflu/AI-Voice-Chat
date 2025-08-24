//
//  PromptBuilder.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct PromptBuilder {
    static func getPrompt(for message: String) -> String {
        let promptText =
        "Please answer this question: \(message) Analyze language and response as same language type. Make responses short."
        
        return promptText
    }
}
