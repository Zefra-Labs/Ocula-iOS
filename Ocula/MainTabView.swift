import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {

            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }

            GalleryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                }

            TripsView()
                .tabItem {
                    Image(systemName: "map")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .tint(.white)
    }
}
