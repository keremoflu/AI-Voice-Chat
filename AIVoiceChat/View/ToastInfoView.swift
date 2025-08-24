//
//  ToastInfoView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct ToastInfoView: View {
    
    var toast: Toast
    
    var body: some View {
        
        HStack{
            Image(systemName: toast.systemImageName)
                .foregroundColor(.white)
            Text(toast.message)
                .font(.quickSand(size: 16, name: .bold))
                .foregroundColor(.white)
                .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.primaryRed)
            )
    }
}

#Preview {
    ToastInfoView(toast: Toast(message: "Test Message", systemImageName: "star.fill"))
}
