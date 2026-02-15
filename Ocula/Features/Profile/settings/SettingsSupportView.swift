//
//  SettingsSupportView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct SettingsSupportView: View {
    var body: some View {
        SettingsScaffold(title: "Support") {
            SettingsList {
                Section {
                    actionRow(
                        icon: "questionmark.circle.fill",
                        title: "Help Center",
                        subtitle: "FAQs and troubleshooting",
                        destination: AnyView(SettingsHelpCenterView()),
                        style: .list
                    )

                    actionRow(
                        icon: "exclamationmark.bubble.fill",
                        title: "Report a Problem",
                        subtitle: "Share feedback or issues",
                        destination: AnyView(SettingsReportProblemView()),
                        style: .list
                    )

                    actionRow(
                        icon: "info.circle.fill",
                        title: "About Ocula",
                        subtitle: "Version and legal information",
                        destination: AnyView(SettingsAboutView()),
                        style: .list
                    )
                }
            }
        }
    }
}

struct SettingsHelpCenterView: View {
    @State private var tipsEnabled = true

    var body: some View {
        SettingsScaffold(title: "Help Center") {
            SettingsList {
                Section {
                    Toggle("Show Driving Tips", isOn: $tipsEnabled)
                        .tint(.blue)
                }

                Section(header: SettingsSectionHeader(title: "Quick Links")) {
                    SettingsRowText(
                        title: "Getting Started",
                        subtitle: "Camera setup, night mode, and storage."
                    )
                }
            }
        }
    }
}

struct SettingsReportProblemView: View {
    @State private var includeLogs = true
    @State private var description = ""

    var body: some View {
        SettingsScaffold(title: "Report a Problem") {
            SettingsList {
                Section {
                    Toggle(isOn: $includeLogs) {
                        SettingsRowText(
                            title: "Include Diagnostics",
                            subtitle: "Attach logs to reports"
                        )
                    }
                    .tint(.blue)

                    Button {
                        print("Compare")
                    } label: {
                        SettingsRowText(
                            title: "Notifications",
                            subtitle: "Manage alerts"
                        )
                    }
                }

                Section(header: SettingsSectionHeader(title: "Describe the Issue")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(AppTheme.Colors.primary.opacity(0.08))
                        )
                }
            }
        }
    }
}

struct SettingsAboutView: View {
    @State private var betaFeatures = false

    var body: some View {
        SettingsScaffold(title: "About Ocula") {
            SettingsList {
                Section {
                    LabeledContent("Version") {
                        Text("1.0.0")
                            .captionStyle()
                    }

                    Toggle("Enable Beta Features", isOn: $betaFeatures)
                        .tint(.blue)
                }
            }
        }
    }
}

#Preview {
    SettingsSupportView()
}
