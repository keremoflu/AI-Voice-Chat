//
//  AIBubbleView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct AIBubbleView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .modifier(AIBubbleStyleModifier())
       
    }
}

struct AIBubbleStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .font(.quickSand(size: 16, name: .medium))
        .foregroundColor(.textPrimary)
        .padding()
        .background(
            SpecificRoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomRight])
                .foregroundColor(.white)
        )
        .compositingGroup()
        .shadow(color: .grayPrimary, radius: 4)
        .bounceOnAppear()
    }
}

#Preview {
    AIBubbleView(text: "preview text")
}
