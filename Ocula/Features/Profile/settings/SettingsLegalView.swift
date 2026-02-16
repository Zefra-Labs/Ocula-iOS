//
//  SettingsLegalView.swift
//  Ocula
//
//  Created by Tyson Miles on 13/2/2026.
//

import SwiftUI
import SafariServices

struct SettingsLegalView: View {

    @State private var selectedLink: LegalLink?

    var body: some View {
        SettingsScaffold(title: "Legal Information") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Legal Policies"), footer: Text("Understand what data and information the Ocula app collects by reading the Terms of Use and Privacy Policy.")
                    .font(.footnote)) {
                        actionRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "How we collect and use your data",
                            action: {
                                selectedLink = LegalLink(
                                    title: "Privacy Overview",
                                    url: URL(string: "https://zefra.au/legal/ocula/privacy-overview")!
                                )
                            },
                            style: .list
                        )
                        
                    actionRow(
                        icon: "info.circle.text.page.fill",
                        title: "Terms of Use",
                        subtitle: "Terms, conditions, and acceptable use",
                        action: {
                            selectedLink = LegalLink(
                                title: "Terms of Use",
                                url: URL(string: "https://zefra.au/legal/ocula/terms")!
                            )
                        },
                        style: .list
                    )
                }
                Section(header: SettingsSectionHeader(title: "Licence Information")) {
                        actionRow(
                            icon: "person.3.fill",
                            title: "Third-Party Licences",
                            subtitle: "",
                            action: {
                                selectedLink = LegalLink(
                                    title: "Third Party Licences",
                                    url: URL(string: "https://zefra.au/legal/ocula/3rd-party-licences")!
                                )
                            },
                            style: .list
                        )
                    actionRow(
                        icon: "checkmark.seal.text.page.fill",
                        title: "App Licence",
                        subtitle: "",
                        action: {
                            selectedLink = LegalLink(
                                title: "App Licence",
                                url: URL(string: "https://zefra.au/legal/ocula/app-licence")!
                            )
                        },
                        style: .list
                    )
                }
                Section(header: SettingsSectionHeader(title: "Other Policies")) {
                        actionRow(
                            icon: "hand.raised.fill",
                            title: "Location Usage Disclosure",
                            subtitle: "How your data is collected and used",
                            action: {
                                selectedLink = LegalLink(
                                    title: "Location Usage Disclosure",
                                    url: URL(string: "https://zefra.au/legal/ocula/location-usage-disclosure")!
                                )
                            },
                            style: .list
                        )
                }
            }
        }
        .fullScreenCover(item: $selectedLink) { link in
            SafariView(url: link.url)
                .ignoresSafeArea()
        }
    }
}

private struct LegalLink: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

private struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SettingsLegalView()
}
