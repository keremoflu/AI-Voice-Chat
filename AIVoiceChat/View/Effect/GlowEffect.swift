//
//  GlowEffect.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import SwiftUI

struct GlowEffect: View {
    
    private var isAnimating: Bool = true
    @State private var isGrowing = false
    
    @State private var lineWidth: CGFloat = 16.0
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            // Glow overlay
            RoundedRectangle(cornerRadius: 40)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .primaryRed.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: isGrowing ? 16 : 8
                )
                .blur(radius: 10)
                .opacity(0.8)
        }
        .ignoresSafeArea()

        .animation(
            Animation.easeInOut(duration: 0.5)
                   .repeatForever(autoreverses: true),
                   value: isGrowing
        )
        .onChange(of: isAnimating) { newValue in
            isGrowing = isAnimating
        }
        .onAppear {
            isGrowing = true
        }
        
    }
}


#Preview {
    GlowEffect()
}
