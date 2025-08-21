//
//  PromptData.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation

struct PromptData {
    static let prompts: [Prompt] = [
        Prompt(image: .food, text: "Hamburger places in Kadıköy, Istanbul."),
        Prompt(image: .music, text: "What do I need to learn playing harmonica?."),
        Prompt(image: .earth, text: "How to prepare for a trip to Japan on a budget?"),
        Prompt(image: .language, text: "How can I learn German while working full-time?")
    ]
}
