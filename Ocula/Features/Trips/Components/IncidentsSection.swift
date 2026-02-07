//
//  IncidentsSection.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct IncidentsSection: View {
    let trip: Trip

    @State private var hasScrolled = false
    private let hideThreshold: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incidents")
                .font(.headline)

            ZStack(alignment: .trailing) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Radius.md) {
                        IncidentCard(title: "Hard Braking", count: trip.hardBraking, icon: "exclamationmark.triangle")
                        IncidentCard(title: "Acceleration", count: trip.hardAcceleration, icon: "speedometer")
                        IncidentCard(title: "Sharp Turns", count: trip.sharpTurns, icon: "arrow.triangle.turn.up.right.circle")
                    }
                    // Tracker placed at the leading edge of content
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: HorizontalScrollOffsetKey.self,
                                value: geo.frame(in: .named("incidentsScroll")).minX
                            )
                        }
                    )
                    .padding(.trailing, 28) // keep last card from sitting under the chevron
                }
                .coordinateSpace(name: "incidentsScroll")
                .onPreferenceChange(HorizontalScrollOffsetKey.self) { minX in
                    // When you scroll right, the leading edge moves left (minX becomes negative).
                    if !hasScrolled, minX < -hideThreshold {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            hasScrolled = true
                        }
                    }
                }

                ScrollHintChevron(isVisible: !hasScrolled)
            }
        }
    }
}

// MARK: - Offset tracking (horizontal)
private struct HorizontalScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // keep the latest value
        value = nextValue()
    }
}
