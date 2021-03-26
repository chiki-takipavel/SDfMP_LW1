//
//  PhonebookAssetFirebaseManager.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import Foundation
import Firebase
import AVFoundation


class PhonebookAssetFirebaseManager {
    
    let db = Firebase.Firestore.firestore()
    let storage = Storage.storage()
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func deleteRemoteAsset(_ asset: PhonebookAsset, completion: @escaping (Error?) -> Void) {
        if let iconFile = asset.iconFileData {
            deleteFile(file: iconFile) { (error) in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted file with path \(iconFile.path)")
                }
            }
        }
        
        if let videoFile = asset.videoFileData {
            deleteFile(file: videoFile) { (error) in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted file with path \(videoFile.path)")
                }
            }
        }
        
        let document = db.collection(Constants.assetsCollectionFirebaseName).document(asset.id)
        document.delete { (error) in
            completion(error)
        }
    }
    
    private func getStorageDownloadURL(path: String, completion: @escaping (URL?, Error?) -> Void) {
        let storageRef = storage.reference()
        let fileRef = storageRef.child(path)
        fileRef.downloadURL { (url, error) in
            completion(url, error)
        }
    }
    
    private func deleteFile(file: CloudFileData, completion: @escaping (Error?) -> Void) {
        let storageRef = self.storage.reference()
        let fileRef = storageRef.child(file.path)
        fileRef.delete { (error) in
            completion(error)
        }
    }
    
    private func uploadFile(fileRef: StorageReference, data: Data, metadata: StorageMetadata, completion: @escaping (CloudFileData?, Error?) -> Void) {
        fileRef.putData(data, metadata: metadata) { (_, error) in
            if let error = error {
                completion(nil, error)
            } else {
                self.getStorageDownloadURL(path: fileRef.fullPath) { (url, error) in
                    if let error = error {
                        completion(nil, error)
                    } else if let url = url {
                        completion(CloudFileData(path: fileRef.fullPath, downloadURL: url.absoluteString), nil)
                    } else {
                        completion(nil, NSError.withLocalizedDescription("Both _ and error in uploadFile are nil"))
                    }
                }
            }
        }
    }
    
    private func uploadImage(_ iconNSURL: NSURL, completion: @escaping (CloudFileData?, Error?) -> Void) {
        do {
            let url = iconNSURL as URL
            let imageData = try Data(contentsOf: url)
            
            if let image = UIImage(data: imageData)?.cropedToSquare()?.resizeImage(128, opaque: true) {
                if let data = image.jpegData(compressionQuality: 1) {
                    let storageRef = storage.reference()
                    let path = "\(Constants.imagesFolderFirebaseName)/\(UUID().uuidString).jpeg"
                    let imageRef = storageRef.child(path)
                    
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    uploadFile(fileRef: imageRef, data: data, metadata: metadata) { (fileData, error) in
                        completion(fileData, error)
                    }
                    
                } else {
                    completion(nil, NSError.withLocalizedDescription("Unable to get png data from image"))
                }
            } else {
                completion(nil, NSError.withLocalizedDescription("Unable to optimize image size and form"))
            }
        } catch {
            completion(nil, NSError.withLocalizedDescription("Unable to process image NSURL"))
        }
    }
    
    private func uploadVideo(_ videoNSURL: NSURL, completion: @escaping (CloudFileData?, Error?) -> Void) {
        if let url = videoNSURL.absoluteURL {
            let avAsset = AVURLAsset(url: url)
            avAsset.exportVideo { (url) in
                if let url = url {
                    do {
                        let nsdata = try NSData(contentsOf: url, options: .mappedIfSafe)
                        let data = Data(referencing: nsdata)
                        
                        let storageRef = self.storage.reference()
                        let path = "\(Constants.videosFolderFirebaseName)/\(UUID().uuidString).mp4"
                        let imageRef = storageRef.child(path)
                        
                        let metadata = StorageMetadata()
                        metadata.contentType = "video/mp4"
                        
                        self.uploadFile(fileRef: imageRef, data: data, metadata: metadata) { (fileData, error) in
                            completion(fileData, error)
                        }
                    } catch {
                        completion(nil, NSError.withLocalizedDescription("Unable to convert video URL"))
                    }
                } else {
                    completion(nil, NSError.withLocalizedDescription("Unable to convert video"))
                }
            }
        } else {
            completion(nil, NSError.withLocalizedDescription("Unable to get video URL"))
        }
    }
    
    private func uploadAsset(_ asset: PhonebookAsset, completion: @escaping (Error?) -> Void) {
        do {
            let data = try encoder.encode(asset)
            if var json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                json.removeValue(forKey: "id")
                
                let document = db.collection(Constants.assetsCollectionFirebaseName).document(asset.id)
                document.setData(json) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                        completion(error)
                    } else {
                        print("Document successfully written!")
                        completion(nil)
                    }
                }
            } else {
                let error = NSError.withLocalizedDescription("Unable to create json object")
                completion(error)
            }
        } catch {
            let error = NSError.withLocalizedDescription("Unable to encode phonebook asset")
            completion(error)
        }
    }
    
    private func updateRemoteAssetRec(_ asset: PhonebookAsset, _ iconNSURL: NSURL?, _ videoNSURL: NSURL?, completion: @escaping (PhonebookAsset?, Error?) -> Void) {
        
        // Upload files 1 by 1 with every call
        // Priority:
        // 1 - Video
        // 2 - Image
        // 3 - Asset
        
        if asset.videoFileData?.downloadURL != videoNSURL?.absoluteString {
            var updatedAsset = asset
            
            // Delete previous file in background
            if let videoFileData = asset.videoFileData {
                updatedAsset.videoFileData = nil
                deleteFile(file: videoFileData) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Deleted icon with path \(videoFileData.path)")
                    }
                }
            }
            
            // Upload with recursive call in completion
            if let videoNSURL = videoNSURL {
                uploadVideo(videoNSURL) { (fileData, error) in
                    if let error = error {
                        // Error uploading video so we ignore it
                        print(error)
                        self.updateRemoteAssetRec(updatedAsset, iconNSURL, nil, completion: completion)
                    } else if let fileData = fileData {
                        // Successful video upload
                        updatedAsset.videoFileData = fileData
                        
                        let downloadnsurl = NSURL(string: fileData.downloadURL)
                        self.updateRemoteAssetRec(updatedAsset, iconNSURL, downloadnsurl, completion: completion)
                    }
                }
            } else {
                self.updateRemoteAssetRec(updatedAsset, iconNSURL, videoNSURL, completion: completion)
            }
            
            return
        }
        
        
        if asset.iconFileData?.downloadURL != iconNSURL?.absoluteString {
            var updatedAsset = asset
            
            // Delete previous file in background
            if let iconFileData = asset.iconFileData {
                updatedAsset.iconFileData = nil
                deleteFile(file: iconFileData) { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("Deleted icon with path \(iconFileData.path)")
                    }
                }
            }
            
            // Upload with recursive call in completion
            if let iconNSURL = iconNSURL {
                uploadImage(iconNSURL) { (fileData, error) in
                    if let error = error {
                        // Error uploading video so we ignore it
                        print(error)
                        self.updateRemoteAssetRec(updatedAsset, nil, videoNSURL, completion: completion)
                    } else if let fileData = fileData {
                        // Successful video upload
                        updatedAsset.iconFileData = fileData
                        
                        let downloadnsurl = NSURL(string: fileData.downloadURL)
                        self.updateRemoteAssetRec(updatedAsset, downloadnsurl, videoNSURL, completion: completion)
                    }
                }
            } else {
                self.updateRemoteAssetRec(updatedAsset, iconNSURL, videoNSURL, completion: completion)
            }
            
            return
        }
        
        uploadAsset(asset) { (error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(asset, nil)
            }
        }
        
    }
    
    func updateRemoteAsset(_ asset: PhonebookAsset, _ iconNSURL: NSURL?, _ videoNSURL: NSURL?, completion: @escaping (PhonebookAsset?, Error?) -> Void) {
        updateRemoteAssetRec(asset, iconNSURL, videoNSURL) { (updatedAssed, error) in
            completion(updatedAssed, error)
        }
    }
    
    func getRemoteAssets(completion: @escaping ([PhonebookAsset]?, Error?) -> Void) {
        db.collection(Constants.assetsCollectionFirebaseName).getDocuments { (query, error) in
            if let error = error {
                completion(nil, error)
            } else if let query = query {
                var assets: [PhonebookAsset] = []
                
                query.documents.forEach { (document) in
                    do {
                        var jsonData = document.data()
                        jsonData.updateValue(document.documentID, forKey: "id")
                        
                        if let data = try? JSONSerialization.data(withJSONObject: jsonData) {
                            var asset = try self.decoder.decode(PhonebookAsset.self, from: data)
                            asset.id = document.documentID
                            assets.append(asset)
                        } else {
                            print("Can't create json data from firebase document data")
                        }
                    } catch {
                        print(error)
                    }
                }
                
                completion(assets, nil)
            } else {
                completion(nil, NSError.withLocalizedDescription("Both query and error in getRemoteAssets are nil"))
            }
        }
    }
}
