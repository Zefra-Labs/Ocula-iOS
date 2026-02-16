//
//  DebugReportSheet.swift
//  Ocula
//
//  Created by Tyson Miles on 2/15/2026.
//

import SwiftUI

struct DebugReportSheet: View {
    enum IssueCategory: String, CaseIterable, Identifiable {
        case crash = "App Crash"
        case recording = "Recording"
        case playback = "Playback"
        case connectivity = "Connectivity"
        case notifications = "Notifications"
        case account = "Account"
        case confusing = "Something is Confusing"
        case cosmetic = "Something looks wrong"
        case other = "Other"
        
        var id: String { rawValue }
    }
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechTranscriber = SpeechTranscriber()
    
    @State private var issueCategory: IssueCategory = .crash
    @State private var descriptionText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                    .frame(alignment: .center)
                    .font(AppTheme.Fonts.regular(36))
                Text("What Happened?")
                    .font(AppTheme.Fonts.semibold(30))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            .padding(.vertical, AppTheme.Spacing.xxl)
            Form {
                Section {
                    Picker("Issue Type", selection: $issueCategory) {
                        ForEach(IssueCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Description")) {
                    ZStack(alignment: .topLeading) {
                        if descriptionText.isEmpty {
                            Text("Describe what happened...")
                                .foregroundColor(.secondary)
                                .padding(.top, 10)
                                .padding(.horizontal, 6)
                        }
                        
                        TextEditor(text: $descriptionText)
                            .frame(minHeight: 120)
                    }
                }
                VStack(spacing: 10) {
                    Button {
                        speechTranscriber.toggleRecording()
                    } label: {
                        Label(
                            speechTranscriber.isRecording ? "Stop Speaking" : "Speak to debug",
                            systemImage: speechTranscriber.isRecording ? "stop.circle.fill" : "mic.fill"
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .tint(AppTheme.Colors.primary)
                    .disabled(!speechTranscriber.isAvailable)
                }
                .onChange(of: speechTranscriber.transcript) { newValue in
                    guard speechTranscriber.isRecording else { return }
                    descriptionText = newValue
                }
                .onDisappear {
                    speechTranscriber.stopTranscribing()
                }
                if let errorMessage = speechTranscriber.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            .navigationTitle("Shake To Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

