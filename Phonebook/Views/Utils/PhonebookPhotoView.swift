//
//  PhonebookPhotoView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 28.03.21.
//

import SwiftUI
import URLImage


struct PhonebookPhotoView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let url: URL?
    
    init(_ urlString: String?) {
        if let iconURLString = urlString,
           let iconURL = URL(string: iconURLString) {
            url = iconURL
        } else {
            if urlString != nil {
                print("Unable to process PhonebookIconView urlString")
            }
            url = nil
        }
    }
    
    var placeholderIcon: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(0.5)
    }
    
    var body: some View {
        NavigationView
        {
            VStack
            {
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
                                    .aspectRatio(contentMode: .fit)
                             }
                    )
                } else {
                    placeholderIcon
                }
            }
            .navigationBarTitle("icon", displayMode: .inline)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
