//
//  UserDefaultsManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation

final class UserDefaultsManager {
    private init() {}
    static let shared = UserDefaultsManager()
    
    enum UserDefaultKeys: String {
        case speechCountryKey = "speechCountry"
    }
    
    var speechCountry: Country {
        get {
            
            if let countryData = UserDefaults.standard.data(forKey: UserDefaultKeys.speechCountryKey.rawValue),
               let country = try? JSONDecoder().decode(Country.self, from: countryData) {
                return country
            }
            return Country(name: "English", flag: "🇬🇧", code: "en-GB")
        }
        
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: UserDefaultKeys.speechCountryKey.rawValue)
            }
        }
    }
}

