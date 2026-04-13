import Foundation

extension CityWeather {
    static let mockToronto = CityWeather(
        city: "Toronto",
        country: "Canada",
        latitude: 0.0,
        longitude: 0.0,
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
    
    static let mockLondon = CityWeather(
            city: "London",
            country: "Canada",
            latitude: 0.0,
            longitude: 0.0,
            temperature: "3°",
            condition: "Heavy Rain",
            highLow: "H: 16°  |  L: 8°",
            hourly: [
                .init(time: "Now", icon: "cloud.heavyrain.fill", temp: "3°", precip: "70%"),
                .init(time: "2 AM", icon: "cloud.heavyrain.fill", temp: "2°", precip: "75%"),
                .init(time: "3 AM", icon: "cloud.rain.fill", temp: "2°", precip: "60%")
            ],
            factors: [
                .init(title: "Heavy Rain", icon: "cloud.heavyrain.fill"),
                .init(title: "Flood Risk", icon: "water.waves"),
                .init(title: "Strong Winds", icon: "wind")
            ],
            theme: .rainy
        )

        static let mockWindsor = CityWeather(
            city: "Windsor",
            country: "Canada",
            latitude: 0.0,
            longitude: 0.0,
            temperature: "-9°",
            condition: "Storm Incoming",
            highLow: "H: 24°  |  L: -18°",
            hourly: [
                .init(time: "Now", icon: "cloud.bolt.rain.fill", temp: "-9°", precip: "55%"),
                .init(time: "2 AM", icon: "cloud.bolt.rain.fill", temp: "-10°", precip: "60%"),
                .init(time: "3 AM", icon: "cloud.snow.fill", temp: "-11°", precip: "40%")
            ],
            factors: [
                .init(title: "Lightning", icon: "bolt.fill"),
                .init(title: "Strong Winds", icon: "wind"),
                .init(title: "Snow Squalls", icon: "cloud.snow.fill")
            ],
            theme: .storm
        )
}

enum MockNotifications {
    static let items: [StormNotification] = [
        StormNotification(
            id: 1,
            city: "Toronto",
            title: "Tornado Warning",
            message: "Rotation detected near Toronto. Seek shelter immediately.",
            source: "Government of Canada",
            severity: .severe,
            issuedAt: Date().addingTimeInterval(-1800),
            notificationKey: "toronto-tornado-warning"
        ),
        StormNotification(
            id: 2,
            city: "London",
            title: "Severe Thunderstorm Alert",
            message: "Severe thunderstorm risk rising in London over the next 2 hours.",
            source: "Government of Canada",
            severity: .high,
            issuedAt: Date().addingTimeInterval(-5400),
            notificationKey: "london-thunderstorm-alert"
        ),
        StormNotification(
            id: 3,
            city: "Windsor",
            title: "Flood Watch",
            message: "Heavy rainfall may cause localized flooding in Windsor.",
            source: "Government of Canada",
            severity: .moderate,
            issuedAt: Date().addingTimeInterval(-86400),
            notificationKey: "windsor-flood-watch"
        ),
        StormNotification(
            id: 4,
            city: "Ottawa",
            title: "Winter Storm Alert",
            message: "Snowfall and blowing snow expected overnight in Ottawa.",
            source: "Government of Canada",
            severity: .moderate,
            issuedAt: Date().addingTimeInterval(-172800),
            notificationKey: "ottawa-winter-storm-alert"
        ),
        StormNotification(
            id: 5,
            city: "Kingston",
            title: "Wind Advisory",
            message: "Strong wind gusts are expected this afternoon in Kingston.",
            source: "Government of Canada",
            severity: .low,
            issuedAt: Date().addingTimeInterval(-250000),
            notificationKey: "kingston-wind-advisory"
        )
    ]
}
