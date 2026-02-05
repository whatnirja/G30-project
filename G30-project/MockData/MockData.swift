import Foundation

extension CityWeather {
    static let mockToronto = CityWeather(
        city: "Toronto",
        temperature: "19°",
        condition: "Mostly Rainy",
        highLow: "H: 24°  |  L: 18°",
        hourly: [
            .init(time: "12 AM", icon: "cloud.rain.fill", temp: "19°", precip: "30%"),
            .init(time: "Now", icon: "cloud.rain.fill", temp: "19°", precip: "30%"),
            .init(time: "2 AM", icon: "cloud.drizzle.fill", temp: "18°", precip: "25%"),
            .init(time: "3 AM", icon: "cloud.rain.fill", temp: "19°", precip: "35%"),
            .init(time: "4 AM", icon: "cloud.rain.fill", temp: "19°", precip: "40%"),
            .init(time: "5 AM", icon: "cloud.bolt.rain.fill", temp: "19°", precip: "45%")
        ],
        factors: [
            .init(title: "Heavy Rain", icon: "cloud.rain.fill"),
            .init(title: "Strong Winds", icon: "wind"),
            .init(title: "Hail Possible", icon: "cloud.hail.fill")
        ],
        theme: .rainy
    )
}

