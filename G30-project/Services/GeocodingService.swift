//
//  GeocodingService.swift
//  G30-project
//
//  Created by Gia Nagpal on 2026-03-13.
//
import Foundation
import MapKit

final class GeocodingService {

    static let shared = GeocodingService()

    private init() {}

    func getCoordinates(for city: String) async throws -> (Double, Double) {

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
              province.lowercased() == "on" || province.lowercased() == "ontario"
        else {
            throw APIError.noData
        }

        let coordinate = placemark.coordinate

        return (coordinate.latitude, coordinate.longitude)
    }
}
