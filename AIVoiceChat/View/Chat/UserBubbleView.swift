//
//  UserBubbleView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct UserBubbleView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .modifier(UserBubbleStyleModifier())
            
    }
}

struct UserBubbleStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.quickSand(size: 16, name: .medium))
            .foregroundColor(.white)
            .padding()
            .background(
                SpecificRoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomLeft])
                    .foregroundColor(.primaryPurple)
            )
            .bounceOnAppear()
    }
}

#Preview {
    UserBubbleView(text: "What’s the weather in Istanbul right now?")
}

