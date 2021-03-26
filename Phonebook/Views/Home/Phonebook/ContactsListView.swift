//
//  PhonebooksListView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct ContactsListView: View {
    
    @EnvironmentObject var session: Session
    @AppStorage("isTableStyle") private var isTableStyle = false
    
    @State var showPhonebookCreator: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let assets = session.getLocalAssets(), !assets.isEmpty {
                    if isTableStyle {
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns) {
                            ForEach(assets) { asset in
                                NavigationLink(destination: PhonebookDetailsView(asset: asset)) {
                                    ContactTableCellView(asset: asset)
                                        .padding(.top)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding()
                    } else {
                        LazyVStack {
                            ForEach(assets) { asset in
                                NavigationLink(destination: PhonebookDetailsView(asset: asset)) {
                                    ContactListCellView(asset: asset)
                                        .padding(.top)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("empty_collection")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationBarTitle("phonebook", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPhonebookCreator.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showPhonebookCreator) {
                PhonebookUniversalCEView(isPresented: $showPhonebookCreator)
                    .environmentObject(session)
                    .environment(\.locale, Locale(identifier: session.settings.localization.languageCode))
            }
        }
    }
}
