import Foundation

final class GeoMetService {
    static let shared = GeoMetService()

    private init() {}

    private let baseURL = "https://api.weather.gc.ca"
    private let collection = "citypageweather-realtime"

    func fetchCityWeatherItem(itemID: String) async throws -> GeoMetCityPageDTO {
        let urlString = "\(baseURL)/collections/\(collection)/items/\(itemID)?f=json&lang=en"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("GeoMet status code:", httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(GeoMetCityPageDTO.self, from: data)
    }
}
