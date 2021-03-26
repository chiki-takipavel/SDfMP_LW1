//
//  PhonebookIconView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI
import URLImage


struct PhonebookIconView: View {
    
    let url: URL?
    let size: CGFloat
    
    init(_ urlString: String?, _ size: CGFloat) {
        if let iconURLString = urlString,
           let iconURL = URL(string: iconURLString) {
            url = iconURL
        } else {
            if urlString != nil {
                print("Unable to process PhonebookIconView urlString")
            }
            url = nil
        }
        
        self.size = size
    }
    
    var placeholderIcon: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(0.5)
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
    }
    
    var body: some View {
        if let url = url {
            URLImage(url: url,
                     empty: {
                        placeholderIcon
                     },
                     inProgress: { _ in
                        placeholderIcon
                     },
                     failure: { _, _ in
                        placeholderIcon
                     },
                     content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                     }
            )
        } else {
            placeholderIcon
        }
    }
}
