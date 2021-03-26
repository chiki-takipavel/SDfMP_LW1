//
//  PhonebookAsset.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import Foundation


struct PhonebookAsset: Codable, Identifiable {
    var id: String
    var givenname: String
    var lastname: String
    var patronymic: String
    var phone: String
    var description: String
    
    var iconFileData: CloudFileData?
    var videoFileData: CloudFileData?
    
    var suggestedLocation: ContactLocation?
}
