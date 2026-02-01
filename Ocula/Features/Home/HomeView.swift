//
//  HomeView.swift
//  Ocula
//
//  Created by Tyson Miles on 23/1/2026.
//

import SwiftUI
import RealityKit


struct HomeView: View {

    // MARK: - State
    @EnvironmentObject var session: SessionManager
    @State private var selectedDevice: String = "Ocula One"

    // MARK: - Body
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Top Nav Bar
                topNavBar

                // 3D Device Area
                deviceHeroView

                // Action Sections (Scrollable)
                actionsSection
                
            }
        }
    }
}

#Preview {
    HomeView()
}
private extension HomeView {

    var topNavBar: some View {
        HStack {
            Menu {
                Button("Ocula One") { selectedDevice = "Ocula One" }
                Button("Ocula Mini") { selectedDevice = "Ocula Mini" }

                Divider()

                Button {
                    // add device action
                } label: {
                    Label {
                        Text("Add Device")
                    } icon: {
                        Image(systemName: "plus").foregroundColor(Color.primary)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedDevice)
                        .titleStyle()

                    Image(systemName: "chevron.down")
                        .bodyStyle()
                        .foregroundColor(AppTheme.Colors.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.sm)
    }
}
private extension HomeView {

    var deviceHeroView: some View {
        ZStack {

            // Glow
            RadialGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 200
            )
            .frame(width: 300, height: 300)
            .blur(radius: 50)

            // 3D Model
            RealityView { content in
                if let entity = try? await Entity(named: "OculaDevice") {
                    entity.scale = SIMD3(repeating: 0.6)
                    entity.position = [0, 0, 0]
                    content.add(entity)
                }
            }
            .frame(height: 260)
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
    
}
private extension HomeView {

    var actionsSection: some View {
        ScrollView {
            VStack(spacing: 12) {

                actionRow(
                    icon: "map.fill",
                    title: "Location & Status",
                    subtitle: "View current location and stats"
                )
                actionRow(
                    icon: "video.fill",
                    title: "Live View",
                    subtitle: "View cameras in real time"
                )

                actionRow(
                    icon: "folder.fill",
                    title: "Clips",
                    subtitle: "Browse saved footage"
                )

                actionRow(
                    icon: "map.fill",
                    title: "Trips",
                    subtitle: "View past drives"
                )

                actionRow(
                    icon: "gearshape.fill",
                    title: "Device Settings",
                    subtitle: "Manage settings for this device"
                )
                actionRow(
                    icon: "gearshape.fill",
                    title: "Signout",
                    subtitle: "Manage settings for this device",
                    action: {
                        session.signOut()
                    }
                )
                actionRow(
                    icon: "shield.fill",
                    title: "Safety & AI",
                    subtitle: "Collision, alerts, detections"
                )

                Spacer(minLength: 80)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
        }
    }
    
}
