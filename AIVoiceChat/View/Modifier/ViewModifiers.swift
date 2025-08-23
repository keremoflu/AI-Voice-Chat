//
//  ViewModifiers.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation
import SwiftUI

struct BounceOnAppear: ViewModifier {
    @State private var scale: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { scale = 1.08 }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9).delay(0.125)) { scale = 1.00 }

            }
    }
}
