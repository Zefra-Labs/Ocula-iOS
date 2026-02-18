//
//  TripDetailView.swift
//  Ocula
//
//  Created by Tyson Miles on 31/1/2026.
//
import SwiftUI
import MapKit

struct TripDetailView: View {

    let trip: Trip
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: - Map Header
                TripMapHeader(trip: trip)
                    .frame(height: 350)

                // MARK: - Content
                VStack(spacing: 24) {
                    header
                    incidentsSection
                    clipsSection
                    safetyScoreSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, 25)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: AppTheme.Radius.xxlg, style: .continuous))
                .offset(y: -28)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Trip Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { shareTrip() } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("\(trip.startLocationName) → \(trip.endLocationName)")
                .font(.title2.bold())

            Text("\(Int(trip.distanceKM)) km • \(trip.durationMinutes) mins • \(trip.endDate.relativeFormatted())")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }

    // MARK: - Incidents section with scroll hint chevron
    private var incidentsSection: some View {
        IncidentsSection(trip: trip)
    }



    // MARK: - Clips
    private var clipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clips")
                .font(.headline)

            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.4))
                .frame(height: 160)
                .overlay(Text("Drive Clips"))
        }
    }

    // MARK: - Safety
    private var safetyScoreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Drive Score")
                .font(.headline)

            SafetyGauge(title: "Hard Braking", value: trip.hardBraking)
            SafetyGauge(title: "Acceleration", value: trip.hardAcceleration)
            SafetyGauge(title: "Sharp Turns", value: trip.sharpTurns)
        }
    }

    // MARK: - Share
    private func shareTrip() {
        let text = """
        Trip from \(trip.startLocationName) to \(trip.endLocationName)
        Distance: \(Int(trip.distanceKM)) km
        Duration: \(trip.durationMinutes) mins
        """
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}
#Preview {
    TripDetailView(trip: .mockTrips().first!)
}
