//
//  MainTabView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            ContactsListView()
                .tabItem {
                    Label("contacts", systemImage: "person")
                }
            
            MapView()
                .tabItem {
                    Label("map", systemImage: "map")
                }
            
            SettingsView()
                .tabItem {
                    Label("settings", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
