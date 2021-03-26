//
//  PhonebookApp.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI
import Firebase
import GoogleMaps

@main
struct PhonebookApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var session = Session()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environment(\.locale, Locale(identifier: session.settings.localization.languageCode))
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let nsDictionary = NSDictionary(contentsOfFile: path),
               let API_KEY = nsDictionary["API_KEY"] as? String {
                GMSServices.provideAPIKey(API_KEY)
            } else {
                fatalError()
            }
            
            FirebaseApp.configure()
            return true
        }
    }
}
