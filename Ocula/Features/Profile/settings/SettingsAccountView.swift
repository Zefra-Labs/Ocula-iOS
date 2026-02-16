//
//  SettingsAccountView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SettingsAccountView: View {
    @EnvironmentObject var session: SessionManager

    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedRange: ProfileTimeRange = .last7Days
    @State private var breakdownSheetMetric: DrivingMetric? = nil
    @State private var achievementSheetItem: Achievement? = nil
    
    var body: some View {
        SettingsScaffold(title: "Account") {
            SettingsList {
                Section {
                    actionRow(
                        icon: "person.crop.circle",
                        title: "Email Info",
                        subtitle: "Update your name and photo",
                        destination: AnyView(SettingsProfileInfoView()),
                        style: .list
                    )
                }
                Section {
                    actionRow(
                        icon: "envelope.fill",
                        title: "Email",
                        subtitle: "Manage login email",
                        destination: AnyView(SettingsEmailView()),
                        style: .list
                    )
                }
                Section {
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
    var driverNickname: String {
        session.user?.driverNickname ?? "Ocula Driver"
    }
    var userDisplayName: String {
        session.user?.displayName
        ?? Auth.auth().currentUser?.displayName
        ?? "Anonymous"
    }

    var userImageURL: String? {
        Auth.auth().currentUser?.photoURL?.absoluteString
    }

    var userEmail: String {
        session.user?.email
        ?? Auth.auth().currentUser?.email
        ?? "hello@ocula.app"
    }
    var profileHeaderCard: some View {
        ProfileHeaderCardView(
            driverNickname: driverNickname,
            email: userEmail,
            totalHours: "\(viewModel.stats.totalHoursDriven)h",
            imageURL: userImageURL
        )
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

#Preview {
    SettingsAccountView()
}
