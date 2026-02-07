//
//  TripRow.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

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
                    Text("\(trip.startLocationName) → \(trip.endLocationName)")
                        .headlineStyle()
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
