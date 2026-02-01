//
//  RootView.swift
//  Ocula
//
//  Created by Tyson Miles on 1/2/2026.
//
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

struct RootView: View {

    @StateObject private var session = SessionManager()

    var body: some View {
        Group {
            if session.isLoading {
                ProgressView()
           // } //else if session.user == nil {
               // AuthView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(session)
    }
}
