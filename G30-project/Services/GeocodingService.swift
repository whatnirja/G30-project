import Foundation

class GeocodingService {

    static let shared = GeocodingService()

    private init() {}

    func getCoordinates(for city: String) async throws -> (Double, Double) {

        // TODO: call geocoding API later

        throw APIError.noData
    }

}
