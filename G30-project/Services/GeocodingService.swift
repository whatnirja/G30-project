import Foundation
import MapKit

final class GeocodingService {
    static let shared = GeocodingService()

    private init() {}

    func getCoordinates(for city: String) async throws -> (Double, Double) {
        print("Geocoding city:", city)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(city), Ontario, Canada"
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let item = response.mapItems.first else {
            throw APIError.noData
        }

        let placemark = item.placemark

        guard let province = placemark.administrativeArea,
              province.lowercased() == "on" || province.lowercased() == "ontario" else {
            throw APIError.noData
        }

        let coordinate = placemark.coordinate
        print("Geocoding success:", coordinate.latitude, coordinate.longitude)
        return (coordinate.latitude, coordinate.longitude)
    }
    
    func searchCities(query: String) async throws -> [CitySearchResult] {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        let results = response.mapItems.compactMap { item -> CitySearchResult? in
            let placemark = item.placemark

            guard let city = placemark.locality ?? placemark.name else {
                return nil
            }

            let province = placemark.administrativeArea ?? ""
            let country = placemark.country ?? "Canada"
            let latitude = placemark.coordinate.latitude
            let longitude = placemark.coordinate.longitude

            return CitySearchResult(
                cityName: city,
                province: province,
                country: country,
                latitude: latitude,
                longitude: longitude
            )
        }

        let uniqueResults: [CitySearchResult] = Array(
            Dictionary<String, CitySearchResult>(
                results.map { ("\($0.cityName.lowercased())-\($0.province.lowercased())", $0) },
                uniquingKeysWith: { first, _ in first }
            ).values
        )

        return uniqueResults
    }
    
}
