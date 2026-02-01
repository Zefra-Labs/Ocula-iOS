//
//  MainTabView.swift
//  Ocula
//
//  Created by Tyson Miles on 26/1/2026.
//

import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {

            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }

            ClipsView()
                .tabItem {
                    Image(systemName: "folder.fill")
                }

            TripsView()
                .tabItem {
                    Image(systemName: "point.topleft.filled.down.to.point.bottomright.curvepath")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .tint(.white)
    }
}
