import Foundation
import MapKit

final class GeocodingService {
    static let shared = GeocodingService()

    private init() {}

    func searchCities(query: String) async throws -> [CitySearchResult] {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedQuery.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(cleanedQuery), Ontario, Canada"
        request.resultTypes = .address

        let ontarioCenter = CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
        request.region = MKCoordinateRegion(
            center: ontarioCenter,
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )

        let response = try await MKLocalSearch(request: request).start()
        let queryLower = cleanedQuery.lowercased()

        let results: [CitySearchResult] = response.mapItems.compactMap { item in
            let placemark = item.placemark

            guard let city = placemark.locality,
                  !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                return nil
            }

            let province = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""

            let isOntario = province.lowercased() == "on" || province.lowercased() == "ontario"
            let isCanada = country.lowercased() == "canada"

            guard isOntario && isCanada else {
                return nil
            }

            return CitySearchResult(
                cityName: city,
                province: province,
                country: country,
                latitude: placemark.coordinate.latitude,
                longitude: placemark.coordinate.longitude
            )
        }

        let uniqueResults = Array(
            Dictionary(
                results.map { ("\($0.cityName.lowercased())-\($0.province.lowercased())", $0) },
                uniquingKeysWith: { first, _ in first }
            ).values
        )

        func score(_ city: String) -> Int {
            let name = city.lowercased()
            if name == queryLower { return 0 }
            if name.hasPrefix(queryLower) { return 1 }
            if name.contains(queryLower) { return 2 }
            return 3
        }

        return uniqueResults.sorted { lhs, rhs in
            let lhsScore = score(lhs.cityName)
            let rhsScore = score(rhs.cityName)

            if lhsScore != rhsScore {
                return lhsScore < rhsScore
            }

            return lhs.cityName.lowercased() < rhs.cityName.lowercased()
        }
    }
}
