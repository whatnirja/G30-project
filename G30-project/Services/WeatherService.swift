import Foundation

final class WeatherService {
    static let shared = WeatherService()

    private init() {}

    func fetchWeather(for city: String) async throws -> CityWeather {
        guard let stationID = CityStationMapper.stationID(for: city) else {
            print("No station ID found for city:", city)
            throw APIError.noData
        }

        print("Using station ID:", stationID)

        let dto = try await GeoMetService.shared.fetchCityWeatherItem(itemID: stationID)

        let mapped = GeoMetCityPageMapper.map(
            dto: dto,
            city: city,
            country: "Canada",
            lat: 0.0,
            lon: 0.0
        )

        print("Mapped weather for:", mapped.city)
        return mapped
    }

    func fetchWeather(for city: String, latitude: Double, longitude: Double, country: String = "Canada") async throws -> CityWeather {
        guard let stationID = WeatherStationLocator.shared.nearestStation(
            lat: latitude,
            lon: longitude
        ) else {
            throw NSError(domain: "No station found", code: -1)
        }

        return try await fetchWeather(
            forStationID: stationID,
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude
        )
    }

    private func fetchWeather(forStationID stationID: String, city: String, country: String, latitude: Double, longitude: Double) async throws -> CityWeather {
        print("Using nearest station ID:", stationID)

        let dto = try await GeoMetService.shared.fetchCityWeatherItem(itemID: stationID)

        let mapped = GeoMetCityPageMapper.map(
            dto: dto,
            city: city,
            country: country,
            lat: latitude,
            lon: longitude
        )

        print("Mapped weather for:", mapped.city)
        return mapped
    }
}
