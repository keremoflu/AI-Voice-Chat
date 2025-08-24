//
//  AboutSheet.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import SwiftUI

struct AboutSheet: View {
    //model missing todo
    var body: some View {
        VStack (spacing: 32) {
            Image("info.circle.fill")
                .font(.system(size: 32))
            
            Text("About")
                .font(.quickSand(size: 24, name: .medium))
            
            Text("AI Voice Chat App created by Kerem Oflu")
                .font(.quickSand(size: 16, name: .regular))
        }
    }
}

#Preview {
    AboutSheet()
}
