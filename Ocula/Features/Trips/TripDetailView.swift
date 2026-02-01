struct TripDetailView: View {

    let trip: Trip
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                header

                incidentsSection
                clipsSection
                safetyScoreSection
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(trip.startLocationName) to \(trip.endLocationName)")
                .font(.title2.bold())

            Text("\(Int(trip.distanceKM)) km  •  \(trip.durationMinutes) mins  •  \(trip.endDate.relativeFormatted())")
                .foregroundStyle(.secondary)
        }
    }
    private var incidentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incidents")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 12) {
                    IncidentCard(title: "Potholes", count: 0, icon: "exclamationmark")
                    IncidentCard(title: "Hard Braking", count: trip.hardBraking, icon: "exclamationmark")
                    IncidentCard(title: "Sharp Turns", count: trip.sharpTurns, icon: "square.and.arrow.up")
                }
            }
        }
    }
    struct IncidentCard: View {
        let title: String
        let count: Int
        let icon: String

        var body: some View {
            HStack {
                Circle()
                    .fill(count > 0 ? .orange : .green)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .fontWeight(.bold)
                    )

                VStack(alignment: .leading) {
                    Text(title)
                    Text(count > 0 ? "\(count) detected" : "None detected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.xlg))
        }
    }
    private var clipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clips")
                .font(.headline)

            RoundedRectangle(cornerRadius: AppTheme.Radius.mdlg)
                .fill(.black.opacity(0.4))
                .frame(height: 160)
                .overlay(Text("Drive Clips"))
        }
    }
    private var safetyScoreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Drive Score")
                .font(.headline)

            SafetyGauge(title: "Hard Braking", value: trip.hardBraking)
            SafetyGauge(title: "Acceleration", value: trip.hardAcceleration)
            SafetyGauge(title: "Sharp Turns", value: trip.sharpTurns)
        }
    }
}
struct SafetyGauge: View {
    let title: String
    let value: Int

    var normalized: Double {
        min(Double(value) / 10.0, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)

            Gauge(value: normalized) { }
                .gaugeStyle(.accessoryLinear)
                .tint(normalized > 0.6 ? .red : normalized > 0.3 ? .orange : .green)

            Text("\(value) incidents")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
extension Date {
    func relativeFormatted() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return formatted(date: .omitted, time: .shortened) }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        return formatted(.dateTime.weekday(.wide))
    }
}