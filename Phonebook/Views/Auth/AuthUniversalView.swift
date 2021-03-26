//
//  AuthUniversalView.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.21.
//

import SwiftUI

struct AuthUniversalView: View {
    
    @EnvironmentObject var session: Session
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State var errorText: LocalizedStringKey = ""
    
    @State var progress: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("greetings")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding(.bottom, 25)
                        
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.secondary)
                                TextField("email", text: $email)
                                    .foregroundColor(.primary)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.uiCornerRadius)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 3)
                            )
                            
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(.secondary)
                                SecureField("password", text: $password)
                                    .foregroundColor(.primary)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.uiCornerRadius)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 3)
                            )
                        }
                        .padding(.bottom, 25)
                        
                        HStack {
                            Button(action: {
                                signUpTap()
                            }) {
                                Text("sign_up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.pink.opacity(0.8))
                                    .cornerRadius(Constants.uiCornerRadius)
                            }
                            
                            Button(action: {
                                signInTap()
                            }) {
                                Text("sign_in")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(Constants.uiCornerRadius)
                            }
                        }
                        .padding(.bottom, 25)
                        
                        Text(errorText)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
            }
            
            
            if progress {
                ProgressView()
            }
        }
        .allowsHitTesting(!progress)
        .onAppear {
            restoreSession()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    func validateEmailPassword() -> Bool {
        return !(email.isEmpty || password.isEmpty)
    }
    
    func restoreSession() {
        withAnimation {
            progress = true
        }
        
        if let authData = session.restore(completion: { (error) in
            withAnimation {
                progress = false
            }
            
            if error != nil {
                print("Unable to restore session")
            }
        }) {
            email = authData.email
            password = authData.password
        }
    }
    
    func signInTap() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if validateEmailPassword() {
            withAnimation {
                progress = true
            }
            
            session.signInEmail(email: email, password: password) { (error) in
                withAnimation {
                    progress = false
                }
                
                if error != nil {
                    self.errorText = "something_wrong"
                }
            }
        } else {
            self.errorText = "email_and_password_must_not_be_empty"
        }
    }
    
    func signUpTap() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if validateEmailPassword() {
            withAnimation {
                progress = true
            }
            
            session.signUpEmail(email: email, password: password) { (error) in
                withAnimation {
                    progress = false
                }
                
                if error != nil {
                    self.errorText = "something_wrong"
                }
            }
        } else {
            self.errorText = "email_and_password_must_not_be_empty"
        }
    }
}
