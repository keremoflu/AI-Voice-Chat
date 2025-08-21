//
//  LanguagePickerView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct LanguagePickerView: View {
    
    @Binding var picked: Country
    
    var body: some View {
        
        Menu {
            ForEach(CountryData.countries, id: \.self) { item in
                Button {
                    picked = item
                } label: {
                    Text("\(item.flag) \(item.name)")
                }
            }
        } label: {
            PickerButtonView(flagname: picked.flag, name: picked.name)
            .modifier(LanguagePickerBackground())
            
        }
    }
}

private struct PickerButtonView: View {
    
    var flagname: String
    var name: String
    
    var body: some View {
        HStack {
            Text("\(flagname) \(name)")
                .font(.quickSand(size: 16, name: .medium))
                
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .light))
        }.foregroundColor(.blackPrimary)
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
    LanguagePickerView(picked: .constant(Country(name: "English", flag: "🇬🇧", code: "en-US")))
}
