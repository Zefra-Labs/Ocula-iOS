//
//  SettingsAppInformationView.swift
//  Ocula
//
//  Created by Tyson Miles on 2/17/2026.
//

import SwiftUI
import Foundation

struct SettingsAppInformationView: View {
    @State private var updateStatus: AppUpdateStatus = .checking

    var body: some View {
        SettingsScaffold(title: "App Information") {
            SettingsList {
                Section(header: SettingsSectionHeader(title: "Build")) {
                    AppInfoRow(title: "Version", value: AppInfo.version)
                    AppInfoRow(title: "Build", value: AppInfo.build)
                }

                Section(header: SettingsSectionHeader(title: "Updates")) {
                    UpdateStatusRow(status: updateStatus)
                }
            }
        }
        .task {
            updateStatus = await AppUpdateChecker.checkStatus(currentVersion: AppInfo.version)
        }
    }
}

private struct AppInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            Text(value)
        }
    }
}

private struct UpdateStatusRow: View {
    let status: AppUpdateStatus

    var body: some View {
        HStack(alignment: .top) {
            Text("Update Status")

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(status.text)
                    .font(AppTheme.Fonts.medium(13))
                    .foregroundColor(status.color)

                if let badgeText = status.badgeText {
                    Text(badgeText)
                        .font(AppTheme.Fonts.semibold(12))
                        .foregroundColor(status.badgeColor)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(status.badgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private enum AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    static var bundleId: String? {
        Bundle.main.bundleIdentifier
    }
}

private enum AppUpdateStatus: Equatable {
    case checking
    case upToDate(storeVersion: String)
    case updateAvailable(storeVersion: String)
    case aheadOfStore(storeVersion: String)
    case unavailable

    var text: String {
        switch self {
        case .checking:
            return "Checking for updates..."
        case .upToDate(let storeVersion):
            return "Up to date (v\(storeVersion))a"
        case .updateAvailable(let storeVersion):
            return "Update available (v\(storeVersion))"
        case .aheadOfStore(let storeVersion):
            return "Beta Version (v\(storeVersion))"
        case .unavailable:
            return "Unavailable"
        }
    }

    var color: Color {
        switch self {
        case .checking:
            return AppTheme.Colors.secondary
        case .upToDate:
            return AppTheme.Colors.secondary
        case .updateAvailable:
            return AppTheme.Colors.accent
        case .aheadOfStore:
            return AppTheme.Colors.secondary
        case .unavailable:
            return AppTheme.Colors.secondary
        }
    }

    var badgeText: String? {
        switch self {
        case .updateAvailable:
            return "Update"
        default:
            return nil
        }
    }

    var badgeColor: Color {
        switch self {
        case .updateAvailable:
            return AppTheme.Colors.accent
        default:
            return AppTheme.Colors.secondary
        }
    }
}

private enum AppUpdateChecker {
    static func checkStatus(currentVersion: String) async -> AppUpdateStatus {
        guard let bundleId = AppInfo.bundleId,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            return .unavailable
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let results = payload?["results"] as? [[String: Any]]
            let storeVersion = results?.first?["version"] as? String

            guard let storeVersion else {
                return .unavailable
            }

            let comparison = storeVersion.compare(currentVersion, options: .numeric)
            switch comparison {
            case .orderedDescending:
                return .updateAvailable(storeVersion: storeVersion)
            case .orderedSame:
                return .upToDate(storeVersion: storeVersion)
            case .orderedAscending:
                return .aheadOfStore(storeVersion: storeVersion)
            }
        } catch {
            return .unavailable
        }
    }
}

#Preview {
    SettingsAppInformationView()
}
