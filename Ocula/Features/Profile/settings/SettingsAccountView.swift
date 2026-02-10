//
//  SettingsAccountView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct SettingsAccountView: View {
    var body: some View {
        SettingsScaffold(title: "Account") {
            SettingsList {
                Section {
                    actionRow(
                        icon: "person.crop.circle",
                        title: "Profile Info",
                        subtitle: "Update your name and photo",
                        destination: AnyView(SettingsProfileInfoView()),
                        style: .list
                    )

                    actionRow(
                        icon: "envelope.fill",
                        title: "Email",
                        subtitle: "Manage login email",
                        destination: AnyView(SettingsEmailView()),
                        style: .list
                    )

                    actionRow(
                        icon: "ipad.and.iphone",
                        title: "Devices",
                        subtitle: "Manage linked Ocula devices",
                        destination: AnyView(SettingsDevicesView()),
                        style: .list
                    )
                }
            }
        }
    }
}

struct SettingsProfileInfoView: View {
    @State private var displayName = "Ocula Driver"
    @State private var bio = "Night drives, clean footage."
    @State private var autoUpload = true

    var body: some View {
        SettingsScaffold(title: "Profile Info") {
            SettingsList {
                Section {
                    LabeledContent("Display Name") {
                        TextField("Name", text: $displayName)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Bio") {
                        VStack(alignment: .trailing, spacing: 8) {
                            TextField("Short bio", text: $bio)
                                .multilineTextAlignment(.trailing)
                            Toggle("", isOn: $autoUpload)
                                .labelsHidden()
                                .tint(.blue)
                        }
                    }

                    Toggle("Auto Upload Clips", isOn: $autoUpload)
                        .tint(.blue)
                }
            }
        }
    }
}

struct SettingsEmailView: View {
    @State private var email = "driver@ocula.app"
    @State private var marketingEmails = false

    var body: some View {
        SettingsScaffold(title: "Email") {
            SettingsList {
                Section {
                    LabeledContent("Primary Email") {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .multilineTextAlignment(.trailing)
                    }

                    Toggle("Product Updates", isOn: $marketingEmails)
                        .tint(.blue)
                }
            }
        }
    }
}

struct SettingsDevicesView: View {
    @State private var crashDetection = true
    @State private var autoSync = true

    var body: some View {
        SettingsScaffold(title: "Devices") {
            SettingsList {
                Section {
                    Toggle("Crash Detection Alerts", isOn: $crashDetection)
                        .tint(.blue)

                    Toggle("Auto Sync Footage", isOn: $autoSync)
                        .tint(.blue)
                }
            }
        }
    }
}

#Preview {
    SettingsAccountView()
}
