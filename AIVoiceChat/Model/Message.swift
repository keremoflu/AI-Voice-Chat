//
//  Message.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import SwiftUI

enum ChatSender: String {
    case ai
    case user
}

struct Message: Identifiable, Hashable {
    let id: UUID
    var sender: ChatSender
    var text: String
}
