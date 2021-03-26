//
//  SettingsView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var session: Session
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isTableStyle") private var isTableStyle = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("language")) {
                    Picker("", selection: $session.settings.localization) {
                        Text("sys_lang")
                            .tag(UserLocale.system)
                        Text("en_lang")
                            .tag(UserLocale.en)
                        Text("ru_lang")
                            .tag(UserLocale.ru)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden()
                }
                Section(header: Text("theme")) {
                    Picker("", selection: $isDarkMode) {
                        Text("light_theme")
                            .tag(false)
                        Text("dark_theme")
                            .tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden()
                }
                Section(header: Text("style")) {
                    Picker("", selection: $isTableStyle) {
                        Text("list_style")
                            .tag(false)
                        Text("table_style")
                            .tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden()
                }
                Section(header: Text("general")) {
                    Section {
                        Button(action: {
                            session.destroy()
                        }) {
                            Text("log_out")
                        }
                    }
                }
            }
            .navigationBarTitle("settings", displayMode: .inline)
        }
    }
}
