//
//  PhonebookUniversalCEView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI
import iPhoneNumberField
import URLImage
import AVKit


enum PhonebookUniversalCEViewSheet: Identifiable {
    case image, video, map
    
    var id: Int {
        hashValue
    }
}

struct PhonebookUniversalCEView: View {
    
    @EnvironmentObject var session: Session
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Binding var isPresented: Bool
    
    @State var activeSheet: PhonebookUniversalCEViewSheet? = nil
    
    @State var progress: Bool = false
    @State var isEditing: Bool = false
    
    @State var givenname: String
    @State var lastname: String
    @State var patronymic: String
    @State var phone: String
    @State var description: String
    
    @State var iconNsUrl: NSURL?
    @State var videoNsUrl: NSURL?
    
    @State var locationNote: String
    @State var locationLatitude: Double?
    @State var locationLongitude: Double?
    
    let assetToEdit: PhonebookAsset?
    let additionalOnDeleteAction: (() -> Void)?
    
    // Init as creator
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.assetToEdit = nil
        self.additionalOnDeleteAction = nil
        
        self._givenname = State(initialValue: "")
        self._lastname = State(initialValue: "")
        self._patronymic = State(initialValue: "")
        self._phone = State(initialValue: "")
        self._description = State(initialValue: "")
        self._iconNsUrl = State(initialValue: nil)
        self._videoNsUrl = State(initialValue: nil)
        
        self._locationNote = State(initialValue: "")
        self._locationLatitude = State(initialValue: nil)
        self._locationLongitude = State(initialValue: nil)
    }
    
    // Init as editor
    init(assetToEdit: PhonebookAsset, onDelete: @escaping () -> Void, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.assetToEdit = assetToEdit
        self.additionalOnDeleteAction = onDelete
        
        self._givenname = State(initialValue: assetToEdit.givenname)
        self._lastname = State(initialValue: assetToEdit.lastname)
        self._patronymic = State(initialValue: assetToEdit.patronymic)
        self._phone = State(initialValue: assetToEdit.phone)
        self._description = State(initialValue: assetToEdit.description)
        
        if let iconFileData = assetToEdit.iconFileData {
            self._iconNsUrl = State(initialValue: NSURL(string: iconFileData.downloadURL))
        } else {
            self._iconNsUrl = State(initialValue: nil)
        }
        
        if let videoFileData = assetToEdit.videoFileData {
            self._videoNsUrl = State(initialValue: NSURL(string: videoFileData.downloadURL))
        } else {
            self._videoNsUrl = State(initialValue: nil)
        }
        
        if let locationData = assetToEdit.suggestedLocation {
            self._locationNote = State(initialValue: locationData.note)
            self._locationLatitude = State(initialValue: locationData.latitude)
            self._locationLongitude = State(initialValue: locationData.longitude)
        } else {
            self._locationNote = State(initialValue: "")
            self._locationLatitude = State(initialValue: nil)
            self._locationLongitude = State(initialValue: nil)
        }
    }
    
    func validateEditedAsset() -> Bool {
        if (givenname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                lastname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(
                        header: Text("general").padding(.top)
                    ) {
                        TextField("lastname", text: $lastname)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                        TextField("givenname", text: $givenname)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                        TextField("patronymic", text: $patronymic)
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                        iPhoneNumberField("", text: $phone, isEditing: $isEditing)
                            .flagHidden(false)
                            .prefixHidden(false)
                            .flagSelectable(true)
                            .maximumDigits(9)
                            .placeholderColor(.red)
                            .clearButtonMode(.whileEditing)
                            .onClear { _ in isEditing.toggle() }
                        TextField("description", text: $description)
                    }
                    
                    Section(
                        header: Text("icon")
                    ) {
                        Button {
                            activeSheet = .image
                        } label: {
                            HStack {
                                Text("select")
                                Spacer()
                                
                                if let iconURL = iconNsUrl?.absoluteURL {
                                    URLImage(url: iconURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.secondary, lineWidth: 2))
                                            .padding(.all, 10)
                                    }
                                }
                            }
                        }
                        
                        if iconNsUrl != nil {
                            Button {
                                withAnimation {
                                    iconNsUrl = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(
                        header: Text("video")
                    ) {
                        Button {
                            activeSheet = .video
                        } label: {
                            HStack {
                                Text("select")
                                Spacer()
                            }
                        }
                        
                        if let url = videoNsUrl?.absoluteURL {
                            let videoPlayer: AVPlayer = AVPlayer(url: url)
                            
                            VideoPlayer(player: videoPlayer)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                            
                            Button {
                                videoPlayer.pause()
                                videoPlayer.replaceCurrentItem(with: nil)
                                
                                withAnimation {
                                    videoNsUrl = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(
                        header: Text("location")
                    ) {
                        Button {
                            activeSheet = .map
                        } label: {
                            HStack {
                                Text("pick_location")
                                Spacer()
                            }
                        }
                        
                        if let locationLatitude = locationLatitude,
                           let locationLongitude = locationLongitude {
                            HStack {
                                Text("latitude")
                                Spacer()
                                Text(String(locationLatitude))
                            }
                            .foregroundColor(.secondary)
                            
                            HStack {
                                Text("longitude")
                                Spacer()
                                Text(String(locationLongitude))
                            }
                            .foregroundColor(.secondary)
                            
                            TextField("note", text: $locationNote)
                            
                            Button {
                                withAnimation {
                                    self.locationNote = ""
                                    self.locationLatitude = nil
                                    self.locationLongitude = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if let assetToEdit = assetToEdit {
                        Section {
                            Button {
                                withAnimation {
                                    progress = true
                                }
                                
                                print("Deleting \(assetToEdit)")
                                
                                session.deleteRemoteAsset(asset: assetToEdit) { (error) in
                                    progress = false
                                    
                                    if error == nil {
                                        additionalOnDeleteAction?()
                                        isPresented.toggle()
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("delete")
                                    Spacer()
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .navigationBarTitle(assetToEdit != nil ? "edit_contact" : "new_contact", displayMode: .inline)
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .image:
                        ImagePickerView(imageNSURL: $iconNsUrl)
                    case .video:
                        VideoPickerView(videoNSURL: $videoNsUrl)
                    case .map:
                        GoogleMapsLocationPickerView(latitude: $locationLatitude, longitude: $locationLongitude)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("back") {
                            isPresented.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save") {
                            withAnimation {
                                progress = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                let location: ContactLocation?
                                if let locationLatitude = locationLatitude,
                                   let locationLongitude = locationLongitude {
                                    location = ContactLocation(note: locationNote, latitude: locationLatitude, longitude: locationLongitude)
                                } else {
                                    location = nil
                                }
                                
                                let asset = PhonebookAsset(
                                    id: assetToEdit?.id ?? UUID().uuidString,
                                    givenname: givenname,
                                    lastname: lastname,
                                    patronymic: patronymic,
                                    phone: phone,
                                    description: description,
                                    iconFileData: assetToEdit?.iconFileData,
                                    videoFileData: assetToEdit?.videoFileData,
                                    suggestedLocation: location
                                )
                                
                                session.updateRemoteAsset(asset: asset, iconNSURL: iconNsUrl, videoNSURL: videoNsUrl) { (error) in
                                    progress = false
                                    
                                    if error == nil {
                                        isPresented.toggle()
                                    }
                                }
                            }
                        }
                        .disabled(!validateEditedAsset())
                    }
                }
                
                if progress {
                    ProgressView()
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .allowsHitTesting(!progress)
    }
}

