import CoreLocation

struct Trip: Identifiable {
    let id: UUID
    let startLocationName: String
    let endLocationName: String
    let distanceKM: Double
    let durationMinutes: Int
    let endDate: Date
    let route: [CLLocationCoordinate2D]
}
