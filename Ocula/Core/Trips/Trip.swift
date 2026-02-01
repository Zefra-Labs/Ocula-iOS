//
//  Trip.swift
//  Ocula
//
//  Created by Tyson Miles on 31/1/2026.
//


import SwiftUI
import MapKit
import CoreLocation

struct Trip: Identifiable, Hashable {

    let id: UUID
    let startLocationName: String
    let endLocationName: String

    let startDate: Date
    let endDate: Date

    let distanceKM: Double
    let durationMinutes: Int
    let route: [CLLocationCoordinate2D]

    var isStarred: Bool = false

    let hardBraking: Int
    let hardAcceleration: Int
    let sharpTurns: Int

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension Trip {

    var dateString: String {
        startDate.formatted(date: .abbreviated, time: .omitted)
    }

    var timeRangeString: String {
        "\(startDate.formatted(date: .omitted, time: .shortened)) – \(endDate.formatted(date: .omitted, time: .shortened))"
    }
}
