import Foundation
import MapKit
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var dashboardItems: [DashboardItem] = []
    @Published var searchResults: [CitySearchResult] = []
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var previewItem: DashboardItem?
    @Published var previewSearchResult: CitySearchResult?

    private let cityStorage = CityStorage()
    private let weatherCacheStorage = WeatherCacheStorage()

    init() {
        loadDashboard()
    }

    func loadDashboard() {
        let savedCities = cityStorage.fetchCities()
        var items: [DashboardItem] = []

        for savedCity in savedCities {
            if let cachedWeather = weatherCacheStorage.fetchWeather(for: savedCity.cityName) {
                let risk = riskLabel(from: cachedWeather.condition)
                let icon = riskIcon(from: cachedWeather.condition)

                items.append(
                    DashboardItem(
                        data: cachedWeather,
                        riskLabel: risk,
                        icon: icon
                    )
                )
            }
        }

        dashboardItems = items
    }

    func searchCities() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let results = try await GeocodingService.shared.searchCities(query: query)
            searchResults = results
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }

        isSearching = false
    }

    func addCityToDashboard(_ result: CitySearchResult) async {
        isLoading = true
        errorMessage = nil

        do {
            let inserted = cityStorage.insertCity(
                cityName: result.cityName,
                province: result.province,
                country: result.country,
                latitude: result.latitude,
                longitude: result.longitude
            )

            if !inserted {
                print("City may already exist or insert failed")
            }

            let weather = try await WeatherService.shared.fetchWeather(
                for: result.cityName,
                latitude: result.latitude,
                longitude: result.longitude
            )
            _ = weatherCacheStorage.saveWeather(weather)

            loadDashboard()
            searchText = ""
            searchResults = []
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func riskLabel(from condition: String) -> String {
        switch condition.lowercased() {
        case let value where value.contains("thunderstorm"):
            return "Severe Risk"
        case let value where value.contains("snow"):
            return "Moderate Risk"
        case let value where value.contains("rain"):
            return "High Risk"
        default:
            return "Low Risk"
        }
    }

    private func riskIcon(from condition: String) -> String {
        switch condition.lowercased() {
        case let value where value.contains("thunderstorm"):
            return "cloud.bolt.rain.fill"
        case let value where value.contains("snow"):
            return "cloud.snow.fill"
        case let value where value.contains("rain"):
            return "cloud.heavyrain.fill"
        case let value where value.contains("cloud"):
            return "cloud.fill"
        default:
            return "sun.max.fill"
        }
    }
    
    func searchAndPreviewCity() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            previewItem = nil
            previewSearchResult = nil
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let results = try await GeocodingService.shared.searchCities(query: query)

            guard let first = results.first else {
                previewItem = nil
                previewSearchResult = nil
                isSearching = false
                return
            }

            let weather = try await WeatherService.shared.fetchWeather(
                for: first.cityName,
                latitude: first.latitude,
                longitude: first.longitude
            )

            let item = DashboardItem(
                data: weather,
                riskLabel: riskLabel(from: weather.condition),
                icon: riskIcon(from: weather.condition)
            )

            previewSearchResult = first
            previewItem = item
            searchResults = results
        } catch {
            errorMessage = error.localizedDescription
            previewItem = nil
            previewSearchResult = nil
        }

        isSearching = false
    }
    
    func savePreviewToDashboard() {
        guard let result = previewSearchResult,
              let previewItem = previewItem else {
            return
        }

        let inserted = cityStorage.insertCity(
            cityName: result.cityName,
            province: result.province,
            country: result.country,
            latitude: result.latitude,
            longitude: result.longitude
        )

        if inserted {
            _ = weatherCacheStorage.saveWeather(previewItem.data)
            loadDashboard()

            searchText = ""
            self.previewItem = nil
            previewSearchResult = nil
        }
    }
    
    func removeCity(_ item: DashboardItem) {
        let deletedCity = cityStorage.deleteCity(cityName: item.data.city)
        let deletedWeather = weatherCacheStorage.deleteWeather(for: item.data.city)

        print("Deleted city:", deletedCity)
        print("Deleted weather:", deletedWeather)

        loadDashboard()
    }
}
