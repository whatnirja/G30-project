import Foundation

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temp: String
    let precip: String
}
