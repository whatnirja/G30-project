import Foundation

struct DashboardItem: Identifiable {
    let id = UUID()
    let data: CityWeather
    let riskLabel: String
    let icon: String
}
