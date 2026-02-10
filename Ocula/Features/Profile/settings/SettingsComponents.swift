//
//  SettingsComponents.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct SettingsScaffold<Content: View>: View {

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(AppTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(AppTheme.Colors.background)
    }
}

struct SettingsList<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        List { content }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
    }
}

struct SettingsSectionHeader: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(AppTheme.Colors.secondary)
            .textCase(nil)
    }
}

struct SettingsRowText: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .headlineStyle()

            if let subtitle {
                Text(subtitle)
                    .captionStyle()
            }
        }
    }
}

#Preview {
    SettingsScaffold(title: "Preview") {
        SettingsList {
            Section(header: SettingsSectionHeader(title: "Preview")) {
                Text("Preview Content")
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
    }
}
