//
//  GlowEffect.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import SwiftUI

struct GlowEffect: View {
    
    @State private var isAnimating: Bool = true
    @State private var lineWidth: CGFloat = 16.0
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 40)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .primaryRed.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: isAnimating ? 16 : 8
                )
                .blur(radius: 10)
                .opacity(0.8)
        }
        .ignoresSafeArea()

        .animation(
            Animation.easeInOut(duration: 0.5)
                   .repeatForever(autoreverses: true),
                   value: isAnimating
        )
        .onChange(of: isAnimating) { newValue in
             
        }
        .onAppear {
            isAnimating.toggle()
        }
    }
}

#Preview {
    GlowEffect()
}
