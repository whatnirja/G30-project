import Foundation

struct CitySearchResult: Identifiable {
    let id = UUID()
    let cityName: String
    let province: String
    let country: String
    let latitude: Double
    let longitude: Double
}
