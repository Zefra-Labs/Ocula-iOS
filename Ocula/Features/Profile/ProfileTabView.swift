//
//  ProfileTabView.swift
//  Ocula
//
//  Created by Tyson Miles on 26/1/2026.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    // MARK: - State
    @EnvironmentObject var session: SessionManager

    @State private var tripsTaken = 246
    @State private var kmsDriven = 88
    @State private var uniqueRoutes = 444
    @State private var safetyScore = 60

    // MARK: - Actions (Injectable)
    var onSafetyScoreTapped: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {

                profileNavBar

                scrollViewSection
                
                Text("Your Stats")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .frame(minWidth: 0, alignment: .leading)

                Spacer(minLength: AppTheme.Spacing.xl) // Reserved space for future sections
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.background)
        }
        .toolbar(.hidden, for: .navigationBar)
        //.onAppear(perform: loadUserData)
    }
}
private extension ProfileView {

    var scrollViewSection: some View {
        ScrollView {
            driveStats
                .padding(.bottom, AppTheme.Spacing.sm)
            VStack(spacing: 12) {
                actionRow(
                    icon: SafetyScoreStyle.icon(for: safetyScore),
                    iconColor: SafetyScoreStyle.color(for: safetyScore),
                    title: "Driver Scoreᴮᴱᵀᴬ",
                    subtitle: SafetyScoreStyle.subtitle(for: safetyScore),
                    trailingValue: "\(safetyScore)",
                    action: {
                        print("Safety Score tapped")
                    }
                )
                actionRow(
                    icon: "rosette",
                    iconColor: .yellow,
                    title: "Leaderboard",
                    subtitle: "Country Ranking",
                    trailingValue: "32,312th",
                    action: {
                        print("Safety Score tapped")
                    }
                )

                Spacer(minLength: 80)
                
            }
        }
    }
}

private extension ProfileView {

    var profileNavBar: some View {
        HStack {
            HStack(spacing: 6) {

                ProfileAvatarView(imageURL: userImageURL)

                Text(userDisplayName)
                    .headlineStyle()
                    .fontWeight(.bold)
            }

            Spacer()

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(AppTheme.Colors.primary)
                    .font(.title2)
            }
            
        }
        .padding(.top, AppTheme.Spacing.md)
        
    }
}
private extension ProfileView {

    var driveStats: some View {
        ZStack {
            HStack(spacing: -40) {

                StatCircleView(
                    number: uniqueRoutes,
                    title: "Routes",
                    icon: "map.fill",
                    size: 120,
                    isPrimary: false
                )

                Spacer(minLength: 60)

                StatCircleView(
                    number: kmsDriven,
                    title: "Traveled",
                    icon: "speedometer",
                    size: 120,
                    isPrimary: false
                )
            }

            StatCircleView(
                number: tripsTaken,
                title: "Trips",
                icon: "car.fill",
                size: 150,
                isPrimary: true
            )
        }
        .padding(.top, AppTheme.Spacing.sm)
    }
}
#if DEBUG
#Preview {
    ProfileView()
        .environmentObject(SessionManager())
}
#endif

private extension ProfileView {

    var userDisplayName: String {
        session.user?.displayName
        ?? Auth.auth().currentUser?.displayName
        ?? "Anonymous"
    }

    var userImageURL: String? {
        Auth.auth().currentUser?.photoURL?.absoluteString
    }
}
