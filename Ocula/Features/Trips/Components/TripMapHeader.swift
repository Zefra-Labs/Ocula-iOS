//
//  TripMapHeader.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI
import MapKit

struct TripMapHeader: View {

    let trip: Trip
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            MapPolyline(coordinates: trip.route)
                .stroke(.black, lineWidth: 3)

            // START MARKER
            if let start = trip.route.first {
                Annotation("", coordinate: start) {
                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(.black, lineWidth: 3)
                        )
                        .shadow(radius: 1)
                }
            }

            // END MARKER
            if let end = trip.route.last {
                Annotation("", coordinate: end) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(.black, lineWidth: 3)
                        )
                        .shadow(radius: 1)
                }
            }
        }
        .onAppear {
            fitRoute()
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 20) // pushes watermark UP
        }
        .ignoresSafeArea(edges: .top)
    }

    private func fitRoute() {
        guard !trip.route.isEmpty else { return }

        let coordinates = trip.route

        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }

        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!

        let latitudeDelta = (maxLat - minLat) * 2.5
        let longitudeDelta = (maxLon - minLon) * 2.5

        // Move the center DOWN by 15% of the visible latitude
        let verticalOffset = latitudeDelta * -0.1

        let center = CLLocationCoordinate2D(
            latitude: ((minLat + maxLat) / 2) - verticalOffset,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: latitudeDelta,
            longitudeDelta: longitudeDelta
        )

        let region = MKCoordinateRegion(center: center, span: span)
        cameraPosition = .region(region)
    }
}
