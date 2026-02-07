//
//  LoginView.swift
//  Ocula
//
//  Created by Tyson Miles on 1/2/2026.
//
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error {
                    Text(error).foregroundColor(.red)
                }

                Button("Sign In") {
                    login()
                }
                .buttonStyle(.borderedProminent)
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                MainTabView()
            }
        }
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error {
                print("At error stage")
                self.error = error.localizedDescription
            }
            else {
                print("At LoggedIN stage")
                self.isLoggedIn = true
            }
        }
    }
}
