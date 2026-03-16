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
        let mapped = GeoMetCityPageMapper.map(dto: dto,city: city)
        print("Mapped weather for:", mapped.city)

        return mapped
    }

    func fetchWeather(for city: String, latitude: Double, longitude: Double) async throws -> CityWeather {
        // for now ignore lat/lon and use city->station mapping
        return try await fetchWeather(for: city)
    }
}
