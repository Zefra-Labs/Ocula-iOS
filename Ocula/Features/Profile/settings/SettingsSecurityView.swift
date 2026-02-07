//
//  SettingsSecurityView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct SettingsSecurityView: View {
    var body: some View {
        SettingsScaffold(title: "Privacy & Security") {
            ScrollView {
                VStack(spacing: 12) {
                    actionRow(
                        icon: "hand.raised.fill",
                        title: "Privacy",
                        subtitle: "Control what data is shared",
                        destination: AnyView(SettingsPrivacyView())
                    )

                    actionRow(
                        icon: "lock.shield.fill",
                        title: "Security",
                        subtitle: "Password and login settings",
                        destination: AnyView(SettingsSecurityDetailView())
                    )

                    actionRow(
                        icon: "location.fill",
                        title: "Permissions",
                        subtitle: "Location, camera, and motion",
                        destination: AnyView(SettingsPermissionsView())
                    )

                    Spacer(minLength: 80)
                }
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

struct SettingsPrivacyView: View {
    @State private var shareDiagnostics = true
    @State private var cloudBackups = true

    var body: some View {
        SettingsScaffold(title: "Privacy") {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    settingsRow(title: "Share Diagnostics") {
                        Toggle("", isOn: $shareDiagnostics)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    settingsRow(title: "Cloud Backups") {
                        Toggle("", isOn: $cloudBackups)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

struct SettingsSecurityDetailView: View {
    @State private var faceId = true
    @State private var requirePasscode = true

    var body: some View {
        SettingsScaffold(title: "Security") {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    settingsRow(title: "Use Face ID") {
                        Toggle("", isOn: $faceId)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    settingsRow(title: "Require Passcode") {
                        Toggle("", isOn: $requirePasscode)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

struct SettingsPermissionsView: View {
    @State private var locationAccess = 1
    @State private var cameraAccess = true
    @State private var motionAccess = true

    var body: some View {
        SettingsScaffold(title: "Permissions") {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    settingsRow(title: "Location Access") {
                        Picker("Location Access", selection: $locationAccess) {
                            Text("Always").tag(0)
                            Text("While Using").tag(1)
                            Text("Never").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 220)
                    }

                    settingsRow(title: "Camera") {
                        Toggle("", isOn: $cameraAccess)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    settingsRow(title: "Motion & Fitness") {
                        Toggle("", isOn: $motionAccess)
                            .labelsHidden()
                            .tint(.blue)
                    }

                    Spacer(minLength: 80)
                }

                .padding(.top, AppTheme.Spacing.sm)
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
}

#Preview {
    SettingsSecurityView()
}
