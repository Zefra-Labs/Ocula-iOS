//
//  Trip+Mock.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import Foundation
import CoreLocation

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
                endLocationName: "Ashmore",
                startDate: now.addingTimeInterval(-7200),
                endDate: now.addingTimeInterval(-3600),
                distanceKM: 32,
                durationMinutes: 38,
                route: baseRoute,
                hardBraking: 1,
                hardAcceleration: 0,
                sharpTurns: 1
            ),
            Trip(
                id: UUID(),
                startLocationName: "Burleigh",
                endLocationName: "Southport",
                startDate: now.addingTimeInterval(-7200),
                endDate: now.addingTimeInterval(-3600),
                distanceKM: 32,
                durationMinutes: 38,
                route: baseRoute,
                hardBraking: 1,
                hardAcceleration: 0,
                sharpTurns: 1
            ),
            Trip(
                id: UUID(),
                startLocationName: "Arundel",
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
