//
//  NSErrorExtension.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.2021.
//

import Foundation


extension NSError {
    static func withLocalizedDescription(_ s: String) -> NSError {
        return NSError(
            domain: "",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey : s
            ])
    }
}
