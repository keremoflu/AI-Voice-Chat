//
//  Toast.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation

struct Toast: Equatable {
    var id = UUID()
    var message: String
    var systemImageName: String
}
