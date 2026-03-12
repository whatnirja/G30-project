import Foundation

class WeatherService {

    static let shared = WeatherService()

    private init() {}

    func fetchWeather(for city: String) async throws -> CityWeather {

        let (lat, lon) = try await GeocodingService.shared.getCoordinates(for: city)

        let urlString = "API_URL_PLACEHOLDER"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)

        return WeatherMapper.map(response: decoded, city: city)

    }

}
