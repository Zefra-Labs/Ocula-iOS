//
//  TripsTabView.swift
//  Ocula
//
//  Created by Tyson Miles on 26/1/2026.
//

import SwiftUI
import MapKit

struct TripsView: View {

    @State private var trips: [Trip] = Trip.mockTrips()
    @State private var selectedTrip: Trip = Trip.mockTrips().first!
    @State private var detent: PresentationDetent = .fraction(0.2)
    @State private var showTripDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                mapLayer
            }
            .sheet(isPresented: .constant(true)) {
                TripsBottomSheet(
                    trips: $trips,
                    selectedTrip: $selectedTrip,
                    detent: $detent,
                    showTripDetail: $showTripDetail
                )
                .presentationDetents(
                    [.fraction(0.1), .medium, .large],
                    selection: $detent
                )
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
                .presentationBackgroundInteraction(.enabled)
            }
            .navigationDestination(isPresented: $showTripDetail) {
                TripDetailView(trip: selectedTrip)
            }
        }
    }

    // MARK: - Map
    private var mapLayer: some View {
        Map {
            // Route
            MapPolyline(coordinates: selectedTrip.route)
                .stroke(.blue, lineWidth: 6)
            
            // Start
            if let start = selectedTrip.route.first {
                Annotation("Start", coordinate: start) {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                }
            }
            
            // End
            if let end = selectedTrip.route.last {
                Annotation("End", coordinate: end) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                }
            }
            
            // Apple blue dot
            UserAnnotation()
            
        }
        .ignoresSafeArea()
    }
}
struct TripsBottomSheet: View {

    @Binding var trips: [Trip]
    @Binding var selectedTrip: Trip
    @Binding var detent: PresentationDetent
    @Binding var showTripDetail: Bool

    @State private var searchText: String = ""

    private var filteredTrips: [Trip] {
        guard !searchText.isEmpty else { return trips }

        return trips.filter {
            $0.startLocationName.localizedCaseInsensitiveContains(searchText) ||
            $0.endLocationName.localizedCaseInsensitiveContains(searchText) ||
            $0.dateString.localizedCaseInsensitiveContains(searchText) ||
            $0.timeRangeString.localizedCaseInsensitiveContains(searchText)
            
        }
    }

    private var isCollapsed: Bool {
        detent == .fraction(0.1)
    }
    var body: some View {
        VStack(spacing: 16) {

            // LAST TRIP (always visible)
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Trip")
                    .titleStyle()

                LastTripCompactRow(trip: selectedTrip) {
                    showTripDetail = true
                }
            }

            // EVERYTHING ELSE hidden at lowest detent
            if !isCollapsed {

                Divider()

                VStack(alignment: .leading, spacing: 12) {

                    Text("Recent Trips")
                        .titleStyle()

                    ForEach(filteredTrips) { trip in
                        TripRow(
                            trip: trip,
                            isStarred: trip.isStarred,
                            onStar: toggleStar,
                            onTap: {
                                selectedTrip = trip
                                detent = .large
                            }
                        )
                    }

                    if filteredTrips.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }

            Spacer()
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer,
            prompt: "Search Trips"
        )
        .padding()
    }


    private func toggleStar(_ trip: Trip) {
        if let index = trips.firstIndex(of: trip) {
            trips[index].isStarred.toggle()
            if selectedTrip.id == trip.id {
                selectedTrip = trips[index]
            }
        }
    }
}
struct LastTripCompactRow: View {

    let trip: Trip
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {

                Image(systemName: "clock.arrow.circlepath")
                    .font(.title3)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(trip.startLocationName) → \(trip.endLocationName)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.primary)

                    Text("\(trip.dateString) • \(trip.timeRangeString)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.secondary)
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xlg)
                    .fill(AppTheme.Colors.primary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }
}


struct TripRow: View {

    let trip: Trip
    let isStarred: Bool
    let onStar: (Trip) -> Void
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(trip.startLocationName) to \(trip.endLocationName)")
                        .foregroundColor(AppTheme.Colors.primary)
                        .lineLimit(1)

                    Text(meta)
                        .subheadline()
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Star (secondary action)
                Button {
                    onStar(trip)
                } label: {
                    Image(systemName: isStarred ? "star.fill" : "star")
                        .foregroundStyle(isStarred ? .yellow : AppTheme.Colors.secondary)
                }
                .buttonStyle(.plain)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xlg)
                    .fill(AppTheme.Colors.primary.opacity(0.08))
            )
        }
        .buttonStyle(PressableRowStyle())
    }

    private var meta: String {
        "\(Int(trip.distanceKM)) km  •  \(trip.durationMinutes) mins  •  \(trip.endDate.relativeFormatted())"
    }
}
extension Trip {

    static func mockTrips() -> [Trip] {

        let now = Date()

        let baseRoute = [
            CLLocationCoordinate2D(latitude: -28.0116, longitude: 153.4052),
            CLLocationCoordinate2D(latitude: -28.0408, longitude: 153.3991),
            CLLocationCoordinate2D(latitude: -28.0700, longitude: 153.3930),
            CLLocationCoordinate2D(latitude: -28.0780, longitude: 153.4075),
            CLLocationCoordinate2D(latitude: -28.0860, longitude: 153.4220),
            CLLocationCoordinate2D(latitude: -28.0930, longitude: 153.4310),
            CLLocationCoordinate2D(latitude: -28.1000, longitude: 153.4400)
        ]

        return [
            Trip(
                id: UUID(),
                startLocationName: "Burleigh",
                endLocationName: "Bundall",
                startDate: now.addingTimeInterval(-3600),
                endDate: now,
                distanceKM: 44,
                durationMinutes: 45,
                route: baseRoute,
                hardBraking: 3,
                hardAcceleration: 1,
                sharpTurns: 2
            ),
            Trip(
                id: UUID(),
                startLocationName: "Miami",
                endLocationName: "Southport",
                startDate: now.addingTimeInterval(-7200),
                endDate: now.addingTimeInterval(-3600),
                distanceKM: 32,
                durationMinutes: 38,
                route: baseRoute,
                hardBraking: 1,
                hardAcceleration: 0,
                sharpTurns: 1
            )
        ]
    }
}




#Preview {
    TripsView()
}

