//
//  Session.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import Foundation
import Firebase

class Session: ObservableObject {
    
    @Published var settings: SettingsData = SettingsData.restoreFromDefaultUD()
    @Published private var authData: AuthData? = nil
    @Published private var dashboard: PhonebookDashboard? = nil
    
    @Published var initialized: Bool = false
    
    private let phonebookAssetManager = PhonebookAssetFirebaseManager()
    
    func getLocalAssets() -> [PhonebookAsset]? {
        return dashboard?.assets
    }
    
    func getLocalAsset(id: String) -> PhonebookAsset? {
        return getLocalAssets()?.first(where: { (asset) -> Bool in
            asset.id == id
        })
    }
    
    private func deleteLocalAsset(asset: PhonebookAsset) {
        if let index = getLocalAssets()?.firstIndex(where: { (a) -> Bool in
            a.id == asset.id
        }) {
            dashboard?.assets.remove(at: index)
        }
    }
    
    func deleteRemoteAsset(asset: PhonebookAsset, completion: @escaping (Error?) -> Void) {
        phonebookAssetManager.deleteRemoteAsset(asset) { (error) in
            if let error = error {
                print(error)
                completion(error)
            } else {
                self.deleteLocalAsset(asset: asset)
                completion(nil)
            }
        }
    }
    
    private func updateLocalAsset(_ asset: PhonebookAsset) {
        if let index = dashboard?.assets.firstIndex(where: { (a) -> Bool in
            a.id == asset.id
        }) {
            dashboard?.assets[index] = asset
        } else {
            dashboard?.assets.append(asset)
        }
    }
    
    func updateRemoteAsset(asset: PhonebookAsset, iconNSURL: NSURL?, videoNSURL: NSURL?, completion: @escaping (Error?) -> Void) {
        phonebookAssetManager.updateRemoteAsset(asset, iconNSURL, videoNSURL) { (updatedAsset, error) in
            if let error = error {
                print(error)
                completion(error)
            } else if let updatedAsset = updatedAsset {
                self.updateLocalAsset(updatedAsset)
                completion(nil)
            } else {
                let error = NSError.withLocalizedDescription("Invalid updateRemoteAsset form PhonebookAssetFirebaseManager closure return")
                completion(error)
            }
        }
    }
    
    func syncDashboard(onCompleted: @escaping () -> Void) {
        phonebookAssetManager.getRemoteAssets { (assets, error) in
            if let error = error {
                print(error)
                self.dashboard?.assets = []
            } else if let assets = assets {
                self.dashboard?.assets = assets
            } else {
                print("Didn't receive assets and error")
                self.dashboard?.assets = []
            }            
            onCompleted()
        }
    }
    
    private func initialize(_ authData: AuthData, onCompleted: @escaping () -> Void) {
        self.authData = authData
        
        AuthDataStorage.saveToKeychain(authData)
        
        dashboard = PhonebookDashboard()
        
        syncDashboard {
            self.initialized = true
            onCompleted()
        }
        
    }
    
    func destroy() {
        initialized = false
        
        settings.localization = .system
        AuthDataStorage.deleteFromKeychain()
        
        do {
            try Firebase.Auth.auth().signOut()
        } catch {
            print(error)
        }
        authData = nil
        dashboard = nil
    }
    
    func restore(completion: @escaping (Error?) -> Void) -> AuthData? {
        if let authData = AuthDataStorage.restoreFromKeychain() {
            signInEmail(email: authData.email, password: authData.password) { (error) in
                self.handleFirebaseAuthResponse(authData: authData, error: error, completion: completion)
            }
            return authData
        } else {
            let error = NSError.withLocalizedDescription("Unable to restore session")
            completion(error)
            return nil
        }
    }
    
    func signUpEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            let authData = AuthData(email: email, password: password)
            self.handleFirebaseAuthResponse(authData: authData, error: error, completion: completion)
        }
    }
    
    func signInEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            let authData = AuthData(email: email, password: password)
            self.handleFirebaseAuthResponse(authData: authData, error: error, completion: completion)
        }
    }
    
    private func handleFirebaseAuthResponse(authData: AuthData, error: Error?, completion: @escaping (Error?) -> Void) {
        guard error == nil else {
            completion(error)
            return
        }
        
        initialize(authData) {
            if self.initialized {
                completion(nil)
            } else {
                let error = NSError.withLocalizedDescription("Unable to initialize session")
                completion(error)
            }
        }
    }
}
