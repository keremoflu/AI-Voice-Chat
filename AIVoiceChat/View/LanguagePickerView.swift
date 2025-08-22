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
            
            VStack {
                Text("Set Speech Language")
                    .font(.quickSand(size: 12, name: .regular))
                ForEach(CountryData.countries, id: \.self) { item in
                    Button {
                        picked = item
                    } label: {
                        Text("\(item.flag) \(item.name)")
                    }
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
                .font(.quickSand(size: 14, name: .medium))
                
            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .light))
        }.foregroundColor(.blackPrimary)
    }
}

private struct LanguagePickerBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
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
