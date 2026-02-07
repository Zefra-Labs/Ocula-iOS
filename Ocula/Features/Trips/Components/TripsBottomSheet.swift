//
//  TripsBottomSheet.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct TripsBottomSheet: View {

    @Binding var trips: [Trip]
    @Binding var selectedTrip: Trip
    @Binding var detent: TripsSheetDetent
    @Binding var showTripDetail: Bool

    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    // Track scroll offset of the recent trips ScrollView
    @State private var scrollOffset: CGFloat = 0

    private var filteredTrips: [Trip] {
        guard !searchText.isEmpty else { return trips }

        return trips.filter {
            $0.startLocationName.localizedCaseInsensitiveContains(searchText) ||
            $0.endLocationName.localizedCaseInsensitiveContains(searchText) ||
            $0.dateString.localizedCaseInsensitiveContains(searchText) ||
            $0.timeRangeString.localizedCaseInsensitiveContains(searchText) ||
            "\(Int($0.distanceKM)) km".localizedCaseInsensitiveContains(searchText) ||
            "\($0.durationMinutes) mins".localizedCaseInsensitiveContains(searchText)
        }
    }

    private var isCollapsed: Bool {
        detent == .collapsed
    }

    var body: some View {
        VStack(spacing: 16) {

            // LAST TRIP (always visible)
            if !(isSearchFocused && !isCollapsed) {
                VStack(alignment: .leading, spacing: 8) {
                    if isCollapsed {
                        HStack {
                            LastTripCompactRow(trip: selectedTrip) {
                                showTripDetail = true
                            }
                            .padding(.top, AppTheme.Spacing.sm)
                            .padding(.bottom, AppTheme.Spacing.lg)
                            Spacer()
                        }
                    } else {
                        Text("Last Trip")
                            .title2Style()
                            .foregroundStyle(AppTheme.Colors.secondary)

                        LastTripCompactRow(trip: selectedTrip) {
                            showTripDetail = true
                        }
                    }
                }
            }

            // EVERYTHING ELSE hidden at lowest detent//
            if !isCollapsed {

                Divider()

                VStack(alignment: .leading, spacing: 12) {

                    Text("Recent Trips")
                        .title2Style()
                        .foregroundStyle(AppTheme.Colors.secondary)

                    SearchField(text: $searchText, placeholder: "Search Trips", isFocused: $isSearchFocused)

                    // Wrap the ScrollView in a ZStack to overlay the chevron
                    ZStack(alignment: .bottom) {

                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(filteredTrips) { trip in
                                    TripRow(
                                        trip: trip,
                                        isStarred: trip.isStarred,
                                        onStar: toggleStar,
                                        onTap: {
                                            selectedTrip = trip
                                            showTripDetail = true
                                        }
                                    )
                                }

                                if filteredTrips.isEmpty {
                                    ContentUnavailableView.search(text: searchText)
                                }
                            }
                            // Track scroll offset using GeometryReader and preference key
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scrollView")).minY)
                                }
                            )
                        }
                        .coordinateSpace(name: "scrollView")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                        }

                        // Show chevron only when scroll is near top and content is scrollable (≥ 3 trips)
                        if scrollOffset >= -10 && filteredTrips.count >= 3 {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .opacity(0.6)
                                .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                                .padding(.bottom, 4)
                                .animation(.easeInOut, value: scrollOffset)
                        }
                    }
                }
            }
        }
        .padding(.top)
        .padding(.horizontal)
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

// PreferenceKey to track vertical scroll offset
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
