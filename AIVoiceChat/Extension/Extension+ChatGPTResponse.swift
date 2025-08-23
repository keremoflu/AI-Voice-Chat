//
//  Extension+ChatGPTResponse.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation

extension ChatGPTResponse {
    var resultText: String? {
        return output.first?.content.first?.text
    }
}
