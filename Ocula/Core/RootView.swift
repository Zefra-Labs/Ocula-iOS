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
    @AppStorage(DebugSettings.shakeToDebugEnabledKey) private var shakeToDebugEnabled = true
    @State private var showDebugReportSheet = false

  //  var body: some View {
  //      MainTabView()
  //          .environmentObject(session)
  //  }

    var body: some View {
        Group {
            if session.isLoading {
                RotatingLoadingView()
            } else if session.user == nil || session.shouldDeferMainView {
                AuthView()
            } else {
                MainTabView()
            }
        }
        .environmentObject(session)
        .preferredColorScheme(.dark)
        .background(
            ShakeDetectorView {
                guard shakeToDebugEnabled, !showDebugReportSheet else { return }
                showDebugReportSheet = true
            }
        )
        .sheet(isPresented: $showDebugReportSheet) {
            DebugReportSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
