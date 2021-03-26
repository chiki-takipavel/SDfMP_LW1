//
//  PhonebookDetailsView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI
import AVKit
import URLImage


struct PhonebookDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let asset: PhonebookAsset
    
    @State var showPhonebookEditor: Bool = false
    @State var showFullPhoto: Bool = false
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                PhonebookIconView(asset.iconFileData?.downloadURL, 110)
                    .onTapGesture {
                        showFullPhoto.toggle()
                    }
                Spacer()
            }
            
            Section(header: Text("phone")) {
                Text(asset.phone)
                    .multilineTextAlignment(.leading)
            }
            
            Section(header: Text("full_name")) {
                Text(asset.lastname)
                    .multilineTextAlignment(.leading)
                Text(asset.givenname)
                    .multilineTextAlignment(.leading)
                if !asset.patronymic.isEmpty {
                    Text(asset.patronymic)
                        .multilineTextAlignment(.leading)
                }
            }
            
            if !asset.description.isEmpty {
                Section(header: Text("description")) {
                    Text(asset.description)
                        .multilineTextAlignment(.leading)
                }
            }
            
            if let urlString = asset.videoFileData?.downloadURL,
               let url = URL(string: urlString) {
                let videoPlayer: AVPlayer = AVPlayer(url: url)
                
                Section(header:
                            Text("video")
                ) {
                    VideoPlayer(player: videoPlayer)
                        .aspectRatio(16.0/9.0, contentMode: .fit)
                        .onDisappear(perform: {
                            videoPlayer.pause()
                        })
                }
            }
            
            if let locationData = asset.suggestedLocation {
                Section(header:
                            Text("location")
                ) {
                    Text(locationData.note)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text("latitude")
                        Spacer()
                        Text(String(locationData.latitude))
                    }
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Text("longitude")
                        Spacer()
                        Text(String(locationData.longitude))
                    }
                    .foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle(asset.givenname + " " + asset.lastname)
        .sheet(isPresented: $showPhonebookEditor, content: {
            PhonebookUniversalCEView(
                assetToEdit: asset,
                onDelete: {
                    presentationMode.wrappedValue.dismiss()
                },
                isPresented: $showPhonebookEditor)
        })
        .sheet(isPresented: $showFullPhoto, content: {
            //PhonebookPhotoView(asset.iconFileData?.downloadURL, 110)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showPhonebookEditor.toggle()
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }
}
