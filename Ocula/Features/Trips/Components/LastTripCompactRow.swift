//
//  LastTripCompactRow.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct LastTripCompactRow: View {

    let trip: Trip
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {

                Image(systemName: "clock.arrow.circlepath")
                    .title2Style()
                    .foregroundStyle(AppTheme.Colors.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(trip.startLocationName) → \(trip.endLocationName)")
                        .headlineBoldStyle()
                        .foregroundStyle(AppTheme.Colors.primary)

                    Text(meta)
                        .subheadline()
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.md)
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xlg, style: .continuous))
        }
        .buttonStyle(.plain)

    }

    private var meta: String {
        "\(Int(trip.distanceKM)) km  •  \(trip.durationMinutes) mins  •  \(trip.endDate.relativeFormatted())"
    }
}
