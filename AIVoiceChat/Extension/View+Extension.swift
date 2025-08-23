//
//  View+Extension.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation
import SwiftUI

extension View {
    func bounceOnAppear() -> some View {
        return modifier(BounceOnAppear())
    }
}
