import Foundation

final class WeatherService {

    static let shared = WeatherService()

    private init() {}

    func fetchWeather(for city: String) async throws -> CityWeather {

        let (lat, lon) = try await GeocodingService.shared.getCoordinates(for: city)

        let urlString = makeWeatherURL(lat: lat, lon: lon)

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)

        return WeatherMapper.map(response: decoded, city: city)
    }

    private func makeWeatherURL(lat: Double, lon: Double) -> String {
        return "API_URL_PLACEHOLDER?lat=\(lat)&lon=\(lon)"
    }
}
