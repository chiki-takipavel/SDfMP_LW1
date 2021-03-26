//
//  UserLocale.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import Foundation

enum UserLocale: String, Identifiable, Codable {
    var id: String {
        return self.rawValue
    }
    
    var languageCode: String {
        switch self {
        case .system:
            if let systemLanguageCode: String = Locale.current.languageCode {
                return systemLanguageCode
            } else {
                return "en"
            }
        case .en:
            return "en"
        case .ru:
            return "ru"
        }
    }
    
    case system = "sys_lang_e"
    case en = "en_lang_e"
    case ru = "ru_lang_e"
}
