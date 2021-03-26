//
//  MapView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct MapView: View {
    
    let assistant: GoogleMapsAssistant = GoogleMapsAssistant()
    
    var body: some View {
        NavigationView {
            GoogleMapsView(assistant: assistant, showPhonebookLocationPins: true)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("map", displayMode: .inline)
        }
    }
}
