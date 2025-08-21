//
//  AIBubbleView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct AIBubbleView: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.3)
            Text("Right now in Istanbul, Turkey, the weather is sunny and around 28°C (83°F)")
                .modifier(AIBubbleStyleModifier())
        }
        .frame(width: 400, height: 400)
        
           
    }
}

private struct AIBubbleStyleModifier: ViewModifier {
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
    }
}

#Preview {
    AIBubbleView()
}
