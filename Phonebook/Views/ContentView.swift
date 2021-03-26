//
//  ContentView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.2021.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var session: Session
    
    var body: some View {
        AuthView()
            .fullScreenCover(
                isPresented: $session.initialized
            ) {
                HomeView()
                    .environmentObject(session)
                    .environment(\.locale, Locale(identifier: session.settings.localization.languageCode))
            }
    }
}
