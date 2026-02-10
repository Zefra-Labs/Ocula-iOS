//
//  SettingsView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {

    @EnvironmentObject var session: SessionManager
    @State private var animateIcon = false

    var body: some View {
        SettingsScaffold(title: "Settings") {
                settingsActions
        }
        .oculaAlertSheet(
            isPresented: $session.showSignOutOverlay,
            icon: "circle.dotted",
            iconTint: .blue,
            title: "Signing Out...",
            message: "",
            showsIconRing: false,
            iconModifier: { image in
                AnyView(image.symbolRenderingMode(.hierarchical))
            },
            iconAnimator: { image, _ in
                if #available(iOS 17.0, *) {
                    return AnyView(
                        image
                            .symbolEffect(.rotate.byLayer, options: .repeat(.continuous))
                    )
                } else {
                    return AnyView(image)
                }
            },
            iconAnimationActive: animateIcon
        )
    }
}

private extension SettingsView {

    var settingsActions: some View {
        SettingsList {
            Section(header: SettingsSectionHeader(title: "Account")) {
                actionRow(
                    icon: "person.fill",
                    title: "Profile",
                    subtitle: "Manage your profile details like email, nickname and more",
                    destination: AnyView(SettingsAccountView()),
                    style: .list
                )

                actionRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    subtitle: "Manage your account's security and data controls",
                    destination: AnyView(SettingsSecurityView()),
                    style: .list
                )
            }

            Section(header: SettingsSectionHeader(title: "App")) {
                actionRow(
                    icon: "car.fill",
                    title: "Car",
                    subtitle: "Driver, vehicle, and color",
                    destination: AnyView(SettingsCarView()),
                    style: .list
                )
            }

            Section(header: SettingsSectionHeader(title: "Account Settings")) {
                actionRow(
                    icon: "person.fill",
                    title: "Profile",
                    subtitle: "Manage your profile details like email, nickname and more",
                    destination: AnyView(SettingsAccountView()),
                    style: .list
                )

                actionRow(
                    icon: "car.fill",
                    title: "Car",
                    subtitle: "Driver, vehicle, and color",
                    destination: AnyView(SettingsSecurityView()),
                    style: .list
                )
            }

            Section(header: SettingsSectionHeader(title: "Preferences")) {
                actionRow(
                    icon: "slider.horizontal.3",
                    title: "Preferences",
                    subtitle: "Appearance, notifications, and units",
                    destination: AnyView(SettingsPreferencesView()),
                    style: .list
                )

                actionRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    subtitle: "Permissions and data controls",
                    destination: AnyView(SettingsSecurityView()),
                    style: .list
                )
            }

            Section(header: SettingsSectionHeader(title: "Group Settings")) {
                actionRow(
                    icon: "wand.and.stars",
                    title: "Weekly driving report",
                    subtitle: "Your habits, highlights, and improvements",
                    destination: AnyView(SettingsSupportView()),
                    style: .list
                )

                actionRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Compare time periods",
                    subtitle: "See how your score changed",
                    destination: AnyView(SettingsSupportView()),
                    style: .list
                )
            }

            Section(header: SettingsSectionHeader(title: "Settings")) {
                actionRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconColor: AppTheme.Colors.destructive,
                    title: "Sign Out",
                    subtitle: "Sign out of your account on this device",
                    action: {
                        animateIcon = true
                        session.signOut { success in
                            if success {
                                animateIcon = false
                            } else {
                                animateIcon = false
                            }
                        }
                    },
                    style: .list
                )
            }
        }
    }

    var userDisplayName: String {
        session.user?.displayName
        ?? Auth.auth().currentUser?.displayName
        ?? "Anonymous"
    }

    var userEmail: String {
        session.user?.email
        ?? Auth.auth().currentUser?.email
        ?? ""
    }

    var userImageURL: String? {
        Auth.auth().currentUser?.photoURL?.absoluteString
    }
}

#Preview {
    SettingsView()
        .environmentObject(SessionManager())
}
