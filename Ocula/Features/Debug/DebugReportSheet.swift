//
//  DebugReportSheet.swift
//  Ocula
//
//  Created by Tyson Miles on 2/15/2026.
//

import SwiftUI

struct DebugReportSheet: View {
    enum IssueCategory: String, CaseIterable, Identifiable {
        case crash = "App Crashed"
        case recording = "Recording Issue"
        case playback = "Playback Issue"
        case connectivity = "Connectivity Issue"
        case notifications = "Notifications"
        case account = "Account Issue"
        case confusing = "Something is confusing"
        case website = "Website issue"
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
            Form {
                Section {
                    VStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                            .font(AppTheme.Fonts.regular(36))
                            .tint(.blue)
                        Text("What Happened?")
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .titleStyle()
                            .fixedSize(horizontal: false, vertical: true)
                        Text("You can use this space to report bugs and request features. Your feedback helps improve the Ocula app.")
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .foregroundStyle(AppTheme.Colors.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.lg)
                }
                
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
                        }
                        
                        TextEditor(text: $descriptionText)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 140)
                    }
                }
                Section {
                    Button {
                        speechTranscriber.toggleRecording()
                    } label: {
                        Label(
                            speechTranscriber.isRecording ? "Stop Speaking" : "Speak to debug",
                            systemImage: speechTranscriber.isRecording ? "stop.circle.fill" : "mic.fill"
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderless)
                    .disabled(!speechTranscriber.isAvailable)
                    
                    if let errorMessage = speechTranscriber.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .multilineTextAlignment(.center)
            .onDisappear {
                speechTranscriber.stopTranscribing()
            }
            .onChange(of: speechTranscriber.transcript) { newValue in
                guard speechTranscriber.isRecording else { return }
                descriptionText = newValue
            }
            
            .navigationTitle("Shake To Report")
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
