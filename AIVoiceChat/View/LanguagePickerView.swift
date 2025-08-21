//
//  LanguagePickerView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct LanguagePickerView: View {
    var body: some View {
        
        HStack {
            Text("🇬🇧 English")
                .font(.quickSand(size: 16, name: .medium))
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .light))
        }.modifier(LanguagePickerBackground())
    }
}

private struct LanguagePickerBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.white)
            ).overlay(
                Capsule()
                    .stroke(Color.grayPrimary, lineWidth: 1)
            )
        
    }
}


#Preview {
    LanguagePickerView()
}
