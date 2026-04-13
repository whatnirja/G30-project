import Foundation
import Combine

@MainActor
final class CityDeepDiveViewModel: ObservableObject {

    @Published var weather: CityWeather
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(initialData: CityWeather) {
        self.weather = initialData
    }

    func fetchFreshData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fresh = try await WeatherService.shared.fetchWeatherFull(for: weather.city)
            weather = fresh
        } catch {
            errorMessage = "Could not refresh weather data."
            print("CityDeepDive refresh failed:", error.localizedDescription)
        }
        isLoading = false
    }
}
